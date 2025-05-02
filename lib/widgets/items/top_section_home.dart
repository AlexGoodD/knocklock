import '../../core/imports.dart';

class TopSectionHome extends StatelessWidget {
  final String firstName;
  final VoidCallback onAddLock;
  final void Function(int index)? onNavigateTo; // Callback para navegación

  const TopSectionHome({
    super.key,
    required this.firstName,
    required this.onAddLock,
    this.onNavigateTo, // Recibe el callback
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Hola ', style: AppTextStyles.primaryTextStyle),
                          Text('$firstName',
                              style: AppTextStyles.primaryTextStyle),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Bienvenido de vuelta',
                        style: TextStyle(
                            color: AppColors.primaryColor, fontSize: 14),
                      ),
                    ],
                  ),
                  ButtonAddLock(onPressed: onAddLock),
                ],
              ),
              const SizedBox(height: 20),
              LatestLogCard(
                lockController: LockController(),
                onPressed: () {
                  onNavigateTo?.call(1);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}