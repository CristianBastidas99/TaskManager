import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  }) : idTarea = idTarea ?? Uuid().v4();

  // Método para serializar a Map para Firebase
  Map<String, dynamic> toMap() {
    return {
      'id_tarea': idTarea,
      'nombre_tarea': nombreTarea,
      'estado_sincronizacion': estadoSincronizacion,
      'fecha_creacion': fechaCreacion,
      'ultima_actualizacion': ultimaActualizacion,
      'usuario_creador': usuarioCreador,
      'actividades': actividades.map((actividad) => actividad.toMap()).toList(),
      if (ubicacion != null) 'ubicacion': ubicacion,
      if (notas != null) 'notas': notas,
    };
  }

  // Constructor desde Map (Firebase)
  factory Tarea.fromMap(Map<String, dynamic> map) {
    return Tarea(
      idTarea: map['id_tarea'] ?? Uuid().v4(),
      nombreTarea: map['nombre_tarea'] ?? '',
      estadoSincronizacion: map['estado_sincronizacion'] ?? "pendiente",
      fechaCreacion: (map['fecha_creacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ultimaActualizacion: (map['ultima_actualizacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      usuarioCreador: map['usuario_creador'] ?? '',
      actividades: (map['actividades'] as List<dynamic>? ?? [])
          .map((actividadMap) => Actividad.fromMap(actividadMap))
          .toList(),
      ubicacion: map['ubicacion'],
      notas: map['notas'],
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

  Actividad({
    required this.idActividad,
    required this.descripcionActividad,
    required this.estado,
    required this.horaInicio,
    required this.horaFin,
    required this.duracion,
  });

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
      idActividad: map['id_actividad'] ?? Uuid().v4(),
      descripcionActividad: map['descripcion_actividad'] ?? '',
      estado: map['estado'] ?? "pendiente",
      horaInicio: map['hora_inicio'] ?? '',
      horaFin: map['hora_fin'] ?? '',
      duracion: map['duracion'] ?? '',
    );
  }
}
