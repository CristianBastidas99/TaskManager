import 'package:app_tareas_conectividad_limitada/models/equipo.dart';
import 'package:app_tareas_conectividad_limitada/models/usuario.dart';
import 'package:flutter/material.dart';
import '../models/actividad.dart';
import '../models/labor.dart';
import '../services/auth_service.dart';
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

  Labor? selectedLabor;
  DateTime selectedStartTime = DateTime.now();
  DateTime selectedEndTime = DateTime.now().add(const Duration(hours: 1));
  bool isLoading = true;
  Usuario? connectedUser;
  Equipo? selectedEquipo;
  Map<String, dynamic> settings = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void reloadPage() {
    setState(() {
      isLoading = true;
    });
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Cargar datos desde almacenamiento local
      connectedUser = await StorageService().getConnectedUser();
      if (connectedUser == null) {
        throw Exception('Usuario conectado no encontrado');
      }
      final equipoData = await StorageService()
          .getDocumentById('equipo', connectedUser!.idEquipo);
      selectedEquipo = equipoData != null ? Equipo.fromMap(equipoData) : null;
      if (selectedEquipo == null) {
        throw Exception('Equipo no encontrado');
      }

      final settingsData = await StorageService().getSettings();
      if (settingsData != null) {
        settings = settingsData;
      } else {
        throw Exception('Configuración no encontrada');
      }

      final fetchedActividades =
          await StorageService().getLocalCollection('actividad');
      final fetchedLabores = await StorageService().getLocalCollection('labor');

      for (var actividad in fetchedActividades) {
        //print(actividad);
      }

      setState(() {
        // Manejando actividades
        final actividadMap = {for (var a in actividades) a.getId: a};
        for (var fetchedActividad
            in fetchedActividades.whereType<Map<String, dynamic>>()) {
          final nuevaActividad = Actividad.fromMap(fetchedActividad);
          if (nuevaActividad.getIdEquipo == selectedEquipo?.getId) {
            actividadMap[nuevaActividad.getId] =
                nuevaActividad; // Sobreescribe si el ID ya existe
          }
        }
        actividades.clear();
        actividades.addAll(actividadMap.values);

        // Manejando labores
        final laborMap = {for (var l in labores) l.getId: l};
        for (var fetchedLabor in fetchedLabores) {
          final nuevaLabor =
              Labor.fromMap(fetchedLabor as Map<String, dynamic>);
          laborMap[nuevaLabor.getId] =
              nuevaLabor; // Sobreescribe si el ID ya existe
        }
        labores.clear();
        labores.addAll(laborMap.values);

        selectedLabor = labores.firstWhere(
          (labor) => labor.getId == settings['idLabor']
        );

        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    }
  }

  Future<String> getLaborNameForActividad(Actividad actividad) async {
    try {
      final laborData =
          await StorageService().getDocumentById('labor', actividad.idLabor);
      if (laborData != null) {
        return Labor.fromMap(laborData).nombre;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener el nombre de la labor: $e')),
      );
    }
    return 'Labor no encontrada';
  }

  void _showCreateActivityModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Labor>(
                decoration: const InputDecoration(
                  labelText: 'Selecciona una labor',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
                value: selectedLabor,
                items: labores.map((labor) {
                  return DropdownMenuItem<Labor>(
                    value: labor,
                    child: Text(labor.nombre),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedLabor = value),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selectTime(context, true),
                      child: const Text('Hora de Inicio'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selectTime(context, false),
                      child: const Text('Hora de Fin'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addActivity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Agregar Actividad'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addActivity() async {
    if (selectedLabor != null && selectedStartTime.isBefore(selectedEndTime)) {
      final actividad = Actividad(
        idEquipo: selectedEquipo!.getId,
        idLabor: selectedLabor!.id,
        idMina: settings['idMina'],
        horaInicio: selectedStartTime,
        horaFin: selectedEndTime,
        horometro: 0.0,
        idOperario: connectedUser!.getId,
        idJefeMina: settings['idJefeMina'],
      );

      await StorageService()
          .saveData('actividad', actividad.getId, actividad.toMap());
      _loadData();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revisa los campos seleccionados')),
      );
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        isStartTime ? selectedStartTime : selectedEndTime,
      ),
    );
    if (pickedTime != null) {
      setState(() {
        final now = DateTime.now();
        final newTime = DateTime(
          now.year,
          now.month,
          now.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        if (isStartTime) {
          selectedStartTime = newTime;
        } else {
          selectedEndTime = newTime;
        }
      });
    }
  }

  Future<void> signOut() async {
    try {
      await AuthService().logout();
      Navigator.pushReplacementNamed(context, loginRoute); // Redirige al login
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: $e')),
      );
    }
  }

  String _formatTo12Hours(DateTime time) {
    return TimeOfDay.fromDateTime(time).format(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actividades'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: signOut, // Llama a la función de cerrar sesión
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: actividades.length,
                    itemBuilder: (context, index) {
                      final actividad = actividades[index];
                      return FutureBuilder<String>(
                        future: getLaborNameForActividad(actividad),
                        builder: (context, snapshot) {
                          final laborName =
                              snapshot.data ?? 'Cargando nombre...';
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(laborName),
                              subtitle: Text(
                                'Fecha: ${actividad.horaInicio.toLocal().toString().split(' ')[0]}\n'
                                'Hora: ${_formatTo12Hours(actividad.horaInicio)} - ${_formatTo12Hours(actividad.horaFin)}',
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () => _showCreateActivityModal(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Crear Nueva Actividad'),
                  ),
                ),
              ],
            ),
    );
  }
}
