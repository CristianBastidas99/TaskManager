import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_tareas_conectividad_limitada/models/usuario.dart';

class ConnectedUserService {

  /// Busca el email de un usuario por su username, lo guarda en 'connected_user' y devuelve el email.
  Future<String?> getEmailAndSaveConnectedUser(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? localData = prefs.getStringList('sync_usuario');

    if (localData == null || localData.isEmpty) {
      return null; // Retorna null si no hay datos en la colección.
    }

    // Busca el usuario por username.
    for (var item in localData) {
      final data = jsonDecode(item);
      if (data['username'] == username) {
        // Guarda el usuario en la colección 'connected_user'.
        await prefs.setString('connected_user', jsonEncode(data));
        //await saveConnectedUser(Usuario.fromJson(data));
        return data['email']; // Retorna el email si coincide el username.
      }
    }

    return null; // Retorna null si no se encuentra el usuario.
  }

  /// Guarda un usuario localmente con la llave 'connected_user'.
  Future<void> saveConnectedUser(Usuario user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('connected_user', jsonEncode(user.toJson()));
  }

  /// Busca en la base de datos local a connected_user y lo cachea con el modelo Usuario.
  Future<Usuario?> getConnectedUser(cachedConnectedUser) async {
    if (cachedConnectedUser != null) {
      return cachedConnectedUser; // Retorna el usuario cacheado si existe.
    }

    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString('connected_user');

    if (userJson == null) {
      return null; // Retorna null si no hay usuario conectado.
    }

    cachedConnectedUser = Usuario.fromJson(jsonDecode(userJson)); // Cachea el usuario.
    return cachedConnectedUser;
  }
}