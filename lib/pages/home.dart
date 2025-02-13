import 'dart:async';
import 'dart:convert';

import 'package:Metre/models/user_model.dart';
import 'package:Metre/pages/login_page.dart';
import 'package:Metre/services/AuthService.dart';
import 'package:Metre/widgets/CustomSnackBar.dart';
import 'package:Metre/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Utilisateur_model? user;
  bool isActive = true;
  bool isDeleted = false;

  String? _id;
  String? _token;
  String? _refreshToken;
  Timer? _refreshTimer; // Timer pour le rafraîchissement du token

  final AuthService _authService = AuthService(); // Instance d'AuthService

  @override
  void initState() {
    super.initState();
    _loadUserData().then((_) {
      if (_refreshToken != null) {
        _startTokenRefreshTimer(_refreshToken!); // Démarrer le timer
      }
    });
  }

  // Mettre à jour le token dans SharedPreferences
  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _id = prefs.getString('id');
      _token = prefs.getString('token');
      _refreshToken =
          prefs.getString('refreshToken'); // Charger le refreshToken
    });
  }

// ::::::::::::::::::::::::::::::::::::::

  // Fonction pour démarrer le rafraîchissement du token à intervalles réguliers
  void _startTokenRefreshTimer(String refreshToken) {
    _refreshTimer =
        Timer.periodic(Duration(milliseconds: 300000), (timer) async {
      final String url = 'http://192.168.56.1:8010/user/refreshtoken';

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refreshToken': refreshToken}),
        );

        if (response.statusCode == 200) {
          print("Token actualisé");
          final data = jsonDecode(response.body);
          final String newToken = data['accessToken'];

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', newToken);
          print("Token mis à jour");
        } else {
          _refreshTimer?.cancel();
          _refreshTimer = null;
          await clearCache();

          // Vérifiez si le widget est encore monté avant d'accéder au contexte
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );

            final message = json.decode(response.body)['message'];
            CustomSnackBar.show(context, message: '$message', isError: true);
          }
        }
      } catch (e) {
        print("Erreur lors de la mise à jour du token : $e");
      }
    });
  }
// :::::::::::::::::::::::::::::::::::::::::::::::

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Supprime toutes les données stockées
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: LogoWidget(),
        backgroundColor: Theme.of(context)
            .colorScheme
            .background, // Changez cette couleur selon vos besoins
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section de bienvenue
            Text(
              "Bonjour, Fatou !",
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2.h),
            Text(
              "Gérez votre atelier avec efficacité 🚀",
              style: TextStyle(fontSize: 10.sp, color: Colors.grey[700]),
            ),
            SizedBox(height: 3.h),

            // Statistiques principales
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard("Commandes", "5", Colors.blue, () {
                  print("les commandes sont la");
                  // Action sur clic "Commandes"
                }),
                SizedBox(width: 2.w),
                _buildStatCard("Clients", "12", Colors.green, () {
                  print("les clients sont la ");
                  // Action sur clic "Clients"
                }),
                SizedBox(width: 2.w),
                _buildStatCard("Revenus", "120k CFA", Colors.orange, () {
                  print("Les revenues");
                  // Action sur clic "Revenus"
                }),
              ],
            ),
            SizedBox(height: 4.h),

            // Actions rapides
            Text(
              "Actions rapides",
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton(Icons.person_add, "Ajouter Client"),
                _buildActionButton(
                    Icons.add_shopping_cart, "Nouvelle Commande"),
                _buildActionButton(Icons.receipt_long, "Payer Commande"),
              ],
            ),
            SizedBox(height: 4.h),

            // Notifications importantes
            Text(
              "Notifications importantes",
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2.h),
            Card(
              color: Colors.red[50],
              child: ListTile(
                leading: Icon(Icons.warning, color: Colors.red, size: 18.sp),
                title: Text("3 commandes en retard",
                    style: TextStyle(fontSize: 12.sp)),
                subtitle: Text("Vérifiez vos commandes en attente.",
                    style: TextStyle(fontSize: 10.sp)),
                trailing: Icon(Icons.arrow_forward, size: 16.sp),
                onTap: () {
                  // Redirection vers les commandes
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour les cartes de statistiques (cliquables)
  Widget _buildStatCard(
      String title, String value, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.sp),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.sp),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  title,
                  style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget pour les boutons d'action
  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 6.w,
          backgroundColor: Color.fromARGB(255, 206, 136, 5).withOpacity(0.1),
          child: Icon(icon, color: Color.fromARGB(255, 206, 136, 5), size: 6.w),
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: TextStyle(fontSize: 9.sp),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
