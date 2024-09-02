import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:projetomobile/carrinho/carrinho.dart';
import 'dart:convert';

class CarrinhoPage extends StatefulWidget {
  @override
  _CarrinhoPageState createState() => _CarrinhoPageState();
}

  class _CarrinhoPageState extends State<CarrinhoPage> {
  List<Map<String, dynamic>> produtos = [];
  List<Map<String, dynamic>> produtosCarrinho = [];

  @override
  void initState() {
    super.initState();
    _loadCart(); // Carrega o carrinho do arquivo
    _fetchProdutos(); // Busca os produtos do Firestore
  }

  void _fetchProdutos() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Busca os produtos da coleção "produtos" no Firestore
    QuerySnapshot snapshot = await firestore.collection('produto').get();

    setState(() {
      // Converte os documentos para Map e adiciona à lista de produtos
      produtos = snapshot.docs.map((doc) {
        return {
          'nome': doc['nome'],
          'preco': doc['preco'],
          'peso': doc['peso'],
          /*'quantidade': doc['quantidade'],*/
        };
      }).toList();
    });
  }

  // Obtém o diretório onde o arquivo será salvo
  Future<String> _getFilePath() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    String filePath = '${appDocumentsDirectory.path}/carrinho.txt';
    return filePath;
  }

  // Salva os itens do carrinho no arquivo
 Future<void> _saveCart() async {
  String filePath = await _getFilePath();
  File file = File(filePath);

  String cartData = jsonEncode(produtosCarrinho); // Salvar como JSON

  await file.writeAsString(cartData);
}

 // Carrega os itens do carrinho do arquivo
  Future<void> _loadCart() async {
    String filePath = await _getFilePath();
    File file = File(filePath);

    if (await file.exists()) {
      String cartData = await file.readAsString();
      setState(() {
        produtos = cartData.split('\n').map((line) {
          List<String> parts = line.split('|');
          return {
            'nome': parts[0],
            'preco': double.parse(parts[1]),
            'peso': double.parse(parts[2]),
          };
        }).toList();
      });
    }
  } 

  void adicionarProduto(Map<String, dynamic> produto) {
    setState(() {
      produtosCarrinho.add(produto);
    });
    _saveCart(); // Salva o carrinho após adicionar o produto
    // Exibe um Snackbar para informar que o produto foi adicionado
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Produto adicionado ao carrinho'),
      duration: Duration(seconds: 2),
    ),
  );
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carrinho de Compras'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Column( 
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: produtos.length,
              itemBuilder: (context, index) {
                final produto = produtos[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal,                   
                    ),
                    title: Text(produto['nome']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Preço: R\$ ${produto['preco'].toStringAsFixed(2)}'),
                        Text('Peso: ${produto['peso'].toStringAsFixed(2)} g'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.add, color: Colors.blue),
                          onPressed: () => adicionarProduto({
                            'nome': produto['nome'],
                            'preco': produto['preco'],
                            'peso': produto['peso'],
                          }),
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
                // Navegar para a tela de carrinho de compras
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Carrinho()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 153, 94, 248),
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              ),
              child: Text(
                'Finalizar Compra',
                style: TextStyle(fontSize: 22, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
}

void main() => runApp(MaterialApp(
  home: CarrinhoPage(),
  debugShowCheckedModeBanner: false,
));
