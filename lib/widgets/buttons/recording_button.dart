import '../../core/imports.dart';

class RecordingButton extends StatelessWidget {
  final bool mostrar;
  final VoidCallback onTap;

  const RecordingButton({
    super.key,
    required this.mostrar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool mostrarBoton = mostrar;

    return IgnorePointer(
      ignoring: !mostrarBoton,
      child: Opacity(
        opacity: mostrarBoton ? 1.0 : 0.0,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 70.0,
            width: 70.0,
            decoration: circularBoxDecoration(
              color: AppColors.of(context).backgroundHelperColor,
            ),
            child: Icon(
              Icons.mic,
              color: AppColors.of(context).primaryColor,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}