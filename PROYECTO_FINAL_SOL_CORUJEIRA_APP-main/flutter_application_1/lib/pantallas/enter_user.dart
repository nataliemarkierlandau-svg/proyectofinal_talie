import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importamos el motor de autenticación
import 'package:flutter_application_1/pantallas/bienvenida.dart';
import 'package:flutter_application_1/pantallas/register.dart';

class EnterUser extends StatefulWidget {
  const EnterUser({super.key});

  @override
  State<EnterUser> createState() => _EnterUserState();
}

class _EnterUserState extends State<EnterUser> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final mailController = TextEditingController();
  
  String mensaje = '';
  bool _estaCargando = false; // Animación de espera para el login

  // --- FUNCIÓN PARA VALIDAR EL INGRESO EN FIREBASE ---
  Future<void> _validarIngreso() async {
    String username = usernameController.text.trim();
    String mail = mailController.text.trim();
    String password = passwordController.text.trim();

    // 1. Validación de campos locales
    if (username.isEmpty || password.isEmpty || mail.isEmpty) {
      setState(() {
        mensaje = 'Por favor, completa todos los campos';
      });
      _mostrarSnackBar(mensaje);
      return;
    }

    setState(() {
      _estaCargando = true; // Activa el círculo de carga
    });

    try {
      // 2. Intentamos iniciar sesión en Firebase con el Mail y la Contraseña
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: mail,
        password: password,
      );

      // Si el login es exitoso, pasamos a la pantalla de Bienvenida
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Bienvenida(
              username: username, // Pasamos el nombre que ingresó
              mail: mail,
            ),
          ),
        );
      }

    } on FirebaseAuthException catch (e) {
      // 3. Captura de errores de credenciales desde Firebase
      setState(() {
        if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
          mensaje = 'Mail o contraseña incorrectos';
        } else if (e.code == 'invalid-email') {
          mensaje = 'El formato del mail no es válido';
        } else {
          mensaje = 'Error al iniciar sesión: ${e.message}';
        }
      });
      _mostrarSnackBar(mensaje);
    } catch (e) {
      setState(() {
        mensaje = 'Ocurrió un error inesperado';
      });
      _mostrarSnackBar(mensaje);
    } finally {
      if (mounted) {
        setState(() {
          _estaCargando = false; // Apaga el círculo de carga
        });
      }
    }
  }

  void _mostrarSnackBar(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    mailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
             
              const Text('Iniciar Sesión', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green)),
              const SizedBox(height: 20),

              const Text('Usuario', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              SizedBox(
                width: 180.0,
                child: TextField(
                  obscureText: false, // Asegura que el nombre sea legible
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.grey, width: 1.5),
                    ),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white24,
                  ),
                  controller: usernameController,
                ),
              ),
              const SizedBox(height: 20),

              const Text('Mail', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              SizedBox(
                width: 180.0,
                child: TextField(
                  obscureText: false, // Asegura que el mail sea legible
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.grey, width: 1.5),
                    ),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white24,
                  ),
                  controller: mailController,
                ),
              ),
              const SizedBox(height: 20),

              const Text('Contraseña', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              SizedBox(
                width: 180.0,
                child: TextField(
                  obscureText: true, // Oculta los caracteres de la contraseña
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.grey, width: 1.5),
                    ),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white24,
                  ),
                  controller: passwordController,
                ),
              ),
              const SizedBox(height: 25),

              // Si está conectando con el servidor muestra un indicador de carga, de lo contrario muestra el botón
              _estaCargando
                ? const CircularProgressIndicator(color: Colors.green)
                : ElevatedButton(
                    onPressed: _validarIngreso,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 20),
                    ),
                    child: const Text("Ingresar", style: TextStyle(color: Colors.white, fontSize: 20)),
                  ),
              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Register()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 20),
                ),
                child: const Text("Registrarse", style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
