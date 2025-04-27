import 'package:knocklock_flutter/core/imports.dart';
import 'package:http/http.dart' as http;

class LockController {
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

  String? _lockId;
  StreamSubscription<String>? _webSocketSubscription;
  BuildContext? dialogContext;
  Timer? _verificacionTimer;

  void conectar(String ip, String lockId) async {
    final url = 'ws://$ip/ws';
    _lockId = lockId;
    _webSocketService.connect(url);

    _webSocketSubscription = _webSocketService.messages.listen((message) {
      _handleMessage(message);
    });

    final doc = await _firestoreService.getLockById(lockId);
    if (doc.exists && doc.data()?['seguroActivo'] != null) {
      seguroActivo.value = doc.data()?['seguroActivo'];
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
    }
  }

  void enviarComando(String mensaje) {
    _webSocketService.send(mensaje);
  }

  void _handleMessage(String message) {
    print("📩 Mensaje del ESP32: $message");

    if (message.trim() == "CONNECTED") {
      isConnected.value = true;
      return;
    }

    estadoVerificacion.value = message;

    if (message.contains("ACCESO_CONCEDIDO")) {
      cambiarEstadoSeguro(_lockId!, false);
    } else if (message.contains("ACCESO_FALLIDO")) {
      cambiarEstadoSeguro(_lockId!, true);
    } else if (message.contains("ACCESO_BLOQUEADO_TEMPORALMENTE")) {
      cambiarEstadoSeguro(_lockId!, true);
      bloqueActivo.value = true;
    }
  }

  Future<void> verificarPassword(String tipoPassword, BuildContext context, Lock lock) async {
    try {
      final passwordDoc = await _firestoreService.getPassword(lock.id, tipoPassword);

      if (!passwordDoc.exists) {
        mostrarBotonGrabacion.value = true;
        return;
      }

      final data = passwordDoc.data();
      final value = data?['value'];

      if (tipoPassword == 'Patron') {
        mostrarBotonGrabacion.value = (value == null || (value is List && value.isEmpty));
      } else if (tipoPassword == 'Clave') {
        mostrarBotonGrabacion.value = (value == null || value.toString().trim().isEmpty);
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
        'modo': 'ninguno',
        'seguroActivo': false,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': user.uid, // Asociar el lock al usuario actual
      });

      // Configura las contraseñas iniciales
      await _firestoreService.setInitialPasswords(lockRef.id);
      await _realtimeDBService.createInitialPasswords(lockRef.id);
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
    try {
      await _firestoreService.updateLockSecureState(lockId, nuevoEstado);
      await _realtimeDBService.updateLockSecureState(lockId, nuevoEstado);
      seguroActivo.value = nuevoEstado;
    } catch (e) {
      print("Error al cambiar estado de seguroActivo: $e");
    }
  }

  void seleccionarModo(String modo) {
    modoSeleccionado.value = modo;
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
}