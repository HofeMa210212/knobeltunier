
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:knobeltunier_v2/Color/app_Colors.dart';
import 'package:knobeltunier_v2/data/match/match_place.dart';
import 'package:knobeltunier_v2/data/player/player.dart';
import 'package:knobeltunier_v2/data/tournament/tournament.dart';
import 'package:knobeltunier_v2/data/tournament/tournament_list.dart';
import 'package:knobeltunier_v2/widgets/custom_textfield.dart';
import 'package:knobeltunier_v2/widgets/snackbar.dart';
import 'package:provider/provider.dart';

class TournamentSettingsContainer extends StatefulWidget {
  const TournamentSettingsContainer({super.key});

  @override
  State<TournamentSettingsContainer> createState() => _TournamentSettingsContainerState();
}

class _TournamentSettingsContainerState extends State<TournamentSettingsContainer> {

  TextEditingController playerFNameController = TextEditingController();
  TextEditingController playerLNameController = TextEditingController();
  TextEditingController playerLifeController = TextEditingController();
  TextEditingController newPlaceNameController = TextEditingController();
  TextEditingController matchTimeController = TextEditingController();

  bool withPlaces = false;
  bool withTime = false;

  TimeOfDay selectedTime = TimeOfDay.now();

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

  @override
  Widget build(BuildContext context) {
    return Consumer<TournamentList>(
      builder: (context, tournamentList,child){
        Tournament t =tournamentList.selectedTournament!;

        return ChangeNotifierProvider<Tournament>.value(
          value: t,
          child: Consumer<Tournament>(
            builder: (context,t,child){
              return  Column(
                children: [

                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 15),
                      child: ElevatedButton(

                        onPressed: () {

                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith((states) {
                            return AppColors.basicContainerColor; // Standardfarbe
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
                                "Spieler: " +t.players.length.toString(),
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
                                key: ValueKey(t.getAvailableTickets()),
                                "Verfügbare Karten: " +t.getAvailableTickets().toString(),
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
                            color: AppColors.basicContainerColor2,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width*0.4 * t.percentageOfSoldTickets() / 100,
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
                          color: AppColors.basicContainerColor,
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
                              child: CustomTextField(width: MediaQuery.of(context).size.width*0.4, hintText: "", controller: playerLifeController, onlyNumbers: true, maxNumber: t.getAvailableTickets(),)
                          ),


                          Center(
                            child: Container(
                              margin: EdgeInsets.only(top: 15),
                              child: ElevatedButton(
                                onPressed: () {

                                  Player p = Player(fName: playerFNameController.text, lName: playerLNameController.text, lifes: int.parse(playerLifeController.text));

                                  t.addPlayer(p);
                                  setState(() {
                                    if(t.hasPlayer(p)){


                                      playerFNameController.text = "";
                                      playerLNameController.text = "";
                                      playerLifeController.text = "";
                                    }

                                  });

                                },
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                                    if (states.contains(WidgetState.hovered)) {
                                      return Color(0x992C2C2C); // Farbe beim Hover
                                    }
                                    return AppColors.basicContainerColor; // Standardfarbe
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
                          color: AppColors.basicContainerColor2,
                          borderRadius: BorderRadius.circular(8)
                      ),
                      child: GridView.builder(
                        itemCount: t.places.length + 1, // +1 für den zusätzlichen Container
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 120, // Maximale Breite pro Item
                          mainAxisSpacing: 10, // Abstand zwischen den Reihen
                          crossAxisSpacing: 10, // Abstand zwischen den Spalten
                          childAspectRatio: 1.2, // Verhältnis von Breite zu Höhe (1 = quadratisch)
                        ),
                        itemBuilder: (context, index) {
                          if (index == t.places.length) {
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
                                                        backgroundColor: AppColors.basicAppRed,
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

                                                        MatchPlace mP = MatchPlace(startime: DateTime.now(), matchLength: 2, name: newPlaceNameController.text);

                                                        t.addMatchPlace(mP);

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
                                  color: AppColors.basicContainerColor, // Farbe des speziellen Containers
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
                              color: AppColors.basicContainerColor2,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              children: [
                                // Inhalt des Containers
                                Center(
                                  child: Text(
                                    t.places[index].name,
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

                                      t.removePlace(t.places[index]);
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
                            backgroundColor: MaterialStateProperty.all(AppColors.basicContainerColor),
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
                                if(t.places.isEmpty){
                                  t.addMatchPlace(MatchPlace(startime: DateTime.now(), matchLength: 0, name: "Not a real Place"));
                                }
                              }
                              if(!withTime){
                                matchTimeController.text = "1";
                              }

                              if(withPlaces && t.places.isEmpty){
                                s.showFailureSnackbar(context, "Es müssen zuerst Plätze hinzugefügt werden");
                                throw "No places added";
                              }

                              if(withTime && matchTimeController.text == ""){
                                s.showFailureSnackbar(context, "Es muss zuerst eine Matchlänge eingegeben werden");
                                throw "No time selected";
                              }

                              t.createMatches(selectedTime, int.parse(matchTimeController.text));

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
                              backgroundColor: WidgetStatePropertyAll(AppColors.basicContainerColor),
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
                                color: AppColors.basicContainerColor2,
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
                        backgroundColor: MaterialStateProperty.all(AppColors.basicContainerColor),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Hier kannst du den BorderRadius anpassen
                          ),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          t.fillWithPlayers();

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
              );
            },
          ),
        );
      },
    );
  }
}
