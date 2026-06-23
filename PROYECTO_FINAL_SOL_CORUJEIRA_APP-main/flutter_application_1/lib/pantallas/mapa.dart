import 'package:flutter/material.dart';
import 'package:flutter_application_1/pantallas/sumar_personas.dart';

class Mapa extends StatelessWidget {
  final Persona persona;

  const Mapa({
    super.key,
    required this.persona,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(persona.nombre),
      ),
      body: Center(
        child: Text(
          'Teléfono: ${persona.telefono}',
        ),
      ),
    );
  }
}