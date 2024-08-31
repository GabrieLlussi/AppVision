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

  // Função para salvar o produto no Firestore
  Future<void> salvarProduto() async {
    try {
      // Convertendo preço e peso para números, se necessário
      double precoDouble = double.tryParse(preco) ?? 0.0;
      double pesoDouble = double.tryParse(peso) ?? 0.0;

      // Salvando no Firestore
      await FirebaseFirestore.instance.collection('produto').add({
        'nome': nome,
        'preco': precoDouble,
        'peso': pesoDouble,
      });

      // Mostra uma mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produto salvo com sucesso!')),
      );

      // Limpar os campos após salvar
      setState(() {
        nome = '';
        preco = '';
        peso = '';
      });
      formKey.currentState?.reset();
    } catch (e) {
      // Mostra uma mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar o produto: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de produto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nome do Produto'),
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
              TextFormField(
                decoration: InputDecoration(labelText: 'Preço'),
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
              TextFormField(
                decoration: InputDecoration(labelText: 'Peso (KG)'),
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
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      salvarProduto();
                    }
                  },
                  child: Text('Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
