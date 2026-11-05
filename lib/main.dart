import 'package:flutter/material.dart';
import 'ui/home_screen.dart';

void main() => runApp(const TicTacToeApp());

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xs and Os',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.black),
      home: const HomeScreen(),
    );
  }
}
