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
        color: AppColors.of(context).backgroundHelperColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.of(context).helperBorderColor),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Container(
            width: 35,
            height: 45,
            decoration: BoxDecoration(
              color: AppColors.of(context).helperColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: Icon(widget.icon, color: AppColors.of(context).primaryColor),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: AppTextStyles(context).primaryModalStyle),
                Text(widget.description ?? '', style: AppTextStyles(context).secondaryModalStyle),
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
              activeColor: AppColors.of(context).backgroundHelperColor,
              activeTrackColor: AppColors.of(context).primaryColor,
              inactiveThumbColor: AppColors.of(context).backgroundHelperColor,
              inactiveTrackColor: AppColors.of(context).secondaryColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}