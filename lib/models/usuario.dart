import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'estadoSincronizacion .dart';

enum TipoUsuario { operario, jefeDeMina }

class Usuario {
  String id;
  String username;
  String email;
  TipoUsuario tipo;
  String idEquipo;
  EstadoSincronizacion estadoSincronizacion;

  Usuario({
    String? id,
    required this.username,
    required this.email,
    required this.tipo,
    required this.idEquipo,
    this.estadoSincronizacion = EstadoSincronizacion.pendiente,
  }) : id = id ?? Uuid().v4();

  Usuario.withoutEquipo({
    String? id,
    required this.username,
    required this.email,
    required this.tipo,
    String? idEquipo,
    this.estadoSincronizacion = EstadoSincronizacion.pendiente,
  })  : id = id ?? Uuid().v4(),
        idEquipo = idEquipo ?? '';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'tipo': tipo.toString().split('.').last,
      'id_equipo': idEquipo,
      'estado_sincronizacion': estadoSincronizacion.toString().split('.').last,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] ?? Uuid().v4(),
      username: map['username'],
      email: map['email'],
      tipo: TipoUsuario.values
          .firstWhere((e) => e.toString().split('.').last == map['tipo']),
      idEquipo: map['id_equipo'],
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
