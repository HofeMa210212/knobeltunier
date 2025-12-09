
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:knobeltunier_v2/Color/app_Colors.dart';
import 'package:knobeltunier_v2/data/tournament/tournament.dart';
import 'package:knobeltunier_v2/data/tournament/tournament_list.dart';
import 'package:knobeltunier_v2/widgets/custom_textfield.dart';
import 'package:knobeltunier_v2/widgets/snackbar.dart';
import 'package:provider/provider.dart';

class NewTournamentContainer extends StatefulWidget {
  const NewTournamentContainer({super.key});

  @override
  State<NewTournamentContainer> createState() => _NewTournamentContainerState();
}

class _NewTournamentContainerState extends State<NewTournamentContainer> {
  double tickedCount = 16;
  TextEditingController tournamentNameController = TextEditingController();
  TextEditingController tournamentTicketCountController = TextEditingController();



  @override
  Widget build(BuildContext context) {

    TournamentList tournamentList = Provider.of<TournamentList>(context, listen: false);

    return Container(
      child:  Column(
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
                    return AppColors.basicContainerColor; // Standardfarbe
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
                  color: AppColors.basicContainerColor,
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
                              backgroundColor: WidgetStatePropertyAll(AppColors.basicContainerColor),
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
                              backgroundColor: WidgetStatePropertyAll(AppColors.basicContainerColor),
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
                          Tournament t = Tournament(name: tournamentNameController.text, ticketCount: tickedCount.toInt(), parentList: tournamentList);
                          setState(() {
                            snackBar s = snackBar();
                            if(!tournamentList.tournaments.contains(t)){

                              if(tournamentNameController.text == "" && tournamentTicketCountController.text == ""){
                                s.showFailureSnackbar(context, "Alle Felder müssen ausgefült werden!");

                              }else{
                                tournamentList.addTournament(t);
                                tournamentNameController.text = "";
                              }


                            }else{

                              s.showFailureSnackbar(context, "Es gibt bereits ein Tunier mit diesen Daten!");
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
    );
  }
}
