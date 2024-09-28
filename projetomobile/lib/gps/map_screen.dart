import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? selectedLocation;

  // Controlador do Google Maps
  GoogleMapController? mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // Função chamada quando o usuário seleciona um local no mapa
  void _onTap(LatLng location) {
    setState(() {
      selectedLocation = location;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecionar Local'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(-15.7942, -47.8822), // Posição inicial no mapa
          zoom: 10,
        ),
        onTap: _onTap,
        markers: selectedLocation != null
            ? {
                Marker(
                  markerId: MarkerId('selected-location'),
                  position: selectedLocation!,
                )
              }
            : {},
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context, selectedLocation); // Retorna as coordenadas para a tela anterior
        },
        child: Icon(Icons.check),
      ),
    );
  }
}
