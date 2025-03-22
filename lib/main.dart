import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(MaterialApp(home: WifiSenderApp()));
}

class WifiSenderApp extends StatefulWidget {
  @override
  State<WifiSenderApp> createState() => _WifiSenderAppState();
}

class _WifiSenderAppState extends State<WifiSenderApp> {
  WebSocketChannel? channel;
  TextEditingController textController = TextEditingController();
  TextEditingController ipController = TextEditingController();
  bool isConnected = false;

  final String wsEndpoint = "/ws";

  void connectToESP32() {
    final String esp32Ip = ipController.text;
    final url = 'ws://$esp32Ip$wsEndpoint';

    // Close the previous connection if it exists
    if (channel != null) {
      channel!.sink.close();
      setState(() {
        isConnected = false;
      });
    }

    try {
      final tempChannel = WebSocketChannel.connect(Uri.parse(url));

      tempChannel.stream.listen(
            (message) {
          print("Mensaje recibido: $message");
          if (message.toString().trim() == "CONNECTED") {
            setState(() {
              channel = tempChannel;
              isConnected = true;
            });
          }
        },
        onError: (error) {
          print("Error al escuchar WebSocket: $error");
          setState(() {
            isConnected = false;
          });
        },
      );
    } catch (e) {
      print("Error al conectar: $e");
      setState(() {
        isConnected = false;
      });
    }
  }

  void sendText(String text) {
    if (isConnected && text.isNotEmpty) {
      channel!.sink.add(text);
      textController.clear();
    }
  }

  @override
  void dispose() {
    if (isConnected) {
      channel!.sink.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Knock Lock",
          style: TextStyle(color: Color(0xFFEEF3CB)),
        ),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: ipController,
              decoration: InputDecoration(
                labelText: "Dirección IP de KnockLock",
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: connectToESP32,
              child: Text("Conectar"),
            ),
            SizedBox(height: 20),
            Text(
              "Conexión: ${isConnected ? "Conectado" : "Desconectado"}",
              style: TextStyle(color: Colors.white),
            ),
            TextField(
              controller: textController,
              decoration: InputDecoration(
                labelText: "Texto a enviar",
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isConnected ? () => sendText(textController.text) : null,
              child: Text("Enviar"),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => sendText("Iniciando grabación"),
                  icon: Icon(Icons.mic),
                  label: Text(""),
                ),
                SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: () => sendText("Iniciando verificación"),
                  icon: Icon(Icons.lock),
                  label: Text(""),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}