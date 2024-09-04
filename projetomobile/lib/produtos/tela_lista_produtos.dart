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
  Future<void> editarProduto(String id, String novoNome, String novoPreco, String novoPeso) async {
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
        backgroundColor: Colors.teal,
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

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 5,
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.0),
                  title: Text(
                    nome,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: Colors.teal[700],
                    ),
                  ),
                  subtitle: Text(
                    'Preço: R\$$preco\nPeso: $peso g',
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
                                      editarProduto(id, novoNome, novoPreco, novoPeso);
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
