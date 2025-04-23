import '../core/imports.dart';

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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundTop,
            AppColors.backgroundBottom,
          ],
        ),
      ),
    child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            Text(
              widget.lock.name,
              style: AppTextStyles.primaryTextStyle,
            ),
            SizedBox(height: 5),
            Text(
              widget.lock.ip,
              style: AppTextStyles.secondaryTextStyle,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                // Acción futura
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35.0),
        child: Column(
          children: [

            Spacer(),
            Container(
              height: 220.0,
              width: 220.0,
              decoration: BoxDecoration(
                color: AppColors.backgroundHelperColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 80,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock,
                    color: Colors.black,
                    size: 60.0,
                  ),
                  SizedBox(height: 12), // Espacio entre el icono y el texto
                  Text(
                    "Estado del\nDispositivo",
                    style: AppTextStyles.secondaryTextStyle.copyWith(color: AppColors.primaryColor),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Modo activo",
                  style: AppTextStyles.secondaryModalStyle,
                ),
                Text(
                  "TÁCTIL",
                  style: AppTextStyles.primaryTextStyle,
                )
              ],
            ),
            const SizedBox(height: 45),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ModeButton(
                  icon: Icons.back_hand,
                  label: "TÁCTIL",
                  onTap: isConnected ? reproducirPatron : null,
                ),
                ModeButton(
                  icon: Icons.password,
                  label: "CLAVE",
                  onTap: isConnected ? pausarReproduccion : null,
                ),
                ModeButton(
                  icon: Icons.shuffle,
                  label: "TOKEN",
                  onTap: isConnected ? generarPatronAleatorio : null,
                ),
              ],
            ),
            const SizedBox(height: 100),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTapDown: (_) => sendText("START_VERIFICACION"),
                  onTapUp: (_) => sendText("STOP_VERIFICACION"),
                  child: Container(
                    height: 70.0,
                    width: 70.0,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryBackgroundHelperColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: Offset(0,0),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    child: IconButton(
                      onPressed: null,
                      icon: Icon(Icons.mic, color: Colors.black, size: 30),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 70),
          ],
        ),
      ),
    ),
    );
  }
}