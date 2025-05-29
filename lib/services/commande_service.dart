import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_app/models/commande.dart';

class CommandeService {
  static const String _apiUrl =
      'http://192.168.154.195:7777/service-commande/commandes';

  static Future<void> submitCommande(Commande commande) async {
    try {
      // Get token from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) throw Exception("No token found");

      // Make the request
      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: jsonEncode(commande.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to submit commande: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
