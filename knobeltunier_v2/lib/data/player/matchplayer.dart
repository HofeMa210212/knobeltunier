import 'package:knobeltunier_v2/data/player/player.dart';

import 'package:hive/hive.dart';

part 'matchplayer.g.dart';

@HiveType(typeId: 2)
class MatchPlayer extends Player {
  static int _idCounter = 0;

  @HiveField(4)
  final int id;

  @HiveField(5)
  bool isInMatch;

  @HiveField(6)
  int number;

  @HiveField(7)
  int? rank;

  MatchPlayer({
    required String fName,
    required String lName,
    required int lifes,
    required this.isInMatch,
    required this.number,
  })  : id = _idCounter++,
        super(fName: fName, lName: lName, lifes: lifes);






}