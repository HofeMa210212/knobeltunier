
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../db/database.dart';

Future<void> generateMatchesPdf(int tournamentID) async {


  List<Map<String, dynamic>> tournamentData = await getTournamentData(tournamentID);

  final pdf = Document();
   int rowsPerPage = 50;

  int pageCount = (tournamentData.length / rowsPerPage).ceil();

  print("Anzahl Spieler: ${tournamentData.length}");

  print("Seiten: $pageCount");

  for (int pageIndex = 0; pageIndex < pageCount; pageIndex++) {
    pdf.addPage(
      Page(
        build: (Context context) {
          return Center(
          child:  Column(
              children: List.generate(
              rowsPerPage,
          (index) {

            return Container(
              width: 400, // Angepasste Breite für die PDF-Darstellung
              height: 15,
              decoration: BoxDecoration(
                color:  PdfColors.white,
                border: Border.all(
                  color: PdfColors.black,
                  width: 1,
                ),
              ),
              child:
            (index + rowsPerPage * pageIndex < tournamentData.length) ?
              Row(
                children: [
                  Container(
                    width: 200,
                    // Angepasste Breite für ein besseres Layout
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Center(
                        child: Text(
                          textAlign: TextAlign.left,
                          tournamentData[index + rowsPerPage * pageIndex]["playerName"],
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 200,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Center(
                        child: Text(
                          textAlign: TextAlign.left,
                          tournamentData[index + rowsPerPage * pageIndex]["matchNumbers"],
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),

                ],
              ) :  Container(),

            );
          },
          ),
          ),
          );
        }
      ),
    );
  }


  String? filePath = await FilePicker.platform.getDirectoryPath();

  if(filePath != null){
    filePath = "${filePath}/Projektor_ansicht_matches.pdf";
    final file = File(filePath!);
    await file.writeAsBytes(await pdf.save());
    print("PDF erfolgreich gespeichert auf: $filePath");
  }else{
    print("Keine Auswahl getroffen.");
  }
}

Future<List<Map<String, dynamic>>> getTournamentData(int id) async {
  var db = await dbController();

  Directory dbDir = await getApplicationSupportDirectory(); // Gemeinsames Verzeichnis
  print(dbDir.path);



  var newtournamentData = await executeQuery(db, '''
   SELECT 
    p.id AS playerId, 
    p.fName || ' ' || p.lName AS playerName,
    (SELECT GROUP_CONCAT(m.matchNumber, ', ') 
     FROM match m 
     JOIN matchPlayer mp ON m.matchPlayer1Id = mp.id OR m.matchPlayer2Id = mp.id
     WHERE mp.playerId = p.id 
     ORDER BY m.matchNumber) AS matchNumbers
FROM player p
WHERE p.tournamentId = $id
AND EXISTS (
    SELECT 1 
    FROM matchPlayer mp 
    JOIN match m ON m.matchPlayer1Id = mp.id OR m.matchPlayer2Id = mp.id
    WHERE mp.playerId = p.id
);

   
   
    ''');

  return newtournamentData;

}
