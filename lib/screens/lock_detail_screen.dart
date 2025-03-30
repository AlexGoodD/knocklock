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
  bool estaPausado = false;
  Completer<void>? _pausaCompleter;
  int barraActiva = -1;
  bool estaReproduciendo = false;

  final String wsEndpoint = "/ws";
  List<int> patronActual = [];
  Timer? _countdownTimer;
  ValueNotifier<int> segundosRestantes = ValueNotifier<int>(0);
  BuildContext? _dialogContext;

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

      if (message.contains("desbloqueado") || message.contains("PATRON_CORRECTO")) {
        if (_dialogContext != null && Navigator.canPop(_dialogContext!)) {
          Navigator.pop(_dialogContext!);
          _dialogContext = null;
        }

        setState(() {
          estadoVerificacion = "🔓 ¡Patrón correcto!";
          colorEstado = Colors.green;
        });

        return;
      }

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

  void generarPatronAleatorio() {
    final patron = _webSocketService.generarYEnviarPatron();

    setState(() {
      patronActual = patron;
      segundosRestantes.value = 5 * 60;
    });

    iniciarContador();

    // 👉 Mostrar diálogo
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        _dialogContext = dialogContext;

        return AlertDialog(
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: PatronWidget(
              patron: patron,
              onCancel: () {
                cancelarPatron();
                Navigator.pop(dialogContext);
              },
              tiempoRestante: segundosRestantes,
            ),
          ),
        );
      },
    );
  }

  void iniciarContador() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (_) {
      segundosRestantes.value--;
      if (segundosRestantes.value <= 0) {
        _countdownTimer?.cancel();
      }
    });
  }

  void reproducirPatron() async {
    if (patronActual.isEmpty || estaReproduciendo) return;

    setState(() {
      estaReproduciendo = true;
      barraActiva = 0;
      estaPausado = false;
    });

    await HapticFeedback.heavyImpact(); // Primer golpe

    for (int i = 0; i < patronActual.length; i++) {
      await Future.delayed(Duration(milliseconds: patronActual[i]));

      if (estaPausado) {
        _pausaCompleter = Completer<void>();
        await _pausaCompleter!.future;
      }

      await HapticFeedback.mediumImpact();

      setState(() {
        barraActiva = i + 1;
      });
    }

    await Future.delayed(Duration(milliseconds: 300));

    setState(() {
      barraActiva = -1;
      estaReproduciendo = false;
      estaPausado = false;
    });
  }

  void pausarReproduccion() {
    if (!estaPausado && estaReproduciendo) {
      setState(() {
        estaPausado = true;
      });
    }
  }

  void continuarReproduccion() {
    if (estaPausado && _pausaCompleter != null) {
      setState(() {
        estaPausado = false;
        _pausaCompleter?.complete();
      });
    }
  }

  void cancelarPatron() {
    setState(() {
      patronActual = [];
      barraActiva = -1;
      estaPausado = false;
      estaReproduciendo = false;
      segundosRestantes.value = 0;
    });
    _countdownTimer?.cancel();
    _pausaCompleter?.complete();
  }

  @override
  void dispose() {
    _webSocketService.disconnect();
    _countdownTimer?.cancel();
    segundosRestantes.dispose();
    super.dispose();
  }

  String formatearSegundos(int segundos) {
    final minutos = (segundos / 60).floor();
    final seg = segundos % 60;
    return '${minutos.toString().padLeft(2, '0')}:${seg.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDetail,
      appBar: AppBar(
        title: Text(
          widget.lock.name,
          style: AppTextStyles.appBarSecondaryTextStyle,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("IP: ${widget.lock.ip}", style: AppTextStyles.secondaryTextStyle),
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
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonBackground),
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

            SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: isConnected ? generarPatronAleatorio : null,
                  icon: Icon(Icons.shuffle),
                  label: Text("Generar"),
                ),
              ],
            ),


            SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTapDown: (_) => sendText("START_GRABACION"),
                  onTapUp: (_) => sendText("STOP_GRABACION"),
                  child: Container(
                    width: 100.0,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: IconButton(
                      onPressed: null,
                      icon: Icon(Icons.mic, color: Colors.black, size: 30),
                    ),
                  ),
                ),
                SizedBox(width: 50),
                GestureDetector(
                  onTapDown: (_) => sendText("START_VERIFICACION"),
                  onTapUp: (_) => sendText("STOP_VERIFICACION"),
                  child: Container(
                    width: 100.0,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: IconButton(
                      onPressed: null,
                      icon: Icon(Icons.lock, color: Colors.black, size: 30),
                    ),
                  ),
                )
              ],
            ),

            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}