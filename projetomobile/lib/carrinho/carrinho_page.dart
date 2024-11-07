import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projetomobile/carrinho/carrinho.dart';
import 'package:projetomobile/carrinho/tela_detalhes.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_tts/flutter_tts.dart';

class CarrinhoPage extends StatefulWidget {
  const CarrinhoPage({super.key});

  @override
  _CarrinhoPageState createState() => _CarrinhoPageState();
}

class _CarrinhoPageState extends State<CarrinhoPage> {
  List<Map<String, dynamic>> produtos = [];
  MobileScannerController scannerController = MobileScannerController();
  FlutterTts flutterTts = FlutterTts();
  bool isScanning = true;
<<<<<<< HEAD
=======
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _wordsSpoken = "";
>>>>>>> 302215ddeb4740ec71e0828a17ac6083e4fb0b3e

  @override
  void initState() {
    super.initState();
    _fetchProdutos();
    scannerController.start();
<<<<<<< HEAD
    
  }

=======
    initSpeech();
  }
>>>>>>> 302215ddeb4740ec71e0828a17ac6083e4fb0b3e


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

  void _addToCart(Map<String, dynamic> produto) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    await firestore.collection('carrinho').add(produto);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${produto['nome']} adicionado ao carrinho')),
    );
  }

  Future<void> _speakProductName(String productName) async {
    await flutterTts.speak(productName);
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
      if (snapshot.docs.isNotEmpty) {
        final produto = snapshot.docs[0].data() as Map<String, dynamic>;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TelaDetalhes(produto: produto),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produto não encontrado')),
        );
      }

      setState(() {
        isScanning = true;
      });
    });
  }

  //Logica para reconhecimento de voz
  //Lógica de reconhecimento de voz
  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {
      
    });
  }

   void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      
    });
  }

  void _onSpeechResult (result) {
    setState(() {
      _wordsSpoken = result.recognizedWords.toLowerCase();
    });

    _processVoiceComand(_wordsSpoken);
  }

  void _processVoiceComand(String comand) {
    if (comand.contains("carrinho")) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Carrinho()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Acessando carrinho')),
      );
      _stopListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Catálogo de Produtos',
          style: TextStyle(fontSize: 28),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 55, 117, 199),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: scannerController,
            fit: BoxFit.cover,
            onDetect: _onBarcodeDetected,
          ),
          Container(
            color: Colors.white,
            width: double.infinity,
            height: double.infinity,
          ),
          produtos.isEmpty
              ? Center(child: CircularProgressIndicator())
              : PageView.builder(
                  itemCount: produtos.length,
                  itemBuilder: (context, index) {
                    final produto = produtos[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => _speakProductName(produto['nome']),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: produto['imgProduto'] != null &&
                                      produto['imgProduto'].isNotEmpty
                                  ? Image.network(
                                      produto['imgProduto'],
                                      fit: BoxFit.cover, 
                                      height: 350, // Tamanho aumentado da imagem
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.image,
                                          size: 250,
                                          color: Colors.grey,
                                        );
                                      },
                                    )
                                  : const Icon(Icons.image, size: 250, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            produto['nome'],
                            style: const TextStyle(
                              fontSize: 44.0,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TelaDetalhes(produto: produto),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  minimumSize: const Size(350, 80), // Botão grande
                                ),
                                child: const Text(
                                  'Detalhes',
                                  style: TextStyle(fontSize: 30, color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0), // Espaço entre os botões
                          ElevatedButton(
                            onPressed: () => _addToCart(produto),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              minimumSize: const Size(350, 80), // Botão grande
                            ),
                            child: const Text(
                              'Adicionar',
                              style: TextStyle(fontSize: 30, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Carrinho()),
          );
        },
        backgroundColor: Colors.purple,
        child: const Icon(
          Icons.shopping_cart,
          color: Colors.black,
          size: 40,
        ),
      ),
      
    );
  }
}
