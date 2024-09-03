import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:path_provider/path_provider.dart';
import 'package:projetomobile/carrinho/carrinho.dart';


class CarrinhoPage extends StatefulWidget {
  @override
  _CarrinhoPageState createState() => _CarrinhoPageState();
}

  class _CarrinhoPageState extends State<CarrinhoPage> {
  List<Map<String, dynamic>> produtos = [];

  @override
  void initState() {
    super.initState();
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
          'id': doc.id,
          'nome': doc['nome'],
          'preco': doc['preco'],
          'peso': doc['peso'],
          /*'quantidade': doc['quantidade'],*/
        };
      }).toList();
    });
  }

  void __addToCart(Map<String, dynamic> produto) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    await firestore.collection('carrinho').add(produto);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${produto['nome']} adicionado ao carrinho'))
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
                        Text('Preço: R\$ ${double.parse(produto['preco']).toStringAsFixed(2)}'),
                        Text('Peso: ${double.parse(produto['peso']).toStringAsFixed(2)} g'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.add, color: Colors.blue),
                          onPressed: () => __addToCart(produto),
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