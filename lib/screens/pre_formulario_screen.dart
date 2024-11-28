import 'package:flutter/material.dart';
import '../models/equipo.dart';
import '../models/mina.dart';
import '../models/usuario.dart';
import '../models/labor.dart';
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

      setState(() {
        jefesMina.addAll(
          fetchedJefesMina.values
              .skip(1)
              .map((value) => Usuario.fromMap(value as Map<String, dynamic>))
              .where(
                  (usuario) => usuario.getTipo == TipoUsuario.jefeDeMina),
        );
        minas.addAll(fetchedMinas.values
            .skip(1)
            .map((value) => Mina.fromMap(value as Map<String, dynamic>)));
        labores.addAll(fetchedLabores.values
            .skip(1)
            .map((value) => Labor.fromMap(value as Map<String, dynamic>)));
            if (operario != null) {
              selectedOperario = operario;
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

  void onContinue() {
    if (selectedJefeMina != null &&
        selectedMina != null &&
        selectedLabor != null) {
      Navigator.pushNamed(
        context,
        actividadesRoute,
        arguments: {
          'equipo': widget.equipo,
          'jefeMina': selectedJefeMina,
          'mina': selectedMina,
          'labor': selectedLabor,
        },
      );
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
        title: const Text('Formulario Previo'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Operario: ${selectedOperario?.getUsername ?? ''}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  Text('Equipo: ${widget.equipo.nombre}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Usuario>(
                    decoration: const InputDecoration(
                      labelText: 'Jefe de Mina',
                      border: OutlineInputBorder(),
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
                      border: OutlineInputBorder(),
                    ),
                    value: selectedMina,
                    items: minas.map((mina) {
                      return DropdownMenuItem<Mina>(
                        value: mina,
                        child: Text(mina.nombre),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => selectedMina = value),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Labor>(
                    decoration: const InputDecoration(
                      labelText: 'Labor',
                      border: OutlineInputBorder(),
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
                  const Spacer(),
                  ElevatedButton(
                    onPressed: onContinue,
                    child: const Text('Continuar'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
