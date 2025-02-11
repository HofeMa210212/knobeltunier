import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:knoppeltunier/db/database.dart';
import 'package:knoppeltunier/views/start_view.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'match_player.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initializeDatabaseFactory();
  final Database db = await dbController();

  // Initialisiere den ID-Zähler
  await MatchPlayer.initializeIdCounter(db);

  runApp(const MyApp());

  Future.microtask(() => setupDatabaseAndServer());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true, // Aktiviert Material 3 Design
      ),
      home: const StartView(),
    );
  }
}





