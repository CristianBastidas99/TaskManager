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

  // Constructor con valores automáticos
  Actividad.automatic({
    String? id,
    String? idEquipo,
    String? idLabor,
    String? idMina,
    DateTime? horaInicio,
    DateTime? horaFin,
    double? horometro,
    String? idOperario,
    String? idJefeMina,
    EstadoSincronizacion? estadoSincronizacion,
  })  : id = id ?? const Uuid().v4(),
        idEquipo = idEquipo ?? 'defaultEquipo',
        idLabor = idLabor ?? 'defaultLabor',
        idMina = idMina ?? 'defaultMina',
        horaInicio = horaInicio ?? DateTime.now(),
        horaFin = horaFin ?? DateTime.now().add(Duration(hours: 1)),
        horometro = horometro ?? 0.0,
        idOperario = idOperario ?? 'defaultOperario',
        idJefeMina = idJefeMina ?? 'defaultJefeMina',
        estadoSincronizacion = estadoSincronizacion ?? EstadoSincronizacion.pendiente,
        horometroController = TextEditingController(text: (horometro ?? 0.0).toString()),
        horaInicioController = TextEditingController(text: (horaInicio ?? DateTime.now()).toString()),
        horaFinController = TextEditingController(text: (horaFin ?? DateTime.now().add(Duration(hours: 1))).toString());

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
      horaInicio: map['horaInicio'] != null
          ? DateTime.parse(map['horaInicio'].replaceAll(' ', ''))
          : DateTime.now(),
      horaFin: map['horaFin'] != null
          ? DateTime.parse(map['horaFin'].replaceAll(' ', ''))
          : DateTime.now(),
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

  // Getters and Setters
  String get getId => id;
  set setId(String id) => this.id = id;

  String get getIdEquipo => idEquipo;
  set setIdEquipo(String idEquipo) => this.idEquipo = idEquipo;

  String get getIdLabor => idLabor;
  set setIdLabor(String idLabor) => this.idLabor = idLabor;

  String get getIdMina => idMina;
  set setIdMina(String idMina) => this.idMina = idMina;

  DateTime get getHoraInicio => horaInicio;
  set setHoraInicio(DateTime horaInicio) => this.horaInicio = horaInicio;

  DateTime get getHoraFin => horaFin;
  set setHoraFin(DateTime horaFin) => this.horaFin = horaFin;

  double get getHorometro => horometro;
  set setHorometro(double horometro) => this.horometro = horometro;

  String get getIdOperario => idOperario;
  set setIdOperario(String idOperario) => this.idOperario = idOperario;

  String get getIdJefeMina => idJefeMina;
  set setIdJefeMina(String idJefeMina) => this.idJefeMina = idJefeMina;

  EstadoSincronizacion get getEstadoSincronizacion => estadoSincronizacion;
  set setEstadoSincronizacion(EstadoSincronizacion estadoSincronizacion) =>
      this.estadoSincronizacion = estadoSincronizacion;

  TextEditingController get getHorometroController => horometroController;
  set setHorometroController(TextEditingController horometroController) =>
      this.horometroController = horometroController;

  TextEditingController get getHoraInicioController => horaInicioController;
  set setHoraInicioController(TextEditingController horaInicioController) =>
      this.horaInicioController = horaInicioController;

  TextEditingController get getHoraFinController => horaFinController;
  set setHoraFinController(TextEditingController horaFinController) =>
      this.horaFinController = horaFinController;
}
