import '../core/imports.dart';

class LockDetailScreen extends StatefulWidget {
  final Lock lock;

  const LockDetailScreen({super.key, required this.lock});

  @override
  State<LockDetailScreen> createState() => _LockDetailScreenState();
}

class _LockDetailScreenState extends State<LockDetailScreen> {
  final LockController _controller = LockController();
  late Future<void> _initialization;


  @override
  void initState() {
    super.initState();
    _controller.conectar(widget.lock.ip, widget.lock.id);
    _initialization = _controller.cargarModo(widget.lock.id);
  }

  @override
  void dispose() {
    _controller.guardarModo(widget.lock.id);
    _controller.desconectar();
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
            body: FutureBuilder<void>(
                future: _initialization,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35.0),
                    child: Column(
                      children: [
                        Spacer(),
                        ActionLockButton(
                          lock: widget.lock,
                          controller: _controller,
                        ),
                        const SizedBox(height: 20),
                        ValueListenableBuilder<String>(
                          valueListenable: _controller.modoSeleccionado,
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
                                          _controller.seleccionarModo("PATRÓN");
                                          _controller.verificarPassword(
                                              'Patron', context, widget.lock);
                                        }
                                    ),
                                    ModeButton(
                                        icon: Icons.password,
                                        label: "CLAVE",
                                        isSelected: modo == "CLAVE",
                                        onTap: () {
                                          _controller.seleccionarModo("CLAVE");
                                          _controller.verificarPassword(
                                              'Clave', context, widget.lock);
                                        }
                                    ),
                                    ModeButton(
                                        icon: Icons.shuffle,
                                        label: "TOKEN",
                                        isSelected: modo == "TOKEN",
                                        onTap: () {
                                          _controller.seleccionarModo("TOKEN");
                                          _controller.verificarPassword(
                                              'Token', context, widget.lock);
                                        }
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
                              valueListenable: _controller.mostrarBotonGrabacion,
                              builder: (context, mostrar, child) {
                                return ValueListenableBuilder<String>(
                                  valueListenable: _controller.modoSeleccionado,
                                  builder: (context, modo, child) {
                                    // Definir si realmente mostrar el botón basado en modo y mostrar
                                    bool mostrarBoton = mostrar && (modo == "PATRÓN" || modo == "CLAVE");
                                    return IgnorePointer(
                                      ignoring: !mostrarBoton,
                                      child: Opacity(
                                        opacity: mostrarBoton ? 1.0 : 0.0,
                                        child: GestureDetector(
                                          onTap: () {
                                            if (modo == "PATRÓN") {
                                              _controller.iniciarGrabacion(context, widget.lock);
                                            } else if (modo == "CLAVE") {
                                              _controller.verificarPassword('Clave', context, widget.lock);
                                            }
                                          },
                                          child: Container(
                                            height: 70.0,
                                            width: 70.0,
                                            decoration: circularBoxDecoration(
                                              color: AppColors.backgroundHelperColor,
                                            ),
                                            child: Icon(
                                              modo == "PATRÓN"
                                                  ? Icons.mic
                                                  : modo == "CLAVE"
                                                  ? Icons.dialpad
                                                  : Icons
                                                  .close, // Esto no se verá porque estará oculto en modo TOKEN
                                              color: Colors.black,
                                              size: 30,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 70),
                      ],
                    ),
                  );
                }
            )
        )
    );
  }
}
