
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:knobeltunier_v2/Color/app_Colors.dart';
import 'package:knobeltunier_v2/data/match/match.dart';
import 'package:knobeltunier_v2/data/tournament/tournament.dart';
import 'package:knobeltunier_v2/data/tournament/tournament_list.dart';
import 'package:knobeltunier_v2/widgets/player_search_container.dart';
import 'package:provider/provider.dart';

class PlayerAndMatchesContainer extends StatefulWidget {
  const PlayerAndMatchesContainer({super.key});

  @override
  State<PlayerAndMatchesContainer> createState() => _PlayerAndMatchesContainerState();
}

class _PlayerAndMatchesContainerState extends State<PlayerAndMatchesContainer> {

  int selectetColumn = 0;

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
                  //Container zum wechseln der Ansicht zweischen Spieler und Matches

                  MouseRegion(
                    cursor: SystemMouseCursors.click, // oder ein anderer Cursor

                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.20,
                      height: 40,
                      margin: EdgeInsets.only(top:5, bottom: 5),
                      decoration: BoxDecoration(
                        color: AppColors.basicContainerColor2,
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
                  ),

                  if(selectetColumn==0)...[
                    PlayerSearchContainer(),

                  ]else...[
                    //Container zum anzieigen der Matches
                    Container(
                      width: MediaQuery.of(context).size.width * 0.28,
                      height: MediaQuery.of(context).size.height -50,
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
                              itemCount: t.matches.length,
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
                                            color: AppColors.basicContainerColor,
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
                                                    "${t.matches[machtIndex].player1.fName} ${t.matches[machtIndex].player1.lName[0]}.",
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
                                                    "${t.matches[machtIndex].player2.fName} ${t.matches[machtIndex].player2.lName[0]}.",
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
                                        color: AppColors.basicAppRed,
                                        size: 30,
                                      ),
                                    )

                                  ],
                                );
                              }
                          ),
                        ),
                      )
                    ),

                  ]

                ],
              );
            },
          ),
        );
      },
    );
  }
}

