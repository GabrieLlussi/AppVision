import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class ProximidadeEstabelecimento {
  final double distanciaMinimaMetros = 20.0;

  Future<void> verificarProximidade(BuildContext context) async {
    //Solicita permissão da localização para o usuário
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissão de localização negada')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissão de localização permanentemente bloqueada pelo usuário')),
      );
    }
    // Obtem a posição atual do usuário
    Position posicaoAtual = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    // Conecta ao Firestore e busca estabelecimentos
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore.collection('estabelecimentos').get();

    // Itera sobre os estabelecimentos para verificar proximidade
    for (var doc in snapshot.docs) {
      final dadosEstabelecimento = doc.data() as Map<String, dynamic>;
      final double latitude = dadosEstabelecimento['latitude'];
      final double longitude = dadosEstabelecimento['longitude'];

      // Calcula a distância entre a posição atual e o estabelecimento
      double distancia = Geolocator.distanceBetween(
        posicaoAtual.latitude,
        posicaoAtual.longitude,
        latitude,
        longitude,
      );

      // Exibe Snackbar se estiver dentro do raio desejado
      if (distancia <= distanciaMinimaMetros) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Você chegou ao estabelecimento: ${dadosEstabelecimento['nome']}!')),
        );
        break; // Opcional: interrompe ao encontrar o primeiro estabelecimento
      }
    }
  }
}