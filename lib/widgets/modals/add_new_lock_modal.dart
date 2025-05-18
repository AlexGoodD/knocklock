import 'package:knocklock_flutter/core/imports.dart';

class AddNewLockModal extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController ipController;
  final VoidCallback onAdd;

  AddNewLockModal({
    required this.nameController,
    required this.ipController,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              top: 20.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
            ),
            decoration: BoxDecoration(
              color: AppColors.of(context).backgroundHelperColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Crear Nuevo Lock',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Crea un nuevo Lock para acceder a sus funcionalidades, desbloqueo por patrón y más',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GeneralInput(controller: nameController, label: 'Nombre del Lock'),
                  const SizedBox(height: 20),
                  GeneralInput(controller: ipController, label: 'IP del Lock'),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 340, // Ancho fijo
                    height: 50, // Alto fijo
                    child: ElevatedButton(
                      onPressed: () {
                        onAdd();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Agregar',
                        style: AppTextStyles(context).authButtonTextStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}