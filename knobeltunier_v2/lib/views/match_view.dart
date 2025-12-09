
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knobeltunier_v2/Color/app_Colors.dart';
import 'package:knobeltunier_v2/data/tournament/tournament.dart';
import 'package:knobeltunier_v2/data/tournament/tournament_list.dart';
import 'package:knobeltunier_v2/widgets/matches_column.dart';
import 'package:provider/provider.dart';

class MatchView extends StatefulWidget {

  final Tournament tournament;

  const MatchView({super.key, required this.tournament});


  @override
  State<MatchView> createState() => _MatchViewState();
}

class _MatchViewState extends State<MatchView> {
  late Tournament t;
  bool showTimes = false;
  bool markePlayedMatches = false;
  double rowHight = 40;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    t = widget.tournament;


  }
  @override
  Widget build(BuildContext context) {
    TournamentList p = Provider.of<TournamentList>(context, listen: false);
    return Scaffold(
      appBar: AppBar(

        toolbarHeight: 50,
        foregroundColor: Colors.white70,
        backgroundColor: AppColors.basicContainerColor,

        actions: [
          //Zum anzeigen der Zeiten
          Switch(
            value: p.showTimes,
            onChanged: (value){
              setState(() {
                p.showTimes = value;
              });},
            activeColor: Colors.green,
            inactiveThumbColor:  AppColors.basicContainerColor,
            inactiveTrackColor:  AppColors.basicContainerColor2,


          ),
          SizedBox(width: 30),

          //Zum makieren der noch nicht gespielten matches
          Switch(
            value: p.markePlayedMatches,
            onChanged: (value){
              setState(() {
                p.markePlayedMatches = value;
              });},
            activeColor: Colors.green,
            inactiveThumbColor:  AppColors.basicContainerColor,
            inactiveTrackColor:  AppColors.basicContainerColor2,


          ),
          SizedBox(width: 30),

          //Pdf machen der Player
          IconButton(
            tooltip: "PDF Tournaments",
            onPressed: (){
              setState(() {
                t.generateMatchesPdf();

              });
            },
            icon: Icon(
              Icons.print,
              color: Colors.white54,
              size: 35,
            ),
          ),
          SizedBox(width: 30),

          //Größe Anpassen so das alles auf den Bildschirm Platz hat
          IconButton(
            tooltip: "Größe anpassen",
            onPressed: (){
              setState(() {
                p.rowHight = (MediaQuery.of(context).size.height -50) / (t.matches.length / 3).ceil();
              });
            },
            icon: Icon(
              Icons.aspect_ratio,
              color: Colors.white54,
              size: 35,
            ),
          ),

          //Größe kleiner machen
          IconButton(
            tooltip: "Kleiner",
            onPressed: (){
              setState(() {
                if(p.rowHight > 10){
                  p.setRowHight(p.rowHight - 10);
                }

              });
            },
            icon: Icon(
              Icons.remove,
              color: Colors.white54,
              size: 35,
            ),
          ),

          //Größe größer machen
          IconButton(
            tooltip: "Größer",
            onPressed: (){
              setState(() {
                if(p.rowHight <= 150){
                  p.setRowHight(p.rowHight + 10);
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

          //Nächste Runde
          IconButton(
            tooltip: "Nächtse Runde",
            onPressed: (){
              setState(() {
                if(t.allMatchesPlayed()){
                  t.nextRound();
                }

              });
            },
            icon: Icon(
              Icons.play_arrow_rounded,
              color: (t.allMatchesPlayed()) ? Colors.green : Colors.white38,
              size: 35,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(3, (index) {
            final matchesPerColumn = (t.matches.length / 3).ceil();

            final from = index * matchesPerColumn;
            int to = (index + 1) * matchesPerColumn;
            if (to > t.matches.length) to = t.matches.length;

            return MatchesColumn(
              tournament: t,
              from: from,
              to: to,
            );
          }),
        ),



      ),

    );

  }
}
