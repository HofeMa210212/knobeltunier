
import 'package:knobeltunier/db/database.dart';
import 'package:knobeltunier/match_player.dart';
import 'package:knobeltunier/player.dart';
import 'package:sqflite/sqflite.dart';

class Match{
  final MatchPlayer player1;
  final MatchPlayer player2;
  MatchPlayer? winner;
  String? place;
  DateTime? time;
   int? id;

   Match({
    required this.player1,
    required this.player2,
     this.place,
     this.time,
     this.id
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Match) return false;
    return player1 == other.player1 && player2 == other.player2;
  }

  Future<void> setWinner(MatchPlayer p) async {
    Database db = await  dbController();
    winner = p;
    print("Winnerid: ${p.id} matchId: $id");

    await db.rawUpdate("UPDATE match SET winnerId =${p.id} WHERE id = $id");
    notifyClients("DB_UPDATED_SETWINNER");


  }

}