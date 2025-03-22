import '../imports.dart';

class LockDetailScreen extends StatefulWidget {
  final Lock lock;

  LockDetailScreen({required this.lock});

  @override
  State<LockDetailScreen> createState() => _LockDetailScreenState();
}

class _LockDetailScreenState extends State<LockDetailScreen> {
  final WebSocketService _webSocketService = WebSocketService();
  TextEditingController textController = TextEditingController();
  bool isConnected = false;
  String estadoVerificacion = "";
  Color colorEstado = Colors.transparent;

  final String wsEndpoint = "/ws";

  @override
  void initState() {
    super.initState();
    connectToESP32();
  }

  void connectToESP32() {
    final String esp32Ip = widget.lock.ip;
    final url = 'ws://$esp32Ip$wsEndpoint';

    _webSocketService.connect(url);

    _webSocketService.messages.listen((message) {
      print("Mensaje recibido (pantalla): $message");

      if (message.toString().trim() == "CONNECTED") {
        setState(() {
          isConnected = true;
        });
      } else {
        setState(() {
          estadoVerificacion = message;

          if (message.contains("desbloqueado")) {
            colorEstado = Colors.green;
          } else if (message.contains("te quedan")) {
            colorEstado = Colors.orange;
          } else if (message.contains("Sin intentos")) {
            colorEstado = Colors.red;
          } else {
            colorEstado = Colors.grey;
          }
        });
      }
    });
  }

  void sendText(String text) {
    if (isConnected && text.isNotEmpty) {
      _webSocketService.send(text);
      textController.clear();
    }
  }

  @override
  void dispose() {
    _webSocketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.lock.name,
          style: AppTextStyles.primaryTextStyle,
        ),
        backgroundColor: AppColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "IP: ${widget.lock.ip}",
              style: AppTextStyles.secondaryTextStyle,
            ),
            SizedBox(height: 20),
            TextField(
              controller: textController,
              decoration: InputDecoration(
                labelText: "Texto a enviar",
                labelStyle: AppTextStyles.secondaryTextStyle,
              ),
              style: AppTextStyles.secondaryTextStyle,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isConnected ? () => sendText(textController.text) : null,
              child: Text("Enviar"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonBackground,
              ),
            ),
            if (estadoVerificacion.isNotEmpty)
              Container(
                margin: EdgeInsets.only(bottom: 20),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colorEstado,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  estadoVerificacion,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTapDown: (_) => sendText("START_GRABACION"),
                  onTapUp: (_) => sendText("STOP_GRABACION"),
                  child: ElevatedButton.icon(
                    onPressed: null,
                    icon: Icon(Icons.mic),
                    label: Text(""),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonBackground,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                GestureDetector(
                  onTapDown: (_) => sendText("START_VERIFICACION"),
                  onTapUp: (_) => sendText("STOP_VERIFICACION"),
                  child: ElevatedButton.icon(
                    onPressed: null,
                    icon: Icon(Icons.lock),
                    label: Text(""),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonBackground,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}