import 'package:firebase_core/firebase_core.dart';

import 'core/imports.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: const MainNavigator(),
  ));
}