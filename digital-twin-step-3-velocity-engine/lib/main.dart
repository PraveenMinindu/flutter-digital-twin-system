import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'features/velocity_engine/presentation/controllers/velocity_controller.dart';
import 'features/velocity_engine/presentation/screens/velocity_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VelocityController(),
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 39, 64, 227)),
          useMaterial3: true,
        ),
        home: const VelocityScreen(),
      ),
    );
  }
}
