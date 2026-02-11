import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mo Kache',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final Random _random = Random();

  // List of words with hints
  final List<Map<String, String>> _words = [
    {'word': 'BONJOU', 'hint': 'Se yon mo ki itilize pou salye moun'},
    {'word': 'HELLO', 'hint': 'Anglè - pou salye'},
    {'word': 'FLUTTER', 'hint': 'Yon SDK pou UI pa Google'},
    {'word': 'MIZIK', 'hint': 'Li gen rapò ak son ak melodi'},
    {'word': 'EDIKASYON', 'hint': 'Yon pwosesis aprantisaj'},
  ];

  late String _word; // chosen word (uppercase)
  late List<bool> _revealed;
  late String _hint;
  int _chances = 5;
  final Set<String> _used = {}
  ;

  final List<String> _qwerty = const [
    'Q','W','E','R','T','Y','U','I','O','P',
    'A','S','D','F','G','H','J','K','L',
    'Z','X','C','V','B','N','M'
  ];

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame(){
    final el = _words[_random.nextInt(_words.length)];
    _word = el['word']!.toUpperCase();
    _hint = el['hint']!;
    _revealed = List<bool>.filled(_word.length, false);
    _chances = 5;
    _used.clear();
    setState((){});
  }

  void _onKeyTap(String letter){
    if(_used.contains(letter) || _chances<=0) return;
    setState((){
      _used.add(letter);
      if(_word.contains(letter)){
        for(int i=0;i<_word.length;i++){
          if(_word[i]==letter) _revealed[i]=true;
        }
        if(_revealed.every((v)=>v)){
          // Win
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_)=> ResultPage(win: true, word: _word, onPlayAgain: _startNewGame),
          ));
        }
      } else {
        _chances--;
        if(_chances<=0){
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_)=> ResultPage(win: false, word: _word, onPlayAgain: _startNewGame),
          ));
        }
      }
    });
  }

  Widget _buildMaskedWord(){
    final chars = <Widget>[];
    for(int i=0;i<_word.length;i++){
      final ch = _word[i];
      final show = _revealed[i];
      chars.add(Container(
        padding: const EdgeInsets.symmetric(horizontal:8, vertical:6),
        child: Text(show? ch : '*', style: const TextStyle(fontSize: 28, letterSpacing: 2)),
      ));
    }
    return Wrap(alignment: WrapAlignment.center, children: chars);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chances: $_chances')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Endis: $_hint', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            Center(child: _buildMaskedWord()),
            const SizedBox(height: 24),
            const Text('Chwazi yon lèt:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 10,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: _qwerty.map((k){
                  final used = _used.contains(k);
                  return ElevatedButton(
                    onPressed: used || _chances<=0 ? null : ()=> _onKeyTap(k),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: used? Colors.grey : null,
                      padding: const EdgeInsets.all(8),
                    ),
                    child: Text(k, style: const TextStyle(fontSize: 16)),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  final bool win;
  final String word;
  final VoidCallback onPlayAgain;

  const ResultPage({super.key, required this.win, required this.word, required this.onPlayAgain});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(win? Icons.celebration : Icons.sentiment_dissatisfied, size: 80, color: win? Colors.green : Colors.red),
              const SizedBox(height: 16),
              Text(win? 'Ou genyen!' : 'Ou pèdi', style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Text('Mo a te: $word', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: (){
                  onPlayAgain();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> const GamePage()));
                },
                child: const Text('Jwe ankò'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
