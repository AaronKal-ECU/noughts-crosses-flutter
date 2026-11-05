
import 'package:flutter_test/flutter_test.dart';
import 'package:appsdeva1_flutter/game/types.dart';
import 'package:appsdeva1_flutter/game/logic.dart';

void main() {
  // TC1_OccupiedCell — isValidMove
  test('TC1_OccupiedCell_isValidMove', () {
    final Board b = List<Player?>.filled(9, null);
    b[0] = Player.x; // occupied
    expect(isValidMove(b, 0), isFalse); // input disregarded
  });

  // TC2_BoardFullWinnerTrue — isDraw
  test('TC2_BoardFullWinnerTrue_isDraw', () {
    final Board b = [
      Player.x, Player.x, Player.x,
      Player.o, Player.o, Player.x,
      Player.o, Player.x, Player.o,
    ];
    expect(checkWinner(b), equals(Player.x)); // winner declared
    expect(isDraw(b), isFalse);               // board-full ignored because winner exists
  });

  // TC3_NoWinner — checkWinner (draw path)
  test('TC3_NoWinner_checkWinner_draw', () {
    final Board b = [
      Player.x, Player.o, Player.x,
      Player.o, Player.x, Player.o,
      Player.o, Player.x, Player.o,
    ];
    expect(checkWinner(b), isNull); // stays NULL
    expect(isDraw(b), isTrue);      // game ends in draw
  });

  // TC4_UndoGameOver — undo
  test('TC4_UndoGameOver_undo_disabled', () {
    // quick win for X: positions 0,1,2
    var s = GameState.fresh();     // X
    s = applyMove(s, 0);           // X
    s = applyMove(s, 3);           // O
    s = applyMove(s, 1);           // X
    s = applyMove(s, 4);           // O
    s = applyMove(s, 2);           // X wins
    expect(s.winner, equals(Player.x));

    final afterVsAi   = undo(s, vsAI: true);
    final afterPvP    = undo(s, vsAI: false);

    // undo is disabled after game over
    expect(identical(afterVsAi, s), isTrue);
    expect(identical(afterPvP, s), isTrue);
  });
}
