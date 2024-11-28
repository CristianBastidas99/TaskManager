import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'models/equipo.dart';
import 'models/usuario.dart';
import 'utils/constants.dart';
import 'services/storage_service.dart';
import 'screens/error_screen.dart';

// Importa tus pantallas
import 'screens/login_screen.dart';
import 'screens/equipo_selection_screen.dart';
import 'screens/pre_formulario_screen.dart';

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
      home: FutureBuilder<String>(
        future: getInitialRoute(),  // Obtiene la ruta inicial dependiendo del usuario y equipo
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());  // Muestra una pantalla de carga
          }

          if (snapshot.hasError) {
            return ErrorScreen();  // Si hay un error, muestra una pantalla de error
          }

          // Una vez que el Future ha terminado, navega a la ruta correspondiente
          return Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (_) {
                  if (snapshot.data == seleccionEquipoRoute) {
                    return EquipoSelectionScreen();  // Si el usuario no tiene equipo, muestra la selección
                  } else {
                    return PreFormularioScreen(equipo: settings.arguments as Equipo);  // Si tiene equipo, muestra el formulario
                  }
                },
              );
            },
          );
        },
      ),
      routes: {
        loginRoute: (context) => LoginScreen(),
        seleccionEquipoRoute: (context) => EquipoSelectionScreen(),
        preFormularioRoute: (context) => PreFormularioScreen(equipo: ModalRoute.of(context)!.settings.arguments as Equipo),
        // Otras rutas que puedas tener...
      },
    );
  }

  Future<String> getInitialRoute() async {
    // Aquí se realiza la validación para decidir la ruta
    StorageService storageService = StorageService();
    Usuario? usuario = await storageService.getConnectedUser();
    if (usuario != null) {
      if (usuario.idEquipo.isNotEmpty) {
        Map<String, dynamic>? equipoData =
            await storageService.getDocumentById('equipo', usuario.idEquipo);
        if (equipoData != null) {
          Equipo equipo = Equipo.fromMap(equipoData);
          return preFormularioRoute;  // Si el usuario tiene equipo, redirige a la pantalla de formulario
        }
      }
      return seleccionEquipoRoute;  // Si el usuario no tiene equipo, redirige a la selección de equipo
    }
    return loginRoute;  // Si no hay usuario autenticado, redirige a la pantalla de login
  }
}
