
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:knobeltunier/db/database.dart';
import 'package:knobeltunier/global_variables.dart';
import 'package:knobeltunier/match_place.dart';
import 'package:knobeltunier/player.dart';
import 'package:knobeltunier/tournament.dart';
import 'package:knobeltunier/views/match_view.dart';

import '../widgets/widgets.dart';

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

   int selectetColumn = 0;

   bool withPlaces = false;
   bool withTime = false;



  TextEditingController tournamentNameController = TextEditingController();
  TextEditingController tournamentTicketCountController = TextEditingController();

  TextEditingController playerFNameController = TextEditingController();
  TextEditingController playerLNameController = TextEditingController();
  TextEditingController playerLifeController = TextEditingController();

  TextEditingController newPlaceNameController = TextEditingController();

  TextEditingController matchTimeController = TextEditingController();


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
    await _tournaments[selectedTournament].fillWithDemoPlayers(context);

    // Danach rufe getPlayersFromDb auf
    await _tournaments[selectedTournament].getPlayersFromDb();
  }

  Future<void> getTournamentMatches() async{

    setState(() {
      _tournaments[selectedTournament].getMatchesFromDb();

    });
  }

  Future<void> getTournamentPlayers() async{

    setState(() {
      _tournaments[selectedTournament].getPlayersFromDb();
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initDb();
    getTournaments();

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

            //Container zum anzeigen der Tournaments
            Container(
              width: MediaQuery.of(context).size.width * 0.28,
              child: Column(
                children: List.generate(_tournaments.length, (tournamentIndex){
                  return Row(
                    children: [
                      IconButton(
                        onPressed: (){
                          setState(() {
        
                            if(selectedTournament == tournamentIndex){
                              selectedTournament = -1;
                            }
                            _tournaments[tournamentIndex].delete();
                            notifyClients("DB_UPDATED_TOURNAMENT");

                            getTournaments();
        
                          });
                        },
                        icon: Icon(
                          Icons.delete,
                          color: basicAppRed,
                          size: 30,
                        ),
                      ),
        
                      GestureDetector(
                        onTap: (){
                          setState(() {
        
                            assert(selectedTournament != null, 'selectedTournament is null');
                            assert(tournamentIndex != null, 'tournamentIndex is null');
        
                            if(selectedTournament == tournamentIndex){
                              selectedTournament = -1;
                            }else {
                              selectedTournament = tournamentIndex;
                            }
                          });
                        },
                        child: Container(
                          margin: EdgeInsetsDirectional.only(top: 5),
                          width: MediaQuery.of(context).size.width * 0.21,
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
                                Container(
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
                        onPressed: () async {
                            await changeToMatchView(tournamentIndex);
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
        
            if(selectedTournament == -1)...[
              //Container für die Erstellung neuer Tournaments
              Column(
                children: [
        
        
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: 50,
                      margin: EdgeInsets.only(top: 15),
                      child: ElevatedButton(
        
                        onPressed: () {
        
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith((states) {
                            return basicContainerColor; // Standardfarbe
                          }),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          elevation: MaterialStateProperty.all(0), // Kein Schatten
                          padding: MaterialStateProperty.all(EdgeInsets.zero),
        
                        ),
        
        
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: AutoSizeText(
                                    "Neues Tunier erstellen",
                                    style: GoogleFonts.roboto(
                                      color: Colors.white70,
                                      fontSize: 20,
                                    ),
                                    maxFontSize: 20,
                                  ),
                                ),
                              ),
        
        
                              Icon(
                                Icons.add,
                                color: Colors.white70,
                                size: 30,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
        
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 20),
                      height: 500,
                      width: MediaQuery.of(context).size.width*0.4,
                      decoration: BoxDecoration(
                          color: basicContainerColor,
                          borderRadius: BorderRadius.circular(8)
                      ),
        
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 20, top: 20),
                            child: Text(
                              "Name des Tunieres",
                              style: GoogleFonts.roboto(
                                  color: Colors.white70,
                                  fontSize: 20
                              ),
                            ),
                          ),
        
                          Container(
                              margin: EdgeInsets.only(top: 10),
                              child: CustomTextField(width: MediaQuery.of(context).size.width*0.4, hintText: "", controller: tournamentNameController,)
                          ),
        
                          Container(
                            margin: EdgeInsets.only(left: 20, top: 20),
                            child: Text(
                              "Anzahl der Karten",
                              style: GoogleFonts.roboto(
                                  color: Colors.white70,
                                  fontSize: 20
                              ),
                            ),
                          ),
        
                          Container(
                            margin: EdgeInsets.only(top: 50),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  width: 120,
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: (){
                                      setState(() {
                                        if(tickedCount>16){
                                          tickedCount =  tickedCount/2;
        
                                        }
                                      });
                                    },
        
                                    style: ButtonStyle(
                                      elevation: WidgetStatePropertyAll(0),
                                      backgroundColor: WidgetStatePropertyAll(basicContainerColor),
                                        shape: WidgetStateProperty.all(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                        ),
                                    ),
        
                                    child: Center(
                                      child: Icon(
                                        Icons.remove,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  tickedCount.toInt().toString(),
                                  style: GoogleFonts.roboto(
                                    color: Colors.white60,
                                    fontSize: 25,
                                  ),
                                ),
                                Container(
                                  width: 120,
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: (){
                                      setState(() {
                                        tickedCount *= 2;
                                      });
                                    },
        
                                    style: ButtonStyle(
                                      elevation: WidgetStatePropertyAll(0),
                                      backgroundColor: WidgetStatePropertyAll(basicContainerColor),
                                      shape: WidgetStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                    ),
        
                                    child: Center(
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ),
        
                              ],
                            ),
                          ),
        
        
                          Center(
                            child: Container(
                              margin: EdgeInsets.only(top: 55),
                              child: ElevatedButton(
                                onPressed: () {
                                  Tournament t = Tournament(id: 0,name: tournamentNameController.text, ticketCount: tickedCount.toInt(),);
                                  setState(() {
                                    snackBar s = snackBar();
                                    if(!_tournaments.contains(t)){

                                      if(tournamentNameController.text == "" && tournamentTicketCountController.text == ""){
                                        s.showFailureSnackbar(context, "Alle Felder müssen ausgefült werden!");

                                      }else{
                                        addTournament(db, t.ticketCount, t.name);
                                        tournamentNameController.text = "";
                                      }


                                    }else{

                                      s.showFailureSnackbar(context, "Es gibt bereits ein Tunier mit diesen Daten!");
                                    }
                                  });
        
                                  getTournaments();
        
                                },
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                                    if (states.contains(WidgetState.hovered)) {
                                      return Color(0x992C2C2C); // Farbe beim Hover
                                    }
                                    return basicContainerColor; // Standardfarbe
                                  }),
                                  shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  elevation: WidgetStateProperty.all(0), // Kein Schatten
                                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                                  fixedSize: WidgetStateProperty.all(Size(180, 50)),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Erstellen",
                                        style: GoogleFonts.roboto(
                                          color: Colors.white70,
                                          fontSize: 20,
                                        ),
                                      ),
        
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
        
                        ],
                      ),
                    ),
                  ),
        
                ],
              ),
            ]else...[
              //Container für die Erstellung neuer Spieler
              Column(
                children: [
        
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 15),
                      child: ElevatedButton(
        
                        onPressed: () {
        
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith((states) {
                            return basicContainerColor; // Standardfarbe
                          }),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          elevation: WidgetStateProperty.all(0), // Kein Schatten
                          padding: WidgetStateProperty.all(EdgeInsets.zero),
                          fixedSize: WidgetStateProperty.all(Size(300, 50)),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Spieler Hinzufügen",
                                style: GoogleFonts.roboto(
                                  color: Colors.white70,
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(width: 20),
                              Icon(
                                Icons.add,
                                color: Colors.white70,
                                size: 30,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
        
                  SizedBox(height: 20,),

                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width*0.4,
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width*0.2,
                            child: Center(
                              child: Text(
                                "Spieler: " +_tournaments[selectedTournament].players.length.toString(),
                                style: GoogleFonts.roboto(
                                  color: Colors.white70,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width*0.2,
                            child: Center(
                              child: Text(
                                key: ValueKey(_tournaments[selectedTournament].getAvailableTickets()),
                                "Verfügbare Karten: " +_tournaments[selectedTournament].getAvailableTickets().toString(),
                                style: GoogleFonts.roboto(
                                  color: Colors.white70,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
        
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width*0.4,
                          height: 7,
                          decoration: BoxDecoration(
                            color: basicContainerColor2,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width*0.4 * _tournaments[selectedTournament].percentageOfSoldTickets() / 100,
                          height: 7,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
        
                      ],
        
                    ),
                  ),
        
                  //Formular für Player
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 5),
                      height: 430,
                      width: MediaQuery.of(context).size.width*0.4,
                      decoration: BoxDecoration(
                          color: basicContainerColor,
                          borderRadius: BorderRadius.circular(8)
                      ),
        
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
        
                          Container(
                            margin: EdgeInsets.only(left: 20, top: 20),
                            child: Text(
                              "Vorname",
                              style: GoogleFonts.roboto(
                                  color: Colors.white70,
                                  fontSize: 20
                              ),
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.only(top: 10),
                              child: CustomTextField(width: MediaQuery.of(context).size.width*0.4, hintText: "", controller: playerFNameController,)
                          ),
        
                          Container(
                            margin: EdgeInsets.only(left: 20, top: 20),
                            child: Text(
                              "Nachname",
                              style: GoogleFonts.roboto(
                                  color: Colors.white70,
                                  fontSize: 20
                              ),
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.only(top: 10),
                              child: CustomTextField(width: MediaQuery.of(context).size.width*0.4, hintText: "", controller: playerLNameController,)
                          ),
        
                          Container(
                            margin: EdgeInsets.only(left: 20, top: 20),
                            child: Text(
                              "Leben",
                              style: GoogleFonts.roboto(
                                  color: Colors.white70,
                                  fontSize: 20
                              ),
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.only(top: 10),
                              child: CustomTextField(width: MediaQuery.of(context).size.width*0.4, hintText: "", controller: playerLifeController, onlyNumbers: true, maxNumber: _tournaments[selectedTournament].getAvailableTickets(),)
                          ),
        
        
                          Center(
                            child: Container(
                              margin: EdgeInsets.only(top: 15),
                              child: ElevatedButton(
                                onPressed: () {

                                  Player p = Player(fName: playerFNameController.text, lName: playerLNameController.text, lifes: int.parse(playerLifeController.text));

                                  setState(() {
                                    if(!_tournaments[selectedTournament].hasPlayer(p)){
                                      _tournaments[selectedTournament].addPlayer(p, _tournaments[selectedTournament].id, context);

                                      playerFNameController.text = "";
                                      playerLNameController.text = "";
                                      playerLifeController.text = "";
                                    }
                                    _tournaments[selectedTournament].getPlayersFromDb();

                                  });

                                },
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                                    if (states.contains(WidgetState.hovered)) {
                                      return Color(0x992C2C2C); // Farbe beim Hover
                                    }
                                    return basicContainerColor; // Standardfarbe
                                  }),
                                  shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  elevation: WidgetStateProperty.all(0), // Kein Schatten
                                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                                  fixedSize: WidgetStateProperty.all(Size(180, 50)),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Hinzufügen",
                                        style: GoogleFonts.roboto(
                                          color: Colors.white70,
                                          fontSize: 20,
                                        ),
                                      ),

                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
        
                        ],
                      ),
                    ),
                  ),

                  Container(
                    width: MediaQuery.of(context).size.width*0.4,
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              
                              value: withPlaces,
                              onChanged: (value){
                                setState(() {
                                  withPlaces = value!;
                                });
                              },
                              activeColor: Colors.green,
                            
                            ),
                            Text(
                            "Plätze generieren",
                              style: GoogleFonts.roboto(
                                color: Colors.white70,
                                fontSize: 18,
                              ),

                            )
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(

                              value: withTime,
                              onChanged: (value){
                                setState(() {
                                  withTime = value!;
                                });
                              },
                              activeColor: Colors.green,

                            ),
                            Text(
                            "Startzeiten generieren",
                              style: GoogleFonts.roboto(
                                color: Colors.white70,
                                fontSize: 18,
                              ),

                            )
                          ],
                        ),

                      ],
                    ),
                  ),

                  // Container zum hinzufügen von Places
                  (withPlaces) ?
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 5),
                      height: 270,
                      width: MediaQuery.of(context).size.width*0.4,
                      decoration: BoxDecoration(
                          color: basicContainerColor2,
                          borderRadius: BorderRadius.circular(8)
                      ),
                      child: GridView.builder(
                        itemCount: _tournaments[selectedTournament].places.length + 1, // +1 für den zusätzlichen Container
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 120, // Maximale Breite pro Item
                          mainAxisSpacing: 10, // Abstand zwischen den Reihen
                          crossAxisSpacing: 10, // Abstand zwischen den Spalten
                          childAspectRatio: 1.2, // Verhältnis von Breite zu Höhe (1 = quadratisch)
                        ),
                        itemBuilder: (context, index) {
                          if (index == _tournaments[selectedTournament].places.length) {
                            // Der letzte Container
                            return GestureDetector(
                              onTap: (){

                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(

                                      child: Container(
                                        width: 400, // Breite des Containers
                                        height: 220, // Höhe des Containers
                                        decoration: BoxDecoration(
                                          color: Color(0xFF191919),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              "Name des Spielplatzes",
                                              style: GoogleFonts.roboto(
                                                color: Colors.white70,
                                                fontSize: 22
                                              ),
                                            ),
                                            SizedBox(height: 20,),
                                            CustomTextField(width: 300, controller: newPlaceNameController,hintText: "New place"),
                                            SizedBox(height: 50,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.all(5),
                                                  width: 130,
                                                  height: 40,
                                                  child: ElevatedButton(
                                                    onPressed: (){
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: Text(
                                                      "Abbrechen",
                                                      style: GoogleFonts.roboto(
                                                        color: Colors.white70,
                                                        fontSize: 16
                                                      ),
                                                    ),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: basicAppRed,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(6), // Border-Radius
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.all(5),
                                                  width: 130,
                                                  height: 40,
                                                  child: ElevatedButton(
                                                    onPressed: (){
                                                      Navigator.of(context).pop();

                                                      setState(() {
                                                       addPlaceAndSync();


                                                      });
                                                    },
                                                    child: Text(
                                                      "Speichern",
                                                      style: GoogleFonts.roboto(
                                                        color: Colors.white70,
                                                        fontSize: 16
                                                      ),
                                                    ),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Color(
                                                          0xFF469300),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(6), // Border-Radius
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      ),
                                    );
                                  },
                                );


                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: basicContainerColor, // Farbe des speziellen Containers
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white70,
                                    size: 35,
                                  )
                                ),
                              ),
                            );
                          }

                          // Standard-Container
                          return Container(
                            width: MediaQuery.of(context).size.width * 0.1,
                            height: 80,
                            decoration: BoxDecoration(
                              color: basicContainerColor2,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              children: [
                                // Inhalt des Containers
                                Center(
                                  child: Text(
                                    _tournaments[selectedTournament].places[index].name,
                                    style: GoogleFonts.roboto(
                                      color: Colors.white70,
                                      fontSize: 22,
                                    ),
                                  ),
                                ),
                                // Delete-Button oben rechts
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: IconButton(
                                    icon: Icon(Icons.close, color: Colors.red),
                                    iconSize: 25,
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                    onPressed: () {


                                      setState(() {
                                        _tournaments[selectedTournament].removeMatchPlace(_tournaments[selectedTournament].places[index]);
                                      });
                                    },
                                    tooltip: 'Delete',
                                  ),
                                ),
                              ],
                            ),
                          );


                        },
                      ),
                    ),

                  ) : Container(),

                  //Buttons und auswahl zum erstellen von Matches
                  Row(
                    children: [
                      //Button zum erstellen von den Matches
                      Container(
                        height: 50,
                        width: 300,
                        margin: EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(basicContainerColor),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              snackBar s = snackBar();

                              if(!withPlaces){
                                if(_tournaments[selectedTournament].places.isEmpty){
                                  _tournaments[selectedTournament].addMatchPlace(MatchPlace(startime: DateTime.now(), matchLength: 0, name: "Not a real Place"),_tournaments[selectedTournament].id);
                                }
                              }
                              if(!withTime){
                                matchTimeController.text = "1";
                              }

                              if(withPlaces && _tournaments[selectedTournament].places.isEmpty){
                                s.showFailureSnackbar(context, "Es müssen zuerst Plätze hinzugefügt werden");
                                throw "No places added";
                              }

                              if(withTime && matchTimeController.text == ""){
                                s.showFailureSnackbar(context, "Es muss zuerst eine Matchlänge eingegeben werden");
                                throw "No time selected";
                              }



                              _tournaments[selectedTournament].createMatches(selectedTime, int.parse(matchTimeController.text));





                              s.showAppleStyleSnackbar(context, "Matches erfolgreich erstellt");
                            });
                          },
                          child: Text(
                            "Matches Erstellen",
                            style: GoogleFonts.roboto(
                              color: Colors.white70,
                              fontSize: 21,
                            ),
                          ),
                        ),
                      ),

                      if(withTime)...[
                      // Container für die Zeitwahl
                      Container(
                        width: 110,
                        height: 50,
                        margin: EdgeInsets.only(top: 10, left: 5),
        
        
                        child: ElevatedButton(
                          onPressed: () => _selectTime(context),
                          child: Text(
                            '${selectedTime!.format(context)}',
                            style: GoogleFonts.roboto(
                                color: Colors.white70,
                                fontSize: 21
                            ),
                          ),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8), // Hier kannst du den BorderRadius anpassen
                              ),
        
                            ),
                            backgroundColor: WidgetStatePropertyAll(basicContainerColor),
                          ),
                        ),
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        margin: EdgeInsets.only(top: 10,),

                        child: Center(
                          child: Text(
                            ":Uhr",
                            style: GoogleFonts.roboto(
                              color: Colors.white60,
                              fontSize: 20,

                            ),
                          ),
                        ),
                      ),

                      // Container für die Minutenwahl
                      Container(
                        width: 60,
                        height: 50,
                        margin: EdgeInsets.only(top: 10, left: 5),
                        decoration: BoxDecoration(
                          color: basicContainerColor2,
                          borderRadius: BorderRadius.circular(8)
                        ),

                        child: Center(
                          child: TextField(
                            controller: matchTimeController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            style: GoogleFonts.roboto(
                              color: Colors.white70,
                              fontSize: 20,
                            ),

                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical:  5, horizontal: 10),
                              border: InputBorder.none,
                            ),
                          ),
                        )
                      ),
                      Container(
                        width: 80,
                        height: 50,
                        margin: EdgeInsets.only(top: 10, left: 5),

                        child: Center(
                          child: Text(
                            ":Minuten",
                            style: GoogleFonts.roboto(
                              color: Colors.white60,
                              fontSize: 20,

                            ),
                          ),
                        ),
                      ),
                      ]
                    ],
                  ),

                  // Button zum auffüllen der Spieler
                  Container(
                    height: 50,
                    width: 300,
                    margin: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10), // Dieser wird überschrieben
                    ),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(basicContainerColor),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Hier kannst du den BorderRadius anpassen
                          ),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          if(selectedTournament >=0 && _tournaments[selectedTournament].players.length < _tournaments[selectedTournament].ticketCount){
                            handleDemoPlayers();
                          }
                          print(_tournaments[selectedTournament].soldTickets());
                          print(_tournaments[selectedTournament].players.length);
                        });
                      },
                      child: Text(
                          "Spieler Auffüllen",
                        style: GoogleFonts.roboto(
                          color: Colors.white70,
                          fontSize: 21,
                        ),
        
                      ),
                    ),
                  ),
        
        
                ],
              ),
            ],

            //Container zum anzeigen der Speiler und der Matcches
            Column(
              children: [
                //Container zum wechseln der Ansicht zweischen Spieler und Matches
                (selectedTournament >= 0)?
                MouseRegion(
                  cursor: SystemMouseCursors.click, // oder ein anderer Cursor

                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.20,
                    height: 40,
                    margin: EdgeInsets.only(top:5, bottom: 5),
                    decoration: BoxDecoration(
                      color: basicContainerColor2,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Stack(
                     children: [
                       AnimatedContainer(
                         duration: Duration(milliseconds: 400),
                         curve: Curves.ease,
                         width: MediaQuery.of(context).size.width * 0.10,
                         height: 40,
                         margin: EdgeInsets.only(top:5, left: MediaQuery.of(context).size.width * 0.10 * selectetColumn),
                         decoration: BoxDecoration(
                             color: Colors.green,
                           borderRadius: BorderRadius.circular(6)
                         ),
                       ),
                       Container(

                         child: Row(
                           children: [
                             GestureDetector(
                               onTap: (){
                                 setState(() {
                                   selectetColumn = 0;
                                 });
                               },
                               child: Container(
                                 width: MediaQuery.of(context).size.width * 0.10,
                                 height: 40,
                                 color: Colors.transparent,
                                 child: Center(
                                   child: Text(
                                     "Spieler",
                                     style: GoogleFonts.roboto(
                                       color: Colors.white60,
                                       fontSize: 20
                                     ),
                                   ),
                                 ),

                               ),
                             ),

                             GestureDetector(
                               onTap: () async{
                                 await getTournamentMatches();
                                 setState(() {
                                   selectetColumn = 1;
                                 });
                               },
                               child: Container(
                                 width: MediaQuery.of(context).size.width * 0.10,
                                 height: 40,
                                 color: Colors.transparent,
                                 child: Center(
                                   child: Text(
                                     "Matches",
                                     style: GoogleFonts.roboto(
                                       color: Colors.white60,
                                       fontSize: 20
                                     ),
                                   ),
                                 ),

                               ),
                             ),
                           ],
                         ),
                       ),


                     ],
                    ),
                  ),
                ): Container(),

                if(selectetColumn==0)...[
                //Container zum anzeigen der Spieler
                  (selectedTournament >= 0) ?
                  PlayerSearchContainer(key: ValueKey(_tournaments[selectedTournament]),t: _tournaments[selectedTournament], onUpdate: () async {await getTournamentPlayers(); print("test");})
                   : SizedBox(width: MediaQuery.of(context).size.width * 0.28,)
                ]else...[
                  //Container zum anzieigen der Matches
                  Container(
                    width: MediaQuery.of(context).size.width * 0.28,
                    height: MediaQuery.of(context).size.height -50,
                    margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03),

                    child:
                    (selectedTournament >= 0)?
                    ScrollbarTheme(
                      data: ScrollbarThemeData(
                        thumbColor: WidgetStateProperty.all(Colors.white54),
                        thickness: WidgetStateProperty.all(5.0),
                        interactive: true,

                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                       child: ListView.builder(
                         itemCount: _tournaments[selectedTournament].matches.length,
                         itemBuilder: (context, machtIndex){
                           return Row(
                             children: [
                               MouseRegion(
                                 cursor: SystemMouseCursors.click, // oder ein anderer Cursor
                                 child: Container(
                                   margin: EdgeInsetsDirectional.only(top: 5),
                                   width: MediaQuery.of(context).size.width * 0.24,
                                   height: 50,
                                   decoration: BoxDecoration(
                                       color: basicContainerColor,
                                       borderRadius: BorderRadius.circular(6)
                                   ),

                                   child: Row(
                                     children: [
                                       Container(
                                         margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.01),
                                         width: MediaQuery.of(context).size.width * 0.07,
                                         child: FittedBox(
                                           fit: BoxFit.scaleDown,
                                           child: Center(
                                             child: AutoSizeText(
                                               "${_tournaments[selectedTournament].matches[machtIndex].player1.fName} ${_tournaments[selectedTournament].matches[machtIndex].player1.lName[0]}.",
                                               style: GoogleFonts.roboto(
                                                 color: Colors.white70,
                                                 fontSize: 22,
                                               ),
                                               maxFontSize: 22,
                                             ),
                                           ),
                                         ),
                                       ),
                                       Container(
                                         margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.01),
                                         width: MediaQuery.of(context).size.width * 0.07,
                                         child: FittedBox(
                                           fit: BoxFit.scaleDown,
                                           child: Center(
                                             child: AutoSizeText(
                                               "VS",
                                               style: GoogleFonts.roboto(
                                                 color: Colors.white70,
                                                 fontSize: 22,
                                               ),
                                               maxFontSize: 22,
                                             ),
                                           ),
                                         ),
                                       ),
                                       Container(
                                         margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.01),
                                         width: MediaQuery.of(context).size.width * 0.07,
                                         child: FittedBox(
                                           fit: BoxFit.scaleDown,
                                           child: Center(
                                             child: AutoSizeText(
                                               "${_tournaments[selectedTournament].matches[machtIndex].player2.fName} ${_tournaments[selectedTournament].matches[machtIndex].player2.lName[0]}.",
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
                               IconButton(
                                 onPressed: (){
                                   setState(() {

                                   });
                                 },
                                 icon: Icon(
                                   Icons.delete,
                                   color: basicAppRed,
                                   size: 30,
                                 ),
                               )

                             ],
                           );
                         }
                       ),
                      ),
                    ): Container(),
                  ),

                ]

              ],
            ),
        
          ],
        ),
      ),
    );
  }
}

