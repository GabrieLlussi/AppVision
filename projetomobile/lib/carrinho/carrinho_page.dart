import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projetomobile/carrinho/carrinho.dart';
import 'package:projetomobile/carrinho/tela_detalhes.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:speech_to_text/speech_to_text.dart';

class CarrinhoPage extends StatefulWidget {
  const CarrinhoPage({super.key});

  @override
  _CarrinhoPageState createState() => _CarrinhoPageState();
}

class _CarrinhoPageState extends State<CarrinhoPage> {
  List<Map<String, dynamic>> produtos = [];
  MobileScannerController scannerController = MobileScannerController();
  SpeechToText _speechToText = SpeechToText();
  bool _isListening = true;
  bool isScanning = true;

  @override
  void initState() {
    super.initState();
    _fetchProdutos();
    _initSpeech();
    scannerController.start();
  }

  Future<void> _initSpeech() async {
    bool available = await _speechToText.initialize(
      onStatus: (status) {
        if (status == "done") {
          _startListening(); // Reinicia a escuta contínua quando o reconhecimento é concluído
        }
      },
      onError: (error) => print("Erro de reconhecimento: $error"),
    );
    if (available) {
      _startListening();
    }
  }

  void _startListening() {
    _speechToText.listen(
      onResult: (result) {
        if (result.finalResult) {
          _processCommand(result.recognizedWords);
        }
      },
      listenMode: ListenMode.dictation,
    );
    setState(() {
      _isListening = true;
    });
  }

  void _processCommand(String command) {
    command = command.toLowerCase();

    if (command.startsWith("adicionar")) {
      // Extrai o nome do produto após a palavra "adicionar"
      String? produtoNome =
          command.replaceFirst("adicionar", "").trim();
      _addProductToCartByName(produtoNome);
      
    } else if (command.startsWith("detalhes")) {
      // Extrai o nome do produto após a palavra "detalhes"
      String? produtoNome = command.replaceFirst("detalhes", "").trim();
      _showProductDetails(produtoNome);
      
    } else if (command.contains("finalizar")) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Carrinho()),
      );
    }
  }


  void _addProductToCartByName(String nomeProduto) {
    final produto = produtos.firstWhere(
      (produto) => produto['nome'].toLowerCase() == nomeProduto.toLowerCase(),
      orElse: () => {},
    );
    if (produto != null) {
      __addToCart(produto);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Produto $nomeProduto não encontrado")),
      );
    }
  }

  void _showProductDetails(String nomeProduto) {
    final produto = produtos.firstWhere(
      (produto) => produto['nome'].toLowerCase() == nomeProduto.toLowerCase(),
      orElse: () => {},
    );
    if (produto != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TelaDetalhes(produto: produto)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Produto $nomeProduto não encontrado")),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Catálogo de Produtos', style: TextStyle(fontSize: 28)),
        centerTitle: true,
        backgroundColor: Colors.black,
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
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: produtos.length,
                  itemBuilder: (context, index) {
                    final produto = produtos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Container(
                                width: 120,
                                height: 180,
                                color: Colors.grey[200],
                                child: produto['imgProduto'] != null &&
                                        produto['imgProduto'].isNotEmpty
                                    ? Image.network(
                                        produto['imgProduto'],
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(Icons.image,
                                              size: 100, color: Colors.grey);
                                        },
                                      )
                                    : const Icon(Icons.image,
                                        size: 100, color: Colors.grey),
                              ),
                            ),
                            const SizedBox(width: 20.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    produto['nome'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28.0,
                                      color: Colors.teal[900],
                                    ),
                                  ),
                                  const SizedBox(height: 12.0),
                                  Text(
                                    'Preço: R\$ ${double.parse(produto['preco']).toStringAsFixed(2)}\n'
                                    'Peso: ${double.parse(produto['peso']).toStringAsFixed(2)} g',
                                    style: const TextStyle(
                                        fontSize: 20.0, color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.add_shopping_cart,
                                      color: Colors.yellow, size: 50),
                                  onPressed: () => __addToCart(produto),
                                  tooltip: 'Adicionar ao carrinho',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.info,
                                      color: Colors.blue, size: 50),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TelaDetalhes(produto: produto),
                                      ),
                                    );
                                  },
                                  tooltip: 'Mais informações',
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
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Carrinho()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  child: const Text(
                    'Carrinho',
                    style: TextStyle(fontSize: 28, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
