import 'package:Metre/pages/commande_page.dart';
import 'package:Metre/pages/home.dart';
import 'package:Metre/pages/modeles_album_page.dart';
import 'package:flutter/material.dart';
import 'package:Metre/pages/add_mesure_page.dart';
import 'package:Metre/pages/mesure_page.dart';
import 'package:Metre/pages/profile_page.dart';
import 'package:sizer/sizer.dart';

class NavigationBarPage extends StatefulWidget {
  final int initialIndex; // Nouvel argument pour définir l'onglet actif
  const NavigationBarPage(
      {super.key, this.initialIndex = 0}); // Par défaut : Accueil

  @override
  State<NavigationBarPage> createState() => _NavigationBarPageState();
}

class _NavigationBarPageState extends State<NavigationBarPage> {
  late int myCurrentIndex;

  @override
  void initState() {
    super.initState();
    myCurrentIndex = widget.initialIndex; // Initialisation de l'index actif
  }

  List page = [
    HomePage(),
    MesurePage(),
    CommandePage(),
    ModelesAlbumPage(),
    ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            // color: Colors.transparent,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 20))
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BottomNavigationBar(
                currentIndex: myCurrentIndex,
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
                selectedItemColor: Color.fromARGB(255, 206, 136, 5),
                selectedLabelStyle: TextStyle(color: Colors.black),
                unselectedItemColor: Theme.of(context).colorScheme.tertiary,
                selectedFontSize: 8.sp,
                showSelectedLabels: true,
                showUnselectedLabels: false,
                iconSize: 20.sp, // Taille des icônes
                onTap: (index) {
                  setState(() {
                    myCurrentIndex = index;
                  });
                },
                items: [
                  // BottomNavigationBarItem(
                  //     icon: Image.asset('assets/image/rubanIcone.png',
                  //         width: 35, height: 30),
                  //     label: "Mésure"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home), label: "Acceuil"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.people), label: "Clients"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.shopping_cart_outlined),
                      label: "Commandes"),
                  BottomNavigationBarItem(
                    icon: Icon(Icons
                        .photo_camera_back_outlined), // Choisissez une icône appropriée
                    label: "Modèles",
                  ),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.account_circle_outlined),
                      label: "Profile"),
                ]),
          ),
        ),
        body: page[myCurrentIndex]);
  }
}
