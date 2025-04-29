import 'package:knocklock_flutter/core/imports.dart';

class TotalBlockButton extends StatefulWidget {
  const TotalBlockButton({super.key});

  @override
  State<TotalBlockButton> createState() => _TotalBlockButtonState();
}

class _TotalBlockButtonState extends State<TotalBlockButton> with TickerProviderStateMixin {
  final LockController _lockController = LockController();
  final FirestoreService _firestoreService = FirestoreService();
  late ScaleAnimationHelper _scaleAnimationHelper;
  bool bloqueoActivado = false;
  int minutosRestantes = 60;

  @override
  void initState() {
    super.initState();
    _scaleAnimationHelper = ScaleAnimationHelper(vsync: this);
  }

  @override
  void dispose() {
    _scaleAnimationHelper.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestoreService.streamLocksByUser(user.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final locks = snapshot.data!;

        final bloqueoInfo = calcularEstadoBloqueo(locks);
        bloqueoActivado = bloqueoInfo['bloqueoActivado'];
        minutosRestantes = bloqueoInfo['minutosRestantes'];

        return GestureDetector(
          onTapUp: (_) async {
            if (!bloqueoActivado) {
              _scaleAnimationHelper.triggerAnimation();
              await _lockController.bloquearTodosLosLocks();
            }
          },
          child: ScaleTransition(
            scale: _scaleAnimationHelper.scaleAnimation,
            child: Opacity(
              opacity: bloqueoActivado ? 0.6 : 1.0,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.errorBackgroundColor,
                  border: Border.all(color: AppColors.errorTextColor, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.errorTextColor, size: 40),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bloqueoActivado
                                ? 'Bloqueo Total Activado'
                                : 'Activar Bloqueo Total',
                            style: const TextStyle(
                              color: AppColors.errorTextColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            bloqueoActivado
                                ? 'Espere $minutosRestantes minutos para el desbloqueo'
                                : 'Inhabilita desbloqueos durante 1 hora',
                            style: const TextStyle(
                              color: AppColors.errorTextColor,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}