import 'package:flutter/material.dart';
import 'package:knocklock_flutter/core/colors.dart';

class CreateDialog extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController ipController;
  final VoidCallback onAdd;

  CreateDialog({
    required this.nameController,
    required this.ipController,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.backgroundDetail,
      title: Text("New Lock", style: AppTextStyles.dialogTitleTextStyle,),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: "Lock's Name", hintText: "Ej. House", labelStyle: AppTextStyles.dialogLabelTextStyle),
            style: AppTextStyles.dialogInputTextStyle,
          ),
          TextField(
            controller: ipController,
            decoration: InputDecoration(labelText: "Locks's IP", hintText: "Ej. 192.168.1.5", labelStyle: AppTextStyles.dialogLabelTextStyle),
            style: AppTextStyles.dialogInputTextStyle,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Cancel"),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black // Color del texto del botón Add
          ),
        ),
        ElevatedButton(
          onPressed: onAdd,
          style: ElevatedButton.styleFrom(
            foregroundColor: AppColors.confirmTextButton,
            backgroundColor: AppColors.confirmBackgroundButton,
            textStyle: TextStyle(fontWeight: FontWeight.bold), // Negritas al texto
            side: BorderSide(color: Colors.black), // Borde negro
          ),
          child: Text("Add"),
        ),
      ],
    );
  }
}