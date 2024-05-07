import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:Metre/pages/changer_password_page.dart';
import 'package:Metre/pages/mon_compte_page.dart';
import 'package:Metre/widgets/logo.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LogoWidget(),
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
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Couture Homme & Femme & Enfant',
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 30,
        ),
        InkWell(
          onTap: () {
            // print("BUTTON cliqué !");
            // Action à effectuer lors du tapotement
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MonComptePage(),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 15),
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border(
                bottom: BorderSide(
                  color:
                      Color.fromARGB(255, 195, 154, 5), // Couleur de la bordure
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      Icons.person,
                      color: Colors.black,
                      size: 25,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    "Mon Compte",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    // margin: const EdgeInsets.only(left: 5.0),
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.keyboard_arrow_right,
                      color: Colors.black,
                      size: 25,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        SizedBox(
          height: 30,
        ),
        // Changer mot de passe
        InkWell(
          onTap: () {
            // Action à effectuer lors du tapotement
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangerPasswordPage(),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 15),
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border(
                bottom: BorderSide(
                  color:
                      Color.fromARGB(255, 195, 154, 5), // Couleur de la bordure
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      Icons.lock,
                      color: Colors.black,
                      size: 25,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    "Changer mots de passe",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    // margin: const EdgeInsets.only(left: 5.0),
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.keyboard_arrow_right,
                      color: Colors.black,
                      size: 25,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        SizedBox(
          height: 70,
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
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
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
    );
  }
}
