import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final _messageController = StreamController<String>.broadcast();
  bool isConnected = false;

  WebSocketChannel? get channel => _channel;
  Stream<String> get messages => _messageController.stream;

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

          _messageController.add(message); // emite mensaje a la UI
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

  void send(String text) {
    if (_channel != null && isConnected && text.isNotEmpty) {
      _channel!.sink.add(text);
      print("📤 Enviado: $text");
    } else {
      print("❌ No se pudo enviar (no conectado o texto vacío)");
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    isConnected = false;
  }

  void dispose() {
    _messageController.close();
  }
}