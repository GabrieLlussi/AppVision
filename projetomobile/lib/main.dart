import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vision+',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vision+'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Bem-vindo ao aplicativo de inclusão social!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Este aplicativo ajuda pessoas com deficiência visual a realizar compras de forma independente.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Navegar para a tela de cadastro de produtos
              },
              child: Text('Cadastrar Produtos'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Navegar para a tela de carrinho de compras
              },
              child: Text('Começar a Fazer Compras'),
            ),
          ],
        ),
      ),
    );
  }
}


