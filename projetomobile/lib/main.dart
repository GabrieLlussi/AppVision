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
        backgroundColor: const Color.fromARGB(255, 55, 117, 199),
        actions: [
          Builder(
              builder: (context) {
                return IconButton(
                  icon: Icon(Icons.menu), // Ícone do menu hamburger
                  onPressed: () {
                    // Ação ao clicar no botão
                    Scaffold.of(context).openEndDrawer();
                  },
                );
            },
          ),
        ],
      ),

      //Botões do menu sanduíche
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Image.asset('assets/visionPlusIcon.png'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              leading: Icon(Icons.add_circle_outline),
              title: Text('Cadastrar produtos'),
              onTap: () {
                // Ação do botão Home
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TelaCadastroProduto()),
                ); // Fechar o drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.edit_outlined),
              title: Text('Catálogo de produtos'),
              onTap: () {
                // Ação do botão Configurações
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TelaListaProdutos()),
                ); // Fechar o drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.gps_fixed),
              title: Text('Coordenadas'),
              onTap: () {
                // Ação do botão Sobre
                Navigator.pop(context); // Fechar o drawer
              },
            ),
          ],
        ),
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
                color: const Color.fromARGB(255, 55, 117, 199), // Maior contraste
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
                backgroundColor: const Color.fromARGB(255, 55, 117, 199),
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


