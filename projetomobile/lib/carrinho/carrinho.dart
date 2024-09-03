import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
// ignore: unused_import
import 'dart:convert';

class Carrinho extends StatefulWidget {
  @override
  _CarrinhoState createState() => _CarrinhoState();
}
  
  class _CarrinhoState extends State<Carrinho> {
  List<Map<String, dynamic>> produtos = [];
  
  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<File> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/carrinho.txt');
  }

  Future<void> _loadCart() async {
    final file = await _getFilePath();
    if (await file.exists()) {
      List<String> lines = await file.readAsLines();
      setState(() {
        produtos = lines.map((line) {
          final Map<String, dynamic> produto = {};
            line.split(', ').forEach((entry) {
              final List<String> keyValue = entry.split(': ');
              if (keyValue.length == 2) {
                produto[keyValue[0]] = keyValue[1];
              }
            });
          return produto;
        }).toList();
         print('Produtos carregados: ${produtos.length}');
      });
    }
  }

  void excluirProduto(int index) {
    setState(() {
      produtos.removeAt(index);
      _saveCart(); // Atualiza o arquivo após excluir
    });
  }

  /*double calcularTotal() {
    return produtos.fold(0, (soma, item) {
      double preco = double.tryParse(item['preco']) ?? 0;
      int quantidade = int.tryParse(item['quantidade']) ?? 1;
      return soma + preco * quantidade;
    });
  }
*/
  Future<void> _saveCart() async {
    final file = await _getFilePath();
    String produtosJson = produtos.map((produto) => produto.toString()).join('\n');
    await file.writeAsString(produtosJson);
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
            child: produtos.isEmpty
              ? Center(child: Text('Carrinho vazio'))
            : ListView.builder(
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
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => excluirProduto(index),
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
              /*children: [
                Text(
                  'Total: R\$ ${calcularTotal().toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],*/
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
  home: Carrinho(),
  debugShowCheckedModeBanner: false,
));