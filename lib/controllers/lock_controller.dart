import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knocklock_flutter/core/imports.dart';

class LockController {
  final WebSocketService _webSocketService = WebSocketService();
  final ValueNotifier<int> segundosRestantes = ValueNotifier<int>(0);
  final ValueNotifier<String> estadoVerificacion = ValueNotifier<String>("");
  final ValueNotifier<Color> colorEstado = ValueNotifier<Color>(Colors.transparent);
  final ValueNotifier<bool> isConnected = ValueNotifier<bool>(false);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Timer? _countdownTimer;
  List<int> patronActual = [];
  bool estaPausado = false;
  bool estaReproduciendo = false;
  int barraActiva = -1;
  Completer<void>? _pausaCompleter;

  BuildContext? _dialogContext;

  Future<void> agregarLock(String nombre, String ip) async {
    try {
      // Agregar un nuevo lock a la colección "locks"
      DocumentReference lockRef = await _firestore.collection('locks').add({
        'name': nombre,
        'ip': ip,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Agregar la subcolección "passwords" con los tres tipos
      await lockRef.collection('passwords').doc('Clave').set({
        'type': 'alfanumerico',
        'value': '', // Valor inicial vacío
        'createdAt': FieldValue.serverTimestamp(),
      });

      await lockRef.collection('passwords').doc('Patron').set({
        'type': 'arreglo_numeros',
        'value': [], // Valor inicial vacío
        'createdAt': FieldValue.serverTimestamp(),
      });

      await lockRef.collection('passwords').doc('Token').set({
        'type': 'alfanumerico',
        'value': '', // Valor inicial vacío
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('Lock y contraseñas agregados correctamente.');
    } catch (e) {
      print('Error al agregar el lock: $e');
    }
  }

  Stream<List<Lock>> obtenerLocks() {
    return _firestore.collection('locks').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Lock(
          id: doc.id,
          name: data['name'] ?? '',
          ip: data['ip'] ?? '',
        );
      }).toList();
    });
  }

  void conectar(String ip) {
    final url = 'ws://$ip/ws';
    _webSocketService.connect(url);

    _webSocketService.messages.listen((message) {
      _handleMessage(message);
    });
  }

  void _handleMessage(String message) {
    if (message.contains("desbloqueado") || message.contains("PATRON_CORRECTO")) {
      estadoVerificacion.value = "🔓 ¡Patrón correcto!";
      colorEstado.value = Colors.green;
      return;
    }

    if (message.trim() == "CONNECTED") {
      isConnected.value = true;
    } else {
      estadoVerificacion.value = message;
      if (message.contains("desbloqueado")) {
        colorEstado.value = Colors.green;
      } else if (message.contains("te quedan")) {
        colorEstado.value = Colors.orange;
      } else if (message.contains("Sin intentos")) {
        colorEstado.value = Colors.red;
      } else {
        colorEstado.value = Colors.grey;
      }
    }
  }

  void generarPatron() {
    patronActual = _webSocketService.generarYEnviarPatron();
    segundosRestantes.value = 5 * 60;
    _iniciarContador();
  }

  void _iniciarContador() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (_) {
      segundosRestantes.value--;
      if (segundosRestantes.value <= 0) {
        _countdownTimer?.cancel();
      }
    });
  }

  Future<void> reproducirPatron(Function(int) onPaso) async {
    if (patronActual.isEmpty || estaReproduciendo) return;

    estaReproduciendo = true;
    barraActiva = 0;
    estaPausado = false;

    await HapticFeedback.heavyImpact();

    for (int i = 0; i < patronActual.length; i++) {
      await Future.delayed(Duration(milliseconds: patronActual[i]));

      if (estaPausado) {
        _pausaCompleter = Completer<void>();
        await _pausaCompleter!.future;
      }

      await HapticFeedback.mediumImpact();
      onPaso(i + 1);
    }

    await Future.delayed(Duration(milliseconds: 300));

    estaReproduciendo = false;
    estaPausado = false;
    barraActiva = -1;
  }

  void pausar() {
    if (!estaPausado && estaReproduciendo) {
      estaPausado = true;
    }
  }

  void continuar() {
    if (estaPausado && _pausaCompleter != null) {
      estaPausado = false;
      _pausaCompleter?.complete();
    }
  }

  void cancelar() {
    patronActual = [];
    barraActiva = -1;
    estaPausado = false;
    estaReproduciendo = false;
    segundosRestantes.value = 0;
    _countdownTimer?.cancel();
    _pausaCompleter?.complete();
  }

  void enviar(String mensaje) {
    if (isConnected.value && mensaje.isNotEmpty) {
      _webSocketService.send(mensaje);
    }
  }

  void dispose() {
    _webSocketService.disconnect();
    _countdownTimer?.cancel();
    segundosRestantes.dispose();
  }
}