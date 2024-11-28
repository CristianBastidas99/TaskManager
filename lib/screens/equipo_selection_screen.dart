import 'package:flutter/material.dart';
import '../models/equipo.dart';
import '../models/usuario.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
//import '../widgets/qr_scanner_widget.dart';

class EquipoSelectionScreen extends StatefulWidget {
  const EquipoSelectionScreen({Key? key}) : super(key: key);

  @override
  _EquipoSelectionScreenState createState() => _EquipoSelectionScreenState();
}

class _EquipoSelectionScreenState extends State<EquipoSelectionScreen> {
  List<Equipo> equipos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEquipos();
  }

  Future<void> fetchEquipos() async {
    try {
      final fetchedEquipos =
          await StorageService().getLocalCollection('equipo');
      //print(fetchedEquipos);
      setState(() {
        equipos = fetchedEquipos.map((dynamic value) {
          return Equipo.fromMap(value as Map<String, dynamic>);
        }).toList();
        isLoading = false;
      });
      print(equipos);
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar equipos: $e')),
      );
    }
  }

  Future<void> onEquipoSelected(Equipo equipo) async {
    Usuario? user = await StorageService().getConnectedUser();
    if (user != null) {
      user.idEquipo = equipo.id;
      StorageService().saveData('usuario', user.id, user.toMap());
      StorageService().saveConnectedUser(user);
      Navigator.pushNamed(context, preFormularioRoute, arguments: equipo);
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

/*
  void onScanQR() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerWidget(
          onScanned: (String qrData) async {
            try {
              final equipo = await StorageService().getEquipoByQR(qrData);
              if (equipo != null) {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text('Detalles del Equipo'),
                          subtitle: Text(
                              'Nombre: ${equipo.nombre}\nHorómetro: ${equipo.horometro}'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(
                              context,
                              '/detalleEquipo',
                              arguments: equipo,
                            );
                          },
                        ),
                        ListTile(
                          title: Text('Llenar Formulario'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(
                              context,
                              '/preFormulario',
                              arguments: equipo,
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Equipo no encontrado en la base de datos.')),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al procesar QR: $e')),
              );
            }
          },
        ),
      ),
    );
  }
*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Selección de Equipo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              // onPressed: onScanQR,
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: signOut, // Llama a la función de cerrar sesión
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando equipos...', style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : equipos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.warning, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No hay equipos disponibles.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: equipos.length,
                  itemBuilder: (context, index) {
                    final equipo = equipos[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () => onEquipoSelected(equipo),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.blue.shade100,
                                child: Text(
                                  equipo.nombre[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      equipo.nombre,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Subequipos: ${equipo.subEquipos.join(', ')}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
