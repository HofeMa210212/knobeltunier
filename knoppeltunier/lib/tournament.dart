import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart' as c;
import 'package:flutter/material.dart' as m;
import 'package:google_fonts/google_fonts.dart';
import 'package:knobeltunier/db/database.dart';
import 'package:knobeltunier/match_place.dart';
import 'package:knobeltunier/match_player.dart';
import 'package:knobeltunier/player.dart';
import 'package:knobeltunier/widgets/widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:sqflite/sqflite.dart';
import 'global_variables.dart';
import 'match.dart';
import 'package:pdf/widgets.dart';
import 'package:file_picker/file_picker.dart';


class Tournament{
  final int ticketCount;
  final String name;
  final int id;
  int matchLength;
  List<Player> _players = [];
  List<Match> _matches = [];
  List<MatchPlace> _places = [];


  Tournament( {
    required this.id,
    required this.name,
    required this.ticketCount,
    this.matchLength =2
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Tournament) return false;
    return name == other.name && ticketCount == other.ticketCount;
  }


  List<Player> get players => List.unmodifiable(_players);

  List<Match> get matches => List.unmodifiable(_matches);

  List<MatchPlace> get places => List.unmodifiable(_places);


  Future<void> addPlayer(Player p, int tournamentId, [c.BuildContext? context]) async {
    final db = await dbController();

    if (!_players.contains(p) && soldTickets() + p.lifes <= ticketCount) {
      _players.add(p);
      addPlayerDb(db, p.fName, p.lName, p.lifes, tournamentId);
    } else {
      if (context != null) {
        snackBar s = snackBar();
        s.showAppleStyleSnackbar(context, "Spieler ${p.fName} ${p.lName} konnte nicht zum Turnier hinzugefügt werden!");
      }

      throw Exception('Player ${p.fName} ${p.lName} could not be added to this Tournament.');
    }
  }


  Future<void> addMatchPlace(MatchPlace mP, int tournamentId) async {
    final db = await dbController();

    if (!_places.contains(mP)) {
      _places.add(mP);
      addPlaceDb(db, mP.matchLength, mP.name, mP.startime.toString(), this.id);

    } else {
      throw Exception('Player ${mP.name} already ecists in this Tournament.');
    }
  }

  void removePlayerAt(int index){

      _players.removeAt(index);

  }

  Future<void> removePlayer(Player p) async {
    final Database db = await dbController();
    print("remove");

    if (_players.contains(p)) {
      _players.remove(p);

      // Verwende Platzhalter für eine sichere Abfrage
      int count = await db.rawDelete(
        "DELETE FROM player WHERE id = ?",
        [p.id],
      );

      if (count == 0) {
        throw Exception('Player with id ${p.id} could not be found in the database.');
      }

      print("Player ${p.fName} ${p.lName} removed successfully.");
    } else {
      throw Exception('Player ${p.fName} ${p.lName} does not exist in this tournament.');
    }
  }

  Future<void> removeMatchPlace(MatchPlace mP) async {
    final Database db = await dbController();

    if (_places.contains(mP)) {
      _places.remove(mP);

      int count = await db.rawDelete(
        "DELETE FROM place WHERE id = ?",
        [mP.id],
      );

      if (count == 0) {
        throw Exception('Match Place with id ${mP.id} could not be found in the database.');
      }

    }
  }

  bool hasPlayer(Player p){
    return _players.contains(p);
  }

  int soldTickets(){
    int soldTickets = 0;

    for(Player p in _players){
      soldTickets += p.lifes;
    }

    return soldTickets;


  }

  Future<void> fillWithDemoPlayers(c.BuildContext context) async {
    Random r = Random();

    List<String> firstNames = [
      "Lukas", "Emma", "Max", "Mia", "Leon", "Hannah", "Finn", "Sofia", "Paul", "Emilia",
      "Elias", "Marie", "Jonas", "Lina", "Noah", "Anna", "Ben", "Laura", "Felix", "Lea",
      "Tim", "Amelie", "Moritz", "Clara", "Philipp", "Nina", "David", "Sarah", "Julian", "Julia",
      "Matteo", "Eva", "Tom", "Sophia", "Jakob", "Lara", "Simon", "Marlene", "Jan", "Lilly",
      "Erik", "Isabella", "Kevin", "Theresa", "Florian", "Elisa", "Alexander", "Charlotte", "Daniel", "Luisa"
    ];

    List<String> lastNames = [
      "Müller", "Schmidt", "Schneider", "Fischer", "Weber", "Meyer", "Wagner", "Becker", "Schulz", "Hoffmann",
      "Koch", "Richter", "Klein", "Wolf", "Schröder", "Neumann", "Schwarz", "Zimmermann", "Braun", "Krüger",
      "Hofmann", "Hartmann", "Lange", "Schmitt", "Werner", "Krause", "Meier", "Lehmann", "Schmid", "Schulze",
      "Maier", "Hermann", "Walter", "König", "Fuchs", "Kaiser", "Lang", "Peters", "Berger", "Martin",
      "Friedrich", "Scholz", "Möller", "Weiß", "Jung", "Hahn", "Schubert", "Vogel", "Roth", "Graf"
    ];

    // Schleife über verbleibende Tickets
    int remainingTickets = ticketCount - soldTickets();

    while (remainingTickets > 0) {
      String fName = firstNames[r.nextInt(firstNames.length)];
      String lName = lastNames[r.nextInt(lastNames.length)];
      int lifes = r.nextInt(remainingTickets > 4 ? 5 : remainingTickets) + 1;

      Player p = Player(fName: fName, lName: lName, lifes: lifes);

      try {
        await addPlayer(p, this.id, context); // Spieler hinzufügen
        remainingTickets -= lifes; // Verbleibende Tickets aktualisieren
      } catch (e) {
        print('Fehler beim Hinzufügen des Spielers: $e');
      }
    }

    // Spieler aus der Datenbank abrufen
    //await getPlayersFromDb();
    print('Demo-Spieler erfolgreich hinzugefügt.');
  }

  Future<void> createMatches(m.TimeOfDay startTime, int matchLength) async {
    Database db =  await dbController();
    List<MatchPlayer> matchPlayers = [];
    this.matchLength = matchLength;
    _matches = [];
    int cycles = 0;
    Random r = Random();


    for (Player p in _players) {
      for (int i = 0; i < p.lifes; i++) {
        MatchPlayer mP = MatchPlayer(
          fName: p.fName,
          lName: p.lName,
          lifes: 1,
          isInMatch: false,
          number: i,
        );
        matchPlayers.add(mP);
        addMatchPlayer(db, p.id!, mP.number, mP.isInMatch, mP.id);
      }
    }

    _matches = _createMatches(matchPlayers);
    final now = DateTime.now();
    print(startTime);
    generateMatchTimes(DateTime(
      now.year,
      now.month,
      now.day,
      startTime.hour,
      startTime.minute,
    ), matchLength);
  }

  bool allMatchesPlayed(){

    for(Match m in _matches){
      if(m.winner == null) return false;
    }
    return true;

  }

  Future<void> nextRound() async {
    Database db =  await dbController();
    List<MatchPlayer> matchPlayers = [];

      if(_matches.length ==1) {
        executeQuery(db, '''
      UPDATE matchPlayer SET rank = 1 WHERE id = ${_matches[0].winner!.id};
      ''');
      }

    if(allMatchesPlayed()){

      for(Match m in _matches){
        matchPlayers.add(m.winner!);


        Player loser = (m.player1.id == m.winner!.id) ? m.player2 : m.player1;

        print("Gewinner ist ${m.winner!.fName}");
        executeQuery(db, '''
        UPDATE matchPlayer 
        SET rank = (SELECT COUNT(*) FROM match WHERE tournamentId = ${this.id}) * 2 
        WHERE id = ${loser.id};
        ''');



      }





      _matches = _createMatches(matchPlayers);
      generateMatchTimes(DateTime.now(), matchLength);

    }

  }

  double percentageOfSoldTickets(){
    return soldTickets() / ticketCount *100;
  }

  List<Match> _createMatches(List<MatchPlayer> players) {
    List<Match> matches = [];
    Random random = Random();
    int cycles = 0;
    int tolerance = 1;



    Map<String, int> matchHistory = {};

    while (true) {
      cycles++;
      matches.clear();
      bool validMatches = true;

      if (cycles % 1000 == 0) print("Cycle: $cycles");

      // Spieler zufällig durchmischen, um Reihenfolge zu ändern
      players.shuffle(random);

      // Alle Spieler auf "nicht im Match" zurücksetzen
      for (var player in players) {
        player.isInMatch = false;
      }

      for (int i = 0; i < players.length; i++) {
        MatchPlayer player1 = players[i];
        if (player1.isInMatch) continue;

        // Finde einen Gegner
        MatchPlayer? opponent = players
            .where((p) => !p.isInMatch && p != player1)
            .reduce((a, b) {
          int aScore = _matchScore(player1, a, matchHistory);
          int bScore = _matchScore(player1, b, matchHistory);
          return aScore < bScore ? a : b;
        });

        if (opponent == null) {
          validMatches = false;
          break;
        }

        // Match erstellen
        Match match = Match(player1: player1, player2: opponent);
        matches.add(match);

        // Spieler markieren
        player1.isInMatch = true;
        opponent.isInMatch = true;

        // Historie aktualisieren
        String matchKey = _matchKey(player1, opponent);
        matchHistory[matchKey] = (matchHistory[matchKey] ?? 0) + 1;

        // Toleranzprüfung
        if (matchHistory[matchKey]! > tolerance) {
          validMatches = false;
          break;
        }
      }

      if (validMatches) break;
    }



    print("Cycles: $cycles");
    print("Matches: ${matches.length}");
    matches.shuffle(random);
    return matches;
  }

  int _matchScore(MatchPlayer p1, MatchPlayer p2, Map<String, int> matchHistory) {
    String key = _matchKey(p1, p2);
    return matchHistory[key] ?? 0;
  }

  String _matchKey(MatchPlayer p1, MatchPlayer p2) {
    List<String> players = [p1.id.toString(), p2.id.toString()]..sort();
    return players.join("-");
  }

  Future<void> generateMatchesPdf() async {
    final pdf = Document();

    // Cover page
    pdf.addPage(
      Page(
        build: (Context context) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Turnier: $name",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                "Anzahl der Tickets: $ticketCount",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                "Anzahl der Matches: ${_matches.length}",
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );

    // Anzahl der Zeilen pro Seite, hier kannst du die Anzahl nach Bedarf anpassen
    const int rowsPerPage = 45;

    int pageCount = (_matches.length / rowsPerPage /2).ceil(); // Berechne die Anzahl der Seiten

    for (int pageIndex = 0; pageIndex < pageCount; pageIndex++) {
      pdf.addPage(
        Page(
          build: (Context context) {
            return Row(
              children: [
                // Erste Spalte mit den Matches der linken Seite
                Column(
                  children: List.generate(
                    rowsPerPage,
                        (index) {
                      int matchIndex = pageIndex * 2 * rowsPerPage + 1 * index;
                      if (matchIndex < _matches.length) {
                        return Container(
                          width: 250,  // Angepasste Breite für die PDF-Darstellung
                          height: 15,
                          decoration: BoxDecoration(
                            color: (matchIndex % 2 == 0) ? PdfColors.white : PdfColors.white,
                            border: Border.all(
                              color: PdfColors.black,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 30, // Angepasste Breite für ein besseres Layout
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Center(
                                    child: Text(
                                      "${matchIndex + 1}.",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Center(
                                    child: Text(
                                      "${matches[matchIndex].player1.fName}",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 20,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Center(
                                    child: Text(
                                      "VS",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Center(
                                    child: Text(
                                      "${matches[matchIndex].player2.fName}",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Container(); // Leeres Container, wenn keine weiteren Matches
                      }
                    },
                  ),
                ),
                // Zweite Spalte mit den Matches der rechten Seite
                Column(
                  children: List.generate(
                    rowsPerPage,
                        (index) {
                          int matchIndex = pageIndex * 2 * rowsPerPage  + 1 * index + rowsPerPage;
                      if (matchIndex < _matches.length) {
                        return Container(
                          width: 250,  // Angepasste Breite für die PDF-Darstellung
                          height: 15,
                          decoration: BoxDecoration(
                            color: (matchIndex % 2 == 0) ? PdfColors.white : PdfColors.white,
                            border: Border.all(
                              color: PdfColors.black,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 30, // Angepasste Breite für ein besseres Layout
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Center(
                                    child: Text(
                                      "${matchIndex + 1}.",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Center(
                                    child: Text(
                                      "${matches[matchIndex].player1.fName}",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 20,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Center(
                                    child: Text(
                                      "VS",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 100,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Center(
                                    child: Text(
                                      "${matches[matchIndex].player2.fName}",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Container(); // Leeres Container, wenn keine weiteren Matches
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      );
    }


    String? filePath = await FilePicker.platform.getDirectoryPath();

    if(filePath != null){
      filePath = "${filePath}/${this.name}_matches.pdf";
      final file = File(filePath!);
      await file.writeAsBytes(await pdf.save());
      print("PDF erfolgreich gespeichert auf: $filePath");
    }else{
      print("Keine Auswahl getroffen.");
    }
  }

  Future<void> generateMatchTimes(DateTime startTime, int matchTimeLength) async {
    Database db = await dbController();


    for(MatchPlace mP in _places){
      mP.startime = startTime;
      mP.matchLength = matchTimeLength;
    }

    Map<int, DateTime> playerLastMatchTime = {};

    Map<String, int> matchesPerPlace = {for (var place in _places) place.name: 0};

    for (Match m in _matches) {
      MatchPlace? assignedPlace;
      DateTime assignedTime = startTime;

      while (true) {
        // Finde den Platz mit den wenigsten Matches
        MatchPlace potentialPlace = _places.reduce((a, b) =>
        matchesPerPlace[a.name]! <= matchesPerPlace[b.name]! ? a : b);
        DateTime potentialTime = potentialPlace.getNextTime();

        // Hole die letzten Zeiten der Spieler
        DateTime lastTimePlayer1 = playerLastMatchTime[m.player1.id] ?? startTime;
        DateTime lastTimePlayer2 = playerLastMatchTime[m.player2.id] ?? startTime;

        // Überprüfe, ob die Spieler zu diesem Zeitpunkt verfügbar sind
        if (potentialTime.isAfter(lastTimePlayer1) && potentialTime.isAfter(lastTimePlayer2)) {
          assignedPlace = potentialPlace;
          assignedTime = potentialTime;
          break;
        }
      }

      // Match zuweisen
      m.time = assignedTime;
      m.place = assignedPlace!.name;

      // Spieler-Zeiten aktualisieren
      playerLastMatchTime[m.player1.id] = assignedTime;
      playerLastMatchTime[m.player2.id] = assignedTime;

      // Match-Zähler für den Platz erhöhen
      matchesPerPlace[assignedPlace.name] = matchesPerPlace[assignedPlace.name]! + 1;

      print("${m.place} am ${m.time}");
    }

    print("\nMatch-Verteilung:");
    matchesPerPlace.forEach((place, count) {
      print("$place: $count Matches");
    });


    await executeQuery(db, "DELETE FROM match WHERE tournamentId=${this.id}");

    int matchNumber = 1;

    for (Match m in _matches) {
      await addMatchDb(db, m.player1.id, m.player2.id, m.place!, m.time.toString(), this.id, matchNumber);
      matchNumber++;
    }


  }

  Future<void> delete() async {
    final db = await dbController();

    executeQuery(db, "DELETE FROM tournament WHERE id=${id}");


  }

  Future<void> getPlayersFromDb() async{
    final db = await dbController();
    List<Map<String, dynamic>> newPlayers = await executeQuery(db, "SELECT * FROM player WHERE tournamentId=${id}");
    _players = [];

    for(int i =0; i!= newPlayers.length; i++){
      _players.add(Player(fName: newPlayers[i]["fName"], lName: newPlayers[i]["lName"], lifes: newPlayers[i]["lifes"], id: newPlayers[i]["id"]));
    }

  }

  Future<void> getMatchPlacesFromDb() async{
    final db = await dbController();
    List<Map<String, dynamic>> newPlaces = await executeQuery(db, "SELECT * FROM place WHERE tournamentId=${id}");
    _places = [];

    for(int i =0; i!= newPlaces.length; i++){
      _places.add(MatchPlace(startime: DateTime.parse(newPlaces[i]["startTime"]), matchLength: newPlaces[i]["matchLength"], name: newPlaces[i]["placeName"], id: newPlaces[i]["id"] ));
    }
  }

  Future<void> getMatchesFromDb() async{
    Database db = await dbController();

    List<Map<String, dynamic>> newMatchData = await executeQuery(db, '''
    SELECT 
    match.id AS matchId,
    match.placeName,
    match.startTime,
    match.tournamentId AS matchTournamentId,
    matchPlayer1.id AS player1Id,
    player1.fName AS player1FirstName,
    player1.lName AS player1LastName,
    player1.lifes AS player1Number,
    matchPlayer2.id AS player2Id,
    player2.fName AS player2FirstName,
    player2.lName AS player2LastName,
    player2.lifes AS player2Number,
    match.winnerId AS winnerId,
    winnerPLayer.fName AS winnerFirstName,
    winnerPLayer.lName AS winnerLastName
FROM 
    match
LEFT JOIN 
    matchPlayer AS matchPlayer1 ON match.matchPlayer1Id = matchPlayer1.id
LEFT JOIN 
    player AS player1 ON matchPlayer1.playerId = player1.id
LEFT JOIN 
    matchPlayer AS matchPlayer2 ON match.matchPlayer2Id = matchPlayer2.id
LEFT JOIN 
    player AS player2 ON matchPlayer2.playerId = player2.id
LEFT JOIN 
    matchPlayer AS winner ON match.winnerId = winner.id
LEFT JOIN
    player as winnerPLayer ON winner.playerId = winnerPLayer.id
WHERE match.tournamentId = $id
ORDER BY match.matchNumber;


    ''');

    _matches = [];
    for(int i =0; i!= newMatchData.length; i++){
      MatchPlayer p1 = MatchPlayer(fName: newMatchData[i]["player1FirstName"], lName: newMatchData[i]["player1LastName"], lifes: 1, isInMatch: true, number: newMatchData[i]["player1Number"],id: newMatchData[i]["player1Id"]);
      MatchPlayer p2 = MatchPlayer(fName: newMatchData[i]["player2FirstName"], lName: newMatchData[i]["player2LastName"], lifes: 1, isInMatch: true, number: newMatchData[i]["player2Number"],id: newMatchData[i]["player2Id"]);
      Match m = Match(player1: p1, player2: p2, place: newMatchData[i]["placeName"],time: DateTime.parse(newMatchData[i]["startTime"]), id: newMatchData[i]["matchId"]);


      if(newMatchData[i]["winnerId"] != null){
        MatchPlayer winner = MatchPlayer(fName: newMatchData[i]["winnerFirstName"], lName: newMatchData[i]["winnerLastName"], lifes: 1, isInMatch: true, number: 1, id: newMatchData[i]["winnerId"]);
        m.winner = winner;
      }





      _matches.add(m);





    }




  }

  int getAvailableTickets() {

    int soldTickets = 0;

    for(Player p in _players){
      soldTickets += p.lifes;
    }
    return ticketCount - soldTickets;

  }

  List<Player> searchPlayer(String regex){
    List<Player> foundPlayers = [];

    for(Player p in players){
      String name1 = p.fName.toLowerCase() + " " + p.lName.toLowerCase();
      String name = p.lName.toLowerCase() + " " + p.fName.toLowerCase();

      if(name.contains(regex.toLowerCase()) || name1.contains(regex.toLowerCase())){
        foundPlayers.add(p);
      }


    }


    return foundPlayers;
  }


}

Future<List<Tournament>> getTournamentsFromDb() async{
  final db = await dbController();

  List<Tournament> tournaments = [];
  List<Map<String, dynamic>> tournamentsRaw = await executeQuery(db, "SELECT * FROM tournament");
  
  for(int i =0; i!= tournamentsRaw.length; i++){
    Tournament t = Tournament(name: tournamentsRaw[i]["tournamentName"], ticketCount: tournamentsRaw[i]["ticketCount"], id: tournamentsRaw[i]["id"]);
    t.getPlayersFromDb();
    tournaments.add(t);
  }

  return tournaments;
}