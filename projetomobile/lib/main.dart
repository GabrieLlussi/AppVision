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
    // Obter o tamanho preferido da fonte do usuário
    double preferredFontSize = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vision+',
          style: TextStyle(fontSize: 24.0 * preferredFontSize),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Vision+',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 70.0 * preferredFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.teal[800], // Maior contraste
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Este aplicativo ajuda pessoas com baixa visão a realizar compras de forma independente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.0 * preferredFontSize, // Aumentar o tamanho da fonte
                color: Colors.black87, // Maior contraste
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                // Fornecer feedback auditivo
                // Navegar para a tela de cadastro de produtos
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => TelaCadastroProduto()),
                );
              },
              icon: Icon(Icons.add_circle_outline, size: 30 * preferredFontSize), // Ícones maiores
              label: Text(
                'Cadastrar Produtos',
                style: TextStyle(fontSize: 22.0 * preferredFontSize), // Aumentar o tamanho do texto
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 20.0), // Mais espaço para toque
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
              icon: Icon(Icons.shopping_cart_outlined, size: 30 * preferredFontSize),
              label: Text(
                'Começar a fazer compras',
                style: TextStyle(fontSize: 22.0 * preferredFontSize),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 20.0),
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
              icon: Icon(Icons.shopping_basket_outlined, size: 30 * preferredFontSize),
              label: Text(
                'Carrinho',
                style: TextStyle(fontSize: 22.0 * preferredFontSize),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 20.0),
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
              icon: Icon(Icons.edit_outlined, size: 30 * preferredFontSize),
              label: Text(
                'Editar Pedido',
                style: TextStyle(fontSize: 22.0 * preferredFontSize),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 20.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


