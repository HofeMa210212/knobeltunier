
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:knobeltunier_v2/Color/app_Colors.dart';
import 'package:knobeltunier_v2/data/match/match.dart';
import 'package:knobeltunier_v2/data/player/matchplayer.dart';
import 'package:knobeltunier_v2/data/tournament/tournament.dart';
import 'package:knobeltunier_v2/data/tournament/tournament_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class MatchesColumn extends StatefulWidget {
  final int from;
  final int to;
  final Tournament tournament;

  const MatchesColumn({
    super.key,
    required this.from,
    required this.to,
    required this.tournament,
  });

  @override
  State<MatchesColumn> createState() => _MatchesColumnState();
}

class _MatchesColumnState extends State<MatchesColumn> {
  late Tournament t;

  @override
  void initState() {
    super.initState();
    t = widget.tournament;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TournamentList>(
      builder: (context, tournamentList, child) {
        double rowHeight = tournamentList.rowHight;
        bool markPlayedMatches = tournamentList.markePlayedMatches;
        bool showTimes = tournamentList.showTimes;

        final visibleMatches = t.matches.sublist(
          widget.from,
          widget.to.clamp(0, t.matches.length),
        );

        return SizedBox(
          height: rowHeight * visibleMatches.length,
          width: MediaQuery.of(context).size.width * 0.33,
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visibleMatches.length,
            itemBuilder: (context, index) {
              final matchIndex = widget.from + index;
              final TournamentMatch match = t.matches[matchIndex];


             return ChangeNotifierProvider<TournamentMatch>.value(
               value: match,
               child: Consumer<TournamentMatch>(
                 builder: (context, match, child){
                   return Container(
                     height: rowHeight,
                     decoration: BoxDecoration(
                       color: (markPlayedMatches && match.winner != null)
                           ? const Color(0x27858585)
                           : (index % 2 == 0
                           ? AppColors.basicContainerColor
                           : AppColors.basicContainerColor2),
                     ),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                       children: [
                         _buildText("${matchIndex + 1}.", 0.03),
                         showTimes
                             ? _buildText(
                             "${match.time?.hour.toString().padLeft(2, '0')}:${match.time?.minute.toString().padLeft(2, '0')}",
                             0.03)
                             : SizedBox(),
                         _buildIconButton(
                           match ,
                           match.player1,
                           match.winner == match.player2,
                         ),
                         _buildText("${match.player1.fName} ${match.player1.lName[0]}.", 0.07),
                         _buildText("VS", 0.02),
                         _buildText("${match.player2.fName} ${match.player2.lName[0]}.", 0.07),
                         _buildIconButton(
                           match,
                           match.player2,
                           match.winner == match.player1,
                         ),
                       ],
                     ),
                   );
                 },
               ),
             );
            },
          ),
        );
      },
    );
  }

  Widget _buildText(String text, double widthFactor) {
    return Container(
      width: MediaQuery.of(context).size.width * widthFactor,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Center(
          child: AutoSizeText(
            text,
            style: GoogleFonts.roboto(
              color: Colors.white70,
              fontSize: 18,
            ),
            maxLines: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(TournamentMatch match, MatchPlayer player, bool showCloseIcon) {
    final isWinner = match.winner == player;
    final color = match.winner == null
        ? Colors.white12
        : isWinner
        ? Colors.green
        : AppColors.basicAppRed;

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.025,
      height: double.infinity,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: IconButton(
          onPressed: () {
            setState(() {
              match.matchWinner = player;
            });


          },
          icon: Icon(
            showCloseIcon ? Symbols.close : Symbols.trophy_sharp,
            color: color,
            size: 30,
            weight: 1000,
          ),
        ),
      ),
    );
  }
}

