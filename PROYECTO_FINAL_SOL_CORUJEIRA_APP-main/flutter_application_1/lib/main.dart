import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart'; // Librería nativa para conectar Firebase
import 'pantallas/enter_user.dart';

void main() async {
  // Asegura que Flutter esté 100% inicializado antes de conectar con internet
  WidgetsFlutterBinding.ensureInitialized(); 

  // Conexión híbrida con tu ProyectoFinal de Firebase
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
      appBar: AppBar(
        title: const Text("Inicio"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EnterUser(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey, 
            foregroundColor: Colors.lightGreen[100], 
            elevation: 5, 
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24), 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15), 
            ),
          ),
          child: const Text(
            "¡Empecemos!", 
            style: TextStyle(
              color: Colors.white, 
              fontSize: 20, 
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}