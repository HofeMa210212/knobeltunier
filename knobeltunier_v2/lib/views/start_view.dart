
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knobeltunier_v2/data/tournament/tournament_list.dart';
import 'package:knobeltunier_v2/widgets/new_tournament_container.dart';
import 'package:knobeltunier_v2/widgets/player_and_matches_container.dart';
import 'package:knobeltunier_v2/widgets/tournament_container.dart';
import 'package:knobeltunier_v2/widgets/tournament_settings_container.dart';
import 'package:provider/provider.dart';

class StartView extends StatefulWidget {
  const StartView({super.key});

  @override
  State<StartView> createState() => _StartViewState();
}

class _StartViewState extends State<StartView> {



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TournamentList>(context, listen: false).read();
    });
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     body: SingleChildScrollView(
       child: Row(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [

           TournamentContainer(),

           Consumer<TournamentList>(
             builder: (context, tournamentList, child){
               bool selected = tournamentList.isTournamentSelected;
               int selectedTournament = tournamentList.selectedTournamentIndex;

              return Row(
                children: [
                  (!selected) ?
                  NewTournamentContainer() : SizedBox(),

                  (selected) ?
                  TournamentSettingsContainer() : SizedBox(),

                  (selected) ?
                  PlayerAndMatchesContainer() : SizedBox(),
                ],
              );



             },
           ),


         ],
       ),
     ),
   );
  }
}

