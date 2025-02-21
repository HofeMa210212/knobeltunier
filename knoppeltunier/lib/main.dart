import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:knobeltunier/db/database.dart';
import 'package:knobeltunier/views/start_view.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';

import 'match_player.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  initializeDatabaseFactory();
  final Database db = await dbController();

  await MatchPlayer.initializeIdCounter(db);

  runApp(const MyApp());

  doWhenWindowReady(() {
    final win = appWindow;
    win.minSize = Size(400, 300);
    win.size = Size(800, 600);
    win.alignment = Alignment.center;
    win.show();
  });

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





