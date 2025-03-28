import 'dart:convert';
import 'package:Metre/notifications/model_notification.dart';
import 'package:http/http.dart' as http;

class Notiservice {
  static const String _baseUrl = 'http://192.168.56.1:8010/api/notification';

  static Future<List<MessageNotif>> fetchUserNotifications(
      String userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/user/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => MessageNotif.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  static Future<void> markNotificationAsRead(String notificationId) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$notificationId/marquer-lue'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read');
    }
  }
}
