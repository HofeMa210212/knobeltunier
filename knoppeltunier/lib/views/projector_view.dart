
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knobeltunier/db/database.dart';
import 'package:path_provider/path_provider.dart';

import '../global_variables.dart';
import '../pdf/makeProjectorViewPdf.dart';



class ProjectorView extends StatefulWidget{

  final String tournamentId;
  ProjectorView({super.key, required this.tournamentId});

  @override
  State<ProjectorView> createState() => _ProjectorViewState();
}

class _ProjectorViewState extends State<ProjectorView>{
  int tournamentId = 0;
  List<Map<String, dynamic>> tournamentData = [];
  var db;
  double rowHight = 40;


  void getTournamentId(){
    try {
      tournamentId = int.parse(widget.tournamentId);
    }catch(e){
      print("Error parsing tournamentId");
    }
  }

  Future<void> getTournamentData() async {
    db = await dbController();

    Directory dbDir = await getApplicationSupportDirectory(); // Gemeinsames Verzeichnis
    print(dbDir.path);



    var newtournamentData = await executeQuery(db, '''
   SELECT 
    p.id AS playerId, 
    p.fName || ' ' || p.lName AS playerName,
    (SELECT GROUP_CONCAT(m.matchNumber, ', ') 
     FROM match m 
     JOIN matchPlayer mp ON m.matchPlayer1Id = mp.id OR m.matchPlayer2Id = mp.id
     WHERE mp.playerId = p.id 
     ORDER BY m.matchNumber) AS matchNumbers
FROM player p
WHERE p.tournamentId = $tournamentId
AND EXISTS (
    SELECT 1 
    FROM matchPlayer mp 
    JOIN match m ON m.matchPlayer1Id = mp.id OR m.matchPlayer2Id = mp.id
    WHERE mp.playerId = p.id
);

   
   
    ''');

    print(newtournamentData);

    setState(() {
      tournamentData = newtournamentData;

    });
  }



  @override
  void initState() {
    super.initState();
    getTournamentId();
    getTournamentData();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: basicBackgroundColor,
        appBar: AppBar(
          backgroundColor: basicBackgroundColor,
         toolbarHeight: 50,
         actions: [
           IconButton(
             tooltip: "PDF",
             onPressed: (){
               setState(() {

                 generateMatchesPdf(tournamentId);
               });
             },
             icon: Icon(
               Icons.picture_as_pdf,
               color: Colors.white54,
               size: 35,
             ),
           ),
           SizedBox(width: 30),
           IconButton(
             tooltip: "Größe anpassen",
             onPressed: (){
               setState(() {

                 rowHight = (MediaQuery.of(context).size.height -60) / ((tournamentData.length/ 2).ceil() +1);


               });
             },
             icon: Icon(
               Icons.aspect_ratio,
               color: Colors.white54,
               size: 35,
             ),
           ),
           SizedBox(width: 30),

           IconButton(
             onPressed: (){
               getTournamentData();

             },
             icon: Icon(
               Icons.sync,
               size: 30,
               color: Colors.white60,
             )
           )
         ],
        ),

        body: SingleChildScrollView(
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                  width: MediaQuery.of(context).size.width / 2,
                  height: rowHight,
                  decoration: BoxDecoration(
                    color:basicContainerColor2,
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                        width: MediaQuery.of(context).size.width * 0.13,
                        child: FittedBox(
                          child: Text(
                            "Spieler",
                            style: TextStyle(

                              color: Colors.white70,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,

                        width: MediaQuery.of(context).size.width * 0.1,
                        child: FittedBox(
                          child: Text(
                            "Matches",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      )
            ],
          ),

        ),
                  SizedBox(height: 10,),

                  Column(

                    children: List.generate((tournamentData.length / 2).ceil(), (index) {
                      return Container(
                        width: MediaQuery.of(context).size.width / 2,
                        height: rowHight,
                        decoration: BoxDecoration(
                          color: (index % 2 == 0) ? basicContainerColor : basicContainerColor2,
                        ),

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                              width: MediaQuery.of(context).size.width * 0.13,
                              child: FittedBox(
                                child: Text(
                                  tournamentData[index]['playerName'],
                                  style: TextStyle(

                                    color: Colors.white70,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerLeft,

                              width: MediaQuery.of(context).size.width * 0.1,
                              child: FittedBox(
                                child: Text(
                                  tournamentData[index]['matchNumbers'],
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),

                      );
                    },
                  ),
                      ),
                ],
              ),
              Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    height: rowHight,
                    decoration: BoxDecoration(
                      color:basicContainerColor2,
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                          width: MediaQuery.of(context).size.width * 0.13,
                          child: FittedBox(
                            child: Text(
                              "Spieler",
                              style: TextStyle(

                                color: Colors.white70,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,

                          width: MediaQuery.of(context).size.width * 0.1,
                          child: FittedBox(
                            child: Text(
                              "Matches",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),

                  ),
                  SizedBox(height: 10,),
                  Column(
                    children: List.generate((tournamentData.length / 2).ceil(), (index) {
                      index = index + (tournamentData.length / 2).ceil();
                      return Container(
                        width: MediaQuery.of(context).size.width / 2,
                        height: rowHight,
                        decoration: BoxDecoration(
                          color: (index % 2 != 0) ? basicContainerColor : basicContainerColor2,
                        ),

                        child:
                        (index < tournamentData.length) ?
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
                              width: MediaQuery.of(context).size.width * 0.13,
                              child: FittedBox(
                                child: Text(
                                  tournamentData[index]['playerName'],
                                  style: TextStyle(

                                    color: Colors.white70,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerLeft,

                              width: MediaQuery.of(context).size.width * 0.1,
                              child: FittedBox(
                                child: Text(
                                  tournamentData[index]['matchNumbers'],
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ): Container()

                      );
                    },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

  }
}

