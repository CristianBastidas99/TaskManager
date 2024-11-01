import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/tarea.dart';

class StorageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isOnline = false;

  // Constructor con inicialización de conexión
  StorageService() {
    _initializeConnectivity();
    print("Inicializando StorageService");
  }

  // Método para inicializar verificación de conexión
  Future<void> _initializeConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    _updateConnectivityStatus(connectivityResult != ConnectivityResult.none);
    Connectivity().onConnectivityChanged.listen((result) {
      _updateConnectivityStatus(result != ConnectivityResult.none);
      if (_isOnline) _syncLocalTasks();
    });
    print("Conectividad $_isOnline");
  }

  void _updateConnectivityStatus(bool isOnline) {
    _isOnline = isOnline;
  }

  // Guardar tarea en Firestore si hay conexión
  Future<void> saveTaskOnline(Tarea tarea) async {
    try {
      await _firestore
          .collection('formularios_tareas')
          .doc(tarea.idTarea)
          .set(tarea.toMap());
    } catch (error) {
      print("Error al guardar en Firestore: $error");
    }
  }

  // Guardar tarea localmente usando SharedPreferences
  Future<void> saveTaskLocally(Tarea tarea) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> localTasks = prefs.getStringList('tareas') ?? [];
    localTasks.add(jsonEncode(tarea.toMap()));
    await prefs.setStringList('tareas', localTasks);
  }

  // Sincronizar tareas guardadas localmente a Firestore
  Future<void> _syncLocalTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> localTasks = prefs.getStringList('tareas') ?? [];

    for (String taskJson in localTasks) {
      final taskData = jsonDecode(taskJson);
      final Tarea tarea = Tarea.fromMap(taskData);
      tarea.estadoSincronizacion = 'sincronizada';
      try {
        await saveTaskOnline(tarea);
      } catch (error) {
        print("Error al sincronizar tarea: $error");
      }
    }

    await prefs.remove('tareas');
  }

  // Método para guardar tarea según el estado de la conexión
  Future<void> saveTask(Tarea tarea) async {
    tarea.estadoSincronizacion = _isOnline ? 'sincronizada' : 'pendiente';

    if (_isOnline) {
      await saveTaskOnline(tarea);
    } else {
      await saveTaskLocally(tarea);
    }
  }

  // Obtener el estado de conexión
  bool get isOnline => _isOnline;
}
