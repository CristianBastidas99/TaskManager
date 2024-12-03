import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
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

  /// Devuelve una colección específica almacenada localmente como un Map.
  Future<List<dynamic>> getLocalCollection(String collection) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? localData = prefs.getStringList('sync_$collection');

    if (localData == null || localData.isEmpty) {
      return []; // Retorna una lista vacía si no hay datos almacenados.
    }

    // Omite el primer valor de localData y retorna el resto como una lista dinámica.
    final List<dynamic> collectionList =
        localData.skip(1).map((item) => jsonDecode(item)).toList();

    return collectionList;
  }

   /// Actualiza un dato local específico o lo agrega si no existe.
  Future<void> updateLocalData(
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
}
