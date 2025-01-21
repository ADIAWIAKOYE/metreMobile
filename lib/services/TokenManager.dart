import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const String _keyToken = 'token';
  static const String _keyRefreshToken = 'refreshToken';
  static const String _refreshTokenUrl =
      'http://192.168.56.1:8010/user/refreshtoken';
  static bool _isRefreshing = false;

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Supprime toutes les données stockées
  }

  static Future<String?> _refreshAccessToken() async {
    if (_isRefreshing) return null;
    _isRefreshing = true;
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        return null;
      }
      final response = await http.post(
        Uri.parse(_refreshTokenUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newToken = data['accessToken'];
        await setToken(newToken);
        return newToken;
      } else {
        // gérér l'echec du refresh ici
        print("echec lors du refresh : ${response.body}");
        return null;
      }
    } catch (e) {
      print("Erreur lors du refresh : $e");
      return null;
    } finally {
      _isRefreshing = false;
    }
  }

  // Fonction pour obtenir un token valide (en rafraîchissant si nécessaire)
  static Future<String?> getValidToken() async {
    String? token = await getToken();
    if (token == null) return null;

    // on fait une simple requête, car on a pas accès aux headers
    final response = await http.get(
      Uri.parse("http://192.168.56.1:8010/api/test"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      // Token invalide, rafraîchir
      print("Token Invalide");
      token = await _refreshAccessToken();
    }
    return token;
  }
}
