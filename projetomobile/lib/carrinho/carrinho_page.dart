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
  stt.SpeechToText speech = stt.SpeechToText();
  bool isScanning = true;
  bool isListening = false;
  String lastCommand = ''; // Armazena o último comando para execução de ações


  @override
  void initState() {
    super.initState();
    _fetchProdutos();
    scannerController.start();
    _initSpeech();
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


 void _initSpeech() async {
    bool hasSpeech = await speech.initialize(
      onStatus: (status) => _onSpeechStatus(status),
      onError: (error) => print('Error: $error'),
    );

    if (hasSpeech) {
      _listen(); // Inicia a escuta contínua
    }
  }

  void _listen() async {
    if (!isListening) {
      setState(() => isListening = true);
      await speech.listen(
        onResult: (result) => _onSpeechResult(result.recognizedWords),
        listenMode: stt.ListenMode.dictation,
        partialResults: false,
        pauseFor: const Duration(seconds: 3),
        cancelOnError: false,
      );
    }
  }

  void _onSpeechResult(String command) {
    setState(() => lastCommand = command.toLowerCase().trim());
    _executeCommand(lastCommand);
  }

  void _onSpeechStatus(String status) {
    if (status == "notListening" && mounted) {
      setState(() => isListening = false);
      _listen(); // Reinicia a escuta ao parar
    }
  }

  void _executeCommand(String command) {
    // Verificar o comando e executar a ação correspondente
    if (command.contains('adicionar')) {
      // Verifica qual produto adicionar
      if (produtos.isNotEmpty) {
        __addToCart(produtos.first); // Exemplo: adiciona o primeiro produto
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produto adicionado ao carrinho')),
      );
    } else if (command.contains('detalhes')) {
      // Abre a tela de detalhes do primeiro produto da lista, por exemplo
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TelaDetalhes(produto: produtos.first),
        ),
      );
    } else if (command.contains('finalizar')) {
      // Abre a tela de finalização
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Carrinho()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Comando não reconhecido')),
      );
    }
  }

  void _confirmAction(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}



  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Catálogo de Produtos', style: TextStyle(fontSize: 28)),
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
                    margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
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
                              child: produto['imgProduto'] != null && produto['imgProduto'].isNotEmpty
                                  ? Image.network(
                                      produto['imgProduto'],
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.image, size: 100, color: Colors.grey);
                                      },
                                    )
                                  : const Icon(Icons.image, size: 100, color: Colors.grey),
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
                                  style: const TextStyle(fontSize: 20.0, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add_shopping_cart, color: Colors.yellow, size: 50),
                                onPressed: () => __addToCart(produto),
                                tooltip: 'Adicionar ao carrinho',
                              ),
                              IconButton(
                                icon: const Icon(Icons.info, color: Colors.blue, size: 50),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TelaDetalhes(produto: produto),
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
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
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