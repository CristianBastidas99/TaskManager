import 'package:flutter/material.dart';
import '../models/actividad.dart';
import '../models/labor.dart';
import '../models/usuario.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class ActividadesScreen extends StatefulWidget {
  const ActividadesScreen({Key? key}) : super(key: key);

  @override
  _ActividadesScreenState createState() => _ActividadesScreenState();
}

class _ActividadesScreenState extends State<ActividadesScreen> {
  final List<Actividad> actividades = [];
  final List<Labor> labores = [];
  final List<Usuario> operarios = [];

  Labor? selectedLabor;
  DateTime selectedStartTime = DateTime.now();
  DateTime selectedEndTime = DateTime.now().add(const Duration(hours: 1));
  int totalHoras = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      // Cargar datos desde almacenamiento local
      final fetchedActividades =
          await StorageService().getLocalCollection('actividad');
      final fetchedLabores = await StorageService().getLocalCollection('labor');
      final fetchedOperarios =
          await StorageService().getLocalCollection('usuario');

      setState(() {
        actividades
            .addAll(fetchedActividades.map((data) => Actividad.fromMap(data)));
        labores.addAll(fetchedLabores.map((data) => Labor.fromMap(data)));
        operarios.addAll(fetchedOperarios.map((data) => Usuario.fromMap(data)));
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al cargar datos: $e')));
    }
  }

  void onAddActivity() {
    // Validaciones para la actividad
    if (selectedLabor != null && totalHoras <= 12) {
      final newActividad = Actividad(
        idLabor: selectedLabor!.id,
        horaInicio: selectedStartTime,
        horaFin: selectedEndTime,
      );
      // Guardar actividad en la BD local
      StorageService().saveData('actividad',newActividad.id, newActividad.toMap());
      setState(() {
        actividades.add(newActividad);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Por favor, verifica los campos antes de continuar.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actividades del Operario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Función de cerrar sesión aquí
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Actividades del Día',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: actividades.length,
                            itemBuilder: (context, index) {
                              final actividad = actividades[index];
                              return ListTile(
                                title: Text(actividad.labor.nombre),
                                subtitle: Text(
                                    'Hora de inicio: ${actividad.horaInicio} - Hora de fin: ${actividad.horaFin}'),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<Labor>(
                            decoration: const InputDecoration(
                              labelText: 'Labor',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                            ),
                            value: selectedLabor,
                            items: labores.map((labor) {
                              return DropdownMenuItem<Labor>(
                                value: labor,
                                child: Text(labor.nombre),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => selectedLabor = value);
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.fromDateTime(
                                          selectedStartTime),
                                    ).then((value) {
                                      if (value != null) {
                                        setState(() {
                                          selectedStartTime = DateTime(
                                            selectedStartTime.year,
                                            selectedStartTime.month,
                                            selectedStartTime.day,
                                            value.hour,
                                            value.minute,
                                          );
                                        });
                                      }
                                    });
                                  },
                                  child:
                                      const Text('Seleccionar Hora de Inicio'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.fromDateTime(
                                          selectedEndTime),
                                    ).then((value) {
                                      if (value != null) {
                                        setState(() {
                                          selectedEndTime = DateTime(
                                            selectedEndTime.year,
                                            selectedEndTime.month,
                                            selectedEndTime.day,
                                            value.hour,
                                            value.minute,
                                          );
                                        });
                                      }
                                    });
                                  },
                                  child: const Text('Seleccionar Hora de Fin'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: onAddActivity,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Agregar Actividad'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
