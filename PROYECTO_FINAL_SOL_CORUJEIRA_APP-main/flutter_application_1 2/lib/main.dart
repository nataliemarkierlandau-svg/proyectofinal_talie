import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'pantallas/enter_user.dart';
import 'pantallas/register.dart';
// Agregamos el import de tu nueva pantalla
import 'pantallas/informacion.dart';

void main() async {
  // Asegura que Flutter esté 100% inicializado antes de conectar con internet
  WidgetsFlutterBinding.ensureInitialized(); 

  // Conexión con tu ProyectoFinal de Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyC6bPEExnW4hzhTXq0PrLRfo_NB98HA0K0",
      authDomain: "proyectofinal-486fb.firebaseapp.com",
      databaseURL: "https://proyectofinal-486fb-default-rtdb.firebaseio.com",
      projectId: "proyectofinal-486fb",
      storageBucket: "proyectofinal-486fb.appspot.com",
      messagingSenderId: "283486047182",
      appId: "1:283486047182:web:1884cd12ecd89cdeeb399f",
    ),
  );

  // Arranca la app metida dentro del marco del celular en Chrome
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: DevicePreview.locale(context), // Idioma adaptado al celular simulado
      builder: DevicePreview.appBuilder,    // Renderiza el marco estético del iPhone
      debugShowCheckedModeBanner: false,
      home: const Inicio(),
    );
  }
}

class Inicio extends StatelessWidget {
  const Inicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey, // Fondo base de la aplicación
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            width: 280,
            height: 500,
            decoration: BoxDecoration(
              color: const Color(0xFF98B4CE), // Celeste/azul grisáceo idéntico al boceto
              borderRadius: BorderRadius.circular(30), // Esquinas redondeadas de la tarjeta
              border: Border.all(color: Colors.black87, width: 2.5), // Contorno grueso marcado
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribuye los elementos simétricamente
              children: [
                // TÍTULO "BIENVENIDO"
                const Padding(
                  padding: EdgeInsets.only(top: 15.0),
                  child: Text(
                    "BIENVENIDO",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),

                // CONTENEDOR DE LOS BOTONES
                Column(
                  children: [
                    // BOTÓN REGISTRARSE
                    SizedBox(
                      width: 220,
                      height: 55,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Register(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B6E8C), // Azul oscuro de tu dibujo
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.black87, width: 2), // Borde definido del botón
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          "REGISTRARSE",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20), // Separación entre ambos botones

                    // BOTÓN INICIAR SESIÓN
                    SizedBox(
                      width: 220,
                      height: 55,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EnterUser(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B6E8C), // Mismo azul oscuro del boceto
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.black87, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          "INICIAR SESIÓN",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // TEXTO / ENLACE "más información sobre esta app" -> AHORA INTERACTIVO
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InformacionScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "más información sobre esta app",
                      style: TextStyle(
                        color: Color(0xFF5CE1E6), // Color claro subrayado como el original
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}