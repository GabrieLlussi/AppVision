import 'package:flutter/material.dart';
import 'produtos/produto_page.dart';
import 'package:projetomobile/produtos/tela_lista_produtos.dart'; // Importe a TelaListaProdutos para edição e exclusão de produtos
import 'package:projetomobile/carrinho/carrinho_page.dart';
import 'package:projetomobile/carrinho/carrinho.dart';
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
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Bem-vindo ao aplicativo Vision+ ',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold, color: Colors.teal[700]),
            ),
            SizedBox(height: 20),
            Text(
              'Este aplicativo ajuda pessoas com deficiência visual a realizar compras de forma independente.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.0, color: Colors.grey[700]),
            ),
            SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                // Navegar para a tela de cadastro de produtos
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => TelaCadastroProduto()),
                );
              },
              icon: Icon(Icons.add_circle_outline),
              label: Text('Cadastrar Produtos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal, //Cor do botão
                foregroundColor: Colors.white, //Cor do texto
                padding: EdgeInsets.symmetric(vertical: 15.0),
                textStyle: TextStyle(fontSize: 18.0),
              ),
            ),
            SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: () {
                // Navegar para a tela de carrinho de compras
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CarrinhoPage()),
                );
              },
              icon: Icon(Icons.shopping_cart_outlined),
              label: Text('Começar a fazer compras'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal, //Cor do botão
                foregroundColor: Colors.white, //Cor do texto
                padding: EdgeInsets.symmetric(vertical: 15.0),
                textStyle: TextStyle(fontSize: 18.0),
              ),
            ),
            SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: () {
                // Navegar para a tela do carrinho
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Carrinho()),
                );
              },
              icon: Icon(Icons.shopping_basket_outlined),
              label: Text('Carrinho'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal, // Cor do botão
                foregroundColor: Colors.white, // Cor do texto
                padding: EdgeInsets.symmetric(vertical: 15.0),
                textStyle: TextStyle(fontSize: 18.0),
              ),
            ),
            SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: () {
                // Navegar para a tela de edição de produtos
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TelaListaProdutos()),
                );
              },
              icon: Icon(Icons.edit_outlined),
              label: Text('Editar Pedido'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal, // Cor do botão
                foregroundColor: Colors.white, // Cor do texto
                padding: EdgeInsets.symmetric(vertical: 15.0),
                textStyle: TextStyle(fontSize: 18.0),
            ),
            ),
          ],
        ),
      ),
    );
  }
}


