import 'package:Metre/utilitaires/taille_des_polices.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:Metre/pages/changer_password_page.dart';
import 'package:Metre/pages/mon_compte_page.dart';
import 'package:Metre/widgets/logo.dart';
import 'package:sizer/sizer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
      body: ListView(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LogoWidget(),
          // SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.only(
                // top: MediaQuery.of(context).padding.top,
                left: 10),
            child: Row(
              children: [
                Expanded(
                  // flex: 1,
                  child: CircleAvatar(
                    radius: 70,
                    backgroundImage: AssetImage('assets/image/avatar.png'),
                    // backgroundColor: Colors.transparent,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'MonStyle couture',
                        style: TextStyle(
                            fontSize: s14px, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Couture Homme & Femme & Enfant',
                        style: TextStyle(fontSize: 8.sp),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: h20px,
          ),
          _buildMenuOption(
            context,
            icon: Icons.person,
            label: "Mon Compte",
            onTap: () => _navigateToPage(context, const MonComptePage()),
          ),
          SizedBox(
            height: 4.h,
          ),
          // Changer mot de passe
          _buildMenuOption(
            context,
            icon: Icons.lock,
            label: "Changer mot de passe",
            onTap: () => _navigateToPage(context, const ChangerPasswordPage()),
          ),
          SizedBox(
            height: 4.h,
          ),
          // Changer mot de passe
          _buildMenuOption(
            context,
            icon: Icons.person_add_disabled,
            label: "Client Supprimer",
            onTap: () => _navigateToPage(context, const ChangerPasswordPage()),
          ),
          SizedBox(
            height: 7.h,
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
                      fontSize: 13),
                ),
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                            side: BorderSide(color: Colors.red)))),
                onPressed: () {
                  print('Vous allez vous deconnecter');
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
}
