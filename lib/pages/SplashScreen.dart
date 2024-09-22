import 'dart:convert';

import 'package:Metre/bottom_navigationbar/navigation_page.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
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
  @override
  void initState() {
    super.initState();
    _navigateToNextPage();
  }

  Future<void> _navigateToNextPage() async {
    await Future.delayed(Duration(seconds: 3)); // Attente de 3 secondes
    _checkLoginStatus(); // Vérifier l'état de connexion
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? refreshToken = prefs.getString('refreshToken');

    // Si l'utilisateur est connecté, on le redirige vers la page d'accueil
    if (token != null) {
      await _refreshToken(refreshToken!);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NavigationBarPage()),
      );
    } else {
      // Sinon, redirection vers la page de bienvenue
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomePage()),
      );
    }
  }
  //  Future<void> _checkLoginStatus() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final String? token = prefs.getString('token');
  //   final String? refreshToken = prefs.getString('refreshToken');

  //   if (token != null && refreshToken != null) {
  //     // Rafraîchir le token avant de rediriger
  //     bool isTokenValid = await _refreshToken(refreshToken);
  //     setState(() {
  //       _isLoggedIn = isTokenValid;
  //       _isLoading = false;
  //     });
  //   } else {
  //     setState(() {
  //       _isLoading = false;
  //       _isLoggedIn = false;
  //     });
  //   }
  // }

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

        // Sauvegarder le nouveau token dans les SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', newToken);

        return true; // Token valide et rafraîchi
      } else {
        final message = json.decode(response.body)['message'];
        print("Erreur lors du rafraîchissement du token.");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$message'),
        ));
        return false; // Rafraîchissement du token échoué
      }
    } catch (e) {
      print("Erreur : $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context)
          .colorScheme
          .background, // Couleur de fond de la SplashScreen
      body: Center(
        // child: Column(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        // Ajouter une animation Lottie
        child: Image.asset(
          'assets/image/Frame_1.png', // Chemin du fichier Lottie
          width: 25.w,
          height: 25.h,
        ),
        // SizedBox(height: 2.h),
        // Text(
        //   'Bienvenue sur Metre',
        //   style: TextStyle(
        //     fontSize: 20.sp,
        //     fontWeight: FontWeight.normal,
        //     letterSpacing: 1.5,
        //   ),
        // ),
        //   ],
        // ),
      ),
    );
  }
}
