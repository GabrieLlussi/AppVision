import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CarrinhoPage extends StatefulWidget {
  @override
  _CarrinhoPageState createState() => _CarrinhoPageState();
}

  class _CarrinhoPageState extends State<CarrinhoPage> {
  List<Map<String, dynamic>> produtos = [];

  @override
  void initState() {
    super.initState();
    _fetchProdutos();
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

  void adicionarProduto() {
    
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
                      /*child: Text(
                        produto['quantidade'].toString(),
                        style: TextStyle(color: Colors.white),
                      ),*/
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
                          onPressed: () => adicionarProduto(),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /*Text(
                  'Total: R\$ ${calcularTotal().toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),*/
                ElevatedButton(
                  onPressed: adicionarProduto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  ),
                  child: Text(
                    'Adicionar Item',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: ElevatedButton(
              onPressed: () {
                // Lógica para finalizar a compra
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
