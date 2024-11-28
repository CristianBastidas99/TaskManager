
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'models/equipo.dart';
import 'models/usuario.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';
import 'services/storage_service.dart';

// Importa tus pantallas
import 'screens/login_screen.dart';
import 'screens/equipo_selection_screen.dart';
import 'screens/pre_formulario_screen.dart';
import 'screens/actividades_screen.dart';

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
      home: SplashScreen(), // Cambia initialRoute por una pantalla inicial
      routes: {
        loginRoute: (context) => LoginScreen(),
        seleccionEquipoRoute: (context) => EquipoSelectionScreen(),
        preFormularioRoute: (context) => PreFormularioScreen(equipo: ModalRoute.of(context)!.settings.arguments as Equipo),
        actividadesRoute: (context) => ActividadesScreen(),
      },
    );
  }

  Future<void> checkUserAndNavigate(BuildContext context) async {
    StorageService storageService = StorageService();
    Usuario? usuario = await storageService.getConnectedUser();
    if (usuario != null) {
      print(usuario.toMap());
      if (usuario.idEquipo != '') {
        Map<String, dynamic>? equipoData =
            await storageService.getDocumentById('equipo', usuario.idEquipo);
        if (equipoData != null) {
          Equipo equipo = Equipo.fromMap(equipoData);
          Navigator.pushNamed(context, preFormularioRoute, arguments: equipo);
        }
      } else {
        Navigator.pushReplacementNamed(context, seleccionEquipoRoute);
      }
    }
  }
}