
import 'package:flutter/cupertino.dart';
import 'package:knobeltunier_v2/data/interfaces/list_interface.dart';
import 'package:knobeltunier_v2/data/player/player.dart';
import 'package:hive/hive.dart';



 class PlayerList extends ChangeNotifier implements ListInterface{

  List<Player> _players = [];


  List<Player> get player{
    return _players;
  }

  void addPlayer(Player p){
    _players.add(p);
    save();
    notifyListeners();
  }

  void removePlayer(Player p){
    _players.remove(p);
    save();
    notifyListeners();
  }

@override
  void save() {
    var box = Hive.box<Player>('playerBox');

    box.clear();

    for (Player p in _players) {
      box.put(p.id, p);
    }
  }

  @override
  void read() {
    var box = Hive.box<Player>('playerBox');

    _players.clear();

    _players.addAll(box.values);
    notifyListeners();
  }

 }