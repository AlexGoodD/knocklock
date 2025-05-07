import 'package:knocklock_flutter/core/imports.dart';

class BlockAllButton extends StatefulWidget {
  const BlockAllButton({super.key});

  @override
  State<BlockAllButton> createState() => _BlockAllButtonState();
}

class _BlockAllButtonState extends State<BlockAllButton> with SingleTickerProviderStateMixin {
  late final ScaleAnimationHelper _animationHelper;
  final lockController = LockController();

  @override
  void initState() {
    super.initState();
    _animationHelper = ScaleAnimationHelper(vsync: this);
  }

  @override
  void dispose() {
    _animationHelper.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        _animationHelper.triggerAnimation();
        await lockController.activarSeguroTodosLosLocks();

        if (context.mounted) {
          mostrarAlertaGlobal('exito', 'Todos tus candados han sido bloqueados.');
        }
      },
      child: ScaleTransition(
        scale: _animationHelper.scaleAnimation,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Icon(Icons.lock_outline, color: Colors.white, size: 50),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Bloquear Todos',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Aplica bloqueo a todos los\ndispositivos activos simultáneamente.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}