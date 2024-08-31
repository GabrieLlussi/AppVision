import 'package:flutter/material.dart';
import 'produtos/produto_page.dart';
import 'package:projetomobile/carrinho/carrinho_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
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
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => TelaCadastroProduto()),
                );
              },
              child: Text('Cadastrar Produtos'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Navegar para a tela de carrinho de compras
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CarrinhoPage()),
                );
              },
              child: Text('Começar a Fazer Compras'),
            ),
          ],
        ),
      ),
    );
  }
}


