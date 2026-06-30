import 'package:flutter/material.dart';

class InformacionScreen extends StatelessWidget {
  const InformacionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey, // Fondo base de la app
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            width: 280,
            height: 520,
            decoration: BoxDecoration(
              color: const Color(0xFF98B4CE), // Celeste/azul grisáceo del boceto
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.black87, width: 2.5),
            ),
            child: Column(
              children: [
                // Margen superior ahora que no está la flecha para que el título respire
                const SizedBox(height: 35),
                
                // TÍTULO "BIENVENIDO/A A FUGA DE MENTES"
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text(
                    "BIENVENIDO/A\nA FUGA DE MENTES",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // RECUADRO INTERNO CON SCROLL CONFIGURADO
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6EEF4), // Fondo claro del texto
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.black54, width: 2),
                      ),
                      padding: const EdgeInsets.all(15.0),
                      // Usamos Scrollbar con padding para desplazar la barra a la derecha
                      child: RawScrollbar(
                        thumbColor: Colors.black38,
                        radius: const Radius.circular(10),
                        thickness: 4,
                        padding: const EdgeInsets.only(right: 6), // Mueve la barra a la derecha sin tocar el borde
                        child: const SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Padding(
                            padding: EdgeInsets.only(right: 14.0), // Separa el texto de la barrita para que no se superpongan
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Nuestro proyecto busca ofrecer un sistema de ayuda en caso de que una persona se pierda mientras está en la vía pública.\n\n"
                                  "Está dirigido a instituciones como geriátricos o escuelas alternativas donde necesitan un seguimiento más específico.\n\n"
                                  "Para evitar esto, se presenta una operación de rastreo que identifica movimientos fuera de lo normal en lo que respecta al usuario.\n\n"
                                  "El proyecto estará acompañado por una aplicación móvil que al iniciar sesión consultará el tipo de usuario al que se quiere rastrear (ya sea niño, adulto o anciano) y el tipo de condición que tenga.\n\n"
                                  "El cuidador podrá establecer una zona o un radio específico dentro del cual la persona podrá moverse, y la app avisará al cuidador en caso de que salga de este.",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // BOTÓN ENTENDIDO (Ex SIGUIENTE)
                SizedBox(
                  width: 200,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context); // Te regresa a la pantalla de bienvenida
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B6E8C), // Azul oscuro
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.black87, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "ENTENDIDO",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}