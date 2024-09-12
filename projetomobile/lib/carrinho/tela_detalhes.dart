import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projetomobile/carrinho/carrinho.dart';

class TelaDetalhes extends StatelessWidget {
  final Map<String, dynamic> produto; // ou outro tipo dependendo de como seu produto está definido

  TelaDetalhes({required this.produto});

  void _addToCart(BuildContext context, Map<String, dynamic> produto) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    await firestore.collection('carrinho').add(produto);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${produto['nome']} adicionado ao carrinho'))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(produto['nome'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(produto['imgProduto']),
            SizedBox(height: 10),
            Text('Nome: ${produto['nome']}', style: TextStyle(fontSize: 20)),
            Text('Preço: R\$${produto['preco']}', style: TextStyle(fontSize: 18)),
            Text('Peso: ${produto['peso']}g', style: TextStyle(fontSize: 18)),
            Text('Descrição: ${produto['descricao']}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20,),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton( 
                 icon: Icon(Icons.add, color: Colors.blue),
                 onPressed: () => _addToCart(context, produto),
                 ),
                 IconButton(
                  icon: Icon(Icons.shopping_cart, color: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Carrinho()),
                    );
                  },
                 )
              ],
            )
          ],
        ),
      )
    ); 
  }
}