//oi
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaListaProdutos extends StatefulWidget {
  @override
  _TelaListaProdutosState createState() => _TelaListaProdutosState();
}

class _TelaListaProdutosState extends State<TelaListaProdutos> {
  // Função para excluir um produto
  Future<void> excluirProduto(String id) async {
    try {
      await FirebaseFirestore.instance.collection('produto').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produto excluído com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir o produto: $e')),
      );
    }
  }

  // Função para editar um produto
  Future<void> editarProduto(String id, String novoNome, double novoPreco, double novoPeso) async {
    try {
      await FirebaseFirestore.instance.collection('produto').doc(id).update({
        'nome': novoNome,
        'preco': novoPreco,
        'peso': novoPeso,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produto atualizado com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar o produto: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Produtos'),
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
              double preco = doc['preco'];
              double peso = doc['peso'];

              return ListTile(
                title: Text(nome),
                subtitle: Text('Preço: \$${preco.toStringAsFixed(2)}, Peso: ${peso.toStringAsFixed(2)} KG'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        // Mostrar um diálogo para editar o produto
                        showDialog(
                          context: context,
                          builder: (context) {
                            String novoNome = nome;
                            String novoPreco = preco.toString();
                            String novoPeso = peso.toString();

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
                                    decoration: InputDecoration(labelText: 'Peso (KG)'),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) => novoPeso = value,
                                    controller: TextEditingController(text: peso.toString()),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    double precoDouble = double.tryParse(novoPreco) ?? 0.0;
                                    double pesoDouble = double.tryParse(novoPeso) ?? 0.0;
                                    editarProduto(id, novoNome, precoDouble, pesoDouble);
                                    Navigator.of(context).pop();
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
                      icon: Icon(Icons.delete),
                      onPressed: () => excluirProduto(id),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
