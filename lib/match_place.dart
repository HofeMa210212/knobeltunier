class MatchPlace {
  DateTime startime;
   int matchLength;
  final String name;
  int? id;

  MatchPlace({required this.startime, required this.matchLength, required this.name, this.id});

  DateTime getNextTime() {
    startime = startime.add(Duration(minutes: matchLength));
    return startime;
  }
}
