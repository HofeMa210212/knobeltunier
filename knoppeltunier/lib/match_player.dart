import 'package:knobeltunier/player.dart';
import 'package:sqflite/sqflite.dart';

class MatchPlayer extends Player {
  static int _idCounter = 1; // Startwert für IDs
  final int id; // Eindeutige ID für jeden Spieler
  bool isInMatch;
  int number;

  MatchPlayer({
    required String fName,
    required String lName,
    required int lifes,
    required this.isInMatch,
    required this.number,
    int? id,
  })  : id = id ?? _idCounter++,
        super(fName: fName, lName: lName, lifes: lifes);

  static Future<void> initializeIdCounter(Database db) async {
    // Abfrage des höchsten vorhandenen `id`-Wertes in der `matchPlayer`-Tabelle
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT MAX(id) AS maxId FROM matchPlayer',
    );

    // Setzt den Zähler auf den höchsten Wert + 1, falls Daten vorhanden sind
    if (result.isNotEmpty && result.first['maxId'] != null) {
      _idCounter = (result.first['maxId'] as int) + 1;
    } else {
      _idCounter = 1; // Standardwert, falls keine Daten vorhanden sind
    }
  }
}
