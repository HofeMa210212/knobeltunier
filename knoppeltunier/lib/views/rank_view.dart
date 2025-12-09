
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:knobeltunier/global_variables.dart';
import 'package:sqflite/sqflite.dart';

import '../db/database.dart';

class RankView extends StatefulWidget {
  final int toudnamentId;
  const RankView({super.key, required this.toudnamentId});

  @override
  State<RankView> createState() => _RankViewState();
}



class _RankViewState extends State<RankView> {

List<Map<String, dynamic>> ranks = [];



  Future<void> getRanks() async {
    Database db = await dbController();

    var newRanks = await db.rawQuery('''
    SELECT mp.rank,
    p.fName || ' ' || p.lName AS name
    FROM matchPlayer mp
    INNER JOIN player p ON p.id = mp.playerId
    WHERE mp.rank IS NOT NULL AND p.tournamentId = ${widget.toudnamentId}
    ORDER BY mp.rank;
  ''');

    setState(() {
      ranks = newRanks;
    });

  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRanks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: basicBackgroundColor,

      appBar: AppBar(
        backgroundColor: basicBackgroundColor,
      ),

      body: SingleChildScrollView(
        child: Row(
          children: [
            ColumnRanks(0, (ranks.length / 2).ceil(), ranks, MediaQuery.of(context).size.width * 0.5, 0),
            ColumnRanks((ranks.length / 2).ceil(), ranks.length, ranks, MediaQuery.of(context).size.width * 0.5, 1),
          ],
        ),
      ),
    );
  }
}


Widget ColumnRanks(int from, int to, List<Map<String, dynamic>> ranks, double width, int startColor){
  return Column(
    children: List.generate(to - from, (index){
      return Container(
        width: width,
        height: 25,
        decoration: BoxDecoration(
            color: (index % 2 == startColor) ? basicContainerColor :  basicContainerColor2
        ),
        child: Row(
          children: [
            Container(
              width: width / 2,
              child: FittedBox(
                child: Text(
                  ranks[index + from]["name"],
                  style: GoogleFonts.roboto(
                      color: Colors.white70,
                      fontSize: 20
                  ),
                ),
              ),
            ),
            Container(
              width: width / 2,
              child: FittedBox(
                child: Text(
                  "${ranks[index + from]["rank"].toString()}. Rang",
                  style: GoogleFonts.roboto(
                      color: Colors.white70,
                      fontSize: 20
                  ),
                ),
              ),
            ),
          ]
        ),
      );



    },
    ),
  );

}