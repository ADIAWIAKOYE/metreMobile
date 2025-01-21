import 'dart:convert';

import 'package:Metre/models/user_model.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // Méthode pour rafraîchir le token
  Future<String?> refreshToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse('http://192.168.56.1:8010/user/refreshtoken'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['accessToken'];
    } else {
      throw Exception("Failed to refresh token");
    }
  }

  // Méthode pour récupérer un utilisateur par son ID
  Future<Utilisateur_model?> getUserById(String id, String token) async {
    final url = 'http://192.168.56.1:8010/user/loadById/$id';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 202) {
        final jsonData = json.decode(response.body)['data'];
        return Utilisateur_model.fromJson(jsonData);
      } else {
        throw Exception('Failed to load user');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }
}
