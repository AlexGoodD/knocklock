import 'package:knocklock_flutter/core/imports.dart';

Future<String?> mostrarDialogoTexto(
    BuildContext context,
    String titulo,
    String valorInicial, {
      required String label,
    }) async {
  final controller = TextEditingController(text: valorInicial);

  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: const BorderSide(color: Colors.grey, width: 1.0),
      ),
      title: Text(
        titulo,
        style: const TextStyle(color: Colors.black),
      ),
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.1,
        width: MediaQuery.of(context).size.width * 0.8,
        child: GeneralInput(
          controller: controller,
          label: label,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Colors.black),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, controller.text.trim()),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Guardar',
                style: TextStyle(color: AppColors.backgroundHelperColor),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Future<bool> mostrarDialogoConfirmacion(BuildContext context, String mensaje) async {
  return await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: const BorderSide(color: Colors.grey, width: 1.0),
      ),
      title: const Text(
        'Confirmar',
        style: TextStyle(color: Colors.black),
      ),
      content: Text(
        mensaje,
        style: const TextStyle(color: Colors.black87),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Colors.black),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: const Text(
            'Eliminar',
            style: TextStyle(color: AppColors.backgroundHelperColor),
          ),
        ),
      ],
    ),
  ) ?? false;
}