import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knobeltunier/views/projector_start_view.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../views/projector_view.dart';

void main() {
  databaseFactory = databaseFactoryFfi;

  runApp(SecondWindowApp());

}


class SecondWindowApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProjectorStartView(),
    );
  }
}
