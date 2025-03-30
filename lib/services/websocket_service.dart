import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final _messageController = StreamController<String>.broadcast();
  bool isConnected = false;

  Timer? _expirationTimer;
  DateTime? _expirationTime;

  WebSocketChannel? get channel => _channel;
  Stream<String> get messages => _messageController.stream;
  DateTime? get expirationTime => _expirationTime;

  void connect(String url) {
    disconnect();

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));

      _channel!.stream.listen(
            (message) {
          print("Mensaje recibido (service): $message");

          if (message.toString().trim() == "CONNECTED") {
            isConnected = true;
          }

          _messageController.add(message); // emitir mensaje a la UI
        },
        onDone: () {
          print("Conexión cerrada");
          isConnected = false;
        },
        onError: (error) {
          print("Error en WebSocket: $error");
          isConnected = false;
        },
      );
    } catch (e) {
      print("Error al conectar: $e");
      isConnected = false;
    }
  }

  void disconnect() {
    _expirationTimer?.cancel();
    _expirationTimer = null;
    _channel?.sink.close();
    _channel = null;
    isConnected = false;
  }

  void dispose() {
    _messageController.close();
    disconnect();
  }

  /// Genera y envía un patrón aleatorio, retorna la lista para mostrar al usuario
  List<int> generarYEnviarPatron({int minGolpes = 4, int maxGolpes = 6}) {
    if (!isConnected) {
      print("❌ No se puede enviar patrón, no conectado");
      return [];
    }

    final random = Random();
    final int numGolpes = 4 + random.nextInt(3);
    final List<int> duraciones = List.generate(numGolpes - 1, (_) {
      return 300 + random.nextInt(800); // Duración entre 300ms y 1100ms
    });

    final String patronString = jsonEncode(duraciones);
    send("PATRON:$patronString");

    _iniciarTemporizadorExpiracion();

    return duraciones;
  }

  void send(String text) {
    if (_channel != null && isConnected && text.isNotEmpty) {
      _channel!.sink.add(text);
      print("📤 Enviado: $text");
    } else {
      print("❌ No se pudo enviar (no conectado o texto vacío)");
    }
  }

  void _iniciarTemporizadorExpiracion() {
    _expirationTimer?.cancel(); // Cancelar cualquier temporizador anterior

    _expirationTime = DateTime.now().add(Duration(minutes: 5));
    _expirationTimer = Timer(Duration(minutes: 5), () {
      print("⏰ Patrón expirado (Flutter)");
      send("EXPIRADO"); // Notificar al ESP32 si quieres
    });
  }

  /// Tiempo restante en segundos (para UI)
  int segundosRestantes() {
    if (_expirationTime == null) return 0;
    final now = DateTime.now();
    final diff = _expirationTime!.difference(now);
    return diff.inSeconds > 0 ? diff.inSeconds : 0;
  }
}