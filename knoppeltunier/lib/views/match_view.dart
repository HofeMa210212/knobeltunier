
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:knobeltunier/global_variables.dart';
import 'package:knobeltunier/tournament.dart';
import 'package:knobeltunier/views/projector_view.dart';
import 'package:knobeltunier/views/start_view.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:knobeltunier/match.dart';
import 'package:window_manager/window_manager.dart';

import '../match_player.dart';

class MatchView extends StatefulWidget {
  final Tournament tournament;


  const MatchView({super.key, required this.tournament});

  @override
  State<MatchView> createState() => _MatchViewState();
}

class _MatchViewState extends State<MatchView> {
  late Tournament tournament;
  double rowHight = 40;
  bool markePlayedMatches = false;



  void getTournaments(){
    tournament = widget.tournament;
  }

  void _openNewWindow() {
    runApp(ProjectorView(tournamentId: tournament.id.toString()));

    doWhenWindowReady(() {
      final win = appWindow;
      win.minSize = Size(600, 400);
      win.size = Size(1024, 768);
      win.alignment = Alignment.center;
      win.show();
    });
  }

  @override
  void initState() {
    super.initState();
    getTournaments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: basicBackgroundColor,

      appBar: AppBar(

        toolbarHeight: 50,
        foregroundColor: Colors.white70,
        backgroundColor: basicBackgroundColor,

        actions: [
          Switch(
            value: markePlayedMatches,
            onChanged: (value){
              setState(() {
                markePlayedMatches = value;
              });},
            activeColor: Colors.green,
            inactiveThumbColor: basicContainerColor,
            inactiveTrackColor: basicContainerColor2,


          ),
          SizedBox(width: 30),

          IconButton(
            tooltip: "Projector view",
            onPressed: () async{
              _openNewWindow();
            },
            icon: Icon(
              Icons.video_camera_back,
              color: Colors.white54,
              size: 35,
            ),
          ),
          SizedBox(width: 30),

          IconButton(
            tooltip: "PDF",
            onPressed: (){
              setState(() {
               tournament.generateMatchesPdf();

              });
            },
            icon: Icon(
              Icons.print,
              color: Colors.white54,
              size: 35,
            ),
          ),
          SizedBox(width: 30),
          IconButton(
            tooltip: "Größe anpassen",
            onPressed: (){
              setState(() {

                rowHight = (MediaQuery.of(context).size.height -50) / (tournament.matches.length / 3).ceil();


              });
            },
            icon: Icon(
              Icons.aspect_ratio,
              color: Colors.white54,
              size: 35,
            ),
          ),

          IconButton(
            tooltip: "Kleiner",
            onPressed: (){
              setState(() {
                if(rowHight > 10){
                  rowHight -=10;
                }

              });
            },
            icon: Icon(
              Icons.remove,
              color: Colors.white54,
              size: 35,
            ),
          ),
          IconButton(
            tooltip: "Größer",
            onPressed: (){
              setState(() {
                if(rowHight <= 150){
                  rowHight += 10;
                }

              });
            },
            icon: Icon(
              Icons.add,
              color: Colors.white54,
              size: 35,
            ),
          ),
          SizedBox(width: 30),

          IconButton(
            tooltip: "Nächtse Runde",
            onPressed: (){
              setState(() {

                if(tournament.allMatchesPlayed()){
                tournament.nextRound();
                }

              });
            },
            icon: Icon(
              Icons.play_arrow_rounded,
              color: (tournament.allMatchesPlayed()) ? Colors.green : Colors.white38,
              size: 35,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            Container(
              height: rowHight * (tournament.matches.length / 3).ceil(),
              width: MediaQuery.of(context).size.width * 0.33,

            child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
              itemCount:(tournament.matches.length / 3).ceil(),
              itemBuilder: (context, index) {
                int matchIndex = index;
                if (matchIndex <= tournament.matches.length) {
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.33,
                    height: rowHight,
                    decoration: BoxDecoration(
                      color: (markePlayedMatches && tournament.matches[matchIndex].winner != null)
                          ? Color(0x27858585)
                          : ((matchIndex % 2 == 0) ? basicContainerColor : basicContainerColor2),


                    ),
                    child: Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.03,

                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Center(
                              child: AutoSizeText(
                                "${matchIndex+1}.",
                                style: GoogleFonts.roboto(
                                    color: Colors.white60,
                                    fontSize: 18),
                                maxFontSize: 18,
                              ),
                            ),
                          ),
                        ),

                        Container(
                          width: MediaQuery.of(context).size.width * 0.03,

                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Center(
                              child: AutoSizeText(
                                "${tournament.matches[matchIndex].time?.hour.toString().padLeft(2, '0')}:${tournament.matches[matchIndex].time?.minute.toString().padLeft(2, '0')}"
                                ,
                                style: GoogleFonts.roboto(
                                    color: Colors.white60,
                                    fontSize: 18),
                                maxFontSize: 18,
                              ),
                            ),
                          ),
                        ),

                        Container(
                          height: rowHight,
                          width: MediaQuery.of(context).size.width * 0.025,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: IconButton(
                              onPressed: (){
                                setState(() {
                                  tournament.matches[matchIndex].setWinner(tournament.matches[matchIndex].player1);



                                });
                              },
                              icon: Icon(
                                (tournament.matches[matchIndex].winner?.id == tournament.matches[matchIndex].player2.id)? Symbols.close : Symbols.trophy_sharp,

                                color: (tournament.matches[matchIndex].winner == null) ? Colors.white12 : (tournament.matches[matchIndex].winner?.id == tournament.matches[matchIndex].player1.id) ? Colors.green : basicAppRed,
                                size: 30,
                                weight: 1000,
                              ),
                            ),
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                          width: MediaQuery.of(context).size.width * 0.07,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Center(
                              child: AutoSizeText(
                                "${tournament.matches[matchIndex].player1.fName} ${tournament.matches[matchIndex].player1.lName[0]}.",
                                style: GoogleFonts.roboto(
                                  color: Colors.white70,
                                  fontSize: 20,
                                ),
                                // maxFontSize: 20,
                              ),
                            ),
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                          width: MediaQuery.of(context).size.width * 0.02,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Center(
                              child: AutoSizeText(
                                "VS",
                                style: GoogleFonts.roboto(
                                    color: Colors.white54,
                                    fontSize: 18
                                ),
                                maxFontSize: 18,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                          width: MediaQuery.of(context).size.width * 0.07,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Center(
                              child: AutoSizeText(
                                "${tournament.matches[matchIndex].player2.fName} ${tournament.matches[matchIndex].player2.lName[0]}.",
                                style: GoogleFonts.roboto(
                                    color: Colors.white70,
                                    fontSize: 20
                                ),
                                maxFontSize: 20,
                              ),
                            ),
                          ),
                        ),

                        Container(
                          height: rowHight,
                          width: MediaQuery.of(context).size.width * 0.025,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: IconButton(
                              onPressed: (){
                                setState(() {

                                  tournament.matches[matchIndex].setWinner(tournament.matches[matchIndex].player2);

                                });
                              },
                              icon: Icon(
                                (tournament.matches[matchIndex].winner?.id == tournament.matches[matchIndex].player1.id)? Symbols.close : Symbols.trophy_sharp,
                                color: (tournament.matches[matchIndex].winner == null) ? Colors.white12 : (tournament.matches[matchIndex].winner?.id == tournament.matches[matchIndex].player2.id) ? Colors.green : basicAppRed,
                                size: 30,
                                weight: 1000,

                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  );
                } else {
                  return Container(); // Leeres Container für überflüssige Spalten
                }
              }
            ),
            ),



            if(tournament.matches.length > 1)...[
              Container(
                  height: rowHight * (tournament.matches.length / 3).ceil(),
                  width: MediaQuery.of(context).size.width * 0.34,
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount:(tournament.matches.length / 3).ceil(),
                    itemBuilder: (context, index){

                      int matchIndex = ((tournament.matches.length / 3).ceil()) + index;
                      if (matchIndex <= tournament.matches.length) {
                        return Container(
                          width: MediaQuery.of(context).size.width * 0.34,
                          height: rowHight,
                          decoration: BoxDecoration(
                            color: (markePlayedMatches && tournament.matches[matchIndex].winner != null)
                                ? Color(0x27858585)  // Grau, wenn makePlayedMatches true und winner null
                                : ((matchIndex % 2 == 0) ? basicContainerColor : basicContainerColor2),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.03,

                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Center(
                                    child: AutoSizeText(
                                      "${matchIndex+1}.",
                                      style: GoogleFonts.roboto(
                                          color: Colors.white60,
                                          fontSize: 18),
                                      maxFontSize: 18,
                                    ),
                                  ),
                                ),
                              ),

                              Container(
                                width: MediaQuery.of(context).size.width * 0.03,

                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Center(
                                    child: AutoSizeText(
                                      "${tournament.matches[matchIndex].time?.hour.toString().padLeft(2, '0')}:${tournament.matches[matchIndex].time?.minute.toString().padLeft(2, '0')}"
                                      ,
                                      style: GoogleFonts.roboto(
                                          color: Colors.white60,
                                          fontSize: 18),
                                      maxFontSize: 18,
                                    ),
                                  ),
                                ),
                              ),

                              Container(
                                height: rowHight,
                                width: MediaQuery.of(context).size.width * 0.025,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: IconButton(
                                    onPressed: (){
                                      setState(() {
                                        tournament.matches[matchIndex].setWinner(tournament.matches[matchIndex].player1);



                                      });
                                    },
                                    icon: Icon(
                                      (tournament.matches[matchIndex].winner?.id == tournament.matches[matchIndex].player2.id)? Symbols.close : Symbols.trophy_sharp,

                                      color: (tournament.matches[matchIndex].winner == null) ? Colors.white12 : (tournament.matches[matchIndex].winner?.id == tournament.matches[matchIndex].player1.id) ? Colors.green : basicAppRed,
                                      size: 30,
                                      weight: 1000,
                                    ),
                                  ),
                                ),
                              ),

                              Container(
                                margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                                width: MediaQuery.of(context).size.width * 0.07,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Center(
                                    child: AutoSizeText(
                                      "${tournament.matches[matchIndex].player1.fName} ${tournament.matches[matchIndex].player1.lName[0]}.",
                                      style: GoogleFonts.roboto(
                                        color: Colors.white70,
                                        fontSize: 20,
                                      ),
                                      // maxFontSize: 20,
                                    ),
                                  ),
                                ),
                              ),

                              Container(
                                margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                                width: MediaQuery.of(context).size.width * 0.02,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Center(
                                    child: AutoSizeText(
                                      "VS",
                                      style: GoogleFonts.roboto(
                                          color: Colors.white54,
                                          fontSize: 18
                                      ),
                                      maxFontSize: 18,
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                              ),

                              Container(
                                margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                                width: MediaQuery.of(context).size.width * 0.07,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Center(
                                    child: AutoSizeText(
                                      "${tournament.matches[matchIndex].player2.fName} ${tournament.matches[matchIndex].player2.lName[0]}.",
                                      style: GoogleFonts.roboto(
                                          color: Colors.white70,
                                          fontSize: 20
                                      ),
                                      maxFontSize: 20,
                                    ),
                                  ),
                                ),
                              ),

                              Container(
                                height: rowHight,
                                width: MediaQuery.of(context).size.width * 0.025,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: IconButton(
                                    onPressed: (){
                                      setState(() {

                                        tournament.matches[matchIndex].setWinner(tournament.matches[matchIndex].player2);

                                      });
                                    },
                                    icon: Icon(
                                      (tournament.matches[matchIndex].winner?.id == tournament.matches[matchIndex].player1.id)? Symbols.close : Symbols.trophy_sharp,
                                      color: (tournament.matches[matchIndex].winner == null) ? Colors.white12 : (tournament.matches[matchIndex].winner?.id == tournament.matches[matchIndex].player2.id) ? Colors.green : basicAppRed,
                                      size: 30,
                                      weight: 1000,

                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Container(); // Leeres Container für überflüssige Spalten
                      }

                    },

                  )
              ),
            ],



            if(tournament.matches.length >5)...[
              Container(
                height: rowHight * ((tournament.matches.length / 3).ceil()),
                width: MediaQuery.of(context).size.width * 0.33,
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  // Es sollen nur die restlichen Matches angezeigt werden:
                  itemCount: tournament.matches.length - (((tournament.matches.length / 3).ceil()) * 2),
                  itemBuilder: (context, index) {
                    int rowsPerColumn = (tournament.matches.length / 3).ceil();
                    int baseIndex = rowsPerColumn * 2;
                    int matchIndex = baseIndex + index;

                    final match = tournament.matches[matchIndex];

                    return Container(
                      width: MediaQuery.of(context).size.width * 0.33,
                      height: rowHight,
                      decoration: BoxDecoration(
                        color: (markePlayedMatches && match.winner != null)
                            ? Color(0x27858585)
                            : ((matchIndex % 2 == 0) ? basicContainerColor : basicContainerColor2),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.03,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Center(
                                child: AutoSizeText(
                                  "${matchIndex + 1}.",
                                  style: GoogleFonts.roboto(
                                    color: Colors.white60,
                                    fontSize: 18,
                                  ),
                                  maxFontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.03,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Center(
                                child: AutoSizeText(
                                  "${match.time?.hour.toString().padLeft(2, '0')}:${match.time?.minute.toString().padLeft(2, '0')}",
                                  style: GoogleFonts.roboto(
                                    color: Colors.white60,
                                    fontSize: 18,
                                  ),
                                  maxFontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: rowHight,
                            width: MediaQuery.of(context).size.width * 0.025,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    match.setWinner(match.player1);
                                  });
                                },
                                icon: Icon(
                                  (match.winner?.id == match.player2.id)
                                      ? Symbols.close
                                      : Symbols.trophy_sharp,
                                  color: (match.winner == null)
                                      ? Colors.white12
                                      : (match.winner?.id == match.player1.id)
                                      ? Colors.green
                                      : basicAppRed,
                                  size: 30,
                                  weight: 1000,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                            width: MediaQuery.of(context).size.width * 0.07,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Center(
                                child: AutoSizeText(
                                  "${match.player1.fName} ${match.player1.lName[0]}.",
                                  style: GoogleFonts.roboto(
                                    color: Colors.white70,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                            width: MediaQuery.of(context).size.width * 0.02,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Center(
                                child: AutoSizeText(
                                  "VS",
                                  style: GoogleFonts.roboto(
                                    color: Colors.white54,
                                    fontSize: 18,
                                  ),
                                  maxFontSize: 18,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                            width: MediaQuery.of(context).size.width * 0.07,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Center(
                                child: AutoSizeText(
                                  "${match.player2.fName} ${match.player2.lName[0]}.",
                                  style: GoogleFonts.roboto(
                                    color: Colors.white70,
                                    fontSize: 20,
                                  ),
                                  maxFontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: rowHight,
                            width: MediaQuery.of(context).size.width * 0.025,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    match.setWinner(match.player2);
                                  });
                                },
                                icon: Icon(
                                  (match.winner?.id == match.player1.id)
                                      ? Symbols.close
                                      : Symbols.trophy_sharp,
                                  color: (match.winner == null)
                                      ? Colors.white12
                                      : (match.winner?.id == match.player2.id)
                                      ? Colors.green
                                      : basicAppRed,
                                  size: 30,
                                  weight: 1000,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )

            ],



          ],
        ),
      ),





    );
  }
}

