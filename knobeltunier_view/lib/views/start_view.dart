
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../db/connect_db_server.dart';
import '../db/database.dart';
import '../global_variables.dart';
import '../match_place.dart';
import '../player.dart';
import '../tournament.dart';
import '../widgets/widgets.dart';
import 'match_view.dart';

class StartView extends StatefulWidget {
  const StartView({super.key});

  @override
  State<StartView> createState() => _StartViewState();
}

class _StartViewState extends State<StartView>{
  List<Tournament> _tournaments = [];
  int selectedTournament = -1;
  double tickedCount =2;
  TimeOfDay selectedTime = TimeOfDay.now();
   var db;


  TextEditingController tournamentNameController = TextEditingController();
  TextEditingController tournamentTicketCountController = TextEditingController();

  TextEditingController playerFNameController = TextEditingController();
  TextEditingController playerLNameController = TextEditingController();
  TextEditingController playerLifeController = TextEditingController();

  TextEditingController newPlaceNameController = TextEditingController();


  Future<void> addPlaceAndSync() async{
    MatchPlace mP = MatchPlace(startime: DateTime.now(), matchLength: 2, name: newPlaceNameController.text);
     await _tournaments[selectedTournament].addMatchPlace(mP, _tournaments[selectedTournament].id);
    await _tournaments[selectedTournament].getMatchPlacesFromDb();

  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark, // Setzt den Dialog auf dunkel
            ),
            useMaterial3: true, // Beibehaltung von Material 3
            dialogBackgroundColor: Colors.black, // Hintergrund des Dialogs
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> getTournaments() async{
    var newTournaments = await getTournamentsFromDb();


    for(Tournament t in newTournaments){
      t.getPlayersFromDb();
      t.getMatchPlacesFromDb();
    }


    setState(() {
      _tournaments = newTournaments;
    });
  }

  Future<void> changeToMatchView(int index) async{
    await _tournaments[index].getMatchesFromDb();

    Navigator.push(
        context,
        MaterialPageRoute(builder: (builder) => MatchView(tournament: _tournaments[index],))
    );


  }

  Future<void> initDb() async{
    db = await dbController();
  }

  Future<void> handleDemoPlayers() async {
    // Warte, bis die fillWithDemoPlayers-Funktion abgeschlossen ist
    await _tournaments[selectedTournament].fillWithDemoPlayers();

    // Danach rufe getPlayersFromDb auf
    await _tournaments[selectedTournament].getPlayersFromDb();
  }

  Future<void> getDbData() async {
    await executeQueryServer("SELECT * FROM tournament");


  }

  void setupWebSocketListener() async {
    try {
      final socket = await WebSocket.connect('ws://localhost:8080/ws');
      print('Verbindung zum WebSocket-Server hergestellt.');

      socket.listen((message) async {
        print(message);
        if(message == "DB_UPDATED_TOURNAMENT"){
        await getTournaments();
        }

        }
      , onDone: () {
        print('Verbindung zum WebSocket-Server geschlossen.');
      });
    } catch (e) {
      print('Fehler beim WebSocket-Verbindungsaufbau: $e');
    }
  }



  @override
  void initState() {
    super.initState();
    initDb();
    getTournaments();
    getDbData();
    setupWebSocketListener();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: basicBackgroundColor,

      body: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
        
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.38,
              child: Column(
                children: List.generate(_tournaments.length, (tournamentIndex){
                  return Row(
                    children: [
        
                      GestureDetector(
                        onTap: (){
                          setState(() {
        
        
                            if(selectedTournament == tournamentIndex){
                              selectedTournament = -1;
                            }else {
                              selectedTournament = tournamentIndex;
                            }
                          });
                        },
                        child: Container(
                          margin: EdgeInsetsDirectional.only(top: 5),
                          width: MediaQuery.of(context).size.width * 0.31,
                          height: 50,
                          decoration: BoxDecoration(
                            color: (selectedTournament == tournamentIndex) ? Color(0x992C2C2C) : basicContainerColor,
                            borderRadius: BorderRadius.circular(6)
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.01),
                                  width: MediaQuery.of(context).size.width * 0.11,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Center(
                                      child: AutoSizeText(
                                        _tournaments[tournamentIndex].name,
                                        style: GoogleFonts.roboto(
                                          color: Colors.white70,
                                          fontSize: 22,
                                        ),
                                        maxFontSize: 22,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.09,
        
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Center(
                                      child: AutoSizeText(
                                        _tournaments[tournamentIndex].ticketCount.toString(),
                                        style: GoogleFonts.roboto(
                                          color: Colors.white70,
                                          fontSize: 22,
                                        ),
                                        maxFontSize: 22,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
        
                      IconButton(
                        onPressed: (){
                          setState(() {
                            changeToMatchView(tournamentIndex);
                          });
                        },
                        icon: Icon(
                          Icons.play_arrow_outlined,
                          color: Colors.green,
                          size: 34,
                        ),
                      ),
        
                    ],
                  );
                }),
              ),
            ),
        

        
          ],
        ),
      ),
    );
  }
}
