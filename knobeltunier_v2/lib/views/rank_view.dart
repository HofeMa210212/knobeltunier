
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:knobeltunier_v2/Color/app_Colors.dart';
import 'package:knobeltunier_v2/data/tournament/tournament.dart';
import 'package:sqflite/sqflite.dart';


class RankView extends StatefulWidget {
  final Tournament tournament;
  const RankView({super.key, required this.tournament});

  @override
  State<RankView> createState() => _RankViewState();
}



class _RankViewState extends State<RankView> {

late Tournament t;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    t = widget.tournament;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Color(0xFF121212),
      ),

      body: SingleChildScrollView(
        child: Row(
          children: [
            ColumnRanks(0, (t.matchPlayersWithRank.length / 2).ceil(), t, MediaQuery.of(context).size.width * 0.5, 0),
            ColumnRanks((t.matchPlayersWithRank.length / 2).ceil(), t.matchPlayersWithRank.length, t, MediaQuery.of(context).size.width * 0.5, 1),
          ],
        ),
      ),
    );
  }
}


Widget ColumnRanks(int from, int to,Tournament t, double width, int startColor){
  return Column(
    children: List.generate(to - from, (index){
      return Container(
        width: width,
        height: 25,
        decoration: BoxDecoration(
            color: (index % 2 == startColor) ? AppColors.basicContainerColor :  AppColors.basicContainerColor2
        ),
        child: Row(
          children: [
            Container(
              width: width / 2,
              child: FittedBox(
                child: Text(
                  "${t.matchPlayersWithRank[index+from].lName} ${t.matchPlayersWithRank[index+from].fName}" ,
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
                  "${t.matchPlayersWithRank[index+from].rank.toString()}. Rang",
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