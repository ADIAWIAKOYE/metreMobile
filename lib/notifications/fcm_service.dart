class FCMService {
  // static Future<void> initialize() async {
  //   await FirebaseMessaging.instance.requestPermission();
  //   final token = await FirebaseMessaging.instance.getToken();

  //   // Envoyer le token à votre backend pour les notifications push
  //   if (token != null) {
  //     await _sendTokenToServer(token);
  //   }

  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     _handleNotification(message);
  //   });
  // }
}
