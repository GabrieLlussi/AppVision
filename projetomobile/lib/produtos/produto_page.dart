import 'package:flutter/material.dart';


class TelaCadastroProduto extends StatefulWidget{
  @override
  TelaCadastroProdutoState createState() => TelaCadastroProdutoState();

}

class TelaCadastroProdutoState extends State<TelaCadastroProduto> {
  final formKey = GlobalKey<FormState>();

  String nome = '';
  String preco = '';
  String peso = '';
  
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
                validator: (value){
                  if (value == null || value.isEmpty){
                    return 'Por favor, insira o nome de um produto';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Preço'),
                keyboardType: TextInputType.number,
                onChanged: (value){
                  setState(() {
                    preco = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty){
                    return 'Por favor, insira o preço do produto';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Peso (KG)'),
                keyboardType: TextInputType.number,
                onChanged: (value){
                  setState(() {
                    peso = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty){
                    return 'Por favor, insira o peso do produto';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()){
                      //Ação de salvar o produto
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Produto salvo com sucesso!')),
                      );
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