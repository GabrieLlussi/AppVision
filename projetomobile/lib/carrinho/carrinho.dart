import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
//import 'package:path_provider/path_provider.dart';
//import 'package:firebase_core/firebase_core.dart';

class Carrinho extends StatefulWidget {
  final String supermercadoID;

  const Carrinho({super.key, required this.supermercadoID});

  @override
  _CarrinhoState createState() => _CarrinhoState();
}

class _CarrinhoState extends State<Carrinho> {
  List<Map<String, dynamic>> carrinho = [];
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _wordsSpoken = "";
  final FlutterTts _flutterTts = FlutterTts(); // Instância do FlutterTts

  @override
  void initState() {
    super.initState();
    _fetchCarrinho();
    initSpeech();
  }

  // Solicitar permissão do microfone
  void _requestMicrophonePermission() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      print("Permissão para uso do microfone negada.");
    }
  }

  // Lógica de reconhecimento de voz
  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(result) {
    setState(() {
      _wordsSpoken = result.recognizedWords.toLowerCase();
    });

    _processVoiceComand(_wordsSpoken);
  }

  void _processVoiceComand(String comand) async {
    if (comand.contains("finalizar")) {
      double total = _calcularTotal();
      _flutterTts.speak(
          "O valor total do carrinho é de R\$ ${total.toStringAsFixed(2)}");
      _stopListening();
    } else if (comand.contains("limpe")) {
      await _clearCarrinho();
      _flutterTts.speak("Todos os itens foram removidos do carrinho");
      _stopListening();
    } else if (comand.contains("pare")) {
      _stopListening();
    }
  }

  // Nova função para texto a fala
  Future<void> _speakProductName(String productName) async {
    try {
      await _flutterTts.setLanguage("pt-BR");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.speak("O produto $productName foi removido do carrinho");
    } catch (e) {
      print("Erro ao executar TTS: $e");
    }
  }

  Future<void> _fetchCarrinho() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot snapshot = await firestore
          .collection('carrinho')
          .where('supermercado', isEqualTo: widget.supermercadoID)
          .get();
      setState(() {
        carrinho = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'nome': doc['nome'],
            'preco': doc['preco'],
            'peso': doc['peso'],
            'imgProduto': doc['imgProduto'],
            'supermercado': doc['supermercado'],
          };
        }).toList();
      });
    } catch (e) {
      print("Erro ao buscar carrinho: $e");
    }
  }

  Future<void> _removeFromCart(String id) async {
    try {
      FirebaseFirestore firebase = FirebaseFirestore.instance;
      final produto = carrinho.firstWhere((item) => item['id'] == id);
      await firebase.collection('carrinho').doc(id).delete();
      setState(() {
        carrinho.removeWhere((produto) => produto['id'] == id);
      });
      await _speakProductName(produto['nome']); // Chamada do TTS ao remover item
    } catch (e) {
      print("Erro ao remover produto do carrinho: $e");
    }
  }

  // Função para limpar o carrinho
  Future<void> _clearCarrinho() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      WriteBatch batch = firestore.batch();

      // Adiciona todas as operações de exclusão ao batch
      for (var produto in carrinho) {
        batch.delete(firestore.collection('carrinho').doc(produto['id']));
      }

      // Executa todas as exclusões de uma vez
      await batch.commit();

      // Atualiza o estado local do carrinho
      setState(() {
        carrinho.clear();
      });
    } catch (e) {
      print("Erro ao limpar carrinho: $e");
    }
  }

  double _calcularTotal() {
    double sum = 0.0;
    for (var produto in carrinho) {
      double preco = double.parse(produto['preco'].toString());
      sum += preco;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrinho de Compras'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 55, 117, 199),
      ),
      body: Column(
        children: [
          Expanded(
            child: carrinho.isEmpty
                ? const Center(child: Text('Carrinho vazio'))
                : ListView.builder(
                    itemCount: carrinho.length,
                    itemBuilder: (context, index) {
                      final produto = carrinho[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        child: ListTile(
                          leading: produto['imgProduto'] != null &&
                                  produto['imgProduto'].isNotEmpty
                              ? Image.network(
                                  produto['imgProduto'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.image,
                                  size: 50, color: Colors.grey),
                          title: Text(produto['nome']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Preço: R\$ ${double.parse(produto['preco']).toStringAsFixed(2)}'),
                              Text(
                                  'Peso: ${double.parse(produto['peso']).toStringAsFixed(2)} g'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeFromCart(produto['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: R\$ ${_calcularTotal().toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: ElevatedButton(
              onPressed: () {
                // Lógica para finalizar a compra
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 55, 117, 199),
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              ),
              child: const Text(
                'Finalizar Compra',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 120, // Largura maior
        height: 120, // Altura maior
        child: FloatingActionButton(
          onPressed:
              _speechToText.isListening ? _stopListening : _startListening,
          tooltip: 'Listen',
          child: Icon(
            _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
            color: Colors.white,
            size: 70, // Ajuste o tamanho do ícone conforme necessário
          ),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
      home: Carrinho(supermercadoID: 'supermercadoID'),
      debugShowCheckedModeBanner: false,
    ));
