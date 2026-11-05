enum Player { x, o }
typedef Board = List<Player?>;

Player nextPlayer(Player p) => p == Player.x ? Player.o : Player.x;

enum GameMode { twoPlayer, vsAI }
enum Difficulty { easy, medium, hard }

class GameState {
  final Board board;        // 9 cells
  final Player current;     // whose turn
  final Player? winner;     // x/o if won, else null
  final bool isDraw;        // true if full + no winner
  final List<int> moveLog;  // history of cell indices (supports Undo)

  const GameState({
    required this.board,
    required this.current,
    required this.winner,
    required this.isDraw,
    required this.moveLog,
  });

  factory GameState.fresh() => GameState(
        board: List<Player?>.filled(9, null),
        current: Player.x,
        winner: null,
        isDraw: false,
        moveLog: const [],
      );

  GameState copyWith({
    Board? board,
    Player? current,
    Player? winner,
    bool? isDraw,
    List<int>? moveLog,
  }) =>
      GameState(
        board: board ?? this.board,
        current: current ?? this.current,
        winner: winner ?? this.winner,
        isDraw: isDraw ?? this.isDraw,
        moveLog: moveLog ?? this.moveLog,
      );
}
