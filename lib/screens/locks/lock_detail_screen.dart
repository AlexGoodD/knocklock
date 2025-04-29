import '../../core/imports.dart';

class LockDetailScreen extends StatefulWidget {
  final Lock lock;
  final LockController controller; // 🔥 ahora recibe el controller

  const LockDetailScreen({
    super.key,
    required this.lock,
    required this.controller,
  });

  @override
  State<LockDetailScreen> createState() => _LockDetailScreenState();
}

class _LockDetailScreenState extends State<LockDetailScreen> {
  late Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    widget.controller.conectar(widget.lock.ip, widget.lock.id);
    _initialization = widget.controller.cargarModo(widget.lock.id);
  }

  @override
  void dispose() {
    widget.controller.guardarModo(widget.lock.id);
    widget.controller.desconectar();
    super.dispose();
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
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Text(
                widget.lock.name,
                style: AppTextStyles.primaryTextStyle,
              ),
              const SizedBox(height: 5),
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
                icon: const Icon(Icons.settings),
                onPressed: () {
                  // Acción futura
                },
              ),
            ),
          ],
        ),
        body: FutureBuilder<void>(
          future: _initialization,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                children: [
                  const Spacer(),
                  ActionLockButton(
                    lock: widget.lock,
                    controller: widget.controller, // 🔥 pasamos el mismo controller
                  ),
                  const SizedBox(height: 20),
                  ValueListenableBuilder<String>(
                    valueListenable: widget.controller.modoSeleccionado,
                    builder: (context, modo, child) {
                      return Column(
                        children: [
                          Text(
                            "Modo activo",
                            style: AppTextStyles.secondaryModalStyle,
                          ),
                          Text(
                            modo,
                            style: AppTextStyles.primaryTextStyle,
                          ),
                          const SizedBox(height: 45),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ModeButton(
                                icon: Icons.back_hand,
                                label: "PATRÓN",
                                isSelected: modo == "PATRÓN",
                                onTap: () {
                                  if (widget.lock.bloqueoActivo) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('El dispositivo está bloqueado. No puedes cambiar el modo.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  widget.controller.seleccionarModo("PATRÓN");
                                  widget.controller.verificarPassword('Patron', context, widget.lock);
                                },
                              ),
                              ModeButton(
                                icon: Icons.password,
                                label: "CLAVE",
                                isSelected: modo == "CLAVE",
                                onTap: () {
                                  if (widget.lock.bloqueoActivo) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('El dispositivo está bloqueado. No puedes cambiar el modo.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  widget.controller.seleccionarModo("CLAVE");
                                  widget.controller.verificarPassword('Clave', context, widget.lock);
                                },
                              ),
                              ModeButton(
                                icon: Icons.shuffle,
                                label: "TOKEN",
                                isSelected: modo == "TOKEN",
                                onTap: () {
                                  if (widget.lock.bloqueoActivo) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('El dispositivo está bloqueado. No puedes cambiar el modo.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  widget.controller.seleccionarModo("TOKEN");
                                  widget.controller.verificarPassword('Token', context, widget.lock);
                                },
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 100),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ValueListenableBuilder<bool>(
                        valueListenable: widget.controller.mostrarBotonGrabacion,
                        builder: (context, mostrar, child) {
                          return ValueListenableBuilder<String>(
                            valueListenable: widget.controller.modoSeleccionado,
                            builder: (context, modo, child) {
                              return RecordingButton(
                                modo: modo,
                                mostrar: mostrar,
                                onPatronTap: () {
                                  widget.controller.iniciarGrabacion(context, widget.lock, "Patron");
                                },
                                onClaveTap: () {
                                  widget.controller.iniciarGrabacion(context, widget.lock, "Clave");
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 70),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}