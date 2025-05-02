import '../../core/imports.dart';

class LockDetailScreen extends StatefulWidget {
  final Lock lock;
  final LockController controller;

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
        resizeToAvoidBottomInset: false,
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
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) => LockDetailModal(
                      lock: widget.lock,
                      controller: widget.controller,
                    ),                  );
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
                    controller: widget.controller,
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
                                  if (widget.lock.bloqueoActivoManual || widget.lock.bloqueoActivoIntentos) {
                                    mostrarAlertaGlobal('error', 'No se puede cambiar el estado: el dispositivo está bloqueado.');
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
                                  if (widget.lock.bloqueoActivoManual || widget.lock.bloqueoActivoIntentos) {
                                    mostrarAlertaGlobal('error', 'No se puede cambiar el estado: el dispositivo está bloqueado.');
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
                                  if (widget.lock.bloqueoActivoManual || widget.lock.bloqueoActivoIntentos) {
                                    mostrarAlertaGlobal('error', 'No se puede cambiar el estado: el dispositivo está bloqueado.');
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
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: ValueListenableBuilder<String>(
                        valueListenable: widget.controller.modoSeleccionado,
                        builder: (context, modo, child) {
                          return ValueListenableBuilder<bool>(
                            valueListenable: widget.controller.mostrarBotonGrabacion,
                            builder: (context, mostrar, _) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (modo == "PATRÓN")
                                    RecordingButton(
                                      mostrar: mostrar,
                                      onTap: () {
                                        widget.controller.iniciarGrabacion(context, widget.lock, "Patron");
                                      },
                                    ),
                                  if (modo == "CLAVE")
                                    EnterButton(
                                      mostrar: mostrar,
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          backgroundColor: Colors.transparent,
                                          isScrollControlled: true,
                                          builder: (context) => NewPasswordModal(lockId: widget.lock.id),
                                        );
                                      },
                                    ),
                                  if (modo == "TOKEN")
                                    EnterButton(
                                      IconName: Icons.shuffle,
                                      mostrar: mostrar,
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          backgroundColor: Colors.transparent,
                                          isScrollControlled: true,
                                          builder: (context) => TokenModal(lockId: widget.lock.id),
                                        );
                                      },
                                    ),
                                ],
                              );
                            },
                          );
                        },
                    ),
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