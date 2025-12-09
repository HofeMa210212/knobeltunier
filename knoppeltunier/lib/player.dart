
class Player{
   String fName;
   String lName;
   int? id;
    int lifes;


   Player({
    required this.fName,
    required this.lName,
    required this.lifes,
     this.id
  });


  void removeLife(){
    if(lifes >0) lifes -=1;
    else throw Exception('Player $fName $lName has already 0 lifes');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Player) return false;
    return fName == other.fName && lName == other.lName;
  }

  @override
  int get hashCode => Object.hash(fName, lName, lifes);

}

