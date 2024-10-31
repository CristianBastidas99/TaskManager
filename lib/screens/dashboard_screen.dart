import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';

import '../models/tarea.dart'; // Asegúrate de importar la clase Tarea

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isOnline = true;
  List<Tarea> _tareas = [];

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _fetchTareas();
  }

  // Chequea conectividad
  void _checkConnectivity() async {
    // Verifica la conectividad de red
    var connectivityResult = await Connectivity().checkConnectivity();
    _updateConnectivityStatus(connectivityResult != ConnectivityResult.none);

    // Escucha cambios en la conectividad de red
    Connectivity().onConnectivityChanged.listen((result) {
      _updateConnectivityStatus(result != ConnectivityResult.none);
    });

    // Verifica que Firestore esté respondiendo
    try {
      // Intento de lectura de un documento de prueba en Firestore
      await FirebaseFirestore.instance.collection('test').doc('testDoc').get();
      print("Firestore está respondiendo.");
    } catch (error) {
      print("Error al conectar con Firestore: $error");
      _updateConnectivityStatus(
          false); // Actualiza estado de conectividad si falla
    }
  }

  void _updateConnectivityStatus(bool isOnline) {
    setState(() {
      _isOnline = isOnline;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isOnline ? 'Conectado' : 'Sin conexión'),
        backgroundColor: _isOnline ? Colors.green : Colors.red,
      ),
    );
  }

  // Cierra sesión
  void _logout() async {
    if (_isOnline) {
      await _auth.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  // Obtiene las tareas desde Firestore
  void _fetchTareas() async {
    final snapshot = await _firestore.collection('formularios_tareas').get();
    setState(() {
      _tareas = snapshot.docs.map((doc) => Tarea.fromMap(doc.data())).toList();
    });
  }

  // Crea una tarea de ejemplo en Firestore
  void _createExampleTarea() async {
    final nuevaTarea = Tarea(
      idTarea: Uuid().v4(),
      nombreTarea: 'Inspección de equipo',
      fechaCreacion: DateTime.now(),
      ultimaActualizacion: DateTime.now(),
      usuarioCreador: _auth.currentUser?.email ?? 'codeaunitest',
      actividades: [
        Actividad(
          idActividad: Uuid().v4(),
          descripcionActividad: 'Revisión de cables',
          estado: 'pendiente',
          horaInicio: '08:30',
          horaFin: '09:00',
          duracion: '30 mins',
        ),
      ],
      estadoSincronizacion: 'pendiente',
      ubicacion: 'Planta A',
      notas: 'Revisar nuevamente en 3 meses',
    );

    print(nuevaTarea.toMap());

    await _firestore
        .collection('formularios_tareas')
        .doc(nuevaTarea.idTarea)
        .set(nuevaTarea.toMap());

    // Recarga las tareas después de añadir una nueva
    _fetchTareas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Cerrar sesión',
          ),
        ],
        backgroundColor: _isOnline ? Colors.blue : Colors.grey,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menú',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.qr_code_scanner),
              title: Text('Escanear QR'),
              onTap: () => Navigator.pushNamed(context, '/qr_scanner'),
            ),
            ListTile(
              leading: Icon(Icons.file_download),
              title: Text('Exportar datos'),
              onTap: () => Navigator.pushNamed(context, '/export_data'),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Ajustes'),
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _tareas.length,
                itemBuilder: (context, index) {
                  final tarea = _tareas[index];
                  return ListTile(
                    title: Text(tarea.nombreTarea),
                    subtitle: Text(
                      'Creado por: ${tarea.usuarioCreador} - Estado: ${tarea.estadoSincronizacion}',
                    ),
                    trailing: Icon(Icons.check_circle,
                        color: tarea.estadoSincronizacion == 'pendiente'
                            ? Colors.grey
                            : Colors.green),
                    onTap: () {
                      // Aquí puedes navegar a una pantalla con más detalles de la tarea
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _createExampleTarea,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Background color
                  foregroundColor: Colors.white, // Text color
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text("Crear Nueva Tarea"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
