import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/tarea.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isOnline = true;
  late Future<List<Tarea>> _tareasFuture;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _tareasFuture = _fetchTareas(); // Inicializa el futuro
  }

  // Chequea conectividad
  void _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    _updateConnectivityStatus(connectivityResult != ConnectivityResult.none);

    Connectivity().onConnectivityChanged.listen((result) {
      _updateConnectivityStatus(result != ConnectivityResult.none);
    });

    // Verifica que Firestore esté respondiendo
    try {
      await FirebaseFirestore.instance.collection('test').doc('testDoc').get();
    } catch (error) {
      _updateConnectivityStatus(false);
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
  Future<List<Tarea>> _fetchTareas() async {
    try {
      final snapshot = await _firestore.collection('formularios_tareas').get();
      return snapshot.docs.map((doc) => Tarea.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error al obtener tareas: $e');
      return []; // Retorna una lista vacía en caso de error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
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
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menú',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Escanear QR'),
              onTap: () => Navigator.pushNamed(context, '/qr_scanner'),
            ),
            ListTile(
              leading: const Icon(Icons.file_download),
              title: const Text('Exportar datos'),
              onTap: () => Navigator.pushNamed(context, '/export_data'),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Ajustes'),
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
      ),
      body: Center(
        child: FutureBuilder<List<Tarea>>(
          future: _tareasFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('No hay tareas disponibles.');
            }

            final tareas = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: tareas.length,
                    itemBuilder: (context, index) {
                      final tarea = tareas[index];
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
                          Navigator.pushNamed(
                            context,
                            '/task_detail',
                            arguments: tarea,
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/task_form');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.add, size: 24),
                      label: const Text("Crear Tarea"),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
