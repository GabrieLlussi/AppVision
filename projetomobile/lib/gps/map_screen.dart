import 'package:flutter/material.dart'; 
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

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
        title: const Text('Selecionar Local'),
      ),
      body: Stack(
        children: [
          // Mapa ocupa todo o espaço
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(-15.7942, -47.8822), // Posição inicial no mapa
              zoom: 10,
            ),
            onTap: _onTap,
            markers: selectedLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId('selected-location'),
                      position: selectedLocation!,
                    )
                  }
                : {},
          ),
          // Botão centralizado
          Align(
            alignment: Alignment.bottomCenter, // Centralizado na parte inferior
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0), // Ajuste o padding se quiser elevar o botão
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pop(context, selectedLocation); // Retorna as coordenadas para a tela anterior
                },
                child: const Icon(Icons.check),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
