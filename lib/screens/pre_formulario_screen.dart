import 'package:flutter/material.dart';
import '../models/equipo.dart';
import '../models/mina.dart';
import '../models/usuario.dart';
import '../models/labor.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class PreFormularioScreen extends StatefulWidget {
  final Equipo equipo;

  const PreFormularioScreen({Key? key, required this.equipo}) : super(key: key);

  @override
  _PreFormularioScreenState createState() => _PreFormularioScreenState();
}

class _PreFormularioScreenState extends State<PreFormularioScreen> {
  final List<Usuario> jefesMina = [];
  final List<Mina> minas = [];
  final List<Labor> labores = [];

  Usuario? selectedOperario;
  Usuario? selectedJefeMina;
  Mina? selectedMina;
  Labor? selectedLabor;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      // Cargar datos de almacenamiento local
      final fetchedJefesMina =
          await StorageService().getLocalCollection('usuario');
      final fetchedMinas = await StorageService().getLocalCollection('mina');
      final fetchedLabores = await StorageService().getLocalCollection('labor');
      final Usuario? operario = await StorageService().getConnectedUser();
      final settings = await StorageService().getSettings();

      setState(() {
        jefesMina.addAll(
          fetchedJefesMina
              .map((value) => Usuario.fromMap(value as Map<String, dynamic>))
              .where((usuario) => usuario.getTipo == TipoUsuario.jefeDeMina),
        );
        minas.addAll(fetchedMinas
            .map((value) => Mina.fromMap(value as Map<String, dynamic>)));
        labores.addAll(fetchedLabores
            .map((value) => Labor.fromMap(value as Map<String, dynamic>)));
        if (operario != null) {
          selectedOperario = operario;
        }
        if (settings != null) {
          final jefeMinaData = settings['idJefeMina'] != null
              ? StorageService()
                  .getDocumentById('usuario', settings['idJefeMina']!)
              : null;
          final minaData = settings['idMina'] != null
              ? StorageService().getDocumentById('mina', settings['idMina']!)
              : null;
          final laborData = settings['idLabor'] != null
              ? StorageService().getDocumentById('labor', settings['idLabor']!)
              : null;

          if (jefeMinaData != null) {
            selectedJefeMina =
                Usuario.fromMap(jefeMinaData as Map<String, dynamic>);
          }
          if (minaData != null) {
            selectedMina = Mina.fromMap(minaData as Map<String, dynamic>);
          }
          if (laborData != null) {
            selectedLabor = Labor.fromMap(laborData as Map<String, dynamic>);
          }
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
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

  void onContinue() {
    if (selectedJefeMina != null &&
        selectedMina != null &&
        selectedLabor != null) {
      StorageService().saveSettings(
        selectedJefeMina!.id,
        selectedMina!.id,
        selectedLabor!.id,
      );
      Navigator.pushReplacementNamed(context, actividadesRoute);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Por favor, selecciona todos los campos antes de continuar.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Formulario Previo',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: signOut, // Llama a la función de cerrar sesión
        ),
      ],
    ),
    body: isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
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
                        Text(
                          'Operario: ${selectedOperario?.getUsername ?? 'Sin asignar'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        StreamBuilder<DateTime>(
                            stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
                            builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                    return Text(
                                        'Fecha y Hora: ${snapshot.data!.toLocal().toString().split('.')[0]}',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                        ),
                                    );
                                } else {
                                    return const Text(
                                        'Cargando fecha y hora...',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                        ),
                                    );
                                }
                            },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Equipo: ${widget.equipo.nombre}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
                      children: [
                        DropdownButtonFormField<Usuario>(
                          decoration: const InputDecoration(
                            labelText: 'Jefe de Mina',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                          ),
                          value: selectedJefeMina,
                          items: jefesMina.map((usuario) {
                            return DropdownMenuItem<Usuario>(
                              value: usuario,
                              child: Text(usuario.username),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => selectedJefeMina = value),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<Mina>(
                          decoration: const InputDecoration(
                            labelText: 'Mina',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                          ),
                          value: selectedMina,
                          items: minas.map((mina) {
                            return DropdownMenuItem<Mina>(
                              value: mina,
                              child: Text(mina.nombre),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => selectedMina = value),
                        ),
                        const SizedBox(height: 16),
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
                          onChanged: (value) =>
                              setState(() => selectedLabor = value),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: onContinue,
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
                  child: const Text('Continuar'),
                ),
              ],
            ),
          ),
  );
}

}
