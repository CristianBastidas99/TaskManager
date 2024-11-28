import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/equipo.dart';
import '../models/usuario.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _navigate(context);
    return Scaffold(
      body: Center(child: CircularProgressIndicator()), // Indicador de carga
    );
  }

  void _navigate(BuildContext context) async {
    StorageService storageService = StorageService();
    Usuario? usuario = await storageService.getConnectedUser();

    if (FirebaseAuth.instance.currentUser == null) {
      Navigator.pushReplacementNamed(
          context, loginRoute); // Sin usuario autenticado
      return;
    }

    if (usuario != null && usuario.idEquipo.isNotEmpty) {
      Map<String, dynamic>? equipoData =
          await storageService.getDocumentById('equipo', usuario.idEquipo);

      if (equipoData != null) {
        Equipo equipo = Equipo.fromMap(equipoData);
        Navigator.pushReplacementNamed(context, preFormularioRoute,
            arguments: equipo);
        return;
      }
    }
    Navigator.pushReplacementNamed(
        context, seleccionEquipoRoute); // Usuario sin equipo
  }
}
