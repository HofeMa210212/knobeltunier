
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:knobeltunier_v2/data/interfaces/list_interface.dart';
import 'package:knobeltunier_v2/data/match/match.dart';
import 'package:knobeltunier_v2/data/match/match_place.dart';
import 'package:knobeltunier_v2/data/tournament/tournament.dart';

class TournamentList extends ChangeNotifier implements ListInterface{
  List<Tournament> _tournaments = [];
  int _selectedTournament = -1;
  double rowHight = 40;
  bool markePlayedMatches = false;
  bool showTimes = false;

  void setRowHight(double heigth){
    rowHight = heigth;
  }

  Tournament? get selectedTournament{
    if(isTournamentSelected){
      return _tournaments[_selectedTournament];
    }
    return null;
  }

  bool get isTournamentSelected{
    return _selectedTournament != -1;
  }

  int get selectedTournamentIndex{
    return _selectedTournament;
  }


   set selectedTournamentIndex(int index){
    _selectedTournament = index;
    notifyListeners();
   }

   List<Tournament> get tournaments{
    return _tournaments;
   }

  void addTournament(Tournament t){
    _tournaments.add(t);
    save();
    notifyListeners();
  }

  void removeTournament(Tournament t){
    _tournaments.remove(t);
    save();
    notifyListeners();
  }

  @override
  void save() {
    var box = Hive.box<Tournament>('tournamentBox');

    box.clear();

    for (Tournament t in _tournaments) {
      box.put(t.id, t);
    }
  }

  @override
  void read() {
    var box = Hive.box<Tournament>('tournamentBox');

    _tournaments.clear();

    List<Tournament> tournaments = box.values.toList();

    for(Tournament t in tournaments){
      t.parentList = this;

      for(TournamentMatch m in t.matches){
        m.parentList = t;
      }


      _tournaments.add(t);
    }
    notifyListeners();

    print(toString());
  }



  @override
  String toString() {
    String string = "";


    for(Tournament t in _tournaments){
      string += "${t.name}: ${t.matches.length} matches \n";
      print("${t.name}: ${t.matches.length} matches \n");
    }

    return string;
  }


}