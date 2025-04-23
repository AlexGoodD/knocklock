import 'package:knocklock_flutter/core/imports.dart';

class LockController {
  final WebSocketService _webSocketService = WebSocketService();
  final ValueNotifier<int> segundosRestantes = ValueNotifier<int>(0);
  final ValueNotifier<String> estadoVerificacion = ValueNotifier<String>("");
  final ValueNotifier<Color> colorEstado = ValueNotifier<Color>(Colors.transparent);
  final ValueNotifier<bool> isConnected = ValueNotifier<bool>(false);

  Timer? _countdownTimer;
  List<int> patronActual = [];
  bool estaPausado = false;
  bool estaReproduciendo = false;
  int barraActiva = -1;
  Completer<void>? _pausaCompleter;

  BuildContext? _dialogContext;

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