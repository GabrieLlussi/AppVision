import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projetomobile/carrinho/carrinho_page.dart';
import 'produtos/produto_page.dart';
import 'package:projetomobile/produtos/tela_lista_produtos.dart'; // Importe a TelaListaProdutos para edição e exclusão de produtos
import 'package:projetomobile/mercado/cadastro_mercado.dart';
import 'package:projetomobile/gps/proximidade_estabelecimentos.dart';
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
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vision plus',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(), // Carrega a HomePage que é um StatefulWidget
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProximidadeEstabelecimento proximidadeEstabelecimento = ProximidadeEstabelecimento();
  Timer? _proximidadeTimer;

  @override
  void initState(){
    super.initState();

    _proximidadeTimer = Timer.periodic(Duration(seconds: 10), (timer){
      proximidadeEstabelecimento.verificarProximidade(context);
    });
  }

  @override
  void dispose() {
    _proximidadeTimer?.cancel(); //Cancela o timer quando sair da tela
    super.dispose();
  }

  Future<void> _reloadData() async {
    setState(() {

    });
  }

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
          IconButton(
          onPressed: _reloadData, 
          icon: const Icon(Icons.refresh),
          ),
          Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.menu), // Ícone do menu hamburger
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
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Image.asset('assets/visionPlusIcon.png'),
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
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
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Cadastrar produtos'),
              onTap: () {
                // Ação do botão Home
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TelaCadastroProduto()),
                ); // Fechar o drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Catálogo de produtos'),
              onTap: () {
                // Ação do botão Configurações
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TelaListaProdutos()),
                ); // Fechar o drawer
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
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
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Cadastrar estabelecimentos'),
              onTap: () {
                // Ação do botão Home
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CadastroMercado()),
                ); // Fechar o drawer
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
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
              leading: const Icon(Icons.gps_fixed),
              title: const Text('Coordenadas'),
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
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Nenhum estabelecimento disponível.'));
            }

            var mercados = snapshot.data!.docs;

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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


