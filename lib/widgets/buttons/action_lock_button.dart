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

class _ActionLockButtonState extends State<ActionLockButton>
    with SingleTickerProviderStateMixin {
  late ScaleAnimationHelper _animationHelper;
  bool isScaledDown = false;
  bool isRecording = false;


  @override
  void initState() {
    super.initState();
    _animationHelper = ScaleAnimationHelper(vsync: this);
  }

  void _handleTap(bool seguroActivoActual) {
    _animationHelper.toggleScale(isScaledDown);
    isScaledDown = !isScaledDown;

    if (!seguroActivoActual) {
      widget.controller.cambiarEstadoSeguro(widget.lock.id, true);
      setState(() {
        isRecording = false;
      });
    } else {
      if (isRecording) {
        widget.controller.detenerVerificacion();
      } else {
        widget.controller.iniciarVerificacion(context, widget.lock);
      }
      setState(() {
        isRecording = !isRecording;
      });
    }
  }

  @override
  void dispose() {
    _animationHelper.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.controller.seguroActivo,
      builder: (context, seguroActivoActual, _) {
        return GestureDetector(
          onTap: () => _handleTap(seguroActivoActual),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 220.0,
            width: 220.0,
            decoration: circularBoxDecoration(
              color: isRecording
                  ? AppColors.primaryColor
                  : AppColors.backgroundHelperColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isRecording
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
                  isRecording ? "Grabando..." : "Estado del\nDispositivo",
                  style: AppTextStyles.secondaryTextStyle.copyWith(
                    color: isRecording
                        ? Colors.white
                        : AppColors.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}