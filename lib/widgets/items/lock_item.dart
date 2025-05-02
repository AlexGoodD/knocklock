import '../../core/imports.dart';

class LockItem extends StatefulWidget {
  final String name;
  final String ip;
  final Lock lock;
  final LockController lockController;

  const LockItem({
    super.key,
    required this.name,
    required this.ip,
    required this.lock,
    required this.lockController,
  });

  @override
  _LockItemState createState() => _LockItemState();
}

class _LockItemState extends State<LockItem> {
  void _toggleSeguro(bool nuevoEstado) async {
    await widget.lockController.cambiarEstadoSeguro(widget.lock.id, nuevoEstado);
  }

  @override
  Widget build(BuildContext context) {
    final isConnectedNotifier =
        widget.lockController.dispositivosConectados[widget.lock.id] ??
            ValueNotifier<bool>(false);

    return ValueListenableBuilder<bool>(
      valueListenable: isConnectedNotifier,
      builder: (context, isConnected, child) {
        return GestureDetector(
          onTap: isConnected
              ? () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LockDetailScreen(
                  lock: widget.lock,
                  controller: widget.lockController,
                ),
              ),
            );
            if (mounted) setState(() {});
          }
              : null,
          child: Opacity(
            opacity: isConnected ? 1.0 : 0.5,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
              decoration: BoxDecoration(
                color: AppColors.backgroundHelperColor,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: ValueListenableBuilder<bool>(
                          valueListenable: widget.lockController
                              .segurosActivosPorLock[widget.lock.id]!,
                          builder: (context, seguroActivo, _) {
                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                    opacity: animation, child: child);
                              },
                              child: Icon(
                                seguroActivo
                                    ? Icons.lock_outlined
                                    : Icons.lock_open,
                                key: ValueKey(seguroActivo),
                                color: AppColors.backgroundHelperColor,
                                size: 20,
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 35),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isConnected
                              ? AppColors.trueConnectionColor
                              : AppColors.falseConnectionColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.ip,
                    style: AppTextStyles.lockItemDescriptionStyle,
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    widget.name,
                    style: AppTextStyles.lockItemTitleStyle,
                    textAlign: TextAlign.left,
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: widget.lockController.segurosActivosPorLock[widget.lock.id]!,
                    builder: (context, seguroActivo, _) {
                      return Switch(
                        value: seguroActivo,
                        onChanged: (widget.lock.bloqueoActivoManual || widget.lock.bloqueoActivoIntentos || !isConnected)
                            ? null
                            : (nuevoEstado) => _toggleSeguro(nuevoEstado),
                        activeColor: AppColors.backgroundHelperColor,
                        activeTrackColor: AppColors.primaryColor,
                        inactiveThumbColor: AppColors.backgroundHelperColor,
                        inactiveTrackColor: AppColors.secondaryColor,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}