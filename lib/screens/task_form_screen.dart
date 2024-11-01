import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/tarea.dart';
import '../services/storage_service.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key});

  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreTareaController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();
  final TextEditingController _notasController = TextEditingController();
  final List<Actividad> _actividades = [];
  final StorageService _storageService = StorageService();

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
  }

  void _addActividad() {
    setState(() {
      _actividades.add(Actividad(
        idActividad: const Uuid().v4(),
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
        idTarea: const Uuid().v4(),
        nombreTarea: _nombreTareaController.text,
        fechaCreacion: DateTime.now(),
        ultimaActualizacion: DateTime.now(),
        usuarioCreador: _storageService.isOnline
            ? (_auth.currentUser?.email ?? 'unknown')
            : 'codeaunitest',
        actividades: _actividades,
        estadoSincronizacion:
            _storageService.isOnline ? 'sincronizada' : 'pendiente',
        ubicacion: _ubicacionController.text,
        notas: _notasController.text,
      );

      await _storageService.saveTask(nuevaTarea);
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
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
          actividad.duracionController.text = '';
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
          actividad.duracionController.text =
              "$hours horas ${minutes > 0 ? 'y $minutes minutos' : ''}";
        } else {
          actividad.duracion = "$minutes minutos";
          actividad.duracionController.text = "$minutes minutos";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nueva Tarea'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreTareaController,
                decoration:
                    const InputDecoration(labelText: 'Nombre de la Tarea'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el nombre de la tarea';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ubicacionController,
                decoration: const InputDecoration(labelText: 'Ubicación'),
              ),
              TextFormField(
                controller: _notasController,
                decoration: const InputDecoration(labelText: 'Notas'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Actividades',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ..._actividades.map((actividad) {
                int index = _actividades.indexOf(actividad);
                return _buildActividadForm(actividad, index);
              }),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _addActividad,
                child: const Text('Agregar Actividad'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Guardar Tarea'),
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
      actividad.duracionController.dispose();
      super.dispose();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          decoration:
              const InputDecoration(labelText: 'Descripción de la Actividad'),
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
              icon: const Icon(Icons.access_time),
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
              icon: const Icon(Icons.access_time),
              onPressed: () => _selectTime(context, false, actividad),
            ),
          ),
        ),
        TextFormField(
          controller: actividad.duracionController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Duración',
            hintText: actividad.duracion,
          ),
        ),
        const Divider(color: Colors.blue),
      ],
    );
  }
}
