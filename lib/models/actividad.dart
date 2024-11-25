import 'dart:convert';
import 'package:app_tareas_conectividad_limitada/models/estadoSincronizacion%20.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Actividad {
  String id;
  String idEquipo;
  String idLabor;
  String idMina;
  DateTime horaInicio;
  DateTime horaFin;
  double horometro;
  String idOperario;
  String idJefeMina;
  EstadoSincronizacion estadoSincronizacion;
  TextEditingController horometroController;
  TextEditingController horaInicioController;
  TextEditingController horaFinController;

  Actividad({
    String? id,
    required this.idEquipo,
    required this.idLabor,
    required this.idMina,
    required this.horaInicio,
    required this.horaFin,
    this.horometro = 0.0,
    required this.idOperario,
    required this.idJefeMina,
    this.estadoSincronizacion = EstadoSincronizacion.pendiente,
  })  : id = id ?? const Uuid().v4(),
        horometroController = TextEditingController(text: '0'),
        horaInicioController =
            TextEditingController(text: horaInicio.toString()),
        horaFinController = TextEditingController(text: horaFin.toString());

  // Método para serializar a Map para Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_equipo': idEquipo,
      'id_labor': idLabor,
      'id_mina': idMina,
      'hora_inicio': horaInicio.toIso8601String(),
      'hora_fin': horaFin.toIso8601String(),
      'horometro': horometro,
      'id_operario': idOperario,
      'id_jefe_mina': idJefeMina,
      'estado_sincronizacion': estadoSincronizacion.toString().split('.').last,
    };
  }

  // Constructor desde Map (Firebase)
  factory Actividad.fromMap(Map<String, dynamic> map) {
    return Actividad(
      id: map['id'] ?? const Uuid().v4(),
      idEquipo: map['id_equipo'] ?? '',
      idLabor: map['id_labor'] ?? '',
      idMina: map['id_mina'] ?? '',
      horaInicio: DateTime.parse(map['hora_inicio']),
      horaFin: DateTime.parse(map['hora_fin']),
      horometro: (map['horometro'] as num?)?.toDouble() ?? 0.0,
      idOperario: map['id_operario'] ?? '',
      idJefeMina: map['id_jefe_mina'] ?? '',
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
