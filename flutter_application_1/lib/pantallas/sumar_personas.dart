import 'dart:typed_data'; // Manejo de bytes para la Web
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pantallas/mapa.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart';    
import 'package:image_picker/image_picker.dart'; 

class Persona {
  final String id; 
  final String nombre;
  final String telefono;
  final String fotoUrl; 

  Persona(this.id, this.nombre, this.telefono, this.fotoUrl);
}

class PersonasScreen extends StatefulWidget {
  const PersonasScreen({super.key});

  @override
  State<PersonasScreen> createState() => _PersonasScreenState();
}

class _PersonasScreenState extends State<PersonasScreen> {
  List<Persona> personas = [];
  String busqueda = '';
  final ImagePicker _picker = ImagePicker(); 

  @override
  void initState() {
    super.initState();
    _cargarPersonasDesdeFirebase(); 
  }

  Future<void> _cargarPersonasDesdeFirebase() async {
    try {
      String? supervisorUid = FirebaseAuth.instance.currentUser?.uid;
      if (supervisorUid == null) return;

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('personas_assigned') // Nota: Asegurar el nombre exacto de la colección
          .where('supervisor_id', isEqualTo: supervisorUid)
          .get();

      List<Persona> listaTemporal = [];
      for (var doc in snapshot.docs) {
        String nombre = doc['nombre'] ?? '';
        String fotoDefecto = "https://ui-avatars.com/api/?name=${Uri.encodeComponent(nombre)}&background=3B6E8C&color=fff&size=128";

        final datos = doc.data() as Map<String, dynamic>;
        String urlFinal = datos.containsKey('foto_url') && datos['foto_url'] != null && datos['foto_url'].toString().isNotEmpty
            ? datos['foto_url']
            : fotoDefecto;

        listaTemporal.add(
          Persona(doc.id, nombre, doc['telefono'] ?? '', urlFinal),
        );
      }

      setState(() {
        personas = listaTemporal;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar personas: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void agregarPersona() {
    TextEditingController nombreController = TextEditingController();
    TextEditingController telefonoController = TextEditingController();
    
    // Para la web guardamos la imagen en formato bytes o como URL interna Blob
    Uint8List? webImageBytes;
    String rutaImagenSeleccionada = ''; 

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( 
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Agregar persona"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // DETECTOR CLIC PARA ELEGIR FOTO
                  GestureDetector(
                    onTap: () async {
                      // ImagePicker en la web abre el selector de archivos nativo de la PC
                      final XFile? imagen = await _picker.pickImage(source: ImageSource.gallery);
                      if (imagen != null) {
                        var bytes = await imagen.readAsBytes();
                        setDialogState(() {
                          webImageBytes = bytes;
                          rutaImagenSeleccionada = imagen.path; // En web esto devuelve un blob://link
                        });
                      }
                    },
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blueGrey.shade100,
                      backgroundImage: webImageBytes != null
                          ? MemoryImage(webImageBytes!) // SOLUCIÓN WEB: Carga la imagen desde la memoria RAM
                          : null,
                      child: webImageBytes == null
                          ? const Icon(Icons.camera_alt, size: 35, color: Colors.blueGrey)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text("Toca para elegir foto de tu PC", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 15),
                  TextField(
                    controller: nombreController,
                    decoration: const InputDecoration(labelText: "Nombre", hintText: "Ingrese el nombre"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: telefonoController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: "Teléfono", hintText: "Ingrese el número"),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () async {
                    if (nombreController.text.isNotEmpty && nombreController.text.isNotEmpty) {
                      try {
                        String? supervisorUid = FirebaseAuth.instance.currentUser?.uid;
                        if (supervisorUid == null) throw Exception("No hay sesión activa");

                        String nombre = nombreController.text.trim();
                        String telefono = telefonoController.text.trim();
                        
                        String fotoAGuardar = rutaImagenSeleccionada.isNotEmpty
                            ? rutaImagenSeleccionada
                            : "https://ui-avatars.com/api/?name=${Uri.encodeComponent(nombre)}&background=3B6E8C&color=fff&size=128";

                        DocumentReference docRef = await FirebaseFirestore.instance.collection('personas_asignadas').add({
                          'nombre': nombre,
                          'telefono': telefono,
                          'foto_url': fotoAGuardar, 
                          'supervisor_id': supervisorUid, 
                          'fecha_creacion': DateTime.now(),
                        });

                        setState(() {
                          personas.add(Persona(docRef.id, nombre, telefono, fotoAGuardar));
                        });

                        if (mounted) Navigator.pop(context);

                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.redAccent),
                          );
                        }
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
      return persona.nombre.toLowerCase().contains(busqueda.toLowerCase()) || persona.telefono.contains(busqueda);
    }).toList();

    personasFiltradas.sort((a, b) => a.nombre.compareTo(b.nombre));

    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(title: const Text("Personas")),
      body: Column(
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
              onChanged: (texto) => setState(() => busqueda = texto),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: personasFiltradas.length,
              itemBuilder: (context, index) {
                Persona persona = personasFiltradas[index];
                String avatarAlternativo = "https://ui-avatars.com/api/?name=${Uri.encodeComponent(persona.nombre)}&background=3B6E8C&color=fff&size=128";

                // En la web las imágenes locales se guardan como links de memoria que empiezan con "blob:" o "data:"
                bool esUrlWebValida = persona.fotoUrl.startsWith('http') || persona.fotoUrl.startsWith('blob:');

                return ListTile(
                  leading: ClipOval(
                    child: esUrlWebValida
                      ? Image.network(
                          persona.fotoUrl,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Image.network(avatarAlternativo, width: 40, height: 40),
                        )
                      : Image.network(avatarAlternativo, width: 40, height: 40), // Si falla va al fallback seguro
                  ),
                  title: Text(persona.nombre),
                  subtitle: Text(persona.telefono),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      try {
                        await FirebaseFirestore.instance.collection('personas_asignadas').doc(persona.id).delete();
                        setState(() => personas.remove(persona));
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Mapa(persona: persona)));
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