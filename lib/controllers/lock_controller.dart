import 'package:knocklock_flutter/core/imports.dart';
import 'package:firebase_database/firebase_database.dart';

class LockController {
  final WebSocketService _webSocketService = WebSocketService();

  final ValueNotifier<String> estadoVerificacion = ValueNotifier<String>("");
  final ValueNotifier<bool> isConnected = ValueNotifier<bool>(false);
  final ValueNotifier<String> modoSeleccionado = ValueNotifier<String>("");
  final ValueNotifier<bool> mostrarBotonGrabacion = ValueNotifier<bool>(false);
  final ValueNotifier<bool> seguroActivo = ValueNotifier<bool>(false);
  final ValueNotifier<bool> bloqueActivo = ValueNotifier<bool>(false);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _realtimeDB = FirebaseDatabase.instance;

  String? _lockId;

  StreamSubscription<String>? _webSocketSubscription;

  BuildContext? dialogContext;

  /// Conexión al WebSocket del ESP32
  void conectar(String ip, String lockId) async {
    final url = 'ws://$ip/ws';
    _lockId = lockId;
    _webSocketService.connect(url);

    _webSocketSubscription = _webSocketService.messages.listen((message) {
      _handleMessage(message);
    });

    final doc = await _firestore.collection('locks').doc(lockId).get();
    if (doc.exists && doc.data()?['seguroActivo'] != null) {
      seguroActivo.value = doc.data()?['seguroActivo'];
    }
  }

  /// Desconecta del WebSocket
  void desconectar() {
    _webSocketService.disconnect();
    _webSocketSubscription?.cancel();
  }

  /// Envía un mensaje al WebSocket
  void enviarComando(String mensaje) {
    _webSocketService.send(mensaje);
  }

  /// Maneja los mensajes recibidos del WebSocket
  void _handleMessage(String message) {
    print("📩 Mensaje del ESP32: $message");

    if (message.trim() == "CONNECTED") {
      isConnected.value = true;
      return;
    }

    // Estado de verificación visual
    estadoVerificacion.value = message;

    // Cambia el estado del candado
    if (message.contains("ACCESO_CONCEDIDO")) {
      cambiarEstadoSeguro(_lockId!, false);
      print('El candado está abierto');
    } else if (message.contains("ACCESO_FALLIDO")) {
      cambiarEstadoSeguro(_lockId!, true);
      print('El candado está bloqueado');
    } else if (message.contains("ACCESO_BLOQUEADO_TEMPORALMENTE")) {
      cambiarEstadoSeguro(_lockId!, true);
      bloqueActivo.value = true;
      print('El candado está bloqueado temporalmente');
    }
  }

  /// Verifica el password de tipo "Clave" o "Patron"
  Future<void> verificarPassword(String tipoPassword, BuildContext context, Lock lock) async {
    try {
      final passwordDoc = await _firestore
          .collection('locks')
          .doc(lock.id)
          .collection('passwords')
          .doc(tipoPassword)
          .get();

      if (!passwordDoc.exists) {
        mostrarBotonGrabacion.value = true;
        return;
      }

      final data = passwordDoc.data();
      final value = data?['value'];

      if (tipoPassword == 'Patron') {
        if (value is List && value.isNotEmpty) {
          print('Con contraseña: $value');
          mostrarBotonGrabacion.value = false;
        } else {
          print('Sin contraseña actual');
          mostrarBotonGrabacion.value = true;
        }
      } else if (tipoPassword == 'Clave') {
        if (value == null || value.toString().trim().isEmpty) {
          print('Sin contraseña actual');
          mostrarBotonGrabacion.value = true;
        } else {
          print('Con contraseña: $value');
          mostrarBotonGrabacion.value = false;
        }
      }
    } catch (e) {
      print('Error al verificar el password: $e');
    }
  }

  /// Inicia la grabación de un nuevo patrón
  void iniciarGrabacion(BuildContext context, Lock lock) {
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
                mostrarBotonGrabacion.value = false; // Ocultar el botón
                Navigator.pop(dialogCtx); // Cerrar el diálogo
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

          // Guardar en Firestore
          await _firestore
              .collection('locks')
              .doc(lock.id)
              .collection('passwords')
              .doc('Patron')
              .set({
            'type': 'arreglo_numeros',
            'value': patronGrabado,
            'createdAt': FieldValue.serverTimestamp(),
          });

          // Guardar en RTDB
          await _realtimeDB.ref('locks/${lock.id}/passwords/Patron').set(patronGrabado);

          // Cambiar seguroActivo a true
          cambiarEstadoSeguro(lock.id, true);

          if (context.mounted) {
            Navigator.pop(context); // Cerrar diálogo de grabación

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

          mostrarBotonGrabacion.value = false; // Ocultar el botón después de guardar
        } catch (e) {
          print("❌ Error al interpretar patrón: $e");
        }
      }
    });
  }

  void detenerGrabacion() {
    enviarComando("STOP_GRABACION");
    print('Grabación detenida');
  }

  /// Inicia la verificación del patrón guardado
  Future<void> iniciarVerificacion(BuildContext context, Lock lock) async {
    enviarComando("START_VERIFICACION");
    try {
      final snapshot = await _realtimeDB.ref('locks/${lock.id}/passwords/Patron').get();

      if (!snapshot.exists) {
        print('⚠️ No hay patrón en RTDB');
        return;
      }

      final patronRTDB = List<int>.from((snapshot.value as List<dynamic>));
      final jsonPatron = jsonEncode(patronRTDB);

      enviarComando("PATRON:$jsonPatron");
      print('✅ Verificación iniciada: Patrón enviado al ESP32');
    } catch (e) {
      print("❌ Error al obtener patrón desde RTDB: $e");
    }
  }

  // Detiene la verificación del patrón
  void detenerVerificacion() {
    enviarComando("STOP_VERIFICACION");
    print('Verificación detenida');
  }

  /// Agrega un nuevo lock en Firestore y RTDB
  Future<void> agregarLock(String nombre, String ip) async {
    try {
      final lockRef = await _firestore.collection('locks').add({
        'name': nombre,
        'ip': ip,
        'modo': 'ninguno',
        'seguroActivo': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await lockRef.collection('passwords').doc('Clave').set({
        'type': 'alfanumerico',
        'value': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await lockRef.collection('passwords').doc('Patron').set({
        'type': 'arreglo_numeros',
        'value': [],
        'createdAt': FieldValue.serverTimestamp(),
      });

      await lockRef.collection('passwords').doc('Token').set({
        'type': 'alfanumerico',
        'value': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _realtimeDB.ref('locks/${lockRef.id}/passwords').set({
        'Patron': [400, 500, 600],
      });
    } catch (e) {
      print(e);
    }
  }

  // Obtiene los locks desde Firestore
  Stream<List<Lock>> obtenerLocks() {
    return _firestore.collection('locks').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Lock(
          seguroActivo: data['seguroActivo'] ?? false,
          id: doc.id,
          name: data['name'] ?? '',
          ip: data['ip'] ?? '',
        );
      }).toList();
    });
  }

  // Cargar el modo desde Firestore
  Future<void> cargarModo(String lockId) async {
    try {
      final doc = await _firestore.collection('locks').doc(lockId).get();
      if (doc.exists) {
        final data = doc.data();
        final modo = data?['modo'] ?? "PATRÓN"; // Valor por defecto
        modoSeleccionado.value = modo;
      }
    } catch (e) {
      print("Error al cargar el modo: $e");
    }
  }

  // Guardar el modo en Firestore
  Future<void> guardarModo(String lockId) async {
    try {
      final nuevoModo = modoSeleccionado.value;

      // Guardar en Firestore
      await _firestore.collection('locks').doc(lockId).update({
        'modo': nuevoModo,
      });

      // Guardar en RTDB
      await _realtimeDB.ref('locks/$lockId').update({
        'modo': nuevoModo,
      });
    } catch (e) {
      print("Error al guardar el modo: $e");
    }
  }

  // Cambiar el estado del seguro en Firestore
  Future<void> cambiarEstadoSeguro(String lockId, bool nuevoEstado) async {
    try {
      // ✅ Actualiza Firebase
      await _firestore.collection('locks').doc(lockId).update({
        'seguroActivo': nuevoEstado,
      });

      // ✅ Actualiza RTDB si lo usas
      await _realtimeDB.ref('locks/$lockId').update({
        'seguroActivo': nuevoEstado,
      });

      // ✅ Actualiza el ValueNotifier también
      seguroActivo.value = nuevoEstado;

    } catch (e) {
      print("Error al cambiar estado de seguroActivo: $e");
    }
  }

  /// Seleccionar un nuevo modo
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

  Stream<List<AccessLog>> obtenerLogsAcceso() {
    return _firestore
        .collectionGroup('accessLogs')
        .snapshots()
        .map((snapshot) {
      print("📦 Documentos recibidos: ${snapshot.docs.length}");
      return snapshot.docs.map((doc) => AccessLog.fromDoc(doc)).toList();
    });
  }
}