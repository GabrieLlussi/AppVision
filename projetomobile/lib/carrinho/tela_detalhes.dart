import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:projetomobile/carrinho/carrinho.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class TelaDetalhes extends StatefulWidget {
  final Map<String, dynamic> produto;
  final String supermercadoID;
  

  TelaDetalhes({Key? key, required this.produto, required this.supermercadoID}) : super(key: key);

  @override
  _TelaDetalhesState createState() => _TelaDetalhesState();
}

class _TelaDetalhesState extends State<TelaDetalhes> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isSpeaking = false;
  String _wordsSpoken = "";
  MobileScannerController scannerController = MobileScannerController();
  bool isScanning = true;
  DateTime? lastScanTime;
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    initSpeech();
    print("Supermercado ID recebido: ${widget.supermercadoID}");
  }

  Future<void> _speakProductName(String productName) async {
    await _flutterTts.speak(productName);
  }

  void _addToCart(BuildContext context) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Adiciona o produto atual ao carrinho
    await firestore.collection('carrinho').add(widget.produto, );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('${widget.produto['nome']} adicionado ao carrinho')),
    );


void _addToCart(Map<String, dynamic> produto) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    await firestore.collection('carrinho').add({
      ...produto,
      'supermercado': widget.supermercadoID,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${produto['nome']} adicionado ao carrinho')),
    );
  }
    // Lê o nome do produto e informa que foi adicionado ao carrinho
    await _speakProductName(
        "O produto ${widget.produto['nome']} foi adicionado ao carrinho.");
  }

  Future<void> _falarDescricao(String texto, String preco) async {
  try {
    double precoConvertido = double.parse(preco);
    String descricaoCompleta = "Preço: R\$${precoConvertido.toStringAsFixed(2)}. $texto";

    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() {
        _isSpeaking = false;
      });
    } else {
      await _flutterTts.speak(descricaoCompleta);
      setState(() {
        _isSpeaking = true;
      });
    }
  } catch (e) {
    print("Erro ao converter o preço: $e");
  }
}

  void _requestMicrophonePermission() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      print("Permissão para uso do microfone negada.");
    }
  }

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

  void _processVoiceComand(String comand) {
    if (comand.contains("carrinho")) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Carrinho(supermercadoID: widget.supermercadoID)),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Acessando carrinho')),
      );
      _stopListening();
    }
    if (comand.contains("remover")) {
      _removeFromCart(context);
      _flutterTts.speak("O item foi removido do carrinho");
      _stopListening();
    } else if (comand.contains("adicionar")) {
      _addToCart(context);
      _flutterTts.speak("O item foi adicionado ao carrinho");
      _stopListening();
    }
  }

  Future<void> _removeFromCart(BuildContext context) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    var carrinhoSnapshot = await firestore
        .collection('carrinho')
        .where('id', isEqualTo: widget.produto['id'])
        .get();

    if (carrinhoSnapshot.docs.isNotEmpty) {
      for (var doc in carrinhoSnapshot.docs) {
        await firestore.collection('carrinho').doc(doc.id).delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('${widget.produto['nome']} removido do carrinho')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produto não está no carrinho')),
      );
    }
  }

  //Leitor de código de barras
   void _onBarcodeDetected(BarcodeCapture capture) async {
    if (!isScanning || capture.barcodes.isEmpty) return;

    final now = DateTime.now();
    if (lastScanTime != null &&
        now.difference(lastScanTime!) < Duration(seconds : 5)) {
          return;
      }
      lastScanTime = now;
    
    setState(() {
      isScanning = false; //Pause o scanner para evitar múltiplas leituras
    });

    final code = capture.barcodes.first.rawValue;
    if (code == null) {
      setState(() {
        isScanning = true;
      });
      return;
    } 
   }
  @override
  Widget build(BuildContext context) {
    double preferredFontSize = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.produto['nome'],
          style: TextStyle(
              fontSize: 30.0 * preferredFontSize, color: Colors.black),
        ),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _falarDescricao(widget.produto['descricao'] ??'Descrição não disponível',
                  widget.produto['preco'].toString(),
                  ),
                  child: SizedBox(
                    height: 350,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.produto['imgProduto'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.image,
                              size: 100,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${widget.produto['nome']}',
                  style: TextStyle(
                    fontSize: 30 * preferredFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'R\$${widget.produto['preco']}',
                      style: TextStyle(
                        fontSize: 30 * preferredFontSize,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromRGBO(0, 131, 22, 1),
                      ),
                    ),
                    Text(
                      '${widget.produto['peso']}g',
                      style: TextStyle(
                        fontSize: 30 * preferredFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _addToCart(context);
                      },
                      icon: Icon(Icons.add, size: 30 * preferredFontSize),
                      label: Text(
                        'Adicionar',
                        style: TextStyle(fontSize: 30.0 * preferredFontSize),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(370, 80),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Carrinho(supermercadoID: widget.supermercadoID)),
                        );
                      },
                      icon: Icon(Icons.shopping_cart,
                          size: 30 * preferredFontSize),
                      label: Text(
                        'Ver carrinho',
                        style: TextStyle(fontSize: 30.0 * preferredFontSize),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(370, 80),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.1,
            minChildSize: 0.02,
            maxChildSize: 0.4,
            builder: (context, scrollController) {
              return Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: ListView(
                  controller: scrollController,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      widget.produto['descricao'] ?? 'Descrição não disponível',
                      style: TextStyle(fontSize: 40 * preferredFontSize),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 120,
        height: 120,
        child: FloatingActionButton(
          onPressed:
              _speechToText.isListening ? _stopListening : _startListening,
          tooltip: 'Listen',
          child: Icon(
            _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
            color: Colors.white,
            size: 70,
          ),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}
