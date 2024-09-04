import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaCadastroProduto extends StatefulWidget {
  @override
  TelaCadastroProdutoState createState() => TelaCadastroProdutoState();
}

class TelaCadastroProdutoState extends State<TelaCadastroProduto> {
  final formKey = GlobalKey<FormState>();

  String nome = '';
  String preco = '';
  String peso = '';

  bool isLoading = false;

  Future<void> salvarProduto() async {
    setState(() {
      isLoading = true;
    });
    try {
      await FirebaseFirestore.instance.collection('produto').add({
        'nome': nome,
        'preco': preco,
        'peso': peso,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produto salvo com sucesso!')),
      );

      setState(() {
        nome = '';
        preco = '';
        peso = '';
        isLoading = false;
      });
      formKey.currentState?.reset();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar o produto: $e')),
      );
    }
  }

  void resetFields() {
    setState(() {
      nome = '';
      preco = '';
      peso = '';
    });
    formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Produto'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Nome do Produto',
                          labelStyle: TextStyle(color: Colors.teal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            nome = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o nome de um produto';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Preço',
                          labelStyle: TextStyle(color: Colors.teal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            preco = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o preço do produto';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Peso (KG)',
                          labelStyle: TextStyle(color: Colors.teal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            peso = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o peso do produto';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: resetFields,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 209, 7, 7),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (formKey.currentState!.validate()) {
                              salvarProduto();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 2, 228, 88),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text('Salvar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
