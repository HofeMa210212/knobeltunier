
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:knobeltunier_v2/Color/app_Colors.dart';
import 'package:knobeltunier_v2/data/match/match.dart';
import 'package:knobeltunier_v2/data/player/player.dart';
import 'package:knobeltunier_v2/widgets/edit_player_dialog.dart';
import 'package:provider/provider.dart';

import '../data/tournament/tournament.dart';
import '../data/tournament/tournament_list.dart';

class PlayerContainer extends StatefulWidget {
  final Player p;
  final Tournament t;

  const PlayerContainer({super.key, required this.p, required this.t});

  @override
  State<PlayerContainer> createState() => _PlayerContainerState();
}

class _PlayerContainerState extends State<PlayerContainer> {

  bool expanded = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    List<TournamentMatch> matches = widget.t.getMatchesForPlayers(widget.p);


    return Row(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            margin: EdgeInsetsDirectional.only(top: 5),
            width: MediaQuery.of(context).size.width * 0.24,
            height: expanded ? matches.length * 45 + 70 : 50,
            decoration: BoxDecoration(
                color: AppColors.basicContainerColor,
                borderRadius: BorderRadius.circular(6)
            ),
    
            child: Column(
              children: [
                GestureDetector(
                  onTap: (){
                    setState(() {
                      expanded = !expanded;
                    });
                  },
                  onSecondaryTap: (){
                    EditPlayer.editPlayerDialog(context, widget.p, widget.t);


                  },
                  child: Container(
                    height: 50,
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.01),
                          width: MediaQuery.of(context).size.width * 0.07,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Center(
                              child: AutoSizeText(
                                widget.p.fName,
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
                                widget.p.lName,
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
                                widget.p.lifes.toString(),
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
                
                Expanded(
                  child: Container(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: matches.length,
                      itemBuilder: (context,matchIndex){
                        TournamentMatch m = matches[matchIndex];

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            
                            Container(
                              height: 10,
                              width: 10,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: m.winner == null ? Colors.grey : m.won(widget.p) ? Colors.green : AppColors.basicAppRed,
                              ),
                            ),
                            
                            Container(
                              height: 40,
                              width:  MediaQuery.of(context).size.width * 0.15,
                              margin: EdgeInsets.only(bottom: 5),
                              decoration: BoxDecoration(
                                color: AppColors.basicContainerColor,
                                borderRadius: BorderRadius.circular(8)
                              ),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    "${m.player1.fName} vs ${m.player2.fName}",
                                    style: GoogleFonts.roboto(
                                        color: Colors.white.withAlpha(180),
                                        fontSize: 20
                                    )
                                  ),
                                ),
                              )
                            ),
                          ],
                        );

                      },
                    ),
                  ),
                ),
              ],
            ),
    
          ),
        ),
        IconButton(
          onPressed: () async {
            setState(() {
              widget.t.removePlayer(widget.p);
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
}

