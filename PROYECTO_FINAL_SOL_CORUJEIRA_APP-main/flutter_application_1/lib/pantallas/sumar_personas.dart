import 'package:flutter/material.dart';
import 'package:flutter_application_1/pantallas/mapa.dart';

class Persona {
  String nombre;
  String telefono;

  Persona(this.nombre, this.telefono);
}

class PersonasScreen extends StatefulWidget {
  const PersonasScreen({super.key});

  @override
  State<PersonasScreen> createState() => _PersonasScreenState();
}

class _PersonasScreenState extends State<PersonasScreen> {
  List<Persona> personas = [];

  String busqueda = '';

  void agregarPersona() {
    TextEditingController nombreController = TextEditingController();
    TextEditingController telefonoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
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
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                if (nombreController.text.isNotEmpty &&
                    telefonoController.text.isNotEmpty) {
                  setState(() {
                    personas.add(
                      Persona(
                        nombreController.text,
                        telefonoController.text,
                      ),
                    );
                  });

                  Navigator.pop(context);
                }
              },
              child: const Text("Agregar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Persona> personasFiltradas = personas.where((persona) {
      return persona.nombre
              .toLowerCase()
              .contains(busqueda.toLowerCase()) ||
          persona.telefono.contains(busqueda);
    }).toList();

    personasFiltradas.sort(
      (a, b) => a.nombre.compareTo(b.nombre),
    );

    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: const Text("Personas"),
      ),
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
              onChanged: (texto) {
                setState(() {
                  busqueda = texto;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: personasFiltradas.length,
              itemBuilder: (context, index) {
                Persona persona = personasFiltradas[index];

                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(persona.nombre),
                  subtitle: Text(
                    persona.telefono,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        personas.remove(persona);
                      });
                    },
                  ),
                  onTap: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (context) => Mapa(
                  persona: persona,
                  ),
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