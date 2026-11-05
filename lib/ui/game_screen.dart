import 'dart:math';
import 'package:flutter/material.dart';
import '../game/types.dart';
import '../game/logic.dart';
import '../data/stats_store.dart';

class GameScreen extends StatefulWidget {
  final GameMode mode;
  final Difficulty difficulty; // used only if mode == vsAI

  const GameScreen({super.key, required this.mode, required this.difficulty});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GameState state = GameState.fresh();

  // player = X, AI = O
  final Player aiPlayer = Player.o;
  final _rng = Random();
  int _aiTurnCount = 0;

  // scoreboard 
  final _store = StatsStore();
  bool _resultSaved = false;
  AiStats? _latest;

  bool get _finished => state.winner != null || state.isDraw;
  bool get _vsAI => widget.mode == GameMode.vsAI;

  void _onCellTap(int i) {
    if (_finished) return;
    if (_vsAI && state.current == aiPlayer) return; // not human's turn

    final next = applyMove(state, i);
    if (identical(next, state)) return;              // illegal or ignored
    setState(() => state = next);

    if (_finished) {
      _saveOutcomeOnce();
    } else if (_vsAI) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAIMove());
    }
  }

  void _maybeAIMove() {
    if (_finished || !_vsAI) return;
    if (state.current != aiPlayer) return;

    _aiTurnCount += 1;
    final idx = aiBestMove(state.board, aiPlayer, widget.difficulty, _aiTurnCount, _rng);
    setState(() => state = applyMove(state, idx));

    if (_finished) _saveOutcomeOnce();
  }

  // Undo a full turn in or a single move otherwise.
  void _undo() {
    if (_finished) return; 

    final before = state;
    final poppedBefore = before.moveLog.length;

    final after = undo(state, vsAI: _vsAI);
    final popped = poppedBefore - after.moveLog.length;

    // If we undid an AI move, step back the AI turn counter.
    if (popped == 2) _aiTurnCount = (_aiTurnCount > 0) ? _aiTurnCount - 1 : 0;

    setState(() {
      state = after;
      // no scoreboard state changes; the game hasn't finished
    });
  }

  Future<void> _saveOutcomeOnce() async {
    if (!_vsAI || _resultSaved) return;

    final s = await _store.load();
    if (state.winner == Player.x)      s.wins   += 1; // human beat AI
    else if (state.winner == Player.o) s.losses += 1; // AI beat human
    else if (state.isDraw)             s.draws  += 1;

    await _store.save(s);
    if (!mounted) return;
    setState(() {
      _resultSaved = true;
      _latest = s;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = _vsAI
        ? '1 Player — ${widget.difficulty.name[0].toUpperCase()}${widget.difficulty.name.substring(1)}'
        : '2 Player';

    final result = state.winner != null
        ? '${state.winner == Player.x ? 'X' : 'O'} wins!'
        : state.isDraw
            ? 'Draw'
            : null;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Turn: ${state.current == Player.x ? 'X' : 'O'}'),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                itemCount: 9,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                itemBuilder: (_, i) {
                  final v = state.board[i];
                  return InkWell(
                    onTap: () => _onCellTap(i),
                    child: Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.black26)),
                      child: Center(
                        child: Text(
                          v == null ? '' : (v == Player.x ? 'X' : 'O'),
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // result banner 
            if (result != null)
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: Colors.black12,
                    child: Text(result, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
                  ),
                  if (_vsAI) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      color: Colors.black12,
                      child: Text(
                        _latest == null
                            ? 'Scoreboard (vs AI): updating...'
                            : 'Scoreboard (vs AI) — '
                              'Wins: ${_latest!.wins}  '
                              'Losses: ${_latest!.losses}  '
                              'Draws: ${_latest!.draws}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),

            const SizedBox(height: 12),

            // undo
            Row(
              children: [
                ElevatedButton(
                  onPressed: _finished ? null : _undo,
                  child: const Text('Undo'),
                ),
                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
