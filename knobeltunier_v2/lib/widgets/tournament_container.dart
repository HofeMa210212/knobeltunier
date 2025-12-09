import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:knobeltunier_v2/Color/app_Colors.dart';
import 'package:knobeltunier_v2/data/tournament/tournament.dart';
import 'package:knobeltunier_v2/data/tournament/tournament_list.dart';
import 'package:knobeltunier_v2/views/match_view.dart';
import 'package:knobeltunier_v2/views/rank_view.dart';
import 'package:provider/provider.dart';


class TournamentContainer extends StatefulWidget {
  const TournamentContainer({super.key});

  @override
  State<TournamentContainer> createState() => _TournamentContainerState();
}

class _TournamentContainerState extends State<TournamentContainer> {
  
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
   return Consumer<TournamentList>(
    builder: (context, tournamentList, child){

      List<Tournament> tournaments = tournamentList.tournaments;

      return SizedBox(
        width: MediaQuery.of(context).size.width * 0.28,
        child: Column(
          children: List.generate(tournaments.length, (tournamentIndex){
            Tournament t = tournaments[tournamentIndex];
            return Row(
              children: [
                IconButton(
                  onPressed: (){
                    setState(() {

                      if(tournamentList.selectedTournamentIndex == tournamentIndex){
                        tournamentList.selectedTournamentIndex = -1;
                      }
                      tournamentList.removeTournament(t);

                    });
                  },
                  icon: Icon(
                    Icons.delete,
                    color: AppColors.basicAppRed,
                    size: 30,
                  ),
                ),

                GestureDetector(
                  onTap: (){
                    setState(() {


                      if(tournamentList.selectedTournamentIndex == tournamentIndex){
                        tournamentList.selectedTournamentIndex = -1;
                      }else {
                        tournamentList.selectedTournamentIndex = tournamentIndex;
                      }
                    });
                  },
                  child: Container(
                    margin: EdgeInsetsDirectional.only(top: 5),
                    width: MediaQuery.of(context).size.width * 0.17,
                    height: 50,
                    decoration: BoxDecoration(
                        color: (tournamentList.selectedTournamentIndex == tournamentIndex) ? Color(0x992C2C2C) : AppColors.basicContainerColor,
                        borderRadius: BorderRadius.circular(6)
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.01),
                            width: MediaQuery.of(context).size.width * 0.11,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Center(
                                child: AutoSizeText(
                                  t.name,
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
                            width: MediaQuery.of(context).size.width * 0.05,

                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Center(
                                child: AutoSizeText(
                                  t.ticketCount.toString(),
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
                ),

                IconButton(
                  onPressed: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (builder) => RankView(tournament: t,))
                    );

                  },
                  icon: Icon(
                    Icons.bar_chart,
                    color: Colors.white60,
                    size: 34,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (builder) => MatchView(tournament: tournaments[tournamentIndex],) )
                    );
                  },
                  icon: Icon(
                    Icons.play_arrow_outlined,
                    color: Colors.green,
                    size: 34,
                  ),
                ),

              ],
            );
          }),
        ),
      );
    },
   );
  }
}
