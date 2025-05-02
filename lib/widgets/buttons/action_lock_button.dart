import 'package:knocklock_flutter/core/imports.dart';

class ActionLockButton extends StatefulWidget {
  final Lock lock;
  final LockController controller;

  const ActionLockButton({
    super.key,
    required this.lock,
    required this.controller,
  });

  @override
  State<ActionLockButton> createState() => _ActionLockButtonState();
}

class _ActionLockButtonState extends State<ActionLockButton> with SingleTickerProviderStateMixin {
  late ScaleAnimationHelper _animationHelper;
  final ValueNotifier<bool> isRecording = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _animationHelper = ScaleAnimationHelper(vsync: this);

    // Asegura que se escucha el estado en Firestore si no está escuchando aún
    if (!widget.controller.segurosActivosPorLock.containsKey(widget.lock.id)) {
      widget.controller.segurosActivosPorLock[widget.lock.id] = ValueNotifier<bool>(widget.lock.seguroActivo);
      widget.controller.escucharEstadoSeguro(widget.lock.id);
    }
  }

  void _handleTap(bool seguroActivoActual) {
    if (widget.lock.bloqueoActivoManual || widget.lock.bloqueoActivoIntentos) {
      mostrarAlertaGlobal('error', 'No se puede cambiar el estado: el dispositivo está bloqueado.');
      return;
    }

    _animationHelper.triggerAnimation();

    final modo = widget.controller.modoSeleccionado.value;

    // Si el dispositivo no está asegurado, lo bloqueamos primero
    if (!seguroActivoActual) {
      widget.controller.cambiarEstadoSeguro(widget.lock.id, true);
      setState(() => isRecording.value = false);
      print('Bloqueando el dispositivo...');
      return;
    }

    // Si ya está asegurado, actuamos según el modo
    switch (modo) {
      case "CLAVE":
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => EnterPasswordModal(lockId: widget.lock.id, tipoPassword: 'Clave'),
        );
        break;

      case "TOKEN":
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => EnterPasswordModal(lockId: widget.lock.id, tipoPassword: 'Token'),
        );
        break;

      case "PATRÓN":
        if (isRecording.value) {
          widget.controller.detenerVerificacion();
          setState(() => isRecording.value = false);
          print('Deteniendo grabación...');
        } else {
          widget.controller.iniciarVerificacion(context, widget.lock);
          setState(() => isRecording.value = true);
          print('Iniciando grabación...');
        }
        break;

      default:
        print('⚠️ Modo no soportado: $modo');
    }
  }

  @override
  void dispose() {
    _animationHelper.dispose();
    isRecording.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool>? seguroNotifier = widget.controller.segurosActivosPorLock[widget.lock.id];

    if (seguroNotifier == null) {
      return const SizedBox.shrink(); // o algún placeholder si el estado no está listo
    }

    return ValueListenableBuilder<bool>(
      valueListenable: seguroNotifier,
      builder: (context, seguroActivoActual, _) {
        return GestureDetector(
          onTap: () => _handleTap(seguroActivoActual),
          child: ScaleTransition(
            scale: _animationHelper.scaleAnimation,
            child: Container(
              height: 220.0,
              width: 220.0,
              decoration: circularBoxDecoration(
                color: isRecording.value
                    ? AppColors.primaryColor
                    : AppColors.backgroundHelperColor,
              ),
              child: ValueListenableBuilder<bool>(
                valueListenable: isRecording,
                builder: (context, recording, _) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      recording
                          ? const AnimatedRecordingIcon()
                          : Icon(
                        seguroActivoActual
                            ? Icons.lock_outlined
                            : Icons.lock_open,
                        color: Colors.black,
                        size: 60.0,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        recording ? "Grabando..." : "Estado del\nDispositivo",
                        style: AppTextStyles.secondaryTextStyle.copyWith(
                          color: recording
                              ? Colors.white
                              : AppColors.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}