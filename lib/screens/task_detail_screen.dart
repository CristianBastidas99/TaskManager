import 'package:flutter/material.dart';
import '../models/tarea.dart';
import '../services/storage_service.dart';

class TaskDetailScreen extends StatefulWidget {
  final Tarea tarea;

  const TaskDetailScreen({Key? key, required this.tarea}) : super(key: key);

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final StorageService _storageService = StorageService();

  // Método para actualizar el estado de la actividad
  Future<void> _toggleActivityCompletion(Actividad actividad) async {
    setState(() {
      // Cambiar el estado de la actividad
      actividad.estado = (actividad.estado == 'completada') ? 'pendiente' : 'completada';
    });

    // Guardar los cambios en el StorageService
    await _storageService.saveTask(widget.tarea);

    // Mostrar mensaje de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Actividad ${actividad.estado}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la Tarea'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.tarea.nombreTarea,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Estado: ${widget.tarea.estadoSincronizacion}'),
            const SizedBox(height: 20),
            Text(
              'Descripción: ${widget.tarea.notas ?? "Sin notas"}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Actividades:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.tarea.actividades.length,
                itemBuilder: (context, index) {
                  final actividad = widget.tarea.actividades[index];
                  return ListTile(
                    title: Text(actividad.descripcionActividad),
                    subtitle: Text('Estado: ${actividad.estado}'),
                    trailing: Checkbox(
                      value: actividad.estado == 'completada',
                      onChanged: (bool? value) {
                        if (value != null) {
                          _toggleActivityCompletion(actividad);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
