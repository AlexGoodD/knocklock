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
    if (!widget.controller.segurosActivosPorLock.containsKey(widget.lock.id)) {
      widget.controller.segurosActivosPorLock[widget.lock.id] = ValueNotifier<bool>(widget.lock.seguroActivo);
    }
  }

  void _handleTap(bool seguroActivoActual) {
    if (widget.lock.bloqueoActivo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El dispositivo se encuentra bloqueado por 1 hora.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _animationHelper.triggerAnimation();

    if (isRecording.value) {
      // Si ya está grabando: detener grabación
      widget.controller.detenerVerificacion();
      isRecording.value = false;
    } else {
      if (!seguroActivoActual) {
        // Si el seguro está DESACTIVADO => Empezar grabación
        widget.controller.iniciarVerificacion(context, widget.lock);
        isRecording.value = true;
      } else {
        // Si el seguro está ACTIVADO => Bloquear el dispositivo
        widget.controller.cambiarEstadoSeguro(widget.lock.id, true);
        isRecording.value = false;
      }
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
    return ValueListenableBuilder<bool>(
      valueListenable: widget.controller.segurosActivosPorLock[widget.lock.id]!,
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