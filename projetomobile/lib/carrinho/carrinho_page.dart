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
        ],
      ),
    );
  }
}