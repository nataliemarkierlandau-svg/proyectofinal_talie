import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/pantallas/enter_user.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  // Controladores para capturar lo que escribe el Supervisor
  final _usernameController = TextEditingController();
  final _mailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Variable para mostrar un círculo de carga mientras se conecta a la nube
  bool _estaCargando = false;

  // --- FUNCIÓN PRINCIPAL DE REGISTRO EN FIREBASE ---
  Future<void> _registrarYGuardarUsuario() async {
    // 1. Validamos que los campos no estén vacíos
    if (_usernameController.text.isEmpty || _mailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, llena todos los campos')),
      );
      return;
    }

    setState(() {
      _estaCargando = true; // Activa la animación de espera
    });

    try {
      // 2. Crear el usuario en Firebase Authentication (Encripta la contraseña automáticamente)
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _mailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 3. Obtenemos el ID único (UID) generado dinámicamente por Firebase para este Supervisor
      String supervisorUid = userCredential.user!.uid;

      // 4. Guardamos los datos del perfil del supervisor en Cloud Firestore
      // Nota: Si la colección 'usuarios' no existe, Firebase la crea en este milisegundo de forma automática
      await FirebaseFirestore.instance.collection('usuarios').doc(supervisorUid).set({
        'nombre': _usernameController.text.trim(),
        'mail': _mailController.text.trim(),
        'rol': 'supervisor', // Lo marcamos por defecto con su nivel de acceso
        'fecha_registro': DateTime.now(),
      });

      // Limpiamos los cuadros de texto de la pantalla
      _usernameController.clear();
      _mailController.clear();
      _passwordController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Supervisor registrado en Firebase con éxito!')),
        );
        
        // Redirigimos automáticamente a la siguiente pantalla del sistema
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EnterUser()),
        );
      }

    } on FirebaseAuthException catch (e) {
      // Manejo de errores típicos de Firebase
      String mensajeError = 'Ocurrió un error en el registro.';
      if (e.code == 'weak-password') {
        mensajeError = 'La contraseña es muy débil (mínimo 6 caracteres).';
      } else if (e.code == 'email-already-in-use') {
        mensajeError = 'Este correo electrónico ya está registrado.';
      } else if (e.code == 'invalid-email') {
        mensajeError = 'El formato del correo no es válido.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensajeError), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _estaCargando = false; // Apaga la animación de espera
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _mailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Registrarse', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const SizedBox(height: 20),
              
              const Text('Usuario', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              SizedBox(
                width: 180.0, 
                child: TextField(
                  controller: _usernameController,
                  obscureText: false, // CORREGIDO: Que se vea el texto del nombre
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.grey, width: 1.5),
                    ),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white24,
                  )
                )
              ),
             
              const SizedBox(height: 20),

              const Text('Mail', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              SizedBox(
                width: 180.0, 
                child: TextField(
                  controller: _mailController, 
                  obscureText: false, // CORREGIDO: Que se vea el texto del mail
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.grey, width: 1.5),
                    ),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white24,
                  )
                )
              ),

              const SizedBox(height: 20),

              const Text('Contraseña', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              SizedBox(
                width: 180.0, 
                child: TextField(
                  controller: _passwordController,
                  obscureText: true, // Mantiene la contraseña oculta
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.grey, width: 1.5),
                    ),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white24,
                  )
                )
              ),

              const SizedBox(height: 25),

              // Si está conectando con la nube muestra un círculo de carga, sino muestra el botón
              _estaCargando 
                ? const CircularProgressIndicator(color: Colors.blueGrey)
                : ElevatedButton(
                    onPressed: _registrarYGuardarUsuario,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey, 
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 20),
                    ),
                    child: const Text('Registrar Usuario', style: TextStyle(color: Colors.white, fontSize: 20)),
                  ),
                  
              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EnterUser()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey, 
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 20),
                ),
                child: const Text('Ver Lista de Usuarios', style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}