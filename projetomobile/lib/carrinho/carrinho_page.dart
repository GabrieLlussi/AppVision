import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:projetomobile/carrinho/carrinho.dart';
import 'package:projetomobile/carrinho/tela_detalhes.dart';

class CarrinhoPage extends StatefulWidget {
  @override
  _CarrinhoPageState createState() => _CarrinhoPageState();
}

class _CarrinhoPageState extends State<CarrinhoPage> {
  List<Map<String, dynamic>> produtos = [];

  @override
  void initState() {
    super.initState();
    _fetchProdutos();
    _startBarcodeScannerInBackground(); // Inicia o escaneamento em segundo plano
  }

  void _fetchProdutos() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Busca os produtos da coleção "produtos" no Firestore
    QuerySnapshot snapshot = await firestore.collection('produto').get();

    setState(() {
      // Converte os documentos para Map e adiciona à lista de produtos
      produtos = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'nome': doc['nome'],
          'preco': doc['preco'],
          'peso': doc['peso'],
          'descricao': doc['descricao'],
          'imgProduto': doc['imgProduto'],
        };
      }).toList();
    });
  }

  Future<void> _startBarcodeScannerInBackground() async {
    var cameraStatus = await Permission.camera.status;

    if (!cameraStatus.isGranted) {
      cameraStatus = await Permission.camera.request();
    }

    if (cameraStatus.isGranted) {
      while (mounted) {
        try {
          var result = await BarcodeScanner.scan(); // Lê o código de barras
          if (result.rawContent.isNotEmpty) {
            _buscarProdutoPorCodigoBarras(result.rawContent);
          }
        } catch (e) {
          print("Erro ao escanear o código de barras: $e");
        }
        await Future.delayed(Duration(seconds: 5)); // Atraso antes de escanear novamente
      }
    } else {
      print("Permissão da câmera negada.");
    }
  }

  void _buscarProdutoPorCodigoBarras(String codigoBarras) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    QuerySnapshot snapshot = await firestore
        .collection('produto')
        .where('codigoBarras', isEqualTo: codigoBarras)
        .get();

    Future<void> _escanearCodigoBarras() async {
  var cameraStatus = await Permission.camera.status;

  if (!cameraStatus.isGranted) {
    cameraStatus = await Permission.camera.request();
  }

  if (cameraStatus.isGranted) {
    try {
      var result = await BarcodeScanner.scan();
      String codigoBarrasEscaneado = result.rawContent;

      // Verifica se o código de barras foi escaneado corretamente
      if (codigoBarrasEscaneado.isNotEmpty) {
        // Busca o produto no Firestore com base no código de barras escaneado
        var produtoSnap = await FirebaseFirestore.instance
            .collection('produto')
            .where('codigoBarras', isEqualTo: codigoBarrasEscaneado)
            .get();

        // Verifica se encontrou algum produto
        if (produtoSnap.docs.isNotEmpty) {
          final fproduto = produtoSnap.docs.first.data() as Map<String, dynamic>?; // Obtém o primeiro produto

          if (fproduto != null && fproduto.containsKey('nome') && fproduto['nome'] != null) {
            // Produto identificado, exibe nome do produto
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Produto identificado: ${fproduto['nome']}')),
            );
          } else {
            // Produto não encontrado ou nome indisponível
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Produto não encontrado ou nome indisponível')),
            );
          }
        } else {
          // Nenhum produto foi encontrado com o código de barras fornecido
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Nenhum produto encontrado para o código de barras escaneado')),
          );
        }
      }
    } catch (e) {
      print("Erro ao escanear o código de barras: $e");
    }
  } else {
    print("Permissão da câmera negada.");
  }
}
  }

  void __addToCart(Map<String, dynamic> produto) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    await firestore.collection('carrinho').add(produto);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${produto['nome']} adicionado ao carrinho')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catálogo de produtos'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 55, 117, 199),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: produtos.length,
              itemBuilder: (context, index) {
                final produto = produtos[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Container(
                            width: 100,
                            height: 150,
                            color: Colors.grey[200],
                            child: produto['imgProduto'] != null &&
                                    produto['imgProduto'].isNotEmpty
                                ? Image.network(
                                    produto['imgProduto'],
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.image,
                                          size: 100, color: Colors.grey);
                                    },
                                  )
                                : Icon(Icons.image,
                                    size: 100, color: Colors.grey),
                          ),
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                produto['nome'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24.0,
                                  color: Colors.teal[800],
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                'Preço: R\$ ${double.parse(produto['preco']).toStringAsFixed(2)}\n'
                                'Peso: ${double.parse(produto['peso']).toStringAsFixed(2)} g',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: const Color.fromARGB(255, 3, 3, 3),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.add_shopping_cart_outlined,
                                  color: Colors.red, size: 40),
                              onPressed: () => __addToCart(produto),
                            ),
                            IconButton(
                              icon: Icon(Icons.info,
                                  color: Colors.blue, size: 45),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TelaDetalhes(produto: produto),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Carrinho()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              ),
              child: Text(
                'Carrinho',
                style: TextStyle(fontSize: 25, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}