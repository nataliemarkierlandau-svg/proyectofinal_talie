import 'package:flutter/material.dart';
import 'package:flutter_application_1/pantallas/mapa.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart';    

class Persona {
  String id; 
  String nombre;
  String telefono;

  Persona({required this.id, required this.nombre, required this.telefono});
}

class PersonasScreen extends StatefulWidget {
  const PersonasScreen({super.key});

  @override
  State<PersonasScreen> createState() => _PersonasScreenState();
}

class _PersonasScreenState extends State<PersonasScreen> {
  List<Persona> personas = [];
  String busqueda = '';
  bool _subiendoDatos = false; 
  bool _cargandoPantalla = true; // <--- NUEVO: Para mostrar una carga al iniciar

  @override
  void initState() {
    super.initState();
    _cargarPersonasDesdeFirebase(); // <--- NUEVO: Trae los datos apenas abre la pantalla
  }

  // --- NUEVA FUNCIÓN: TRAE LAS PERSONAS DE INTERNET ---
  Future<void> _cargarPersonasDesdeFirebase() async {
    try {
      String? supervisorUid = FirebaseAuth.instance.currentUser?.uid;
      if (supervisorUid == null) return;

      // Buscamos en Firestore solo las personas que le pertenecen a este supervisor
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('personas_asignadas')
          .where('supervisor_id', isEqualTo: supervisorUid)
          .get();

      List<Persona> listaTemporal = [];
      for (var doc in snapshot.docs) {
        listaTemporal.add(
          Persona(
            id: doc.id,
            nombre: doc['nombre'] ?? '',
            telefono: doc['telefono'] ?? '',
          ),
        );
      }

      setState(() {
        personas = listaTemporal;
        _cargandoPantalla = false; // Apaga la carga inicial
      });
    } catch (e) {
      setState(() {
        _cargandoPantalla = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar personas: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  // --- FUNCIÓN PARA AGREGAR PERSONA A FIREBASE ---
  void agregarPersona() {
    TextEditingController nombreController = TextEditingController();
    TextEditingController telefonoController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) {
        return StatefulBuilder( 
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Agregar persona"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nombreController,
                    decoration: const InputDecoration(
                      labelText: "Nombre",
                      hintText: "Ingrese el nombre",
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: telefonoController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Teléfono",
                      hintText: "Ingrese el número",
                    ),
                  ),
                ],
              ),
              actions: _subiendoDatos
                  ? [const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()))]
                  : [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancelar"),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (nombreController.text.isNotEmpty && telefonoController.text.isNotEmpty) {
                            
                            setDialogState(() {
                              _subiendoDatos = true; 
                            });

                            try {
                              String? supervisorUid = FirebaseAuth.instance.currentUser?.uid;
                              if (supervisorUid == null) throw Exception("No hay sesión activa");

                              DocumentReference docRef = await FirebaseFirestore.instance.collection('personas_asignadas').add({
                                'nombre': nombreController.text.trim(),
                                'telefono': telefonoController.text.trim(),
                                'supervisor_id': supervisorUid, 
                                'fecha_creacion': DateTime.now(),
                              });

                              setState(() {
                                personas.add(
                                  Persona(
                                    id: docRef.id,
                                    nombre: nombreController.text.trim(),
                                    telefono: telefonoController.text.trim(),
                                  ),
                                );
                              });

                              if (mounted) Navigator.pop(context); 

                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.redAccent),
                                );
                              }
                            } finally {
                              setDialogState(() {
                                _subiendoDatos = false; 
                              });
                            }
                          }
                        },
                        child: const Text("Agregar"),
                      ),
                    ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Persona> personasFiltradas = personas.where((persona) {
      return persona.nombre.toLowerCase().contains(busqueda.toLowerCase()) ||
          persona.telefono.contains(busqueda);
    }).toList();

    personasFiltradas.sort((a, b) => a.nombre.compareTo(b.nombre));

    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: const Text("Personas"),
      ),
      body: _cargandoPantalla
          ? const Center(child: CircularProgressIndicator(color: Colors.white)) // Muestra carga si está leyendo de Firebase
          : Column(
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Buscar persona o teléfono",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (texto) {
                      setState(() {
                        busqueda = texto;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: personasFiltradas.isEmpty
                      ? const Center(child: Text("No hay personas asignadas", style: TextStyle(color: Colors.white70, fontSize: 16)))
                      : ListView.builder(
                          itemCount: personasFiltradas.length,
                          itemBuilder: (context, index) {
                            Persona persona = personasFiltradas[index];

                            return ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                              title: Text(persona.nombre),
                              subtitle: Text(persona.telefono),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  try {
                                    await FirebaseFirestore.instance.collection('personas_asignadas').doc(persona.id).delete();
                                    setState(() {
                                      personas.remove(persona);
                                    });
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error al eliminar: $e'), backgroundColor: Colors.redAccent),
                                      );
                                    }
                                  }
                                },
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Mapa(persona: persona),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: agregarPersona,
        child: const Icon(Icons.add),
      ),
    );
  }
}