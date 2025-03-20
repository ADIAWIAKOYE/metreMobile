import 'dart:convert';

import 'package:Metre/models/user_model.dart';
import 'package:Metre/pages/clientSupprimer_page.dart';
import 'package:Metre/pages/collaborateur_page.dart';
import 'package:Metre/pages/commandes/commande_annuler_page.dart';
import 'package:Metre/pages/login_page.dart';
import 'package:Metre/utilitaires/taille_des_polices.dart';
import 'package:Metre/widgets/CustomSnackBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:Metre/pages/changer_password_page.dart';
import 'package:Metre/pages/mon_compte_page.dart';
import 'package:Metre/widgets/logo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Utilisateur_model user;
  bool isLoading = true;

  late String messages;

  String? _id;
  String? _token;

  @override
  void initState() {
    super.initState();
    // Ajoute un délai de 2 secondes avant de charger les données utilisateur
    // Future.delayed(Duration(seconds: 2), () {
    _loadUserData().then((_) {
      _getUserByIduser();
    });
    // });
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   _getUserByIduser();
  // }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _id = prefs.getString('id');
      _token = prefs.getString('token');
    });
    // print('ID: $_id, Token: $_token'); // Débogage
  }

  Future<void> _getUserByIduser() async {
    if (_id != null && _token != null) {
      final url = 'http://192.168.56.1:8010/user/getUserPrincipale/$_id';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $_token'},
      );
      // print('Code de statut: ${response.statusCode}');
      // print(
      //     'Contenu de la réponse : ${response.body}'); // Ajoute ceci pour déboguer

      if (response.statusCode == 202) {
        final jsonData = json.decode(response.body)['data'];
        final message = json.decode(response.body)['message'];
        messages = message;
        setState(() {
          user = Utilisateur_model.fromJson(
              jsonData); // Utilisation du modèle User
          isLoading = false;
        });
      } else {
        CustomSnackBar.show(context,
            message:
                'Une erreur s\'est produite. Veuillez vérifier votre connexion.',
            isError: true);
      }
    } else {
      print('id ou token null');
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
              ? const Center(child: Text('Aucune donnée disponible.'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: user!.profile == ""
                              ? AssetImage('assets/image/avatar.png')
                              : NetworkImage(user!.profile) as ImageProvider,
                        ),
                        SizedBox(width: 5.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.nom ?? 'Nom non disponible',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: h6px,
                            ),
                            Text(
                              user?.specialite ?? 'Spécialité non disponible',
                              style: TextStyle(fontSize: 10.sp),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: h20px,
                    ),
                    _buildMenuOption(
                      context,
                      icon: Icons.person,
                      label: "Mon Compte",
                      onTap: () =>
                          _navigateToPage(context, const MonComptePage()),
                    ),
                    SizedBox(
                      height: 4.h,
                    ),
                    // Changer mot de passe
                    _buildMenuOption(
                      context,
                      icon: Icons.lock,
                      label: "Changer mot de passe",
                      onTap: () =>
                          _navigateToPage(context, const ChangerPasswordPage()),
                    ),

                    SizedBox(
                      height: 4.h,
                    ),
                    if (messages == "ok")
                      _buildMenuOption(
                        context,
                        icon: Icons.remove_shopping_cart_sharp,
                        label: "Commande Annuler",
                        onTap: () =>
                            _navigateToPage(context, CommandeAnnuleePage()),
                      ),
                    SizedBox(
                      height: 4.h,
                    ),
                    if (messages == "ok")
                      _buildMenuOption(
                        context,
                        icon: Icons.people_outline_outlined,
                        label: "Mes Collaborateurs",
                        onTap: () =>
                            _navigateToPage(context, const CollaborateurPage()),
                      ),
                    SizedBox(
                      height: 4.h,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          child: Text(
                            'Deconnecter',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                              fontSize: 10.sp,
                            ),
                          ),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.red),
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                    side: BorderSide(color: Colors.red))),
                            padding:
                                MaterialStateProperty.all<EdgeInsetsGeometry>(
                              EdgeInsets.symmetric(
                                  vertical: 1.h,
                                  horizontal: 3.w), // Ajout du padding
                            ),
                          ),
                          onPressed: () {
                            seDeconnecter();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
    );
  }

  Widget _buildMenuOption(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: h10px),
        padding: EdgeInsets.symmetric(vertical: 3.5.w, horizontal: h14px),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border(
            bottom: BorderSide(
              color: Color.fromARGB(255, 206, 136, 5), // Couleur de la bordure
              width: 0.3.w,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon,
                color: Theme.of(context).colorScheme.tertiary, size: s21px),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            Icon(Icons.keyboard_arrow_right,
                color: Theme.of(context).colorScheme.tertiary, size: s21px),
          ],
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  // supprimer un  client
  void seDeconnecter() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Attention",
            style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          content: Text(
            "Vous allez vous deconnectés si vous cliquez sur 'Se Deconnecter' ",
            style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          actions: [
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child:
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 2.h),
                    backgroundColor: Color.fromARGB(255, 206, 136, 5),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    "Annuler",
                    style: TextStyle(
                      fontSize: 8.sp,
                      letterSpacing: 2,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Fermer la boîte de dialogue
                  },
                ),
                // ),
                SizedBox(
                  width: 3.w,
                ),
                // Padding(
                //   padding: EdgeInsets.all(0.8.h),
                // child:
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 2.h),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    "Se Deconnecter",
                    style: TextStyle(
                      fontSize: 8.sp,
                      letterSpacing: 2,
                    ),
                  ),
                  onPressed: () async {
                    // ::::::::::::::::::::::::::::::::::::::::
                    // Vider le cache (SharedPreferences)
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.clear(); // Supprimer toutes les données
                    //:::::::::::::::::::::::::::::::::::::::::::

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Container(
                          padding: EdgeInsets.all(8),
                          height: 8.h,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 43, 158, 47),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                              SizedBox(
                                width: 3.w,
                              ),
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Success :",
                                    style: TextStyle(
                                        fontSize: 14.sp, color: Colors.white),
                                  ),
                                  Spacer(),
                                  Text(
                                    'Vous avez été deconnecter',
                                    style: TextStyle(
                                        fontSize: 12.sp, color: Colors.white),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ))
                            ],
                          ),
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                      ),
                    );
                  },
                ),
                // ),
              ],
            ),
          ],
        );
      },
    );
  }
}
