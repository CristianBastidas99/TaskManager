import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Importa tus pantallas
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
//import 'screens/qr_scanner_screen.dart';
//import 'screens/task_detail_screen.dart';
//import 'screens/task_form_screen.dart';
//import 'screens/export_data_screen.dart';
//import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/login' : '/dashboard',
      routes: {
        '/login': (context) => LoginScreen(),
        '/dashboard': (context) => DashboardScreen(),
        //'/task_detail': (context) => TaskDetailScreen(tarea: ModalRoute.of(context)!.settings.arguments as Tarea),
        //'/qr_scanner': (context) => QRScannerScreen(),
        //'/task_form': (context) => TaskFormScreen(),
        //'/export_data': (context) => ExportDataScreen(),
        //'/settings': (context) => SettingsScreen(),
      },
    );
  }
}
