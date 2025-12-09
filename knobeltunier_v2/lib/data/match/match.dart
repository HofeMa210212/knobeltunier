
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:knobeltunier_v2/data/player/matchplayer.dart';
import 'package:knobeltunier_v2/data/tournament/tournament.dart';
import 'package:knobeltunier_v2/data/tournament/tournament_list.dart';

part 'match.g.dart';

@HiveType(typeId: 1)
class TournamentMatch extends HiveObject with ChangeNotifier{
  @HiveField(0)
   MatchPlayer player1;
  @HiveField(1)
   MatchPlayer player2;
  @HiveField(2)
  MatchPlayer? winner;
  @HiveField(3)
  MatchPlayer? loser;
  @HiveField(4)
  String? place;
  @HiveField(5)
  DateTime? time;
  @HiveField(6)
  int? id;
  @HiveField(7)
  int matchNr;


  Tournament? parentList;

  TournamentMatch({
    required this.player1,
    required this.player2,
    this.place,
    this.time,
    this.id,
    this.parentList,
    required this.matchNr
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TournamentMatch) return false;
    return player1 == other.player1 && player2 == other.player2;
  }

   set matchWinner(MatchPlayer mP){
    winner = mP;

    (winner == player1) ? loser = player2 : loser = player1;

    notifyListeners();
    saveParent();

  }

  void saveParent(){
    parentList?.saveParent();
  }

}