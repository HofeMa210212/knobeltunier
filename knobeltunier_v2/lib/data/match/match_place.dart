import 'package:hive/hive.dart';

part 'match_place.g.dart';

@HiveType(typeId: 4)
class MatchPlace extends HiveObject {
  @HiveField(0)
  DateTime startime;
  @HiveField(1)
  int matchLength;
  @HiveField(2)
  final String name;
  @HiveField(3)
  int? id;

  MatchPlace({required this.startime, required this.matchLength, required this.name, this.id});

  DateTime getNextTime() {
    startime = startime.add(Duration(minutes: matchLength));
    return startime;
  }
}
