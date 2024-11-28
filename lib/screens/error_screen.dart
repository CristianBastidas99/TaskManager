import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ErrorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Error"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 100.0,
            ),
            SizedBox(height: 20),
            Text(
              "Hubo un error al cargar los datos. Intenta nuevamente más tarde.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Puedes agregar lógica para intentar nuevamente o redirigir
                Navigator.pushReplacementNamed(context, loginRoute);
              },
              child: Text("Intentar de nuevo"),
            ),
          ],
        ),
      ),
    );
  }
}
