import 'package:knocklock_flutter/core/imports.dart';

class SwitchOptionButton extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? description;
  final bool? value;           // Valor externo (modo controlado)
  final bool? initialValue;    // Valor inicial si no se controla externamente
  final ValueChanged<bool> onChanged;

  const SwitchOptionButton({
    Key? key,
    required this.icon,
    required this.title,
    this.description,
    this.value,
    this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<SwitchOptionButton> createState() => _SwitchOptionButtonState();
}

class _SwitchOptionButtonState extends State<SwitchOptionButton> {
  late bool internalValue;

  bool get isControlled => widget.value != null;

  @override
  void initState() {
    super.initState();
    internalValue = widget.initialValue ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final switchValue = isControlled ? widget.value! : internalValue;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 0),
          ),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.HelperBorderColor),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Container(
            width: 35,
            height: 45,
            decoration: BoxDecoration(
              color: AppColors.helperColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: Icon(widget.icon, color: AppColors.primaryColor),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: AppTextStyles.primaryModalStyle),
                Text(widget.description ?? '', style: AppTextStyles.secondaryModalStyle),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.75,
            child: Switch(
              value: switchValue,
              onChanged: (val) {
                if (!isControlled) {
                  setState(() {
                    internalValue = val;
                  });
                }
                widget.onChanged(val);
              },
              activeColor: AppColors.backgroundHelperColor,
              activeTrackColor: AppColors.primaryColor,
              inactiveThumbColor: AppColors.backgroundHelperColor,
              inactiveTrackColor: AppColors.secondaryColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}