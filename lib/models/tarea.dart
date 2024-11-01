import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class Tarea {
  String idTarea;
  String nombreTarea;
  String estadoSincronizacion;
  DateTime fechaCreacion;
  DateTime ultimaActualizacion;
  String usuarioCreador;
  List<Actividad> actividades;
  String? ubicacion;
  String? notas;

  Tarea({
    String? idTarea,
    required this.nombreTarea,
    required this.estadoSincronizacion,
    required this.fechaCreacion,
    required this.ultimaActualizacion,
    required this.usuarioCreador,
    required this.actividades,
    this.ubicacion,
    this.notas,
  }) : idTarea = idTarea ?? const Uuid().v4();

  // Método para serializar a Map para Firebase
  Map<String, dynamic> toMap() {
    return {
      'id_tarea': idTarea,
      'nombre_tarea': nombreTarea,
      'estado_sincronizacion': estadoSincronizacion,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'ultima_actualizacion': ultimaActualizacion.toIso8601String(),
      'usuario_creador': usuarioCreador,
      'actividades': actividades.map((actividad) => actividad.toMap()).toList(),
      if (ubicacion != null) 'ubicacion': ubicacion,
      if (notas != null) 'notas': notas,
    };
  }

  // Constructor desde Map (Firebase)
  factory Tarea.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) {
        return date.toDate();
      } else if (date is String) {
        return DateTime.tryParse(date) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return Tarea(
      idTarea: map['id_tarea'] ?? const Uuid().v4(),
      nombreTarea: map['nombre_tarea'] ?? '',
      estadoSincronizacion: map['estado_sincronizacion'] ?? "pendiente",
      fechaCreacion: parseDate(map['fecha_creacion']),
      ultimaActualizacion: parseDate(map['ultima_actualizacion']),
      usuarioCreador: map['usuario_creador'] ?? '',
      actividades: (map['actividades'] as List<dynamic>?)
            ?.map((actividadMap) {
              // Validar que cada actividad es un mapa
              if (actividadMap is Map<String, dynamic>) {
                return Actividad.fromMap(actividadMap);
              } else {
                print('Actividad no es un mapa: $actividadMap');
                return null; // O manejar de otra manera
              }
            })
            .where((actividad) => actividad != null)
            .cast<Actividad>()
            .toList() ??
        [],
      ubicacion: map['ubicacion'],
      notas: map['notas'],
    );
  }

  String toJson() {
    return jsonEncode({
      'idTarea': idTarea,
      'nombreTarea': nombreTarea,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'ultimaActualizacion': ultimaActualizacion.toIso8601String(),
      'usuarioCreador': usuarioCreador,
      'actividades': actividades.map((a) => a.toJson()).toList(),
      'estadoSincronizacion': estadoSincronizacion,
      'ubicacion': ubicacion,
      'notas': notas,
    });
  }

  static Tarea fromJson(String source) {
    final data = json.decode(source);

    return Tarea(
      idTarea: data['idTarea'],
      nombreTarea: data['nombreTarea'],
      fechaCreacion: DateTime.parse(data['fechaCreacion']),
      ultimaActualizacion: DateTime.parse(data['ultimaActualizacion']),
      usuarioCreador: data['usuarioCreador'],
      actividades: (data['actividades'] as List)
          .map((actividad) => Actividad.fromMap(actividad))
          .toList(),
      estadoSincronizacion: data['estadoSincronizacion'],
      ubicacion: data['ubicacion'],
      notas: data['notas'],
    );
  }
}

// Clase Actividad para las actividades de la tarea
class Actividad {
  String idActividad;
  String descripcionActividad;
  String estado;
  String horaInicio;
  String horaFin;
  String duracion;
  TextEditingController horaInicioController;
  TextEditingController horaFinController;
  TextEditingController duracionController;

  Actividad({
    required this.idActividad,
    required this.descripcionActividad,
    required this.estado,
    required this.horaInicio,
    required this.horaFin,
    required this.duracion,
  })  : horaInicioController = TextEditingController(),
        horaFinController = TextEditingController(),
        duracionController = TextEditingController();

  // Método para serializar a Map para Firebase
  Map<String, dynamic> toMap() {
    return {
      'id_actividad': idActividad,
      'descripcion_actividad': descripcionActividad,
      'estado': estado,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'duracion': duracion,
    };
  }

  // Constructor desde Map (Firebase)
  factory Actividad.fromMap(Map<String, dynamic> map) {
    return Actividad(
      idActividad: map['id_actividad'] ?? const Uuid().v4(),
      descripcionActividad: map['descripcion_actividad'] ?? '',
      estado: map['estado'] ?? "pendiente",
      horaInicio: map['hora_inicio'] ?? '',
      horaFin: map['hora_fin'] ?? '',
      duracion: map['duracion'] ?? '',
    );
  }

  String toJson() {
    return jsonEncode({
      'id_actividad': idActividad,
      'descripcion_actividad': descripcionActividad,
      'estado': estado,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'duracion': duracion,
    });
  }
}
