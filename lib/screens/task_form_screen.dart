import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tarea.dart';

class TaskFormScreen extends StatefulWidget {
  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isOnline = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreTareaController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();
  final TextEditingController _notasController = TextEditingController();
  List<Actividad> _actividades = [];

  Future<void> _selectTime(
      BuildContext context, bool isFirstTime, Actividad actividad) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        if (isFirstTime) {
          actividad.horaInicio = picked.format(context);
          actividad.horaInicioController.text = picked.format(context);
        } else {
          actividad.horaFin = picked.format(context);
          actividad.horaFinController.text = picked.format(context);
        }
        _calculateDuration(actividad);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  void _checkConnectivity() async {
    Connectivity().onConnectivityChanged.listen((result) {
      _updateConnectivityStatus(result != ConnectivityResult.none);
      if (_isOnline) {
        _syncLocalTasks();
      }
    });
  }

  void _updateConnectivityStatus(bool isOnline) {
    setState(() {
      _isOnline = isOnline;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isOnline ? 'Conectado' : 'Sin conexión'),
        backgroundColor: _isOnline ? Colors.green : Colors.red,
      ),
    );
  }

  void _addActividad() {
    setState(() {
      _actividades.add(Actividad(
        idActividad: Uuid().v4(),
        descripcionActividad: '',
        estado: 'pendiente',
        horaInicio: '',
        horaFin: '',
        duracion: '',
      ));
    });
  }

  void _saveTask() async {
    if (_formKey.currentState?.validate() ?? false) {
      final nuevaTarea = Tarea(
        idTarea: Uuid().v4(),
        nombreTarea: _nombreTareaController.text,
        fechaCreacion: DateTime.now(),
        ultimaActualizacion: DateTime.now(),
        usuarioCreador: _auth.currentUser?.email ?? 'codeaunitest',
        actividades: _actividades,
        estadoSincronizacion: _isOnline ? 'sincronizada' : 'pendiente',
        ubicacion: _ubicacionController.text,
        notas: _notasController.text,
      );

      try {
        if (_isOnline) {
          await _firestore
              .collection('formularios_tareas')
              .doc(nuevaTarea.idTarea)
              .set(nuevaTarea.toMap());
        } else {
          await _saveTaskLocally(nuevaTarea);
        }
        Navigator.pop(context, nuevaTarea);
      } catch (error) {
        print("Error al guardar la tarea: $error");
        await _saveTaskLocally(nuevaTarea);
      }
    }
  }

  Future<void> _saveTaskLocally(Tarea tarea) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tareasLocales = prefs.getStringList('tareas') ?? [];
    tareasLocales.add(tarea.toJson());
    await prefs.setStringList('tareas', tareasLocales);
  }

  Future<void> _syncLocalTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tareasLocales = prefs.getStringList('tareas') ?? [];

    for (String tareaJson in tareasLocales) {
      Tarea tarea = Tarea.fromJson(tareaJson);
      try {
        await _firestore.collection('tareas').add(tarea.toMap());
      } catch (error) {
        print("Error al sincronizar tarea: $error");
      }
    }
    await prefs.remove('tareas');
  }

  void _calculateDuration(Actividad actividad) {
    if (actividad.horaInicio.isEmpty || actividad.horaFin.isEmpty) {
      return;
    }

    // Verificar si `horaInicio` y `horaFin` están en el formato correcto y sin "AM/PM"
    final startParts = actividad.horaInicio.split(" ");
    final endParts = actividad.horaFin.split(" ");

    // Asegurarse de que hay un valor de hora y una parte AM/PM
    if (startParts.length == 2 && endParts.length == 2) {
      // Extraer horas y minutos, y convertir al formato de 24 horas
      final startHourMinute = startParts[0].split(":");
      final endHourMinute = endParts[0].split(":");

      int startHour = int.parse(startHourMinute[0]);
      int startMinute = int.parse(startHourMinute[1]);
      int endHour = int.parse(endHourMinute[0]);
      int endMinute = int.parse(endHourMinute[1]);

      // Convertir AM/PM al formato de 24 horas
      if (startParts[1] == "PM" && startHour != 12) startHour += 12;
      if (startParts[1] == "AM" && startHour == 12) startHour = 0;
      if (endParts[1] == "PM" && endHour != 12) endHour += 12;
      if (endParts[1] == "AM" && endHour == 12) endHour = 0;

      // Crear DateTime para calcular la duración
      final start = DateTime(0, 0, 0, startHour, startMinute);
      final end = DateTime(0, 0, 0, endHour, endMinute);

      // Validar que `start` sea menor que `end`
      if (end.isBefore(start) || end.isAtSameMomentAs(start)) {
        setState(() {
          actividad.duracion = '';
        });
        return;
      }

      final duration = end.difference(start).inMinutes;

      // Convertir duración en horas y minutos
      final hours = duration.abs() ~/ 60;
      final minutes = duration.abs() % 60;

      setState(() {
        if (hours > 0) {
          actividad.duracion =
              "$hours horas ${minutes > 0 ? 'y $minutes minutos' : ''}";
        } else {
          actividad.duracion = "$minutes minutos";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Nueva Tarea'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreTareaController,
                decoration: InputDecoration(labelText: 'Nombre de la Tarea'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el nombre de la tarea';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ubicacionController,
                decoration: InputDecoration(labelText: 'Ubicación'),
              ),
              TextFormField(
                controller: _notasController,
                decoration: InputDecoration(labelText: 'Notas'),
              ),
              SizedBox(height: 20),
              Text(
                'Actividades',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ..._actividades.map((actividad) {
                int index = _actividades.indexOf(actividad);
                return _buildActividadForm(actividad, index);
              }).toList(),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _addActividad,
                child: Text('Agregar Actividad'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Guardar Tarea'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActividadForm(Actividad actividad, int index) {

    @override
  void dispose() {
    actividad.horaInicioController.dispose();
    actividad.horaFinController.dispose();
    super.dispose();
  }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          decoration: InputDecoration(labelText: 'Descripción de la Actividad'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, ingrese una descripción para la actividad';
            }
            return null;
          },
          onChanged: (value) =>
              setState(() => actividad.descripcionActividad = value),
        ),
        TextFormField(
          controller: actividad.horaInicioController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Hora de Inicio',
            suffixIcon: IconButton(
              icon: Icon(Icons.access_time),
              onPressed: () => _selectTime(context, true, actividad),
            ),
          ),
        ),
        TextFormField(
          controller: actividad.horaFinController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Hora de Fin',
            suffixIcon: IconButton(
              icon: Icon(Icons.access_time),
              onPressed: () => _selectTime(context, false, actividad),
            ),
          ),
        ),
        TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Duración',
            hintText: actividad.duracion,
          ),
        ),
        Divider(color: Colors.grey),
      ],
    );
  }
}
