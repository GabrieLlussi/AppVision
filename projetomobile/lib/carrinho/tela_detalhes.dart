import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projetomobile/carrinho/carrinho.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class TelaDetalhes extends StatefulWidget {
  final Map<String, dynamic> produto;

  TelaDetalhes({Key? key, required this.produto}) : super(key: key);

  @override
  _TelaDetalhesState createState() => _TelaDetalhesState();
}

class _TelaDetalhesState extends State<TelaDetalhes> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _commandText = '';
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _addToCart(BuildContext context) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Adiciona o produto atual ao carrinho
    await firestore.collection('carrinho').add(widget.produto);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.produto['nome']} adicionado ao carrinho')),
    );
  }

  Future<void> _falarDescricao(String texto) async {
    await _flutterTts.speak(texto);
  }

  void _initializeSpeechRecognition() async {
    bool available = await _speech.initialize(
      onStatus: (val) {
        if (val == "done") {
          _startListening();
        }
      },
      onError: (val) => print('Erro: $val'),
    );
    if (!available) {
      setState(() {
        _commandText = 'Reconhecimento de voz não disponível no dispositivo';
      });
    } else {
      _startListening();
    }
  }

  void _startListening() async {
    if (!_isListening) {
      setState(() => _isListening = true);
      print("Iniciando o reconhecimento de voz...");
      await _speech.listen(
        onResult: (val) {
          setState(() {
            _commandText = val.recognizedWords;
            print("Texto reconhecido: $_commandText");
            _processVoiceCommand(_commandText);
          });
        },
        listenMode: stt.ListenMode.dictation,
      );
    }
  }

  void _processVoiceCommand(String command) {
  command = command.toLowerCase();

  if (command.contains("carrinho")) {
    // Navegar para a página do carrinho
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Carrinho()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Indo para o carrinho...')),
    );
    _stopListening();
  } else if (command.contains("adicione ao carrinho")) {
    // Chama a função de adicionar ao carrinho
    _addToCart(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produto adicionado ao carrinho.')),
    );
    _stopListening();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comando não reconhecido')),
    );
  }
}

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double preferredFontSize = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.produto['nome'],
          style: TextStyle(fontSize: 24.0 * preferredFontSize),
        ),
        backgroundColor: const Color.fromARGB(255, 55, 117, 199),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 400,
              width: double.infinity,
              child: Image.network(
                widget.produto['imgProduto'],
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${widget.produto['nome']}',
              style: TextStyle(
                fontSize: 34 * preferredFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'R\$${widget.produto['preco']}',
              style: TextStyle(
                fontSize: 26 * preferredFontSize,
                fontWeight: FontWeight.bold,
                color: const Color.fromRGBO(0, 131, 22, 1),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${widget.produto['peso']}g',
              style: TextStyle(
                fontSize: 22 * preferredFontSize,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _falarDescricao(widget.produto['descricao'] ?? 'Descrição não disponível'),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54, width: 2.0),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Text(
                  '${widget.produto['descricao']}',
                  style: TextStyle(
                    fontSize: 22 * preferredFontSize,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _addToCart(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Produto adicionado ao carrinho.'),
                      ),
                    );
                  },
                  icon: Icon(Icons.add, size: 30 * preferredFontSize),
                  label: Text(
                    'Adicionar',
                    style: TextStyle(fontSize: 22.0 * preferredFontSize),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lime,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Carrinho()),
                    );
                  },
                  icon: Icon(Icons.shopping_cart, size: 30 * preferredFontSize),
                  label: Text(
                    'Carrinho',
                    style: TextStyle(fontSize: 22.0 * preferredFontSize),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}