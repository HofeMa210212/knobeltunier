import 'dart:io';
import 'dart:convert';

Future<List<Map<String, dynamic>>> executeQueryServer(String query) async {
  try {
    final client = HttpClient();
    final request = await client.postUrl(Uri.parse('http://localhost:8080'));
    request.headers.set('Content-Type', 'text/plain');
    request.write(query);
    final response = await request.close();

    final responseData = await response.transform(utf8.decoder).join();

    return List<Map<String, dynamic>>.from(jsonDecode(responseData));
  } catch (e) {
    print('Fehler beim Senden der Abfrage: $e');
    return [];
  }
}


