import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'package:image_save/image_save.dart';
import '../models/tarea.dart';
import '../services/storage_service.dart';
import 'dart:typed_data';

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
      actividad.estado = (actividad.estado == 'completada') ? 'pendiente' : 'completada';
    });
    await _storageService.saveTask(widget.tarea);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Actividad ${actividad.estado}'),
      ),
    );
  }

  // Método para generar el código QR y mostrar el diálogo
  Future<void> _showQRCodeDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Código QR de la Tarea"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data: widget.tarea.idTarea,
                size: 200.0,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _saveQRCodeAsImage,
                icon: const Icon(Icons.download),
                label: const Text("Guardar QR"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar"),
            ),
          ],
        );
      },
    );
  }

  // Método para guardar el QR como imagen en la galería usando image_gallery_saver
  Future<void> _saveQRCodeAsImage() async {
    try {
      final qrValidationStatus = QrPainter(
        data: widget.tarea.idTarea,
        version: QrVersions.auto,
        gapless: true,
        color: Colors.black,
        emptyColor: Colors.white,
      );

      final picData = await qrValidationStatus.toImageData(2048, format: ui.ImageByteFormat.png);

      if (picData != null) {
        // Guardar la imagen como archivo temporal
        final Uint8List pngBytes = picData.buffer.asUint8List();
        final success = await ImageSave.saveImage(
            pngBytes,
            "${widget.tarea.idTarea}.png", // Asegúrate de incluir la extensión
            albumName: "Tareas" // Nombre del álbum en el que guardar la imagen
        );

        if (success != null && success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("QR guardado en la galería")),
          );
        } else {
          throw Exception("No se pudo guardar la imagen");
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar el QR: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la Tarea'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: _showQRCodeDialog,
            tooltip: 'Ver QR de la Tarea',
          ),
        ],
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
