import '../../core/imports.dart';

class EnterButton extends StatelessWidget {
  final bool mostrar;
  final VoidCallback onTap;

  const EnterButton({
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
              color: AppColors.backgroundHelperColor,
            ),
            child: Icon(
              Icons.dialpad,
              color: Colors.black,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}