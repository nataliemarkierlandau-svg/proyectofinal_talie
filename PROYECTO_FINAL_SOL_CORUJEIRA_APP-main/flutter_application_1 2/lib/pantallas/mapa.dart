import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
// Importamos sumar_personas para poder usar la clase Persona que definimos ahí
import 'package:flutter_application_1/pantallas/sumar_personas.dart';

class Mapa extends StatefulWidget {
  final Persona persona;

  const Mapa({
    super.key,
    required this.persona,
  });

  @override
  State<Mapa> createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  // Ubicación por defecto inicial (Buenos Aires, Argentina)
  LatLng ubicacion = const LatLng(-34.6037, -58.3816);
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    obtenerUbicacion();
  }

  Future<void> obtenerUbicacion() async {
    LocationPermission permiso = await Geolocator.requestPermission();

    if (permiso == LocationPermission.denied ||
        permiso == LocationPermission.deniedForever) {
      return;
    }

    Position posicion = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    LatLng nuevaUbicacion = LatLng(
      posicion.latitude,
      posicion.longitude,
    );

    setState(() {
      ubicacion = nuevaUbicacion;
    });

    // Mueve la cámara del mapa automáticamente hacia la posición real obtenida
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: nuevaUbicacion, zoom: 15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.persona.nombre),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: ubicacion,
          zoom: 15,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
        },
        markers: {
          Marker(
            markerId: const MarkerId('miUbicacion'),
            position: ubicacion,
            infoWindow: InfoWindow(
              title: widget.persona.nombre,
              snippet: 'Teléfono: ${widget.persona.telefono}',
            ),
          ),
        },
      ),
    );
  }
}