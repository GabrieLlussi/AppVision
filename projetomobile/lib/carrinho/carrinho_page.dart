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
  List<Map<String, dynamic>> carrinho = [];

  @override
  void initState() {
    super.initState();
    _fetchProdutos(); // Busca os produtos do Firestore
    _loadCart(); //Carrega o carrinho salvo localmente
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

  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/carrinho.txt';
  }

  Future<void> _saveCart() async {
    final filePath = await _getFilePath();
    final file = File(filePath);
    String carrinhoJson = json.encode(carrinho);
    await file.writeAsString(carrinhoJson);
  }

  Future<void> _loadCart() async {
    final filePath = await _getFilePath();
    final file = File(filePath);

    if (await file.exists()) {
      String carrinhoJson = await file.readAsString();
      setState(() {
        carrinho = List<Map<String, dynamic>>.from(json.decode(carrinhoJson));
      });
    }
  }

  void _addToCart(Map<String, dynamic> produto) {
    setState(() {
      carrinho.add(produto);
    });
    _saveCart();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${produto['nome']} adicionado ao carrinho')),
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
                          onPressed: () => _addToCart(produto),
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
