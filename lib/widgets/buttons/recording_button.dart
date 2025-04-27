import '../../core/imports.dart';

class RecordingButton extends StatelessWidget {
  final String modo;
  final bool mostrar;
  final VoidCallback onPatronTap;
  final VoidCallback onClaveTap;

  const RecordingButton({
    super.key,
    required this.modo,
    required this.mostrar,
    required this.onPatronTap,
    required this.onClaveTap,
  });

  @override
  Widget build(BuildContext context) {
    bool mostrarBoton = mostrar && (modo == "PATRÓN" || modo == "CLAVE");

    return IgnorePointer(
      ignoring: !mostrarBoton,
      child: Opacity(
        opacity: mostrarBoton ? 1.0 : 0.0,
        child: GestureDetector(
          onTap: () {
            if (modo == "PATRÓN") {
              onPatronTap();
            } else if (modo == "CLAVE") {
              onClaveTap();
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
                  : Icons.close,
              color: Colors.black,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}