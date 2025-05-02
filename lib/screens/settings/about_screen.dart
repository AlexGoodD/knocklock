import '../../core/imports.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundTop,
            AppColors.backgroundBottom,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _CustomAppBar(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Acerca de Nosotros',
                      style: AppTextStyles.sectionPrimaryStyle,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Consulta la información general de la aplicación, versión actual, políticas y medios de contacto.',
                      style: AppTextStyles.sectionSecondaryStyle,
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Section(
                        title: 'Versión de la aplicación',
                        content: 'Versión 1.2.3 - Abril 2025',
                      ),
                      SizedBox(height: 15),
                      Section(
                        title: 'Descripción del sistema',
                        content:
                        'KnockLock es un sistema de seguridad que permite desbloquear puertas mediante patrones personalizados de golpes, ofreciendo una alternativa práctica y segura a los métodos tradicionales.',
                      ),
                      SizedBox(height: 15),
                      Section(
                        title: 'Misión',
                        content:
                        'Proveer un método de acceso inteligente, intuitivo y seguro para situaciones donde las contraseñas o biometría no son viables.',
                      ),
                      SizedBox(height: 15),
                      Section(
                        title: 'Visión',
                        content:
                        'Convertirse en una solución líder en accesos físicos inteligentes, adaptable a distintos entornos residenciales y comerciales.',
                      ),
                      SizedBox(height: 15),
                      Section(
                        title: 'Equipo',
                        items: [
                          'Brayan Vallejo Solis – Integración de comunicación Wi-Fi',
                          'Diego Alonso Noriega Bañuelos – Seguridad y validación de accesos vía Firestore',
                          'Edwin Manuel Guerrero Martínez – Testing y pruebas de usuario',
                          'Emmanuel Alejandro Chavarría Buendía – Líder de Proyecto & Desarrollo de App',
                          'Guillermo Vladimir Flores Báez – Implementación de hardware (Arduino y sensores)',
                          'Jorge Benito Mireles Mendoza – Documentación técnica y soporte',
                          'Marcelo Treviño Juárez – UI/UX y diseño de interfaz móvil',
                          'Victor Gerardo Villarreal Montero – Programación del algoritmo de verificación de patrones',
                        ],
                      ),
                      SizedBox(height: 15),
                      SizedBox(height: 15),
                      Section(
                        title: 'Contacto y soporte',
                        items: [
                          'Correo: soporte@knocklock.com',
                        ],
                      ),
                      SizedBox(height: 35),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomAppBar extends StatelessWidget {
  const _CustomAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kToolbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}