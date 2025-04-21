import 'package:flutter/material.dart';
import 'talk_repository.dart';
import 'models/talk.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyTEDx',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, this.title = 'MyTEDx'});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  late Future<List<Talk>> _talks;
  int page = 1;
  bool init = true;

  @override
  void initState() {
    super.initState();
    _talks = initEmptyList();
  }

  void _getTalksByTag() {
    setState(() {
      init = false;
      _talks = getTalksByTag(_controller.text, page);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My TEDx App')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: init
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter your favorite talk',
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    child: const Text('Search by tag'),
                    onPressed: () {
                      page = 1;
                      _getTalksByTag();
                    },
                  ),
                ],
              )
            : FutureBuilder<List<Talk>>(
                future: _talks,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final talks = snapshot.data!;
                    return Column(
                      children: [
                        Text(
                          "#${_controller.text}",
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: talks.length,
                            itemBuilder: (context, index) {
                              final talk = talks[index];
                              final isEven = index % 2 == 0;

                              return Container(
                                color:
                                    isEven ? Colors.white : Colors.red.shade50,
                                child: ListTile(
                                  subtitle: Text(talk.mainSpeaker),
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(talk.title),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 6,
                                        children: talk.keyPhrases
                                            .map((k) => Chip(
                                                  label: Text(k,
                                                      style: const TextStyle(
                                                          fontSize: 12)),
                                                  backgroundColor:
                                                      Colors.red.shade100,
                                                ))
                                            .toList(),
                                      ),
                                    ],
                                  ),
                                  onTap: () => ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                          content: Text(talk.details))),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }

                  return const Center(child: CircularProgressIndicator());
                },
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: (!init)
          ? FloatingActionButton(
              child: const Icon(Icons.arrow_drop_down),
              onPressed: () {
                setState(() {
                  page += 1;
                  _getTalksByTag();
                });
              },
            )
          : null,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                setState(() {
                  init = true;
                  page = 1;
                  _controller.clear();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
