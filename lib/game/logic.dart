import 'dart:math';
import 'types.dart';

/// All winning lines (rows/cols/diagonals).
const _lines = <List<int>>[
  [0,1,2],[3,4,5],[6,7,8],
  [0,3,6],[1,4,7],[2,5,8],
  [0,4,8],[2,4,6],
];

bool isValidMove(Board b, int i) => i >= 0 && i < 9 && b[i] == null;

Player? checkWinner(Board b) {
  for (final line in _lines) {
    final a = line[0], c = line[1], d = line[2];
    if (b[a] != null && b[a] == b[c] && b[c] == b[d]) return b[a];
  }
  return null;
}

bool isDraw(Board b) => checkWinner(b) == null && !b.contains(null);

GameState applyMove(GameState s, int i) {
  if (!isValidMove(s.board, i) || s.winner != null || s.isDraw) return s;

  final nb = List<Player?>.from(s.board)..[i] = s.current;
  final w = checkWinner(nb);
  final d = w == null && !nb.contains(null);

  return s.copyWith(
    board: nb,
    current: (w == null && !d) ? nextPlayer(s.current) : s.current,
    winner: w,
    isDraw: d,
    moveLog: [...s.moveLog, i],        // ← record the move
  );
}

GameState undo(GameState s, {required bool vsAI}) {
  if (s.winner != null || s.isDraw) return s;         // don't allow after finish
  if (s.moveLog.isEmpty) return s;

  final pops = vsAI
      ? (s.moveLog.length >= 2 ? 2 : 1)               // if only one move, pop 1
      : 1;

  final trimmed = s.moveLog.sublist(0, s.moveLog.length - pops);

  var rebuilt = GameState.fresh();
  for (final idx in trimmed) {
    rebuilt = applyMove(rebuilt, idx);
  }
  return rebuilt;
}

/// ---------- AI helpers (Hard strategy) ----------

int? _twoInRowTo(Board b, Player p) {
  for (final line in _lines) {
    final cells = line.map((i) => b[i]).toList();
    final countP = cells.where((v) => v == p).length;
    final countE = cells.where((v) => v == null).length;
    if (countP == 2 && countE == 1) {
      final emptyAt = cells.indexWhere((v) => v == null);
      return line[emptyAt];
    }
  }
  return null;
}

int? _forkFor(Board b, Player p) {
  for (var i = 0; i < 9; i++) {
    if (b[i] != null) continue;
    final tmp = List<Player?>.from(b)..[i] = p;
    var threats = 0;
    for (final line in _lines) {
      final cells = line.map((j) => tmp[j]).toList();
      final countP = cells.where((v) => v == p).length;
      final countE = cells.where((v) => v == null).length;
      if (countP == 2 && countE == 1) threats++;
    }
    if (threats >= 2) return i;
  }
  return null;
}

// 6-step strategy
int hardMove(Board b, Player me) {
  final opp = nextPlayer(me);

  final win = _twoInRowTo(b, me);
  if (win != null) return win;

  final block = _twoInRowTo(b, opp);
  if (block != null) return block;

  final fork = _forkFor(b, me);
  if (fork != null) return fork;

  if (b[4] == null) return 4;

  const corners = [0, 2, 6, 8];
  int opposite(int c) => 8 - c;
  for (final c in corners) {
    if (b[c] == opp && b[opposite(c)] == null) return opposite(c);
  }

  for (final c in corners) {
    if (b[c] == null) return c;
  }

  for (var i = 0; i < 9; i++) {
    if (b[i] == null) return i;
  }
  return 0;
}

int randomMove(Board b, Random r) {
  final empties = <int>[];
  for (var i = 0; i < 9; i++) if (b[i] == null) empties.add(i);
  return empties[r.nextInt(empties.length)];
}

int mediumMove(Board b, Player me, int aiTurnCount, Random r) {
  final odd = aiTurnCount.isOdd;
  return odd ? randomMove(b, r) : hardMove(b, me);
}

int aiBestMove(Board b, Player me, Difficulty diff, int aiTurnCount, Random r) {
  switch (diff) {
    case Difficulty.easy:   return randomMove(b, r);
    case Difficulty.medium: return mediumMove(b, me, aiTurnCount, r);
    case Difficulty.hard:   return hardMove(b, me);
  }
}
