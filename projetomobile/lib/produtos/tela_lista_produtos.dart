import 'package:firebase_storage/firebase_storage.dart'; 
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:barcode_scan2/barcode_scan2.dart'; // Adicionado para leitura de código de barras

class TelaListaProdutos extends StatefulWidget {
  @override
  _TelaListaProdutosState createState() => _TelaListaProdutosState();
}

class _TelaListaProdutosState extends State<TelaListaProdutos> {
  File? _novaImagem;
  String? _codigoBarras;

  // Função para excluir um produto
  Future<void> excluirProduto(String id) async {
    try {
      await FirebaseFirestore.instance.collection('produto').doc(id).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produto excluído com sucesso!')),
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
        final storageRef = FirebaseStorage.instance.ref().child('produtos/$id.jpg');
        await storageRef.putFile(_novaImagem!);
        return await storageRef.getDownloadURL();
      } catch (e) {
        print("Erro ao fazer upload da imagem: $e");
        return null;
      }
    }
    return null;
  }

  // Função para escanear o código de barras
  Future<void> _escanearCodigoBarras() async {
    try {
      var result = await BarcodeScanner.scan();
      setState(() {
        _codigoBarras = result.rawContent;
      });
    } catch (e) {
      print("Erro ao escanear o código de barras: $e");
    }
  }

  // Função para editar um produto
  Future<void> editarProduto(String id, String novoNome, String novoPreco, String novoPeso, String novaDescricao, String? novaImagemUrl) async {
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
      await FirebaseFirestore.instance.collection('produto').doc(id).update(dataAtualizada);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produto atualizado com sucesso!')),
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
        title: Text('Lista de Produtos'),
        backgroundColor: const Color.fromARGB(255, 55, 117, 199),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('produto').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Nenhum produto cadastrado.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              String id = doc.id;
              String nome = doc['nome'];
              String preco = doc['preco'].toString();
              String peso = doc['peso'].toString();
              String descricao = doc['descricao'];
              String imgProduto = doc['imgProduto'];
              
              final data = doc.data() as Map<String, dynamic>?; // Fazendo o cast para Map
             String? codigoBarras = data != null && data.containsKey('codigoBarras') ? data['codigoBarras'] : null;
             
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 5,
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.0),
                  leading: imgProduto.isNotEmpty
                      ? Image.network(
                          imgProduto,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.image, size: 50, color: Colors.grey),
                  title: Text(
                    nome,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: Colors.teal[700],
                    ),
                  ),
                  subtitle: Text(
                    'Preço: R\$$preco\nPeso: $peso g\nCódigo de Barras: ${codigoBarras ?? "Não cadastrado"}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              String novoNome = nome;
                              String novoPreco = preco.toString();
                              String novoPeso = peso.toString();
                              String novaDescricao = descricao;

                              return AlertDialog(
                                title: Text('Editar Produto'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      decoration: InputDecoration(labelText: 'Nome do Produto'),
                                      onChanged: (value) => novoNome = value,
                                      controller: TextEditingController(text: nome),
                                    ),
                                    TextField(
                                      decoration: InputDecoration(labelText: 'Preço'),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) => novoPreco = value,
                                      controller: TextEditingController(text: preco.toString()),
                                    ),
                                    TextField(
                                      decoration: InputDecoration(labelText: 'Peso (g)'),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) => novoPeso = value,
                                      controller: TextEditingController(text: peso.toString()),
                                    ),
                                    TextField(
                                      decoration: InputDecoration(labelText: 'Descrição'),
                                      onChanged: (value) => novaDescricao = value,
                                      controller: TextEditingController(text: descricao),
                                    ),
                                    SizedBox(height: 10),
                                    TextButton(
                                      onPressed: _selecionarImagem,
                                      child: Text('Selecionar nova imagem'),
                                    ),
                                    _novaImagem != null
                                        ? Image.file(
                                            _novaImagem!,
                                            width: 100,
                                            height: 100,
                                          )
                                        : Container(),
                                    TextButton(
                                      onPressed: _escanearCodigoBarras,
                                      child: Text('Adicionar código de barras'),
                                    ),
                                    _codigoBarras != null
                                        ? Text('Código de Barras: $_codigoBarras')
                                        : Container(),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      String? novaImagemUrl = await _uploadImagem(id);
                                      if (mounted) {
                                        editarProduto(id, novoNome, novoPreco, novoPeso, novaDescricao, novaImagemUrl);
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    child: Text('Salvar'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => excluirProduto(id),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
