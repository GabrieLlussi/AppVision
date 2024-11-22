import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class TelaCadastroProduto extends StatefulWidget {
  const TelaCadastroProduto({super.key});

  @override
  TelaCadastroProdutoState createState() => TelaCadastroProdutoState();
}

class TelaCadastroProdutoState extends State<TelaCadastroProduto> {
  final formKey = GlobalKey<FormState>();

  String nome = '';
  String preco = '';
  String peso = '';
  String descricao = '';
  String? mercadoSelecionado;
  File ? imgProduto;
  bool isLoading = false;

  //Função para buscar e cadastrar supermercados
  List<Map<String, String>> mercado = [];

  @override
   void initState(){
    super.initState();
    buscarMercados();
   }

   Future<void> buscarMercados() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('mercado').get();
      final lista = snapshot.docs.map((doc) => {'id' : doc.id, 'nome':doc['nome'].toString()}).toList();

      setState(() {
        mercado = lista;
      });
    } catch (e) {
      print('Erro ao buscar estabelecimentos: $e');
    }
   }

  //Função para selecionar imagem
  Future<void> escolherImagem() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imgProduto = File(pickedFile.path);
      });
    }
  }

  //Função para fazer upload de imagem
  Future<String?> uploadImagem(File imgProduto) async {
    try{
      String nomeArquivo = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child('Vision').child(nomeArquivo);
      UploadTask uploadTask = ref.putFile(imgProduto);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Erro ao fazer upload da imagem: $e');
      return null;
    }
  }

  Future<void> salvarProduto() async {
    if (imgProduto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor escolha uma imagem')),
      );
      return;
    }
    if (mercadoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecione o estabelecimento')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      //Faz upload da imagem e obter a URL
      String? urlImagem =  await uploadImagem(imgProduto!);
      if (urlImagem == null) {
        throw 'Erro ao fazer upload da imagem';
      }

      //Salva o produto no banco
      await FirebaseFirestore.instance.collection('produto').add({
        'nome': nome,
        'preco': preco,
        'peso': peso,
        'descricao' : descricao,
        'imgProduto':urlImagem,
        'supermercado': mercadoSelecionado,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produto salvo com sucesso!')),
      );

      setState(() {
        nome = '';
        preco = '';
        peso = '';
        descricao = '';
        imgProduto = null;
        mercadoSelecionado = null;
        isLoading = false;
      });
      formKey.currentState?.reset();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar o produto: $e')),
      );
    }
  }

  void resetFields() {
    setState(() {
      nome = '';
      preco = '';
      peso = '';
      descricao = '';
      mercadoSelecionado = null;
    });
    formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Cadastro de Produto'),
      backgroundColor: const Color.fromARGB(255, 55, 117, 199),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Adicionar o texto de instrução
            const Text(
              'Preencha as informações do produto:',
              style: TextStyle(
                fontSize: 20.0, // Tamanho da fonte
                fontWeight: FontWeight.bold, // Negrito
                color: Color.fromARGB(255, 0, 0, 0), // Cor do texto
              ),
            ),
            const SizedBox(height: 15), // Espaço entre o texto e o formulário
            // Card para os campos do formulário
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Nome do Produto',
                        labelStyle: const TextStyle(color: Colors.teal),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          nome = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o nome de um produto';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Preço',
                        labelStyle: const TextStyle(color: Colors.teal),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          preco = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o preço do produto';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Peso (g)',
                        labelStyle: const TextStyle(color: Colors.teal),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          peso = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o peso do produto';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Descrição',
                        labelStyle: const TextStyle(color: Colors.teal),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          descricao = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira a descrição do produto';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Supermercado',
                        labelStyle: const TextStyle(color: Colors.teal),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0)
                        ),
                      ),
                      value:mercadoSelecionado,
                      items: mercado
                        .map((supermercado) => DropdownMenuItem(
                            value: supermercado['id'],
                            child: Text(supermercado['nome']!),
                        ))
                        .toList(),
                      onChanged: (value) {
                        setState(() {
                          mercadoSelecionado = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor selecione um estabelecimento';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: escolherImagem,
                      child: const Text('Escolher Imagem'),
                    ),
                    const SizedBox(height: 15),
                    if (imgProduto != null)
                      Image.file(imgProduto!, height: 150),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Botões de cancelar e salvar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: resetFields,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 209, 7, 7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (formKey.currentState!.validate()) {
                            salvarProduto();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 36, 102, 41),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Salvar'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}
