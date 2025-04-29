import 'package:knocklock_flutter/core/imports.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;

  void toggleScreen() async {
    setState(() {
      isContentVisible = false;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      isLogin = !isLogin;
    });

    setState(() {
      isContentVisible = true;
    });
  }

  bool isContentVisible = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedAuthScreen(
      height: isLogin ? 600 : 750,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: isContentVisible
            ? (isLogin
            ? LoginContent(onToggle: toggleScreen)
            : RegisterContent(onToggle: toggleScreen))
            : const SizedBox(), // Vacío mientras cambia
      ),
    );
  }
}