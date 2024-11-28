import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'estadoSincronizacion .dart';

class Equipo {
  String id;
  String nombre;
  String idMina;
  List<String> subEquipos;
  double horometro;
  EstadoSincronizacion estadoSincronizacion;

  Equipo({
    String? id,
    required this.nombre,
    required this.idMina,
    required this.subEquipos,
    required this.horometro,
    this.estadoSincronizacion = EstadoSincronizacion.pendiente,
  }) : id = id ?? Uuid().v4();

  // Método para serializar a Map para Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'id_mina': idMina,
      'sub_equipos': subEquipos,
      'horometro': horometro,
      'estado_sincronizacion': estadoSincronizacion.toString().split('.').last,
    };
  }

  // Constructor desde Map (Firebase)
  factory Equipo.fromMap(Map<String, dynamic> map) {
    return Equipo(
      id: map['id'] ?? Uuid().v4(),
      nombre: map['nombre'] ?? '',
      idMina: map['id_mina'] ?? '',
      subEquipos: List<String>.from(map['sub_equipos'] ?? []),
      horometro: map['horometro']?.toDouble() ?? 0.0,
      estadoSincronizacion: EstadoSincronizacion.values.firstWhere(
        (e) => e.toString().split('.').last == map['estado_sincronizacion'],
        orElse: () => EstadoSincronizacion.pendiente,
      ),
    );
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  factory Equipo.fromJson(String source) {
    return Equipo.fromMap(jsonDecode(source));
  }
}
