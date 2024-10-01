import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'package:path_provider/path_provider.dart';
//import 'package:firebase_core/firebase_core.dart';

class Carrinho extends StatefulWidget {
  @override
  _CarrinhoState createState() => _CarrinhoState();
}
  
  class _CarrinhoState extends State<Carrinho> {
  List<Map<String, dynamic>> carrinho = [];
  
  @override
    void initState(){
      super.initState();
      _fetchCarrinho();
    }
  
  Future<void> _fetchCarrinho() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot snapshot = await firestore.collection('carrinho').get();
      setState(() {
        carrinho = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'nome' : doc['nome'],
            'preco' : doc['preco'],
            'peso' : doc['peso'],
            'imgProduto' : doc['imgProduto']
          };
        }).toList();
      });
    } catch (e) {
      print("Erro ao buscar carrinho: $e");
    }
  }

  Future<void> _removeFromCart(String id) async {
    try {
      FirebaseFirestore firebase = FirebaseFirestore.instance;
      await firebase.collection('carrinho').doc(id).delete();
      setState(() {
        carrinho.removeWhere((produto) => produto['id'] == id);
      });
    } catch (e) {
      print("Erro ao remover produto do carrinho: $e");
    }
  }


  double _calcularTotal() {
  double sum = 0.0;
  for (var produto in carrinho) {
    double preco = double.parse(produto['preco'].toString());
    sum += preco;
  }
  return sum;
}

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carrinho de Compras'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 55, 117, 199),
      ),
      body: Column( 
        children: [
          Expanded(
            child: carrinho.isEmpty
              ? Center(child: Text('Carrinho vazio'))
            : ListView.builder(
              itemCount: carrinho.length,
              itemBuilder: (context, index) {
                final produto = carrinho[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: ListTile(
                    leading: produto['imgProduto'] != null && produto['imgProduto'].isNotEmpty
                    ? Image.network(
                      produto['imgProduto'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                    : Icon(Icons.image, size: 50, color: Colors.grey),

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
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeFromCart(produto['id']),
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
                Text(
                  'Total: R\$ ${_calcularTotal().toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
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
                backgroundColor: const Color.fromARGB(255, 55, 117, 199),
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              ),
              child: Text(
                'Finalizar Compra',
                style: TextStyle(fontSize: 30, color: Colors.black,
                fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
}

void main() => runApp(MaterialApp(
  home: Carrinho(),
  debugShowCheckedModeBanner: false,
));