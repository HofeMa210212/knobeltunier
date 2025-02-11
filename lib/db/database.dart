import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

void initializeDatabaseFactory() {
  sqfliteFfiInit(); // Initialisiert die FFI-Unterstützung
  databaseFactory = databaseFactoryFfi; // Setzt die Datenbank-Factory
}

Future<Database> dbController() async {
  final dbPath = p.join(Directory.current.path, 'lib', 'db', 'database.db');

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

List<WebSocket> connectedClients = [];

Future<void> setupDatabaseAndServer() async {
  final db = await dbController();

  // HTTP-Server starten
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
  print('Server läuft auf ${server.address.address}:${server.port}');

  // WebSocket-Server für Echtzeit-Kommunikation
  await for (HttpRequest request in server) {
    if (request.uri.path == '/ws') {
      // WebSocket-Upgrade für Echtzeitkommunikation
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        WebSocket socket = await WebSocketTransformer.upgrade(request);
        print('Neuer WebSocket-Client verbunden.');
        connectedClients.add(socket);

        socket.listen((message) {
          print('Nachricht vom Client: $message');
        }, onDone: () {
          connectedClients.remove(socket);
          print('Client hat die Verbindung geschlossen.');
        });
      }
    } else if (request.method == 'POST') {
      try {
        final content = await utf8.decoder.bind(request).join();
        final query = content.trim();

        final result = await db.rawQuery(query);

        final jsonResponse = jsonEncode(result);
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(jsonResponse)
          ..close();

        notifyClients('DB_UPDATED');
      } catch (e) {
        request.response
          ..statusCode = HttpStatus.internalServerError
          ..write('Fehler: ${e.toString()}')
          ..close();
      }
    }
  }
}

void notifyClients(String message) {
  for (var client in connectedClients) {
    if (client.readyState == WebSocket.open) {
      client.add(message);
    }
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
  notifyClients("DB_UPDATED_PLAYER");

}

Future<void> addTournament(Database db, int ticketCount, String tournamentName) async {
  await db.insert('tournament', {
    'ticketCount': ticketCount,
    'tournamentName': tournamentName,
  });
  print('Neues Turnier hinzugefügt: $tournamentName');
  notifyClients("DB_UPDATED_TOURNAMENT");

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


