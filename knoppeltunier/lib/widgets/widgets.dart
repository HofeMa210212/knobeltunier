
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:knobeltunier/tournament.dart';

import '../db/database.dart';
import '../global_variables.dart';
import '../player.dart';

class CustomTextField extends StatelessWidget {
  final double width;
  final TextEditingController controller;
  final String hintText;
  final String? followingText;
  final bool? onlyNumbers;
  final int? maxNumber;

  const CustomTextField({
    required this.width,
    required this.controller,
    required this.hintText,
    this.followingText = "",
    this.onlyNumbers = false,
    this.maxNumber,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 60,
      decoration: BoxDecoration(
        color: basicContainerColor2,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Row(
          children: [
            Container(
              width: (followingText == "") ? width : width - 20,
              child: TextField(
                keyboardType: (onlyNumbers == true) ? TextInputType.number : TextInputType.text,
                inputFormatters: onlyNumbers == true
                    ? [
                  FilteringTextInputFormatter.digitsOnly,
                  if (maxNumber != null) NumberLimitFormatter(maxNumber!)
                ]
                    : [],

                controller: controller,
                style: GoogleFonts.roboto(
                  color: Colors.white60,
                  fontSize: 18,
                ),
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: GoogleFonts.roboto(
                    color: Colors.white38,
                    fontSize: 18,
                  ),
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
                cursorColor: Colors.white70,
              ),
            ),
            if (followingText != "")
              Container(
                width: 20,
                child: Text(
                  followingText!,
                  style: GoogleFonts.roboto(
                    color: Colors.white60,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class snackBar{
  void showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.white, size: 24),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.blueGrey.shade800,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.all(16),
      duration: Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showAppleStyleSnackbar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50, // Abstand vom unteren Rand
        left: MediaQuery.of(context).size.width * 0.1,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info, color: Colors.white, size: 24),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Füge die Snackbar zum Overlay hinzu
    overlay?.insert(overlayEntry);

    // Entferne die Snackbar nach 3 Sekunden
    Future.delayed(Duration(seconds: 3)).then((_) => overlayEntry.remove());
  }

  void showFailureSnackbar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50, // Abstand vom unteren Rand
        left: MediaQuery.of(context).size.width * 0.1,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),

            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 24),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Füge die Snackbar zum Overlay hinzu
    overlay?.insert(overlayEntry);

    // Entferne die Snackbar nach 3 Sekunden
    Future.delayed(Duration(seconds: 3)).then((_) => overlayEntry.remove());
  }



}

class NumberLimitFormatter extends TextInputFormatter {
  final int maxNumber;

  NumberLimitFormatter(this.maxNumber);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final number = int.tryParse(newValue.text);
    if (number == null || number > maxNumber) return oldValue; // Maximalwert beachten
    return newValue;
  }
}

class PlayerSearchContainer extends StatefulWidget {
  final Tournament t;
  final VoidCallback onUpdate;

  const PlayerSearchContainer({super.key, required this.t, required this.onUpdate});

  @override
  State<PlayerSearchContainer> createState() => _PlayerSearchContainerState();
}

class _PlayerSearchContainerState extends State<PlayerSearchContainer> {
  late Tournament t;
  TextEditingController searchController = TextEditingController();
  String regex ="";

  void getTournament(){
    t = widget.t;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTournament();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.24,
          height: 50,

          decoration: BoxDecoration(
              color: basicContainerColor,
              borderRadius: BorderRadius.circular(6)
          ),

          child: Row(
            children: [
              Container(
                width: 50,
                child: Icon(
                  Icons.search,
                  color: Colors.white60,
                  size: 30,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.24 - 50,
                child: TextField(
                  onChanged: (Value){
                    setState(() {
                      regex = Value;
                    });
                  },
                  controller: searchController,
                  cursorColor: Colors.white60,
                  decoration:InputDecoration(
                      border: InputBorder.none
                  ),
                  style: GoogleFonts.roboto(
                      color: Colors.white70,
                      fontSize: 20
                  ),


                ),
              ),
            ],
          ),

        ),

        Container(
          decoration: BoxDecoration(
              color: Colors.transparent
          ),
          width: MediaQuery.of(context).size.width * 0.28,
          height: MediaQuery.of(context).size.height -116,
          margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.03),
          child: ScrollbarTheme(
            data: ScrollbarThemeData(
              thumbColor: WidgetStateProperty.all(Colors.white54),
              thickness: WidgetStateProperty.all(5.0),
              interactive: true,

            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: t.searchPlayer(regex).length,
                itemBuilder: (context, playerIndex){
                  return GestureDetector(
                    onTap: (){
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return EditPlayerDialog(context,t.searchPlayer(regex)[playerIndex], (String fname, String lname, int lifes) {

                            setState(() {

                              t.searchPlayer(regex)[playerIndex].fName = fname;
                              t.searchPlayer(regex)[playerIndex].lName = lname;
                              t.searchPlayer(regex)[playerIndex].lifes = lifes;

                            });

                          }, t, widget.onUpdate);
                        },
                      );
                    },
                    child: Row(
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
                                        t.searchPlayer(regex)[playerIndex].fName,
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
                                        t.searchPlayer(regex)[playerIndex].lName,
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
                                        t.searchPlayer(regex)[playerIndex].lifes.toString(),
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
                          onPressed: () async {


                            setState(() {
                              t.removePlayer(t.players[playerIndex]);
                            });
                            widget.onUpdate();
                          },
                          icon: Icon(
                            Icons.delete,
                            color: basicAppRed,
                            size: 30,
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          )
        ),
      ],
    );
  }
}


Widget EditPlayerDialog(context,Player player, Function save, Tournament t, Function onUpdate){

  TextEditingController fNameController = TextEditingController(text: player.fName);
  TextEditingController lNameController = TextEditingController(text: player.lName);
  TextEditingController lifesController = TextEditingController(text: player.lifes.toString());

  int maxCards(){

    if(t.ticketCount - t.soldTickets() <= 0){
      return player.lifes;
    }else{
      if(t.ticketCount - t.soldTickets() >=5){
        return 5;
      }else{
        return t.ticketCount - t.soldTickets() + player.lifes;
      }
    }


  }

  return AlertDialog(

    backgroundColor: Colors.grey[900], // Hintergrundfarbe des Dialogs
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16), // Abgerundete Ecken
    ),
    title: Text(
      "Spieler mit der Id: ${player.id}",
      style: GoogleFonts.roboto(
        color: Colors.white70,
        fontSize: 20,
      ),
    ),
    content: SizedBox(
      height: 400,
      width: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Vorname",
            style: GoogleFonts.roboto(
              color: Colors.white70,
              fontSize: 17,),
          ),
          CustomTextField(width: 400, controller: fNameController, hintText: "",),
          Text(
            "Nachname",
            style: GoogleFonts.roboto(
              color: Colors.white70,
              fontSize: 17,),
          ),
          CustomTextField(width: 400, controller: lNameController, hintText: "",),
          Text(
            "Leben",
            style: GoogleFonts.roboto(
              color: Colors.white70,
              fontSize: 17,),
          ),
          CustomTextField(width: 400, controller: lifesController, hintText: "", onlyNumbers: true, maxNumber: maxCards(),),




        ],
      ),
    ),


    actions: [
      TextButton(
        onPressed: () {
          Navigator.of(context)
              .pop(); // Dialog schließen, wenn abgebrochen wird
        },
        child: Text(
          "Abbrechen",
          style: GoogleFonts.roboto(
            color: Colors.white70,
            fontSize: 17,
          ),
        ),
      ),
      TextButton(
        onPressed: () async {
          Navigator.of(context).pop(); // Dialog schließen nach dem Löschen
          var db = await dbController();
          executeQuery(db, "UPDATE player SET fName = '${fNameController.text}', lName = '${lNameController.text}', lifes =  ${lifesController.text} WHERE id = ${player.id};");
          save(fNameController.text, lNameController.text, int.parse(lifesController.text));
          onUpdate();

        },
        child: Text(
          "Speichern",
          style: GoogleFonts.roboto(
            color: Colors.green, // Rote Farbe für die Löschen-Schaltfläche
            fontSize: 17,
          ),
        ),
      ),
    ],
  );
}
