import '../../core/imports.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool isTestMode = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.of(context).backgroundTop,
            AppColors.of(context).backgroundBottom,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notificaciones',
                    style: AppTextStyles(context).sectionPrimaryStyle,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Administra tus alertas importantes en la app',
                    style: AppTextStyles(context).sectionSecondaryStyle,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    children: [
                      ...[
                        SwitchOptionButton(
                          icon: Icons.public_outlined,
                          title: 'Generales',
                          description: 'Activa o desactiva todas las notificaciones de la aplicación.',
                          initialValue: isTestMode,
                          onChanged: (value) {
                            setState(() {
                              isTestMode = value;
                            });
                          },
                        ),
                        SwitchOptionButton(
                          icon: Icons.public_outlined,
                          title: 'Desbloqueo éxitoso',
                          description: 'Recibe una alerta cuando un dispositivo se desbloquee correctamente.',
                          initialValue: isTestMode,
                          onChanged: (value) {
                            setState(() {
                              isTestMode = value;
                            });
                          },
                        ),
                        SwitchOptionButton(
                          icon: Icons.public_outlined,
                          title: 'Intento fallido',
                          description: 'Te notifica si alguien intenta desbloquear un dispositivo sin éxito',
                          initialValue: isTestMode,
                          onChanged: (value) {
                            setState(() {
                              isTestMode = value;
                            });
                          },
                        ),
                      ].expand((widget) => [
                        widget,
                        const SizedBox(height: 30),
                      ]).toList()
                        ..removeLast(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}