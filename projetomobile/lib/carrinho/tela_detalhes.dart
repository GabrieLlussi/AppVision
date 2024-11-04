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
      SnackBar(
          content: Text('${widget.produto['nome']} adicionado ao carrinho')),
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
          style: TextStyle(
              fontSize: 30.0 * preferredFontSize, color: Colors.black),
        ),
        backgroundColor: const Color.fromARGB(255, 55, 117, 199),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Aumentar o tamanho da imagem e adicionar o gesto de toque
            GestureDetector(
              onTap: () => _falarDescricao(
                  widget.produto['descricao'] ?? 'Descrição não disponível'),
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
                fontSize: 44 * preferredFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // Distribui o espaço entre os filhos
              children: [
                Text(
                  'R\$${widget.produto['preco']}',
                  style: TextStyle(
                    fontSize: 35 * preferredFontSize,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromRGBO(0, 131, 22, 1),
                  ),
                ),
                Text(
                  '${widget.produto['peso']}g',
                  style: TextStyle(
                    fontSize: 35 * preferredFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Usar uma Column para os botões
            Column(
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
                      MaterialPageRoute(builder: (context) => Carrinho()),
                    );
                  },
                  icon: Icon(Icons.shopping_cart, size: 30 * preferredFontSize),
                  label: Text(
                    'Ver carrinho',
                    style: TextStyle(fontSize: 30.0 * preferredFontSize),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(370, 80),
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
