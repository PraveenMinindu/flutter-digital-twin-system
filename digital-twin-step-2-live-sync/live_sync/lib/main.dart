import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'features/live_sync/presentation/screens/live_map_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const Step2LiveSyncApp());
}

class Step2LiveSyncApp extends StatelessWidget {
  const Step2LiveSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LiveMapScreen(),
    );
  }
}
