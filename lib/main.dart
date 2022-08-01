import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de produtos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
//Para poder atualizar os valores, precisamos controlar eles:
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();

  final CollectionReference _produtos =
      FirebaseFirestore.instance.collection('produtos');

  //Método para atualizar as informações
  Future<void> _update([DocumentSnapshot? documentSnapShot]) async {
    if (documentSnapShot != null) {
      _nomeController.text = documentSnapShot['nome'];
      _precoController.text = documentSnapShot['preco'].toString();
    }
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nomeController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  controller: _precoController,
                  decoration: const InputDecoration(
                    labelText: 'Preço',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: const Text('Atualizar'),
                  onPressed: () async {
                    final String nome = _nomeController.text;
                    final double? preco =
                        double.tryParse(_precoController.text);
                    if (preco != null) {
                      await _produtos
                          .doc(documentSnapShot!.id)
                          .update({"nome": nome, "preco": preco});
                      _nomeController.text = '';
                      _precoController.text = '';
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          );
        });
  }

//Método para inserir informações
  Future<void> _create([DocumentSnapshot? documentSnapShot]) async {
    if (documentSnapShot != null) {
      _nomeController.text = documentSnapShot['nome'];
      _precoController.text = documentSnapShot['preco'].toString();
    }
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nomeController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  controller: _precoController,
                  decoration: const InputDecoration(
                    labelText: 'Preço',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: const Text('Adicionar Produto'),
                  onPressed: () async {
                    final String nome = _nomeController.text;
                    final double? preco =
                        double.tryParse(_precoController.text);
                    if (preco != null) {
                      await _produtos.add({"nome": nome, 'preco': preco});
                      _nomeController.text = '';
                      _precoController.text = '';
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
          );
        });
  }

//Método para deletar informações
  Future<void> _deletar(String productId) async {
    await _produtos.doc(productId).delete();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Produto deletado com sucesso!'),
    ));
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Lista de produtos'),
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 500.0,
                width: double.infinity,
                color: Colors.white,
                child: StreamBuilder(
                  stream: _produtos.snapshots(), //constroi a conexão
                  builder:
                      (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                    if (streamSnapshot.hasData) {
                      return ListView.builder(
                        itemCount: streamSnapshot
                            .data!.docs.length, //número de colunas
                        itemBuilder: (context, index) {
                          final DocumentSnapshot documentSnapshot =
                              streamSnapshot.data!.docs[index];
                          return Card(
                            margin: const EdgeInsets.all(10),
                            child: ListTile(
                              title: Text(documentSnapshot['nome']),
                              subtitle:
                                  Text(documentSnapshot['preco'].toString()),
                              trailing: SizedBox(
                                  width: 100,
                                  child: Row(
                                    children: [
                                      IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () =>
                                              _update(documentSnapshot)),
                                      IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () =>
                                              _deletar(documentSnapshot.id)),
                                    ],
                                  )),
                            ),
                          );
                        },
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Add new product
        floatingActionButton: FloatingActionButton(
          onPressed: () => _create(),
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
