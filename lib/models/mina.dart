import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'estadoSincronizacion .dart';

class Mina {
  String id;
  String nombre;
  EstadoSincronizacion estadoSincronizacion;

  Mina({
    String? id,
    required this.nombre,
    this.estadoSincronizacion = EstadoSincronizacion.pendiente,
  }) : id = id ?? Uuid().v4();

  // Método para serializar a Map para Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'estado_sincronizacion': estadoSincronizacion.toString().split('.').last,
    };
  }

  // Constructor desde Map (Firebase)
  factory Mina.fromMap(Map<String, dynamic> map) {
    return Mina(
      id: map['id'] ?? Uuid().v4(),
      nombre: map['nombre'] ?? '',
      estadoSincronizacion: EstadoSincronizacion.values.firstWhere(
        (e) => e.toString().split('.').last == map['estado_sincronizacion'],
        orElse: () => EstadoSincronizacion.pendiente,
      ),
    );
  }

  String toJson() {
    return jsonEncode(toMap());
  }
}
