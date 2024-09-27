import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class CadastroMercado extends StatefulWidget {
  @override
  CadastroMercadoState createState() => CadastroMercadoState();
}

class CadastroMercadoState extends State<CadastroMercado> {
  final formKey = GlobalKey<FormState>();

  String nome = '';
  File ? imgMercado;
  bool isLoading = false;

  //Função para selecionar imagem
  Future<void> escolherImagem() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imgMercado = File(pickedFile.path);
      });
    }
  }

  //Função para fazer upload de imagem
  Future<String?> uploadImagem(File imgMercado) async {
    try{
      String nomeArquivo = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child('Vision').child(nomeArquivo);
      UploadTask uploadTask = ref.putFile(imgMercado);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Erro ao fazer upload da imagem: $e');
      return null;
    }
  }

  Future<void> salvarProduto() async {
    if (imgMercado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor escolha uma imagem')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      //Faz upload da imagem e obter a URL
      String? urlImagem =  await uploadImagem(imgMercado!);
      if (urlImagem == null) {
        throw 'Erro ao fazer upload da imagem';
      }

      //Salva o produto no banco
      await FirebaseFirestore.instance.collection('produto').add({
        'nome': nome,
        'imgProduto':urlImagem,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produto salvo com sucesso!')),
      );

      setState(() {
        nome = '';
        imgMercado = null;
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
    });
    formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Cadastro de Estabelecimentos'),
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
            Text(
              'Preencha as informações do estabelecimento:',
              style: TextStyle(
                fontSize: 20.0, // Tamanho da fonte
                fontWeight: FontWeight.bold, // Negrito
                color: const Color.fromARGB(255, 0, 0, 0), // Cor do texto
              ),
            ),
            SizedBox(height: 15), // Espaço entre o texto e o formulário
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
                        labelText: 'Nome do estabelecimento',
                        labelStyle: TextStyle(color: Colors.teal),
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
                    
                    ElevatedButton(
                      onPressed: escolherImagem,
                      child: Text('Escolher Imagem'),
                    ),
                    SizedBox(height: 15),
                    if (imgMercado != null)
                      Image.file(imgMercado!, height: 150),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Botões de cancelar e salvar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: resetFields,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 209, 7, 7),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Cancelar'),
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
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text('Salvar'),
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
