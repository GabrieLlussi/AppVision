import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projetomobile/carrinho/carrinho.dart';
import 'package:projetomobile/carrinho/tela_detalhes.dart';

import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;


class CarrinhoPage extends StatefulWidget {
  const CarrinhoPage({super.key});

  @override
  _CarrinhoPageState createState() => _CarrinhoPageState();
}

class _CarrinhoPageState extends State<CarrinhoPage> {
  List<Map<String, dynamic>> produtos = [];
  MobileScannerController scannerController = MobileScannerController();
  bool isScanning = true;

  // Instância de reconhecimento de voz
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _commandText = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeSpeechRecognition();
    _fetchProdutos();
    scannerController.start();
  }

  void _fetchProdutos() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Busca os produtos da coleção "produtos" no Firestore
    QuerySnapshot snapshot = await firestore.collection('produto').get();

    setState(() {
      // Converte os documentos para Map e adiciona à lista de produtos
      produtos = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'nome': doc['nome'],
          'preco': doc['preco'],
          'peso': doc['peso'],
          'descricao': doc['descricao'],
          'imgProduto': doc['imgProduto'],
        };
      }).toList();
    });
  }

  void __addToCart(Map<String, dynamic> produto) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    await firestore.collection('carrinho').add(produto);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${produto['nome']} adicionado ao carrinho')),
    );
  }

  //Leitura do código de barras

  void _onBarcodeDetected(BarcodeCapture capture) async {
    if (!isScanning || capture.barcodes.isEmpty) return;

    final code = capture.barcodes.first.rawValue;
    if (code == null) return;

    setState(() {
      isScanning = false; //Pause o scanner para evitar múltiplas leituras 
    });

    FirebaseFirestore.instance
      .collection('produto')
      .where('codigoBarras', isEqualTo: code)
      .get()
      .then((QuerySnapshot snapshot) {
        if (snapshot.docs.isNotEmpty){
          final produto = snapshot.docs[0].data() as Map<String, dynamic>;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TelaDetalhes(produto: produto),
              ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content:  Text('Produto não encontrado')),
          );
        }

        setState(() {
          isScanning = true;
        });
      });
  }

  // Função para iniciar o reconhecimento de voz
  void _initializeSpeechRecognition() async {
    bool available = await _speech.initialize(
      onStatus: (val) => setState(() => _isListening = _speech.isListening),
      onError: (val) => print('Erro: $val'),
    );
    if (!available) {
      setState(() {
        _commandText = 'Reconhecimento de voz não disponível no dispositivo';
      });
    }
  }

  // Função para iniciar a escuta de voz
  void _startListening() async {
    if (!_isListening) {
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (val) => setState(() {
          _commandText = val.recognizedWords; // Atualiza o texto com a transcrição
        }),
      );
    }
  }

  // Processa o comando de voz e verifica o produto
  void _processVoiceCommand(String command) {
    command = command.toLowerCase();
    final produto = produtos.firstWhere(
      (produto) => command.contains(produto['nome'].toLowerCase()),
      orElse: () => {},
    );
    if (produto.isNotEmpty) {
      __addToCart(produto);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produto não encontrado no catálogo')),
      );
    }
    _stopListening();
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
    });
    _speech.stop();
  }


  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Catálogo de produtos'),
      centerTitle: true,
      backgroundColor: const Color.fromARGB(255, 55, 117, 199),
    ),
    body: 
    
    Stack(
      children: [
        //Colocar código do leitor aqui para ficar em segundo plano
        MobileScanner(
          controller: scannerController,
          fit: BoxFit.cover,
          onDetect: _onBarcodeDetected,
        ),

    Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: produtos.length,
            itemBuilder: (context, index) {
              final produto = produtos[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                          width: 100, // Aumentando o tamanho da imagem aqui
                          height: 150,
                          color: Colors.grey[200],
                          child: produto['imgProduto'] != null &&
                                  produto['imgProduto'].isNotEmpty
                              ? Image.network(
                                  produto['imgProduto'],
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.image,
                                        size: 100, color: Colors.grey);
                                  },
                                )
                              : const Icon(Icons.image, size: 100, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 16.0), // Espaço entre a imagem e o texto
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              produto['nome'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24.0,
                                color: Colors.teal[800],
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Preço: R\$ ${double.parse(produto['preco']).toStringAsFixed(2)}\n'
                              'Peso: ${double.parse(produto['peso']).toStringAsFixed(2)} g',
                              style: const TextStyle(
                                fontSize: 16.0,
                                color: Color.fromARGB(255, 3, 3, 3),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add_shopping_cart_outlined,
                                color: Colors.red, size: 40),
                            onPressed: () => __addToCart(produto),
                          ),
                          IconButton(
                            icon: const Icon(Icons.info, color: Colors.blue, size: 45),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TelaDetalhes(produto: produto),
                                ),
                              );
                            },
                          ),
                        ],
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
          child: ElevatedButton(
            onPressed: () {
              // Lógica para finalizar a compra
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Carrinho()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 0, 0),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            ),
            child: const Text(
              'Carrinho',
              style: TextStyle(fontSize: 25, color: Colors.black),
            ),
          ),
        ),
      ],
    ),
    // Botão para iniciar o reconhecimento de voz, sobreposto no canto inferior direito
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _isListening ? _stopListening : _startListening,
              backgroundColor: Colors.red,
              child: Icon(_isListening ? Icons.mic : Icons.mic_none),
            ),
          ),
        ],
      ),
    );
  }
}