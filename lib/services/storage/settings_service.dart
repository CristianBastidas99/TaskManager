import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  /// Guarda los valores de idJefeMina, idMina e idLabor localmente con la llave 'settings'.
  Future<void> saveSettings(
      String idJefeMina, String idMina, String idLabor) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, String> settings = {
      'idJefeMina': idJefeMina,
      'idMina': idMina,
      'idLabor': idLabor,
    };
    await prefs.setString('settings', jsonEncode(settings));
  }

  /// Obtiene los valores de idJefeMina, idMina e idLabor almacenados localmente con la llave 'settings'.
  Future<Map<String, String>?> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final String? settingsJson = prefs.getString('settings');

    if (settingsJson == null) {
      return null; // Retorna null si no hay datos de configuración.
    }

    final Map<String, dynamic> settingsMap = jsonDecode(settingsJson);
    return settingsMap.map((key, value) => MapEntry(key, value as String));
  }

  /// Elimina los valores almacenados localmente con la llave 'settings'.
  Future<void> deleteSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('settings');
  }
}