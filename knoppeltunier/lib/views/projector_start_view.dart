
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:knobeltunier/db/database.dart';
import 'package:knobeltunier/global_variables.dart';
import 'package:knobeltunier/views/projector_view.dart';

class ProjectorStartView extends StatefulWidget {
  const ProjectorStartView({super.key});

  @override
  State<ProjectorStartView> createState() => _ProjectorStartViewState();
}

class _ProjectorStartViewState extends State<ProjectorStartView> {
  List<Map<String, dynamic>> tournaments = [];
  var db;


  @override
  void initState() {
    super.initState();
    initDatabase();
    getTournaments();

  }

  Future<void> initDatabase() async {
    db = await dbController();
  }


  Future<void> getTournaments()async{
    db = await dbController();
    var newData = await executeQuery(db, "SELECT * FROM tournament");

    setState(() {
      tournaments = newData;
    });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: basicBackgroundColor,


      body: SingleChildScrollView(
        child: Column(
          children: List.generate(
            tournaments.length,
              (index){
              return Row(

                children: [
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: 40,
                    decoration: BoxDecoration(
                      color: basicContainerColor,
                      borderRadius: BorderRadius.circular(6)
                    ),

                    child: Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.15,

                          child: FittedBox(
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                tournaments[index]["tournamentName"],
                                style: GoogleFonts.roboto(
                                  color: Colors.white70,
                                  fontSize: 20,
                                ),

                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.15,

                          child: FittedBox(
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                tournaments[index]["ticketCount"].toString(),
                                style: GoogleFonts.roboto(
                                  color: Colors.white70,
                                  fontSize: 20,
                                ),

                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                  ),
                  Container(
                  margin: EdgeInsets.only(top: 10),
                    height: 40,
                    child: Center(
                      child: IconButton(
                        onPressed: (){
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (builder) => ProjectorView(tournamentId: tournaments[index]["id"].toString()))
                          );
                        },
                        icon: Icon(
                          Icons.play_arrow_outlined,
                          color: Colors.green,
                          size: 35,
                        ),
                      ),
                    ),
                  ),
                ],
              );
              }
          ),
        ),
      ),
    );
  }
}
