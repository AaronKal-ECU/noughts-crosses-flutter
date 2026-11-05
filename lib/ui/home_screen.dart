import 'package:flutter/material.dart';
import '../game/types.dart';
import '../data/stats_store.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GameMode mode = GameMode.twoPlayer;
  Difficulty difficulty = Difficulty.easy;

  final _store = StatsStore();
  AiStats? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final s = await _store.load();
    if (!mounted) return;
    setState(() {
      _stats = s;
      _loading = false;
    });
  }

  Future<void> _resetStats() async {
    await _store.reset();
    await _loadStats();
  }

  Future<void> _startGame() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameScreen(mode: mode, difficulty: difficulty)),
    );
    // refresh after returning from a finished game 
    await _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Noughts & Crosses')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // game mode selector
              const Text('Game Mode'),
              const SizedBox(height: 6),
              DropdownButton<GameMode>(
                value: mode,
                items: const [
                  DropdownMenuItem(value: GameMode.twoPlayer, child: Text('2 Player')),
                  DropdownMenuItem(value: GameMode.vsAI, child: Text('1 Player (vs AI)')),
                ],
                onChanged: (m) => setState(() => mode = m!),
              ),

              // difficulty vs AI
              if (mode == GameMode.vsAI) ...[
                const SizedBox(height: 12),
                const Text('Difficulty'),
                const SizedBox(height: 6),
                DropdownButton<Difficulty>(
                  value: difficulty,
                  items: const [
                    DropdownMenuItem(value: Difficulty.easy, child: Text('Easy')),
                    DropdownMenuItem(value: Difficulty.medium, child: Text('Medium')),
                    DropdownMenuItem(value: Difficulty.hard, child: Text('Hard')),
                  ],
                  onChanged: (d) => setState(() => difficulty = d!),
                ),
              ],

              const SizedBox(height: 16),
              ElevatedButton(onPressed: _startGame, child: const Text('Start')),

              // scoreboard
              const SizedBox(height: 24),
              const Text('Results vs AI'),
              const SizedBox(height: 6),
              _loading
                  ? const CircularProgressIndicator()
                  : Text(
                      'Wins: ${_stats?.wins ?? 0}  '
                      'Losses: ${_stats?.losses ?? 0}  '
                      'Draws: ${_stats?.draws ?? 0}',
                    ),
              const SizedBox(height: 8),
              TextButton(onPressed: _resetStats, child: const Text('Reset Scoreboard')),
            ],
          ),
        ),
      ),
    );
  }
}
