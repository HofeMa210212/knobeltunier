import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as m;
import 'package:hive/hive.dart';
import 'package:knobeltunier_v2/data/match/match_place.dart';
import 'package:knobeltunier_v2/data/player/matchplayer.dart';
import 'package:knobeltunier_v2/data/player/player.dart';
import 'package:knobeltunier_v2/data/match/match.dart';
import 'package:knobeltunier_v2/data/tournament/tournament_list.dart';

import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';


part 'tournament.g.dart';

@HiveType(typeId: 3)
class Tournament extends HiveObject with ChangeNotifier {
  @HiveField(0)
  final int ticketCount;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final int id;
  @HiveField(3)
  int matchLength;
  @HiveField(4)
  List<Player> _players = [];
  @HiveField(5)
  List<TournamentMatch> _matches = [];
  @HiveField(6)
  List<MatchPlace> _places = [];
  @HiveField(7)
  List<MatchPlayer> _matchPlayers = [];



  TournamentList? parentList;

  static int _idCounter =0;


  Tournament({
    required this.name,
    required this.ticketCount,
    this.parentList,
    this.matchLength =2
  }) : id = _idCounter++;

  List<TournamentMatch> get matches => _matches;

  List<MatchPlace> get places => _places;

  List<Player> get players => _players;

  List<MatchPlayer> get matchPlayersWithRank{
    List<MatchPlayer> mPs = _matchPlayers;

    mPs.sort((a,b) => a.rank!.compareTo(b.rank!));

    return mPs;

  }

  int getAvailableTickets() {

    int soldTickets = 0;

    for(Player p in _players){
      soldTickets += p.lifes;
    }
    return ticketCount - soldTickets;

  }

  double percentageOfSoldTickets(){
    return soldTickets() / ticketCount *100;
  }

  int soldTickets(){
    int soldTickets = 0;

    for(Player p in _players){
      soldTickets += p.lifes;
    }

    return soldTickets;


  }

  bool hasPlayer(Player p){
    return _players.contains(p);
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



  void addPlayer(Player p) {
    _players.add(p);
    notifyListeners();
    saveParent();
  }

  void addMatchPlace(MatchPlace mP) {
    _places.add(mP);
    notifyListeners();
    saveParent();

  }

  void removePlace(MatchPlace m) {
    _places.remove(m);
    notifyListeners();
  }

  void addMatch(TournamentMatch m){
    _matches.add(m);
    notifyListeners();
  }

  void fillWithPlayers()  {
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
         _players.add(p);
        remainingTickets -= lifes;
      } catch (e) {
        print('Fehler beim Hinzufügen des Spielers: $e');
      }
    }

    notifyListeners();
    saveParent();
  }

  void removePlayer(Player player) {
    _players.remove(player);
    saveParent();
    notifyListeners();
  }

  Future<void> createMatches(m.TimeOfDay startTime, int matchLength) async {

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
    notifyListeners();
    saveParent();
  }

  List<TournamentMatch> _createMatches(List<MatchPlayer> players) {
    List<TournamentMatch> matches = [];
    Random random = Random();
    int cycles = 0;
    int tolerance = 1;

    Map<String, int> matchHistory = {};

    while (true) {
      cycles++;
      matches.clear();
      bool validMatches = true;
      int machtNrCounter = 1;


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
        TournamentMatch match = TournamentMatch(player1: player1, player2: opponent,matchNr: machtNrCounter);
        matches.add(match);
        machtNrCounter ++;

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

  Future<void> generateMatchTimes(DateTime startTime, int matchTimeLength) async {



    for(MatchPlace mP in _places){
      mP.startime = startTime;
      mP.matchLength = matchTimeLength;
    }

    Map<int, DateTime> playerLastMatchTime = {};

    Map<String, int> matchesPerPlace = {for (var place in _places) place.name: 0};

    for (TournamentMatch m in _matches) {
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


    int matchNumber = 1;




  }

  bool allMatchesPlayed(){

    for(TournamentMatch m in _matches){
      if(m.winner == null) return false;
    }
    return true;

  }

  void nextRound()  {
    List<MatchPlayer> winners = [];

    if(_matches.length ==1) {
      _matches[0].winner!.rank =1;
      _matchPlayers.add(_matches[0].winner!);
    }

    if(allMatchesPlayed()){

      for(TournamentMatch m in _matches){
        winners.add(m.winner!);
        m.loser!.rank = _matches.length *2;
        _matchPlayers.add(m.loser!);
      }


      _matches = _createMatches(winners);
      generateMatchTimes(DateTime.now(), matchLength);

    }
    notifyListeners();
    saveParent();

  }

  List<Map<String, String>> getPlayerMatches() {
    Map<String, String> data = {};

    for (TournamentMatch m in _matches) {
      for (MatchPlayer p in [m.player1, m.player2]) {
        String id = p.fName + p.lName;
        if (data.containsKey(id)) {
          data[id] = "${data[id]}, ${m.matchNr}";
        } else {
          data[id] = "${m.matchNr}";
        }
        print(data[id] ?? "");
      }
    }

    // Map in Liste von Maps umwandeln
    List<Map<String, String>> result = data.entries.map((e) {
      return {"id": e.key, "matches": e.value};
    }).toList();

    return result;
  }

  Future<void> generateMatchesPdf() async {
    print("Pdf in vorbereitung");
    final pdf = pw.Document();

    int rowsPerPage = 50;

    List<Map<String, String>> tournamentData = getPlayerMatches();

    if(rowsPerPage > tournamentData.length) rowsPerPage = tournamentData.length;

    int pageCount = (players.length/ rowsPerPage).ceil();

    print("Anzahl Spieler: ${players.length}");

    print("Seiten: $pageCount");

    for (int pageIndex = 0; pageIndex < pageCount; pageIndex++) {
      pdf.addPage(
        pw.Page(
            build: (pw.Context context) {
              return pw.Center(
                child:  pw.Column(
                  children: List.generate(
                    rowsPerPage,
                        (index) {

                      return pw.Container(
                          width: 400, // Angepasste Breite für die PDF-Darstellung
                          height: 15,
                          decoration: pw.BoxDecoration(
                            color:  PdfColors.white,
                            border: pw.Border.all(
                              color: PdfColors.black,
                              width: 1,
                            ),
                          ),
                          child:
                          // (index + rowsPerPage * pageIndex < tournamentData.length) ?
                          pw.Row(
                            children: [
                              pw.Container(
                                width: 200,
                                // Angepasste Breite für ein besseres Layout
                                child:  pw.FittedBox(
                                  fit:  pw.BoxFit.scaleDown,
                                  child:  pw.Center(
                                    child:  pw.Text(
                                      textAlign:  pw.TextAlign.left,
                                      tournamentData[index + rowsPerPage * pageIndex]["id"] ?? "",
                                      style:  pw.TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                              pw.Container(
                                width: 200,
                                child:  pw.FittedBox(
                                  fit:  pw.BoxFit.scaleDown,
                                  child:  pw.Center(
                                    child:  pw.Text(
                                      textAlign:  pw.TextAlign.left,
                                      tournamentData[index + rowsPerPage * pageIndex]["matches"] ?? "",
                                      style:  pw.TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),

                            ],

                          ),

                      );
                    },
                  ),
                ),
              );
            }
        ),
      );
    }


    String? filePath = await FilePicker.platform.getDirectoryPath();

    if(filePath != null){
      filePath = "${filePath}/${this.name}_${tournamentData.length}_matches.pdf";
      final file = File(filePath!);
      await file.writeAsBytes(await pdf.save());
      print("PDF erfolgreich gespeichert auf: $filePath");
    }else{
      print("Keine Auswahl getroffen.");
    }


  }

  void saveParent(){
    parentList?.save();
  }


}