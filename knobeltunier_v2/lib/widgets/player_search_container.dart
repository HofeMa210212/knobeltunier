
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:knobeltunier_v2/Color/app_Colors.dart';
import 'package:knobeltunier_v2/widgets/player_cotainer.dart';
import 'package:provider/provider.dart';

import '../data/tournament/tournament.dart';
import '../data/tournament/tournament_list.dart';

class PlayerSearchContainer extends StatefulWidget {


  @override
  State<PlayerSearchContainer> createState() => _PlayerSearchContainerState();
}

class _PlayerSearchContainerState extends State<PlayerSearchContainer> {

  TextEditingController searchController = TextEditingController();
  String regex ="";



  @override
  void initState() {
    // TODO: implement initState
    super.initState();

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
                  Container(
                    width: MediaQuery.of(context).size.width * 0.24,
                    height: 50,
                    decoration: BoxDecoration(
                        color: AppColors.basicContainerColor,
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
                              return PlayerContainer(p: t.searchPlayer(regex)[playerIndex], t: t,);
                            },
                          ),
                        ),
                      )
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

