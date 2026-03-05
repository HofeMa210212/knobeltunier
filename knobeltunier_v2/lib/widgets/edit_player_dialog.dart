import 'package:flutter/material.dart';
import 'package:knobeltunier_v2/data/player/player.dart';
import 'package:knobeltunier_v2/data/tournament/tournament.dart';
import 'package:knobeltunier_v2/widgets/custom_textfield.dart';

import '../Color/app_Colors.dart';

class EditPlayer{

   static void editPlayerDialog(BuildContext context, Player p, Tournament t) {
     TextEditingController fName = TextEditingController();
     TextEditingController lName = TextEditingController();
     TextEditingController lives = TextEditingController();

     fName.text = p.fName;
     lName.text = p.lName;
     lives.text = p.lifes.toString();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.basicContainerColor.withAlpha(250),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(Icons.edit, color: Colors.green),
              SizedBox(width: 8),
              Text(
                "Spieler editieren",
                style: TextStyle(
                    color: Colors.white
                ),

              ),
            ],
          ),
          content: SizedBox(
            height: 350,
            width: 500,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                CustomTextField(
                  width: 450,
                  controller: fName,
                  hintText: "Vorname",

                ),
                CustomTextField(
                  width: 450,
                  controller: lName,
                  hintText: "Nachname",

                ),
                CustomTextField(
                  width: 450,
                  controller: lives,
                  hintText: "Leben",
                  maxNumber: (t.getAvailableTickets() + p.lifes <= 5) ? t.getAvailableTickets() + p.lifes : 5,
                  onlyNumbers: true,

                ),


              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: (){

                p.lName = lName.text;
                p.fName = fName.text;
                p.lifes = int.parse(lives.text);

                t.notify();

                Navigator.of(context).pop();
              },
              child: const Text("Speichern"),
            ),
          ],
        );
      },
    );
  }



}