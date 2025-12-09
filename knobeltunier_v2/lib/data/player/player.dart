
import 'package:hive/hive.dart';
import 'package:knobeltunier_v2/data/player/matchplayer.dart';

part 'player.g.dart';

@HiveType(typeId: 0)
class Player extends HiveObject {
  
  @HiveField(0)
  String fName;

  @HiveField(1)
  String lName;

  @HiveField(2)
  int? id;

  @HiveField(3)
  int lifes;


  Player({
    required this.fName,
    required this.lName,
    required this.lifes,
    this.id
  });

  List<MatchPlayer> get matchPlayers{
    List<MatchPlayer> mPs = [];

    for(int i = 0; i!= lifes; i++){
      mPs.add(MatchPlayer(fName: fName, lName: lName, lifes: lifes, isInMatch: false, number: i,));
    }

    return mPs;

  }

  void removeLife(){
    if(lifes >0) lifes -=1;
    else throw Exception('Player $fName $lName has already 0 lifes');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Player) return false;
    return fName == other.fName && lName == other.lName;
  }

  @override
  int get hashCode => Object.hash(fName, lName, lifes);

}

