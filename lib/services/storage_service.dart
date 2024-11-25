import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

/// Servicio de almacenamiento que soporta sincronización entre datos locales y en línea.
/// Utiliza Firebase Firestore para almacenamiento en línea y SharedPreferences para almacenamiento local.
class StorageService<T> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final collections = ['actividad', 'equipo', 'labor', 'mina', 'usuario'];
  bool _isOnline = false; // Estado de conectividad

  /// Constructor que inicializa el servicio y verifica la conectividad.
  StorageService() {
    _initializeConnectivity();
    print("Inicializando StorageService");
  }

  /// Inicializa la conectividad y escucha cambios en el estado de la red.
  Future<void> _initializeConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    _updateConnectivityStatus(connectivityResult != ConnectivityResult.none);

    // Escucha los cambios de conectividad y sincroniza datos si está en línea.
    Connectivity().onConnectivityChanged.listen((result) {
      _updateConnectivityStatus(result != ConnectivityResult.none);
      if (_isOnline) {
        _syncLocalData(); // Sincroniza datos pendientes si hay conexión.
        updateAllLocalDatabases(); // Actualiza todas las bases de datos locales.
      }
    });
    print("Conectividad $_isOnline");
  }

  /// Actualiza el estado de conectividad.
  void _updateConnectivityStatus(bool isOnline) {
    _isOnline = isOnline;
  }

  /// Guarda datos en Firestore y actualiza su estado en el almacenamiento local.
  Future<void> saveDataOnline(
      String collection, String id, Map<String, dynamic> data) async {
    try {
      // Guarda el documento en Firestore.
      await _firestore.collection(collection).doc(id).set(data);

      // Marca los datos como sincronizados localmente.
      data['estado_sincronizacion'] = 'sincronizada';
      await _updateLocalData('sync_$collection', id, data);
    } catch (error) {
      print("Error al guardar en Firestore: $error");
    }
  }

  /// Guarda o actualiza datos localmente utilizando SharedPreferences.
  Future<void> saveDataLocally(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> localData = prefs.getStringList(key) ?? [];

    // Busca si el dato ya existe para actualizarlo.
    final index = localData.indexWhere((item) {
      final existingData = jsonDecode(item);
      return existingData['id'] == data['id'];
    });

    if (index != -1) {
      localData[index] = jsonEncode(data); // Actualiza el dato existente.
    } else {
      localData.add(jsonEncode(data)); // Agrega el dato si no existe.
    }

    await prefs.setStringList(key, localData);
  }

  /// Sincroniza los datos locales pendientes con Firestore si hay conexión a internet.
  Future<void> _syncLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('sync_'));

    // Itera sobre las claves que almacenan datos pendientes de sincronización.
    for (String key in keys) {
      final List<String> localData = prefs.getStringList(key) ?? [];

      for (String dataJson in localData) {
        final data = jsonDecode(dataJson);
        if (data['estado_sincronizacion'] == 'pendiente') {
          try {
            // Intenta guardar el dato pendiente en Firestore.
            await saveDataOnline(
                key.replaceFirst('sync_', ''), data['id'], data);
          } catch (error) {
            print("Error al sincronizar dato: $error");
          }
        }
      }
    }
  }

  /// Actualiza un dato local específico o lo agrega si no existe.
  Future<void> _updateLocalData(
      String key, String id, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> localData = prefs.getStringList(key) ?? [];

    // Busca el dato local por su ID.
    final index = localData.indexWhere((item) {
      final existingData = jsonDecode(item);
      return existingData['id'] == id;
    });

    if (index != -1) {
      localData[index] = jsonEncode(data); // Actualiza el dato existente.
    } else {
      localData.add(jsonEncode(data)); // Agrega el dato si no existe.
    }

    await prefs.setStringList(key, localData);
  }

  /// Actualiza la base de datos local con los datos de Firestore.
  Future<void> updateLocalDatabaseFromFirestore(String collection) async {
    try {
      // Obtiene todos los documentos de la colección en Firestore.
      final querySnapshot = await _firestore.collection(collection).get();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id; // Asegúrate de incluir el ID en los datos.

        // Guarda o actualiza los datos localmente.
        await _updateLocalData('sync_$collection', doc.id, data);
      }
    } catch (error) {
      print(
          "Error al actualizar la base de datos local desde Firestore: $error");
    }
  }

  /// Actualiza las bases de datos locales para todas las colecciones especificadas.
  Future<void> updateAllLocalDatabases() async {
    for (String collection in collections) {
      await updateLocalDatabaseFromFirestore(collection);
    }
  }

  /// Inyecta los datos de prueba directamente en Firestore sin realizar validaciones.
  Future<void> injectTestData() async {
    try {
      print('Inyectando datos de prueba en Firestore...');
      // Carga los datos de prueba desde un archivo JSON.
      final String jsonString =
          await rootBundle.loadString('lib/json/datos_de_prueba.json');
      print(jsonString);
      final Map<String, dynamic> testData = jsonDecode(jsonString);

      // Recorre las colecciones en los datos de prueba.
      for (String collection in testData.keys) {
        // Obtiene los datos de la colección específica del archivo JSON.
        final List<dynamic> items = testData[collection];

        // Itera sobre cada elemento en la colección.
        for (var item in items) {
          // Inyecta directamente el documento en Firestore.
          await _firestore
              .collection(collection)
              .doc(item['id'])
              .set(item, SetOptions(merge: true));
        }
      }

      print('Datos de prueba inyectados con éxito en Firestore.');
    } catch (e) {
      // Captura cualquier error que ocurra durante la inyección y lo registra en la consola.
      print('Error al inyectar datos de prueba en Firestore: $e');
    }
  }

  /// Devuelve una colección específica almacenada localmente como un Map.
  Future<Map<String, dynamic>> getLocalCollection(String collection) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? localData = prefs.getStringList('sync_$collection');

    if (localData == null || localData.isEmpty) {
      return {}; // Retorna un Map vacío si no hay datos almacenados.
    }

    // Convierte los datos de JSON a Map<String, dynamic>.
    final Map<String, dynamic> collectionMap = {
      for (var item in localData)
        jsonDecode(item)['id']: jsonDecode(item) // Clave: ID del documento.
    };

    return collectionMap;
  }

  /// Busca un documento por ID en una colección específica almacenada localmente.
  Future<Map<String, dynamic>?> getDocumentById(
      String collection, String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? localData = prefs.getStringList('sync_$collection');

    if (localData == null || localData.isEmpty) {
      return null; // Retorna null si no hay datos en la colección.
    }

    // Busca el documento por ID.
    for (var item in localData) {
      final data = jsonDecode(item);
      if (data['id'] == id) {
        return data; // Retorna el documento si coincide el ID.
      }
    }

    return null; // Retorna null si no se encuentra el documento.
  }

  /// Busca un usuario por email en la colección 'usuario' almacenada localmente.
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? localData = prefs.getStringList('sync_usuario');

    if (localData == null || localData.isEmpty) {
      return null; // Retorna null si no hay datos en la colección.
    }

    // Busca el usuario por email.
    for (var item in localData) {
      final data = jsonDecode(item);
      if (data['email'] == email) {
        return data; // Retorna el usuario si coincide el email.
      }
    }

    return null; // Retorna null si no se encuentra el usuario.
  }

  /// Guarda los datos tanto localmente como en Firestore, dependiendo del estado de conectividad.
  Future<void> saveData(
      String collection, String id, Map<String, dynamic> data) async {
    data['id'] = id; // Asegúrate de incluir el ID en los datos.
    await saveDataLocally('sync_$collection', data);

    if (_isOnline) {
      await saveDataOnline(
          collection, id, data); // Guarda en línea si hay conexión.
    }
  }

  /// Devuelve el estado de conectividad.
  bool get isOnline => _isOnline;
}
