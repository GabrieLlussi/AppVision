import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projetomobile/carrinho/carrinho_page.dart';
import 'produtos/produto_page.dart';
import 'package:projetomobile/produtos/tela_lista_produtos.dart'; // Importe a TelaListaProdutos para edição e exclusão de produtos
//import 'package:projetomobile/carrinho/carrinho_page.dart';
import 'package:projetomobile/mercado/cadastro_mercado.dart';
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
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Produtos',
                style: TextStyle(
                  color: Colors.blue, // Cor pétala (pode substituir por outra cor)
                  fontSize: 20.0, // Tamanho da fonte
                  fontWeight: FontWeight.bold, // Deixar o texto em negrito
                ),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Supermercados',
                style: TextStyle(
                  color: Colors.blue, // Cor pétala (pode substituir por outra cor)
                  fontSize: 20.0, // Tamanho da fonte
                  fontWeight: FontWeight.bold, // Deixar o texto em negrito
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.add_circle_outline),
              title: Text('Cadastrar estabelecimentos'),
              onTap: () {
                // Ação do botão Home
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CadastroMercado()),
                ); // Fechar o drawer
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Informações',
                style: TextStyle(
                  color: Colors.blue, // Cor pétala (pode substituir por outra cor)
                  fontSize: 20.0, // Tamanho da fonte
                  fontWeight: FontWeight.bold, // Deixar o texto em negrito
                ),
              ),
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

      //Tela inicial
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance.collection('mercado').get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('Nenhum estabelecimento disponível.'));
            }

            var mercados = snapshot.data!.docs;

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, //Num de colunas
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 0.75, //Proporção ajustada para mostrar imagens
                ),
                itemCount: mercados.length,
                itemBuilder: (context, index) {
                  var mercado = mercados[index];
                  var imageUrl = mercado['imgMercado']; 
                  var nome = mercado['nome'];

                  return GestureDetector(
                    onTap: () {
                      //Navegar para o catálogo de produtos correspondente
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CarrinhoPage(),
                          )
                      );
                    },
                  child: Card(
                    elevation: 5,
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            nome,
                            style: TextStyle(
                              fontSize: 16.0 * preferredFontSize,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 1, 4, 9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        )
      )
    );
  }
}


