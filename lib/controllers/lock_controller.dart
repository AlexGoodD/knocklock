import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:knocklock_flutter/core/imports.dart';
import 'package:http/http.dart' as http;
import 'package:excel/excel.dart';

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
      await _firestoreService.registrarIntentoFallido(_lockId!);
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

      // Agrega el lock con el uid del usuario
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

      // Configura las contraseñas iniciales
      await _firestoreService.setInitialPasswords(lockRef.id);
      await _realtimeDBService.createInitialPasswords(lockRef.id);

      // Agrega el lock a RTBD junto con el IP
      await FirebaseDatabase.instance
          .ref("locks/${lockRef.id}")
          .update({
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

    return Stream.fromFuture(_firestoreService.getLocksByUser(user.uid)).map((locksData) {
      return locksData.map((data) {
        return Lock(
          id: data['id'],
          name: data['name'] ?? '',
          ip: data['ip'] ?? '',
          seguroActivo: data['seguroActivo'] ?? false,
          bloqueoActivoManual: data['bloqueoActivoManual'] ?? false,
          bloqueoActivoIntentos: data['bloqueoActivoIntentos'] ?? false,
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
      print("Error al guardar el modo: $e");
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
      mostrarAlertaGlobal('error', 'No se puede cambiar el estado: el dispositivo está bloqueado.');
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
        mostrarAlertaGlobal('error', 'No se puede cambiar el estado: no hay contraseña configurada para el modo actual. $modo');
        print('Hola');
        return;
      }

      // Cambiar estado si hay contraseña
      await _firestoreService.updateLockSecureState(lockId, nuevoEstado);
      await _realtimeDBService.updateLockSecureState(lockId, nuevoEstado);

      if (segurosActivosPorLock.containsKey(lockId)) {
        segurosActivosPorLock[lockId]!.value = nuevoEstado;
      }

    } catch (e) {
      print("❌ Error al cambiar estado de seguroActivo: $e");
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
      return logsData.map((data) => AccessLog.fromMap(data)).toList();
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
    if (user == null) {
      print('⚠️ Usuario no autenticado');
      return;
    }

    try {
      final locks = await _firestoreService.getLocksByUser(user.uid);
      final now = DateTime.now();
      final bloqueoTermina = now.add(const Duration(hours: 1)); // 1 hora de bloqueo

      for (final lock in locks) {
        final lockId = lock['id'];

        // Actualizar en Firestore
        await FirebaseFirestore.instance.collection('locks').doc(lockId).update({
          'seguroActivo': true,
          'bloqueoActivoManual': true,
          'bloqueoTimestamp': Timestamp.fromDate(bloqueoTermina),
        });

        // Actualizar también en Realtime Database si quieres
        await _realtimeDBService.bloquearLock(lockId, bloqueoTermina);
      }

      print('✅ Todos los locks han sido bloqueados correctamente');
    } catch (e) {
      print('❌ Error al bloquear todos los locks: $e');
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

            print('🔓 Lock $lockId desbloqueado automáticamente por intentos.');
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
      print('⚠️ Usuario no autenticado');
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

      print('🔒 Todos los locks ahora tienen seguroActivo = true');
    } catch (e) {
      print('❌ Error al activar seguro en todos los locks: $e');
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

      print('✅ Contraseña guardada correctamente');
    } catch (e) {
      print('❌ Error al guardar la contraseña: $e');
    }
  }

  Future<bool> verificarClave(String lockId, String passwordIngresada, String tipo) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('locks')
          .doc(lockId)
          .collection('passwords')
          .doc(tipo)
          .get();

      if (!doc.exists) {
        print('⚠️ No se encontró una contraseña guardada para $tipo');
        return false;
      }

      final data = doc.data();
      final hashedPasswordGuardada = data?['value'];
      final Timestamp? createdAt = data?['createdAt'];

      if (tipo == 'Token' && createdAt != null) {
        final now = DateTime.now();
        final tokenTime = createdAt.toDate();
        final difference = now.difference(tokenTime);

        if (difference.inMinutes >= 1) {
          // Eliminar token expirado
          await doc.reference.update({
            'value': null,
            'createdAt': null,
          });
          print('⏳ Token expirado y eliminado automáticamente');
          return false;
        }
      }

      final hashedPasswordIngresada =
      sha256.convert(utf8.encode(passwordIngresada)).toString();

      return hashedPasswordGuardada == hashedPasswordIngresada;
    } catch (e) {
      print('❌ Error al verificar $tipo: $e');
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

      print('✅ Contraseña guardada correctamente en $tipoPassword');
    } catch (e) {
      print('❌ Error al guardar la contraseña: $e');
    }
  }

  Future<void> registrarIntentoFallido(String lockId) async {
    final doc = await _firestoreService.getLockById(lockId);
    final data = doc.data();

    final bool modoPrueba = data?['modoPrueba'] ?? false;

    if (modoPrueba) {
      return;
    }

    int intentos = data?['intentos'] ?? 3;
    bool bloqueoIntentos = data?['bloqueoActivoIntentos'] ?? false;

    if (bloqueoIntentos) return;

    intentos--;

    if (intentos <= 0) {
      await FirebaseFirestore.instance.collection('locks').doc(lockId).update({
        'bloqueoActivoIntentos': true,
        'bloqueoTimestamp': Timestamp.now(),
        'intentos': 0,
      });

      mostrarAlertaGlobal('error', '🔒 Candado bloqueado por intentos fallidos. Intenta en 5 minutos.');
    } else {
      await FirebaseFirestore.instance.collection('locks').doc(lockId).update({
        'intentos': intentos,
      });
    }
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
    if (user == null) {
      print('⚠️ Usuario no autenticado');
      return;
    }

    try {
      final locks = await _firestoreService.getLocksByUser(user.uid);

      for (final lock in locks) {
        final lockId = lock['id'];

        // Actualizar en Firestore
        await FirebaseFirestore.instance.collection('locks').doc(lockId).update({
          'modoPrueba': true,
        });

        // (Opcional) Actualizar también en Realtime Database
        await FirebaseDatabase.instance
            .ref("locks/$lockId")
            .update({'modoPrueba': true});
      }

      mostrarAlertaGlobal('exito', 'Todos los locks están ahora en modo prueba.');
    } catch (e) {
      mostrarAlertaGlobal('error', 'Error al activar modo prueba.');
    }
  }

  Future<void> desactivarModoPruebaEnTodosLosLocks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('⚠️ Usuario no autenticado');
      return;
    }

    try {
      final locks = await _firestoreService.getLocksByUser(user.uid);

      for (final lock in locks) {
        final lockId = lock['id'];

        // Actualizar en Firestore
        await FirebaseFirestore.instance.collection('locks').doc(lockId).update({
          'modoPrueba': false,
        });

        // (Opcional) Actualizar también en Realtime Database
        await FirebaseDatabase.instance
            .ref("locks/$lockId")
            .update({'modoPrueba': false});
      }

      mostrarAlertaGlobal('exito', 'Ya no se encuentran tus locks en modo prueba.');
    } catch (e) {
      mostrarAlertaGlobal('error', 'Error al desactivar modo prueba.');
    }
  }

  Future<void> exportarLogsDelUsuarioAExcel() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      mostrarAlertaGlobal('error', '⚠️ Usuario no autenticado');
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
          TextCellValue(log['estado'] ?? ''),
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
      print('❌ Error al exportar logs: $e');
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
        print('⚠️ Usuario no autenticado');
        return;
      }

      try {
        final locks = await _firestoreService.getLocksByUser(user.uid);

        for (final lock in locks) {
          final lockId = lock['id'];
          final seguroActivo = lock['seguroActivo'] ?? false;

          if (!seguroActivo) {
            await FirebaseFirestore.instance.collection('locks').doc(lockId).update({
              'seguroActivo': true,
            });

            await _realtimeDBService.updateLockSecureState(lockId, true);
          }
        }

        print('✅ Verificación periódica completada: seguros activados donde fue necesario');
      } catch (e) {
        print('❌ Error al ejecutar seguro automático: $e');
      }
    });

    mostrarAlertaGlobal('exito', 'Bloqueo automático activado para tus locks');
  }

  void desactivarSeguroAutomatico() {
    _seguroAutoTimer?.cancel();
    _seguroAutoTimer = null;
    mostrarAlertaGlobal('error', 'Bloqueo automático desactivado para tus locks');
  }
}