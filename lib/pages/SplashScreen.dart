import 'dart:async';
import 'dart:convert';

import 'package:Metre/bottom_navigationbar/navigation_page.dart';
import 'package:Metre/models/user_model.dart';
import 'package:Metre/pages/login_page.dart';
import 'package:Metre/widgets/CustomSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'welcome_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Timer? _refreshTokenTimer; // Déclarer un Timer nullable
  Utilisateur_model? user;
  late bool isActive;
  late bool isDeleted;

  @override
  void initState() {
    super.initState();
    _navigateToNextPage();
  }

  Future<void> _navigateToNextPage() async {
    await Future.delayed(Duration(seconds: 2)); // Attente de 3 secondes
    if (mounted) {
      _checkLoginStatus(); // Vérifier l'état de connexion
    }
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? refreshToken = prefs.getString('refreshToken');

    if (token != null && refreshToken != null) {
      // Si l'utilisateur est connecté, on rafraîchit le token
      final tokenRefreshed = await _refreshToken(refreshToken);

      if (tokenRefreshed) {
        // _startTokenRefreshTimer(refreshToken);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => NavigationBarPage()),
          );
        }
      } else {
        _redirectToLogin();
      }
    } else {
      _redirectToWelcome();
    }
  }

  Future<void> _redirectToLogin() async {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  Future<void> _redirectToWelcome() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    CustomSnackBar.show(
      context,
      message: 'Désolé, votre compte a été supprimé ou désactivé !',
      isError: true,
    );
    // Ajoute un délai si nécessaire
    Future.delayed(Duration.zero, () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomePage()),
      );
    });
  }

  Future<bool> _refreshToken(String refreshToken) async {
    final String url = 'http://192.168.56.1:8010/user/refreshtoken';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String newToken = data['accessToken'];
        final String newrefreshToken = data['refreshToken'];
        // Sauvegarder le nouveau token dans les SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final String? _id = prefs.getString('id');
        await prefs.setString('token', newToken);
        await prefs.setString('refreshToken', newrefreshToken);
        // Obtenir les informations utilisateur
        await _getUserById(_id ?? "id", newToken);
        return true; // Token valide et rafraîchi
      } else {
        // Effacer les SharedPreferences en cas d'échec
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // Affichage du message d'erreur avec SnackBar
        CustomSnackBar.show(
          context,
          message: 'Veuillez vous reconnecter !',
          isError: true,
        );

        _redirectToLogin();
        return false;
      }
    } catch (e) {
      print("Erreur : $e");
      return false;
    }
  }

  Future<void> _getUserById(String id, String token) async {
    final url = 'http://192.168.56.1:8010/user/loadById/$id';

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 202) {
      final jsonData = json.decode(response.body)['data'];

      // Mettez à jour l'état après avoir obtenu les données de l'utilisateur
      Utilisateur_model utilisateur = Utilisateur_model.fromJson(jsonData);
      bool active = utilisateur.isActive;
      bool deleted = utilisateur.isDeleted;

      // Ensuite, vous pouvez utiliser setState pour mettre à jour l'interface utilisateur
      setState(() {
        user = utilisateur;
        isActive = active;
        isDeleted = deleted;
      });

      // Vérifiez les conditions après la mise à jour de l'état
      if (!isActive || isDeleted) {
        _redirectToWelcome();
        return; // Arrêter l'exécution pour éviter tout autre traitement
      }
    } else {
      CustomSnackBar.show(
        context,
        message:
            'Une erreur s\'est produite. Veuillez vérifier votre connexion.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context)
          .colorScheme
          .background, // Couleur de fond de la SplashScreen
      body: Center(
        child: Image.asset(
          'assets/image/Frame_1.png', // Chemin du fichier Lottie
          width: 25.w,
          height: 25.h,
        ),
      ),
    );
  }
}
