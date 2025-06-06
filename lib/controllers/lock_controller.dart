import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:knocklock_flutter/core/imports.dart';
import 'package:http/http.dart' as http;
import 'package:excel/excel.dart';

import '../services/websocket_service.dart';

class LockController {
  static final LockController _instance = LockController._internal();
  factory LockController() => _instance;

  LockController._internal();

  final WebSocketService _webSocketService = WebSocketService();
  final FirestoreService _firestoreService = FirestoreService();
  final RealtimeDatabaseService _realtimeDBService = RealtimeDatabaseService();

  final ValueNotifier<String> estadoVerificacion = ValueNotifier<String>("");
  final ValueNotifier<bool> isConnected = ValueNotifier<bool>(false);
  final ValueNotifier<String> modoSeleccionado = ValueNotifier<String>("");
  final ValueNotifier<bool> mostrarBotonGrabacion = ValueNotifier<bool>(false);
  final ValueNotifier<bool> seguroActivo = ValueNotifier<bool>(false);
  final ValueNotifier<bool> bloqueActivo = ValueNotifier<bool>(false);

  final Map<String, ValueNotifier<bool>> dispositivosConectados = {};
  final Map<String, ValueNotifier<bool>> segurosActivosPorLock = {};

  String? _lockId;
  StreamSubscription<String>? _webSocketSubscription;
  BuildContext? dialogContext;
  Timer? _verificacionTimer;
  Timer? _bloqueoCheckerTimer;
  Timer? _seguroAutoTimer;

  void conectar(String ip, String lockId) async {
    final url = 'ws://$ip/ws';
    _lockId = lockId;
    _webSocketService.connect(url);

    _webSocketSubscription = _webSocketService.messages.listen((message) {
      _handleMessage(message);
    });

    final doc = await _firestoreService.getLockById(lockId);
    if (doc.exists) {
      final data = doc.data();
      final activo = data?['seguroActivo'] ?? false;
      seguroActivo.value = activo;
      segurosActivosPorLock[lockId] = ValueNotifier<bool>(activo);
      escucharEstadoSeguro(lockId);
    }
  }

  void desconectar() {
    _webSocketService.disconnect();
    _webSocketSubscription?.cancel();
  }

  void iniciarVerificacionPeriodica(List<Lock> locks) {
    _verificacionTimer?.cancel();

    _verificacionTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await _barridoPing(locks);
    });
  }

  Future<void> _barridoPing(List<Lock> locks) async {
    final futures = locks.map((lock) => verificarConexion(lock.ip, lock.id)).toList();
    await Future.wait(futures);
  }

  Future<void> verificarConexion(String ip, String lockId) async {
    try {
      final url = Uri.parse('http://$ip/ping');

      final response = await http.get(url).timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        dispositivosConectados[lockId]?.value = true;
      } else {
        dispositivosConectados[lockId]?.value = false;
      }
    } catch (e) {
      dispositivosConectados[lockId]?.value = false;
    }
  }

  void inicializarEstadoDispositivos(List<Lock> locks) {
    for (final lock in locks) {
      if (!dispositivosConectados.containsKey(lock.id)) {
        dispositivosConectados[lock.id] = ValueNotifier<bool>(false);
        verificarConexion(lock.ip, lock.id);
      }

      if (!segurosActivosPorLock.containsKey(lock.id)) {
        segurosActivosPorLock[lock.id] = ValueNotifier<bool>(lock.seguroActivo);
      }

      // Escuchar cambios en tiempo real
      escucharEstadoSeguro(lock.id);
    }
  }

  void enviarComando(String mensaje) {
    _webSocketService.send(mensaje);
  }

  Future<void> _handleMessage(String message) async {
    print("📩 Mensaje del ESP32: $message");

    if (message.trim() == "CONNECTED") {
      isConnected.value = true;
      return;
    }

    estadoVerificacion.value = message;

    if (message.contains("ACCESO_CONCEDIDO")) {
      await _firestoreService.registrarAccesoCorrecto(_lockId!);
      cambiarEstadoSeguro(_lockId!, false);
    } else if (message.contains("ACCESO_FALLIDO")) {
      mostrarAlertaGlobal('error', 'Contraseña incorrecta');
      await _firestoreService.registrarAccesoFallido(_lockId!);
      cambiarEstadoSeguro(_lockId!, true);
    } else if (message.contains("ACCESO_BLOQUEADO_TEMPORALMENTE")) {
      cambiarEstadoSeguro(_lockId!, true);
      bloqueActivo.value = true;
    }
  }

  Future<void> verificarPassword(String tipoPassword, BuildContext context, Lock lock) async {
    try {
      // Si el seguro está activo, no mostrar el botón de grabación
      if (segurosActivosPorLock[lock.id]?.value ?? false) {
        mostrarBotonGrabacion.value = false;
        return;
      }

      final passwordDoc = await _firestoreService.getPassword(lock.id, tipoPassword);

      if (!passwordDoc.exists) {
        mostrarBotonGrabacion.value = true;
        return;
      }

      final data = passwordDoc.data();
      final value = data?['value'];

      switch (tipoPassword) {
        case 'Patron':
          mostrarBotonGrabacion.value = (value == null || (value is List && value.isEmpty));
          break;

        case 'Clave':
        case 'Token':
          mostrarBotonGrabacion.value = (value == null || value.toString().trim().isEmpty);
          break;

        default:
          mostrarBotonGrabacion.value = false;
          break;
      }
    } catch (e) {
      print('Error al verificar el password: $e');
    }
  }

  void iniciarGrabacion(BuildContext context, Lock lock, String tipoGrabacion) {
    if (tipoGrabacion == "Patron") {
      enviarComando("START_GRABACION");

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) {
          return AlertDialog(
            title: Text("Grabando..."),
            content: Text("Presiona el botón para detener la grabación."),
            actions: [
              TextButton(
                onPressed: () {
                  enviarComando("STOP_GRABACION");
                  mostrarBotonGrabacion.value = false;
                  Navigator.pop(dialogCtx);
                },
                child: Text("Detener grabación"),
              ),
            ],
          );
        },
      );

      _webSocketSubscription = _webSocketService.messages.listen((message) async {
        if (message.startsWith("PATRON_GRABADO:")) {
          final jsonStr = message.replaceFirst("PATRON_GRABADO:", "");

          try {
            final List<dynamic> duraciones = jsonDecode(jsonStr);
            final patronGrabado = duraciones.cast<int>();

            await _firestoreService.savePattern(lock.id, patronGrabado);
            await _realtimeDBService.savePattern(lock.id, patronGrabado);
            cambiarEstadoSeguro(lock.id, true);

            if (context.mounted) {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Grabación finalizada'),
                  content: Text('El patrón ha sido guardado.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Aceptar'),
                    ),
                  ],
                ),
              );
            }

            mostrarBotonGrabacion.value = false;
          } catch (e) {
            print("❌ Error al interpretar patrón: $e");
          }
        }
      });
    } else if (tipoGrabacion == "Clave") {
      print("Ingresa tu clave");
    }
  }

  void detenerGrabacion() {
    enviarComando("STOP_GRABACION");
    print('Grabación detenida');
  }

  Future<void> iniciarVerificacion(BuildContext context, Lock lock) async {
    final lockDoc = await _firestoreService.getLockById(lock.id);
    final data = lockDoc.data();
    final bloqueoActivo = data?['bloqueoActivo'] ?? false;

    if (bloqueoActivo) {
      return;
    }

    // Si no está bloqueado, continuar normalmente
    enviarComando("START_VERIFICACION");

    try {
      final snapshot = await _realtimeDBService.getPattern(lock.id);

      if (!snapshot.exists) {
        print('⚠️ No hay patrón en RTDB');
        return;
      }

      final patronRTDB = List<int>.from((snapshot.value as List<dynamic>));
      final jsonPatron = jsonEncode(patronRTDB);

      enviarComando("PATRON:$jsonPatron");
    } catch (e) {
      print("❌ Error al obtener patrón desde RTDB: $e");
    }
  }

  void detenerVerificacion() {
    enviarComando("STOP_VERIFICACION");
  }

  Future<void> agregarLock(String nombre, String ip) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('⚠️ No hay un usuario autenticado.');
        return;
      }

      // Buscar si ya existe un lock con esa IP
      final existingLocks = await _firestoreService.getLocksByIp(ip);
      if (existingLocks.isNotEmpty) {
        final existingLock = existingLocks.first;
        final createdBy = existingLock['createdBy'];

        if (createdBy != user.uid) {
          // Es un invitado: relaciona al usuario con ese lock
          await _firestoreService.asociarUsuarioInvitado(user.uid, existingLock['id']);
          print('🔑 Usuario agregado como invitado al lock existente.');
          return;
        }
      }

      // Crear un lock nuevo si no existe
      final lockRef = await _firestoreService.addLock({
        'name': nombre,
        'ip': ip,
        'modo': 'Ninguno',
        'seguroActivo': false,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': user.uid,
        'intentos': 3,
        'bloqueoActivoManual': false,
        'bloqueoActivoIntentos': false,
        'modoPrueba': false,
      });

      await _firestoreService.setInitialPasswords(lockRef.id);
      await _realtimeDBService.createInitialPasswords(lockRef.id);
      await FirebaseDatabase.instance.ref("locks/${lockRef.id}").update({
        "ip": ip,
      });

    } catch (e) {
      print('❌ Error al agregar lock: $e');
    }
  }

  Stream<List<Lock>> obtenerLocks() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestoreService.getLocksByUserStream(user.uid).map((locksData) {
      return locksData.map((data) {
        return Lock(
          id: data['id'],
          name: data['name'] ?? '',
          ip: data['ip'] ?? '',
          seguroActivo: data['seguroActivo'] ?? false,
          bloqueoActivoManual: data['bloqueoActivoManual'] ?? false,
          bloqueoActivoIntentos: data['bloqueoActivoIntentos'] ?? false,
          esInvitado: data['esInvitado'] ?? false,
        );
      }).toList();
    });
  }

  Future<void> cargarModo(String lockId) async {
    try {
      final doc = await _firestoreService.getLockById(lockId);
      if (doc.exists) {
        final data = doc.data();
        modoSeleccionado.value = data?['modo'] ?? "PATRÓN";
      }
    } catch (e) {
      print("Error al cargar el modo: $e");
    }
  }

  Future<void> guardarModo(String lockId) async {
    try {
      final nuevoModo = modoSeleccionado.value;

      await _firestoreService.updateLockMode(lockId, nuevoModo);
      await _realtimeDBService.updateLockMode(lockId, nuevoModo);
    } catch (e) {
    }
  }

  Future<void> cambiarEstadoSeguro(String lockId, bool nuevoEstado) async {
    final lockDoc = await _firestoreService.getLockById(lockId);
    final data = lockDoc.data();
    final bloqueoActivoManual = data?['bloqueoActivoManual'] ?? false;
    final bloqueoActivoIntentos = data?['bloqueoActivoIntentos'] ?? false;
    final modoRaw = data?['modo'] ?? 'Ninguno';
    final modo = normalizarModo(modoRaw);

    if (bloqueoActivoManual || bloqueoActivoIntentos) {
      mostrarAlertaGlobal('error', 'El dispositivo está bloqueado.');
      return;
    }

    // Verificar si hay contraseña configurada para el modo actual
    try {
      final passwordDoc = await _firestoreService.getPassword(lockId, modo);

      bool hasPassword = false;

      if (passwordDoc.exists) {
        final value = passwordDoc.data()?['value'];

        if (modo == 'Patron') {
          hasPassword = value is List && value.isNotEmpty;
        } else {
          hasPassword = value is String && value.trim().isNotEmpty;
        }
      }

      if (!hasPassword) {
        mostrarAlertaGlobal('error', 'Ingresa una contraseña para bloquear el candado.');
        print('Hola');
        return;
      }

      // Cambiar estado si hay contraseña
      await _firestoreService.updateLockSecureState(lockId, nuevoEstado);
      await _realtimeDBService.updateLockSecureState(lockId, nuevoEstado);

      if (segurosActivosPorLock.containsKey(lockId)) {
        segurosActivosPorLock[lockId]!.value = nuevoEstado;
      }

      if (nuevoEstado == true) {
        _webSocketService.send("CERRADO");
      } else {
        _webSocketService.send("ABIERTO");
      }

    } catch (e) {
    }
  }

  void seleccionarModo(String modo) async {
    if (_lockId == null) return;

    final seguroBloqueado = segurosActivosPorLock[_lockId]?.value ?? false;

    if (seguroBloqueado) {
      return;
    }

    modoSeleccionado.value = modo;
    await guardarModo(_lockId!);

  }

  Stream<List<MapEntry<AccessLog, Lock>>> obtenerLogsConLocks() {
    final logsStream = obtenerLogsAcceso();
    final locksStream = obtenerLocks();

    return Rx.combineLatest2(
      logsStream,
      locksStream,
          (List<AccessLog> logs, List<Lock> locks) {
        return logs.map((log) {
          final lock = locks.firstWhere(
                (l) => l.id == log.lockId,
            orElse: () => Lock(
              id: 'Desconocido',
              name: 'Desconocido',
              ip: '0.0.0.0',
              seguroActivo: false,
              bloqueoActivoManual: false,
              bloqueoActivoIntentos: false,
            ),
          );
          return MapEntry(log, lock);
        }).toList();
      },
    );
  }

  Stream<List<AccessLog>> obtenerLogsAcceso() async* {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      yield [];
      return;
    }

    yield* _firestoreService.getAccessLogsByUser(user.uid).map((logsData) {
      final logs = logsData.map((data) => AccessLog.fromMap(data)).toList();

      logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return logs;
    });
  }

  Stream<Map<String, int>> obtenerEstadoGlobalLocksDelUsuario() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value({'bloqueados': 0, 'desbloqueados': 0});
    }

    return _firestoreService
        .streamLocksByUser(user.uid)
        .map((locksData) {
      final desbloqueados = locksData.where((lock) => !(lock['seguroActivo'] as bool)).length;
      final bloqueados = locksData.where((lock) => (lock['seguroActivo'] as bool)).length;

      return {
        'bloqueados': bloqueados,
        'desbloqueados': desbloqueados,
      };
    });
  }

  Future<void> bloquearTodosLosLocks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final locks = await _firestoreService.getLocksByUser(user.uid);
      final now = DateTime.now();
      final bloqueoTermina = now.add(const Duration(hours: 1));

      for (final lock in locks) {
        if (lock['createdBy'] != user.uid) continue;

        final lockId = lock['id'];

        await FirebaseFirestore.instance.collection('locks').doc(lockId).update({
          'seguroActivo': true,
          'bloqueoActivoManual': true,
          'bloqueoTimestamp': Timestamp.fromDate(bloqueoTermina),
        });

        await _realtimeDBService.bloquearLock(lockId, bloqueoTermina);
      }
      mostrarAlertaGlobal('exito', 'Se ha activado el bloqueo total');
    } catch (e) {
    }
  }

  void iniciarChequeoDesbloqueo() {
    _bloqueoCheckerTimer?.cancel(); // Detener si ya existe

    _bloqueoCheckerTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final locks = await _firestoreService.getLocksByUser(user.uid);
      final now = DateTime.now();

      for (final lock in locks) {
        final lockId = lock['id'];
        final bloqueoActivoIntentos = lock['bloqueoActivoIntentos'] ?? false;
        final bloqueoTimestamp = lock['bloqueoTimestamp'];

        if (bloqueoActivoIntentos && bloqueoTimestamp != null) {
          final fechaFin = (bloqueoTimestamp as Timestamp).toDate();

          if (now.isAfter(fechaFin)) {
            // Desbloquear por intentos
            await FirebaseFirestore.instance.collection('locks').doc(lockId).update({
              'bloqueoActivoIntentos': false,
              'bloqueoTimestamp': null,
              'intentos': 1, // Reinicia a 1 intento
            });
          }
        }
      }
    });
  }

  void detenerChequeoDesbloqueo() {
    _bloqueoCheckerTimer?.cancel();
  }

  Future<void> activarSeguroTodosLosLocks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      mostrarAlertaGlobal('error', 'Usuario no autenticado');
      return;
    }

    try {
      final locks = await _firestoreService.getLocksByUser(user.uid);

      for (final lock in locks) {
        final lockId = lock['id'];

        await FirebaseFirestore.instance.collection('locks').doc(lockId).update({
          'seguroActivo': true,
        });

        await _realtimeDBService.updateLockSecureState(lockId, true);
      }
    } catch (e) {
    }
  }

  void escucharEstadoSeguro(String lockId) {
    FirebaseFirestore.instance.collection('locks').doc(lockId).snapshots().listen((doc) {
      final data = doc.data();
      if (data != null && data.containsKey('seguroActivo')) {
        final activo = data['seguroActivo'] as bool;
        if (segurosActivosPorLock.containsKey(lockId)) {
          segurosActivosPorLock[lockId]!.value = activo;
        } else {
          segurosActivosPorLock[lockId] = ValueNotifier<bool>(activo);
        }
      }
    });
  }

  Future<void> guardarClave(String lockId, String password) async {
    try {
      final bytes = utf8.encode(password);
      final hashedPassword = sha256.convert(bytes).toString();
      await FirebaseFirestore.instance
          .collection('locks')
          .doc(lockId)
          .collection('passwords')
          .doc('Clave')
          .set({'value': hashedPassword});
    } catch (e) {
    }
  }

  Future<bool> verificarClave(String lockId, String passwordIngresada, String tipo) async {
    try {
      final hashedPasswordIngresada =
      sha256.convert(utf8.encode(passwordIngresada)).toString();

      // Primero intenta con el tipo proporcionado
      final docPrincipal = await FirebaseFirestore.instance
          .collection('locks')
          .doc(lockId)
          .collection('passwords')
          .doc(tipo)
          .get();

      if (docPrincipal.exists) {
        final data = docPrincipal.data();
        final hashedPasswordGuardada = data?['value'];
        final Timestamp? createdAt = data?['createdAt'];

        if (tipo == 'Token' && createdAt != null) {
          final now = DateTime.now();
          final tokenTime = createdAt.toDate();
          final difference = now.difference(tokenTime);

          if (difference.inMinutes >= 1) {
            // Eliminar token expirado
            await docPrincipal.reference.update({
              'value': null,
              'createdAt': null,
            });
            return false;
          }
        }

        if (hashedPasswordGuardada == hashedPasswordIngresada) {
          _webSocketService.send("ACCESO_CONCEDIDO");
          return true;
        }
      }

      // Si es tipo Token y no coincidió, intenta con la contraseña tipo Clave
      if (tipo == 'Token') {
        final docClave = await FirebaseFirestore.instance
            .collection('locks')
            .doc(lockId)
            .collection('passwords')
            .doc('Clave')
            .get();

        if (docClave.exists) {
          final dataClave = docClave.data();
          final hashedPasswordClave = dataClave?['value'];

          if (hashedPasswordClave == hashedPasswordIngresada) {
            return true;
          } else {
            mostrarAlertaGlobal('error', 'Contraseña incorrecta');
          }
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> guardarToken(String lockId, String password, String tipoPassword) async {
    try {
      final hashedPassword = sha256.convert(utf8.encode(password)).toString();
      await FirebaseFirestore.instance
          .collection('locks')
          .doc(lockId)
          .collection('passwords')
          .doc(tipoPassword)
          .set({
        'value': hashedPassword,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
    }
  }

  Future<bool> esModoPrueba(String lockId) async {
    final doc = await _firestoreService.getLockById(lockId);
    return doc.data()?['modoPrueba'] ?? false;
  }

  Future<void> restablecerIntentos(String lockId) async {
    await FirebaseFirestore.instance.collection('locks').doc(lockId).update({
      'intentos': 3,
      'bloqueoActivo': false,
      'bloqueoTimestamp': null,
    });
  }

  Future<void> activarModoPruebaEnTodosLosLocks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final locks = await _firestoreService.getLocksByUser(user.uid);

      for (final lock in locks) {
        if (lock['createdBy'] != user.uid) continue;

        final lockId = lock['id'];
        await FirebaseFirestore.instance.collection('locks').doc(lockId).update({
          'modoPrueba': true,
        });

        await FirebaseDatabase.instance
            .ref("locks/$lockId")
            .update({'modoPrueba': true});
      }

      mostrarAlertaGlobal('exito', 'Modo de prueba activado.');
    } catch (e) {
      mostrarAlertaGlobal('error', 'Error al activar modo de prueba.');
    }
  }

  Future<void> desactivarModoPruebaEnTodosLosLocks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final locks = await _firestoreService.getLocksByUser(user.uid);

      for (final lock in locks) {
        if (lock['createdBy'] != user.uid) continue;

        final lockId = lock['id'];
        await FirebaseFirestore.instance.collection('locks').doc(lockId).update({
          'modoPrueba': false,
        });

        await FirebaseDatabase.instance
            .ref("locks/$lockId")
            .update({'modoPrueba': false});
      }

      mostrarAlertaGlobal('exito', 'Modo prueba desactivado.');
    } catch (e) {
      mostrarAlertaGlobal('error', 'Error al desactivar modo prueba.');
    }
  }

  Future<void> exportarLogsDelUsuarioAExcel() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      mostrarAlertaGlobal('error', 'Usuario no autenticado');
      return;
    }

    try {
      // Obtener logs una sola vez
      final logsData = await FirestoreService()
          .getAccessLogsByUser(user.uid)
          .first;

      if (logsData.isEmpty) {
        mostrarAlertaGlobal('error', 'No hay registros para exportar.');
        return;
      }

      // Crear libro Excel y hoja
      final excel = Excel.createExcel();
      final sheet = excel['Logs'];

      // Encabezados
      sheet.appendRow([
        TextCellValue('ID del Lock'),
        TextCellValue('Estado'),
        TextCellValue('Fecha y Hora'),
      ]);

      // Agregar filas
      for (final log in logsData) {
        final timestamp = log['timestamp'] is Timestamp
            ? (log['timestamp'] as Timestamp).toDate()
            : DateTime.tryParse(log['timestamp'].toString());

        sheet.appendRow([
          TextCellValue(log['lockId'] ?? ''),
          TextCellValue(log['access'] == true ? 'Acceso correcto' : 'Acceso fallido'),
          TextCellValue(timestamp?.toIso8601String() ?? 'Fecha inválida'),
        ]);
      }

      // Obtener la ruta adecuada
      final directory = await _getStorageDirectory();
      final filePath = '${directory.path}/logs_usuario.xlsx';

      // Guardar archivo
      final bytes = excel.save();
      if (bytes != null) {
        final file = File(filePath);
        await file.writeAsBytes(bytes, flush: true);


        // Compartir el archivo
        await Share.shareXFiles([XFile(filePath)], text: 'Aquí están tus registros de acceso');
      } else {
        mostrarAlertaGlobal('error', 'No se pudo generar el archivo.');
      }
    } catch (e) {
      mostrarAlertaGlobal('error', 'Error inesperado al exportar los logs.');
    }
  }

// Ruta accesible en Android (Download) e iOS (Documentos)
  Future<Directory> _getStorageDirectory() async {
    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      final path = directory?.path.split("Android")?.first ?? '/storage/emulated/0/';
      final downloadsDir = Directory('$path/Download');

      if (!downloadsDir.existsSync()) {
        downloadsDir.createSync(recursive: true);
      }

      return downloadsDir;
    } else if (Platform.isIOS) {
      return await getApplicationDocumentsDirectory();
    } else {
      throw UnsupportedError("Plataforma no soportada");
    }
  }

  void activarSeguroAutomatico() {
    _seguroAutoTimer?.cancel();

    _seguroAutoTimer = Timer.periodic(const Duration(minutes: 5), (_) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        mostrarAlertaGlobal('error', "Usuario no autenticado");
        return;
      }

      try {
        final locks = await _firestoreService.getLocksByUser(user.uid);

        for (final lock in locks) {
          if (lock['createdBy'] != user.uid) continue;

          final lockId = lock['id'];
          final seguroActivo = lock['seguroActivo'] ?? false;

          if (!seguroActivo) {
            await FirebaseFirestore.instance.collection('locks').doc(lockId).update({
              'seguroActivo': true,
            });

            await _realtimeDBService.updateLockSecureState(lockId, true);
          }
        }
      } catch (e) {
        mostrarAlertaGlobal('error', 'Ocurrió un error al activar bloque automático.');
      }
    });

    mostrarAlertaGlobal('exito', 'Bloqueo automático activado (5 minutos).');
  }

  void desactivarSeguroAutomatico() {
    _seguroAutoTimer?.cancel();
    _seguroAutoTimer = null;
    mostrarAlertaGlobal('exito', 'Bloqueo automático desactivado');
  }
}