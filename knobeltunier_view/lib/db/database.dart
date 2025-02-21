import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

void initializeDatabaseFactory() {
  sqfliteFfiInit(); // Initialisiert die FFI-Unterstützung
  databaseFactory = databaseFactoryFfi; // Setzt die Datenbank-Factory
}

Future<Database> dbController() async {
  final dbPath = p.join(Directory.current.path, 'lib', 'db', 'database.db');
  databaseFactory = databaseFactoryFfi;
  final dbDir = p.dirname(dbPath);
  final dir = Directory(dbDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true); 
    print('Datenbankordner erstellt: $dbDir');
  }

  // Erstelle die Datenbank, falls sie nicht existiert
  return await openDatabase(
    dbPath,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE player (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    fName VARCHAR(255),
    lName VARCHAR(255),
    lifes INTEGER,
    tournamentId INTEGER,
    FOREIGN KEY (tournamentId) REFERENCES tournament(id) ON DELETE CASCADE
);

CREATE TABLE tournament (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ticketCount INTEGER,
    tournamentName VARCHAR(255)
);

CREATE TABLE match (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    matchPlayer1Id INTEGER,
    matchPlayer2Id INTEGER,
    winnerId INTEGER,  -- Hier ist der Gewinner zunächst NULL
    placeName VARCHAR(255),
    startTime TIME,
    tournamentId INTEGER,
    FOREIGN KEY (matchPlayer1Id) REFERENCES matchPlayer(id) ON DELETE CASCADE,
    FOREIGN KEY (matchPlayer2Id) REFERENCES matchPlayer(id) ON DELETE CASCADE,
    FOREIGN KEY (winnerId) REFERENCES matchPlayer(id) ON DELETE SET NULL,  -- Der Gewinner kann später gesetzt werden
    FOREIGN KEY (tournamentId) REFERENCES tournament(id) ON DELETE CASCADE

);

CREATE TABLE place (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    matchLength INTEGER,
    placeName VARCHAR(255),
    startTime TIME,
    tournamentId INTEGER,
    FOREIGN KEY (tournamentId) REFERENCES tournament(id) ON DELETE CASCADE
);

CREATE TABLE matchPlayer (
    id INTEGER PRIMARY KEY,
    playerId INTEGER,
    number INTEGER,
    isInMatch BOOLEAN,
    FOREIGN KEY (playerId) REFERENCES player(id) ON DELETE CASCADE
);
      ''');
      await db.execute("PRAGMA foreign_keys = ON;");
    },
  );

}

Future<void> setupDatabaseAndServer() async {
  final db = await dbController();
  
  


  // Server starten
  final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 8080);
  print('Server läuft auf ${server.address.address}:${server.port}');

  await for (var socket in server) {
    socket.listen((data) async {
      final query = String.fromCharCodes(data).trim();
      print('Empfangene Abfrage: $query');

      try {
        final result = await db.rawQuery(query);
        socket.add(result.toString().codeUnits);
      } catch (e) {
        socket.add('Fehler: ${e.toString()}'.codeUnits);
      } finally {
        socket.close();
      }
    });
  }
}

Future<void> addPlayerDb(Database db, String fName, String lName, int lifes, int tournamentId) async {
  await db.insert('player', {
    'fName': fName,
    'lName': lName,
    'lifes': lifes,
    'tournamentId': tournamentId
  });
  print('Neuer Spieler hinzugefügt: $fName $lName');
}

Future<void> addTournament(Database db, int ticketCount, String tournamentName) async {
  await db.insert('tournament', {
    'ticketCount': ticketCount,
    'tournamentName': tournamentName,
  });
  print('Neues Turnier hinzugefügt: $tournamentName');
}

Future<void> addMatchDb(Database db, int? matchPlayer1Id, int? matchPlayer2Id, String place, String? startTime, int tournamentId) async {
  await db.insert('match', {
    'matchPlayer1Id': matchPlayer1Id,
    'matchPlayer2Id': matchPlayer2Id,
    'winnerId': null,
    'placeName': place,
    'startTime': startTime,
    'tournamentId': tournamentId,
  });
  print('Neues Match hinzugefügt');
}

Future<void> addPlaceDb(Database db, int matchLength, String placeName, String? startTime, int tournamentId) async {
  await db.insert('place', {
    'matchLength': matchLength,
    'placeName': placeName,
    'startTime': startTime,
    'tournamentId': tournamentId
  });
  print('Neuer Ort hinzugefügt: $placeName');
}

Future<void> addMatchPlayer(Database db, int playerId, int number, bool isInMatch, int id) async {
  await db.insert('matchPlayer', {
    'id': id,
    'playerId': playerId,
    'number': number,
    'isInMatch': isInMatch ? 1 : 0,
  });
  print('Neuer Match-Spieler hinzugefügt mit Spieler-ID: $playerId');
}

Future<List<Map<String, dynamic>>> executeQuery(Database db, String query) async {

  try {
    return await db.rawQuery(query);
  } catch (e) {
    print('Error executing query: $e');
    return [];
  }
}
