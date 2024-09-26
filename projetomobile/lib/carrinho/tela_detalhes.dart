import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projetomobile/carrinho/carrinho.dart';

class TelaDetalhes extends StatelessWidget {
  final Map<String, dynamic> produto; // ou outro tipo dependendo de como seu produto está definido

  TelaDetalhes({required this.produto});

  void _addToCart(BuildContext context, Map<String, dynamic> produto) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    await firestore.collection('carrinho').add(produto);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${produto['nome']} adicionado ao carrinho'))
    );
  }

    final FlutterTts _flutterTts = FlutterTts();

    Future<void> _falarDescricao(String texto) async {
    await _flutterTts.speak(texto);
  }
  

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return Scaffold(
      appBar: AppBar(title: Text(produto['nome'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(produto['imgProduto']),
            SizedBox(height: 10),
            Text('Nome: ${produto['nome']}', style: TextStyle(fontSize: 20)),
            Text('Preço: R\$${produto['preco']}', style: TextStyle(fontSize: 18)),
            Text('Peso: ${produto['peso']}g', style: TextStyle(fontSize: 18)),
            //Text('Descrição: ${produto['descricao']}', style: TextStyle(fontSize: 18)),
            GestureDetector(
              onTap: () => _falarDescricao(produto['descricao'] ?? 'Descrição não disponível'),
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text('${produto['descricao']}', style: TextStyle(fontSize: 18)),
                ),
            ),
            SizedBox(height: 20,),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton( 
                 icon: Icon(Icons.add, color: Colors.blue),
                 onPressed: () => _addToCart(context, produto),
                 ),
                 IconButton(
                  icon: Icon(Icons.shopping_cart, color: Colors.red),

  // Obter o tamanho preferido da fonte do usuário
  double preferredFontSize = MediaQuery.of(context).textScaleFactor;

  return Scaffold(
    appBar: AppBar(
      title: Text(
        produto['nome'],
        style: TextStyle(fontSize: 24.0 * preferredFontSize),
      ),
      backgroundColor: const Color.fromARGB(255, 55, 117, 199),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem grande do produto
          Container(
            height: 400, // Altura maior para a imagem
            width: double.infinity, // Largura total da tela
            child: Image.network(
              produto['imgProduto'],
              fit: BoxFit.cover, // Preencher o container
            ),
          ),
          SizedBox(height: 20),
          // Exibir o nome do produto com maior destaque
          Text(
            '${produto['nome']}',
            style: TextStyle(
              fontSize: 30 * preferredFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87, // Maior contraste
            ),
          ),
          SizedBox(height: 10),
          // Maior destaque para o preço
          Text(
            'Preço: R\$${produto['preco']}',
            style: TextStyle(
              fontSize: 26 * preferredFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.teal[800], // Maior contraste
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Peso: ${produto['peso']}g',
            style: TextStyle(
              fontSize: 22 * preferredFontSize,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Descrição: ${produto['descricao']}',
            style: TextStyle(
              fontSize: 22 * preferredFontSize,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 30),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Adicionar Semantics aos botões
              Semantics(
                label: 'Adicionar ao carrinho',
                child: ElevatedButton.icon(
                  onPressed: () {
                    _addToCart(context, produto);
                    // Fornecer feedback auditivo
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Produto adicionado ao carrinho.'),
                      ),
                    );
                  },
                  icon: Icon(Icons.add, size: 30 * preferredFontSize),
                  label: Text(
                    'Adicionar',
                    style: TextStyle(fontSize: 22.0 * preferredFontSize),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                  ),
                ),
              ),
              SizedBox(width: 20),
              Semantics(
                label: 'Ir para o carrinho de compras',
                child: ElevatedButton.icon(
>>>>>>> d207ef1ece0231566c9e40e50446d7cc31b18567
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Carrinho()),
                    );
                  },
                  icon: Icon(Icons.shopping_cart, size: 30 * preferredFontSize),
                  label: Text(
                    'Carrinho',
                    style: TextStyle(fontSize: 22.0 * preferredFontSize),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}
