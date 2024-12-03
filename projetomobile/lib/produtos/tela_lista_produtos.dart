import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_tts/flutter_tts.dart'; // Dependência para síntese de voz

class TelaListaProdutos extends StatefulWidget {
  const TelaListaProdutos({super.key});

  @override
  _TelaListaProdutosState createState() => _TelaListaProdutosState();
}

class _TelaListaProdutosState extends State<TelaListaProdutos> {
  File? _novaImagem;
  String? _codigoBarras;
  final FlutterTts _flutterTts = FlutterTts(); // Instância do sintetizador de voz

  // Função para reproduzir o nome do produto
  Future<void> _speakProductName(String productName) async {
    await _flutterTts.setLanguage('pt-BR');
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak('Adicionado ao carrinho: $productName');
  }

  // Função para excluir um produto
  Future<void> excluirProduto(String id) async {
    try {
      await FirebaseFirestore.instance.collection('produto').doc(id).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto excluído com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir o produto: $e')),
        );
      }
    }
  }

  // Função para selecionar nova imagem
  Future<void> _selecionarImagem() async {
    final picker = ImagePicker();
    final PickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (PickedFile != null) {
      setState(() {
        _novaImagem = File(PickedFile.path);
      });
    }
  }

  // Função para fazer upload da nova imagem
  Future<String?> _uploadImagem(String id) async {
    if (_novaImagem != null) {
      try {
        final storageRef =
            FirebaseStorage.instance.ref().child('produtos/$id.jpg');
        await storageRef.putFile(_novaImagem!);
        return await storageRef.getDownloadURL();
      } catch (e) {
        print("Erro ao fazer upload da imagem: $e");
        return null;
      }
    }
    return null;
  }

  // Função para escanear o código de barras com permissão da câmera
  Future<void> _escanearCodigoBarras() async {
    showDialog(
      context: context, 
      builder:(BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: 300,
            height: 400,
            child: MobileScanner(
              onDetect: (BarcodeCapture barcodeCapture) {
                final List<Barcode> barcodes = barcodeCapture.barcodes;
                if (barcodes.isNotEmpty){
                final String? code = barcodes.first.rawValue;
                if (code != null) {
                  setState(() {
                    _codigoBarras = code;
                  });
                  Navigator.of(context).pop();
                }
              }},
            )
          ),
        );
      }
    );
  }

  // Função para editar um produto
  Future<void> editarProduto(String id, String novoNome, String novoPreco,
      String novoPeso, String novaDescricao, String? novaImagemUrl) async {
    Map<String, dynamic> dataAtualizada = {
      'nome': novoNome,
      'preco': novoPreco,
      'peso': novoPeso,
      'descricao': novaDescricao,
      'codigoBarras': _codigoBarras, // Salva o código de barras no produto
    };

    if (novaImagemUrl != null) {
      dataAtualizada['imgProduto'] = novaImagemUrl;
    }

    try {
      await FirebaseFirestore.instance
          .collection('produto')
          .doc(id)
          .update(dataAtualizada);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto atualizado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar o produto: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Produtos'),
        backgroundColor: const Color.fromARGB(255, 55, 117, 199),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('produto').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum produto cadastrado.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              String id = doc.id;
              String nome = doc['nome'];
              String preco = doc['preco'].toString();
              String peso = doc['peso'].toString();
              String descricao = doc['descricao'];
              String imgProduto = doc['imgProduto'];

              final data = doc.data()
                  as Map<String, dynamic>?; // Fazendo o cast para Map
              String? codigoBarras =
                  data != null && data.containsKey('codigoBarras')
                      ? data['codigoBarras']
                      : null;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
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
                            width: 100, // Aumente o tamanho da imagem aqui
                            height: 150,
                            color: Colors.grey[200],
                            child: Image.network(
                              imgProduto,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.image,
                                    size: 100, color: Colors.grey);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(
                            width:
                                16.0), // Espaçamento entre a imagem e o conteúdo textual
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nome,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24.0,
                                  color: Colors.teal[800],
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Preço: R\$ $preco\nPeso: $peso g\nCódigo de Barras: ${codigoBarras ?? "Não cadastrado"}',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Color.fromARGB(255, 3, 3, 3),
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              ElevatedButton.icon(
                                onPressed: () {
                                  _speakProductName(nome); // Fala o nome do produto
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('$nome adicionado ao carrinho.'),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add_shopping_cart),
                                label: const Text("Adicionar ao Carrinho"),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.blue, size: 30),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    String novoNome = nome;
                                    String novoPreco = preco.toString();
                                    String novoPeso = peso.toString();
                                    String novaDescricao = descricao;

                                    return AlertDialog(
                                      title: const Text('Editar Produto'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextField(
                                            decoration: const InputDecoration(
                                                labelText: 'Nome do Produto'),
                                            onChanged: (value) =>
                                                novoNome = value,
                                            controller: TextEditingController(
                                                text: nome),
                                          ),
                                          TextField(
                                            decoration: const InputDecoration(
                                                labelText: 'Preço'),
                                            keyboardType: TextInputType.number,
                                            onChanged: (value) =>
                                                novoPreco = value,
                                            controller: TextEditingController(
                                                text: preco.toString()),
                                          ),
                                          TextField(
                                            decoration: const InputDecoration(
                                                labelText: 'Peso (g)'),
                                            keyboardType: TextInputType.number,
                                            onChanged: (value) =>
                                                novoPeso = value,
                                            controller: TextEditingController(
                                                text: peso.toString()),
                                          ),
                                          TextField(
                                            decoration: const InputDecoration(
                                                labelText: 'Descrição'),
                                            onChanged: (value) =>
                                                novaDescricao = value,
                                            controller: TextEditingController(
                                                text: descricao),
                                          ),
                                          TextField(
                                            decoration: const InputDecoration(
                                                labelText: 'Código de Barras'),
                                            onChanged: (value) =>
                                                _codigoBarras = value,
                                            controller: TextEditingController(
                                                text: codigoBarras),
                                          ),
                                          const SizedBox(height: 8),
                                          ElevatedButton.icon(
                                            onPressed: _escanearCodigoBarras,
                                            icon: const Icon(Icons.qr_code),
                                            label: const Text(
                                                'Escanear Código de Barras'),
                                          ),
                                          const SizedBox(height: 8),
                                          if (_novaImagem != null)
                                            Image.file(
                                              _novaImagem!,
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            ),
                                          ElevatedButton(
                                            onPressed: _selecionarImagem,
                                            child: const Text(
                                                'Selecionar Nova Imagem'),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            String? novaImagemUrl =
                                                await _uploadImagem(id);
                                            editarProduto(
                                              id,
                                              novoNome,
                                              novoPreco,
                                              novoPeso,
                                              novaDescricao,
                                              novaImagemUrl,
                                            );
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Salvar'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red, size: 30),
                              onPressed: () {
                                excluirProduto(id);
                              },
                            ),
                          ],
                        ),
                      ],
                    )),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
