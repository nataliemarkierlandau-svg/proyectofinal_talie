import 'package:flutter/material.dart';
import 'package:flutter_application_1/pantallas/sumar_personas.dart';

class Bienvenida extends StatelessWidget {
  final String username;
  final String mail;

  const Bienvenida({
    super.key,
    required this.username,
    required this.mail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Ya ingresaste $username',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center, // Centra el texto por si el nombre es largo
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PersonasScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey, // Color de fondo
                foregroundColor: Colors.lightGreen[100], // Color del texto y de los iconos
                elevation: 5, // Sombra del botón
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24), // Espaciado interno
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // Bordes redondeados
                ),
              ),
              child: const Text(
                "¡Empecemos!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}