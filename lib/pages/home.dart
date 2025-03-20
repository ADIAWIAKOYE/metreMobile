import 'dart:async';
import 'dart:convert';

import 'package:Metre/bottom_navigationbar/navigation_page.dart';
import 'package:Metre/models/user_model.dart';
import 'package:Metre/pages/add_depense_page.dart';
import 'package:Metre/pages/add_mesure_page.dart';
import 'package:Metre/pages/commandes/commandeteste.dart';
import 'package:Metre/pages/login_page.dart';
import 'package:Metre/pages/revenue_depense_page.dart';
import 'package:Metre/pages/unbound_client_page.dart';
import 'package:Metre/services/AuthService.dart';
import 'package:Metre/widgets/CustomSnackBar.dart';
import 'package:Metre/widgets/logo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  // Nouvelles variables pour le nombre de clients
  int _nbClients = 0;
  bool _isLoadingClients = true;
  String? _errorMessageClients;

  @override
  void initState() {
    super.initState();
    _loadUserData().then((_) {
      if (_refreshToken != null) {
        _startTokenRefreshTimer(_refreshToken!); // Démarrer le timer
      }
      _loadRevenusCeMois(); // Charger les revenus du mois
      _loadNbCommandesCeMois(); // Charger le nombre de commandes du mois
      _loadNbClients(); // Charger le nombre de clients
      _getUserById();
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

  // Ajout d'une variable pour stocker le revenu du mois
  double _revenusCeMois = 0.0;

  bool _isLoading = true;
  String? _errorMessage;

  int _nbcommandeCeMois = 0;
  bool _isLoadingnbcomm = true;
  String? _errorMessagenbc;

  Future<void> _loadNbCommandesCeMois() async {
    setState(() {
      _isLoadingnbcomm = true;
      _errorMessagenbc = null;
    });

    if (_id == null) {
      print("ID de l'utilisateur non trouvé.");
      setState(() {
        _isLoadingnbcomm = false;
        _errorMessagenbc = "ID utilisateur non trouvé.";
      });
      return;
    }

    final DateTime now = DateTime.now();
    final int month = now.month;
    final int year = now.year;

    final String url =
        'http://192.168.56.1:8010/api/commandes/countByUser/$_id?mois=$month&annee=$year'; // Remplacez par l'URL correcte de votre API

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token'
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        setState(() {
          _nbcommandeCeMois = (data as num).toInt();
          _isLoadingnbcomm = false;
        });
      } else {
        print(
            'Erreur lors de la récupération du nombre de commandes: ${response.statusCode}');
        setState(() {
          _isLoadingnbcomm = false;
          _errorMessagenbc =
              "Erreur de chargement (code ${response.statusCode})";
        });
      }
    } catch (e) {
      print('Erreur de connexion: $e');
      setState(() {
        _isLoadingnbcomm = false;
        _errorMessagenbc = "Erreur de connexion";
      });
    }
  }

  // Fonction pour charger les revenus du mois
  Future<void> _loadRevenusCeMois() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    if (_id == null) {
      print("ID de l'utilisateur non trouvé.");
      setState(() {
        _isLoading = false;
        _errorMessage = "ID utilisateur non trouvé.";
      });
      return;
    }

    final String url =
        'http://192.168.56.1:8010/api/transactions/users/$_id/totalRevenusCeMois';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token'
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _revenusCeMois = (data['data'] as num).toDouble();
          _isLoading = false;
        });
      } else {
        print(
            'Erreur lors de la récupération des revenus: ${response.statusCode}');
        setState(() {
          _isLoading = false;
          _errorMessage =
              "Erreur de chargement (code ${response.statusCode})"; //Message d'erreur plus clair
        });
      }
    } catch (e) {
      print('Erreur de connexion: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = "Erreur de connexion";
      });
    }
  }

  Future<void> _loadNbClients() async {
    setState(() {
      _isLoadingClients = true;
      _errorMessageClients = null;
    });

    if (_id == null) {
      print("ID de l'utilisateur non trouvé.");
      setState(() {
        _isLoadingClients = false;
        _errorMessageClients = "ID utilisateur non trouvé.";
      });
      return;
    }

    final String url =
        'http://192.168.56.1:8010/user/$_id/nombreClients'; // Assurez-vous que l'URL est correcte

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token'
        },
      );

      if (response.statusCode == 202) {
        final data = jsonDecode(response.body)['data'];
        setState(() {
          _nbClients = (data as num).toInt();
          _isLoadingClients = false;
        });
      } else {
        print(
            'Erreur lors de la récupération du nombre de clients: ${response.statusCode}');
        setState(() {
          _isLoadingClients = false;
          _errorMessageClients =
              "Erreur de chargement (code ${response.statusCode})";
        });
      }
    } catch (e) {
      print('Erreur de connexion: $e');
      setState(() {
        _isLoadingClients = false;
        _errorMessageClients = "Erreur de connexion";
      });
    }
  }

  // Fonction pour formater la devise
  final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'CFA');

  // Fonction pour formater les grands nombres (ex: 5K, 1.2M)
  String _formatCompactNumber(double number) {
    final NumberFormat format = NumberFormat.compact(locale: 'fr');
    return format.format(number);
  }

  Future<void> _getUserById() async {
    final url = 'http://192.168.56.1:8010/user/loadById/$_id';

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $_token'},
    );
    if (response.statusCode == 202) {
      final jsonData = json.decode(response.body)['data'];
      setState(() {
        user = Utilisateur_model.fromJson(jsonData);
        // isLoading = false;
      });
    } else {
      setState(() {
        // isLoading = false;
      });
      CustomSnackBar.show(context,
          message:
              'Une erreur s\'est produite. Veuillez vérifier votre connexion.',
          isError: true);
    }
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
            Row(
              children: [
                CircleAvatar(
                  radius: 5.w,
                  backgroundImage: user != null && user!.profile.isNotEmpty
                      ? NetworkImage(user!.profile) as ImageProvider
                      : AssetImage('assets/image/avatar.png'),
                  // ), // Remplace par l'URL de l'avatar
                ),
                SizedBox(width: 2.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${user!.nom}",
                      style: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "La créativité est votre meilleur atout.",
                      style:
                          TextStyle(fontSize: 10.sp, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 3.h),

            // Statistiques principales
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatCard(
                      //Afficher un loading circulaire, un message d'erreur ou la valeur
                      _isLoading
                          ? "chargement..."
                          : _errorMessage != null
                              ? _errorMessage!
                              : _formatCompactNumber(
                                  _revenusCeMois), // Utilisation de la nouvelle fonction
                      "Revenus (ce mois)",
                      Colors.orange, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RevenueDepensePage(),
                      ),
                    );
                    print("revenue");
                  }, Icons.attach_money),
                  SizedBox(width: 1.w),
                  _buildStatCard(
                      _isLoadingnbcomm
                          ? "chargement..."
                          : _errorMessagenbc != null
                              ? _errorMessagenbc!
                              : _nbcommandeCeMois.toString(),
                      "Commandes ce mois",
                      Colors.blue, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NavigationBarPage(
                          initialIndex: 2, // Rediriger vers la page des clients
                        ),
                      ),
                    );
                  }, Icons.shopping_cart), // Icône pour les commandes
                  SizedBox(width: 1.w),
                  _buildStatCard(
                      _isLoadingClients
                          ? "chargement..."
                          : _errorMessageClients != null
                              ? _errorMessageClients!
                              : _nbClients.toString(),
                      "Clients enregistrés",
                      Colors.green, () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => NavigationBarPage(
                          initialIndex: 1, // Rediriger vers la page des clients
                        ),
                      ),
                    );
                  }, Icons.people),
                ],
              ),
            ),
            SizedBox(height: 4.h),

            // Actions rapides
            Text(
              "Actions rapides",
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2.h),
            Wrap(
              spacing: 4.w,
              runSpacing: 2.h,
              children: [
                AnimatedActionButtonCard(
                    icon: Icons.person_add,
                    label: "Ajouter Client",
                    description:
                        "Enregistrez un nouveau client dans votre base de données.",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddMesurePage(),
                        ),
                      );
                      // Action pour ajouter un client
                    }),
                AnimatedActionButtonCard(
                    icon: Icons.add_shopping_cart,
                    label: "Ajouter dépense",
                    description:
                        "Enregistrez les dépenses liées à votre activité.",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddDepensesPage(),
                        ),
                      );
                    }),
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
  Widget _buildStatCard(String title, String value, Color color,
      VoidCallback onTap, IconData icon) {
    return SizedBox(
      width: 40.w,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.sp),
        child: Card(
          elevation: 3,
          shadowColor: Colors.grey.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.sp),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Alignement à gauche
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 20.sp), // Ajout de l'icône
                    SizedBox(width: 1.w),
                    if (title == "Revenus (ce mois)")
                      Expanded(
                        child: _isLoading
                            ? Center(
                                child: SizedBox(
                                  width: 20.sp,
                                  height: 20.sp,
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(color),
                                  ),
                                ),
                              )
                            : Text(
                                title,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    color: color,
                                    fontWeight: FontWeight.bold),
                              ),
                      )
                    else if (title == "Commandes ce mois")
                      Expanded(
                        child: _isLoadingnbcomm
                            ? Center(
                                child: SizedBox(
                                  width: 20.sp,
                                  height: 20.sp,
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(color),
                                  ),
                                ),
                              )
                            : Text(
                                title,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    color: color,
                                    fontWeight: FontWeight.bold),
                              ),
                      )
                    else
                      Expanded(
                        child: _isLoadingClients
                            ? Center(
                                child: SizedBox(
                                  width: 20.sp,
                                  height: 20.sp,
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(color),
                                  ),
                                ),
                              )
                            : Text(
                                title,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    color: color,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 10.sp, // Augmentation de la taille de la police
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedActionButtonCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onPressed;

  const AnimatedActionButtonCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.description,
    required this.onPressed,
  }) : super(key: key);

  @override
  _AnimatedActionButtonCardState createState() =>
      _AnimatedActionButtonCardState();
}

class _AnimatedActionButtonCardState extends State<AnimatedActionButtonCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..translate(0.0, _isHovering ? -5 : 0.0), // Déplacement vertical
        child: _buildActionButtonCard(
          widget.icon,
          widget.label,
          widget.description,
          widget.onPressed,
        ),
      ),
    );
  }

  Widget _buildActionButtonCard(
      IconData icon, String label, String description, VoidCallback onPressed) {
    return SizedBox(
      width: 90.w,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.sp),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 206, 136, 5).withOpacity(0.8),
                Color.fromARGB(255, 206, 136, 5).withOpacity(0.5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.sp),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Colors.white, size: 16.sp),
                    SizedBox(width: 4.w),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  description,
                  style: TextStyle(fontSize: 8.sp, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
