import 'package:shared_preferences/shared_preferences.dart';

// Persistent totals for player vs AI 
class AiStats {
  int wins;    // player wins 
  int losses;  // player losses 
  int draws;   
  AiStats({required this.wins, required this.losses, required this.draws});
}

class StatsStore {
  static const _kW = 'human_vs_ai_wins';
  static const _kL = 'human_vs_ai_losses';
  static const _kD = 'human_vs_ai_draws';

  Future<AiStats> load() async {
    final sp = await SharedPreferences.getInstance();
    return AiStats(
      wins: sp.getInt(_kW) ?? 0,
      losses: sp.getInt(_kL) ?? 0,
      draws: sp.getInt(_kD) ?? 0,
    );
  }

  Future<void> save(AiStats s) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kW, s.wins);
    await sp.setInt(_kL, s.losses);
    await sp.setInt(_kD, s.draws);
  }

  Future<void> reset() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kW);
    await sp.remove(_kL);
    await sp.remove(_kD);
  }
}
