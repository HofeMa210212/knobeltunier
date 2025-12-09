import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:knobeltunier_v2/data/match/match.dart';
import 'package:knobeltunier_v2/data/match/match_place.dart';
import 'package:knobeltunier_v2/data/player/matchplayer.dart';
import 'package:knobeltunier_v2/data/player/player.dart';
import 'package:knobeltunier_v2/data/player/player_list.dart';
import 'package:knobeltunier_v2/data/tournament/tournament.dart';
import 'package:knobeltunier_v2/data/tournament/tournament_list.dart';
import 'package:knobeltunier_v2/views/start_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  final appDir = await getApplicationDocumentsDirectory();
  Hive.init(appDir.path);

  Hive.registerAdapter(PlayerAdapter());
  Hive.registerAdapter(TournamentMatchAdapter());
  Hive.registerAdapter(MatchPlayerAdapter());
  Hive.registerAdapter(TournamentAdapter());
  Hive.registerAdapter(MatchPlaceAdapter());


  await Hive.openBox<Player>('playerBox');
  await Hive.openBox<TournamentMatch>('matchBox');
  await Hive.openBox<Tournament>('tournamentBox');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayerList()),
        ChangeNotifierProvider(create: (_) => TournamentList()),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: Color(0xFF121212),

      ),
      home: StartView(),
    );
  }
}

