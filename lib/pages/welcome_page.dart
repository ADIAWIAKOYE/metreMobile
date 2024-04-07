import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:metremobile/pages/login_page.dart';
import 'package:metremobile/pages/signup_page.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    // Obtenir la taille de l'écran
    final screenHeight = MediaQuery.of(context).size.height;
    // Calculer l'espace entre les parties en fonction de la hauteur de l'écran
    final spaceBetweenSections = screenHeight * 0.06;

    return Scaffold(
      body: ListView(children: [
        Container(
          // width: double.infinity,
          // padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Container(
              // margin: EdgeInsets.all(10),
              // child: Column(
              // children: [
              // SizedBox(
              //   height: 20,
              // ),
              SizedBox(height: spaceBetweenSections),
              // Partie de l'image
              SizedBox(
                width: 350,
                child: Image.asset("assets/image/tailleur.png"),
              ),
              SizedBox(height: spaceBetweenSections),
              // Partie des textes
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin:
                      EdgeInsets.only(right: 30, left: 30), // Marge à droite
                  child: Text(
                    "Bienvenue sur Mètre pour la gestion des mesures de vos clients en toute facilité ...... ",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(height: spaceBetweenSections),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin:
                      EdgeInsets.only(right: 30, left: 30), // Marge à droite
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              "En appuyant sur se Connecter ou s’inscrire, vous acceptez nos ",
                          style: TextStyle(
                            color: Colors.black, // Couleur du texte
                            fontSize: 15,
                            decoration:
                                TextDecoration.none, // Pas de décoration
                          ),
                        ),
                        TextSpan(
                          text: "Conditions générales.",
                          style: TextStyle(
                            color: Colors.black, // Couleur du texte cliquable
                            fontSize: 15,
                            decoration:
                                TextDecoration.underline, // Souligner le texte
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Action à effectuer lors du clic sur "inscrivez-vous"
                              // ignore: deprecated_member_use
                              launch(
                                  'https://flutter.dev/'); // Lien URL de vos conditions générales
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) => SignupPage()),
                              // );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin:
                      EdgeInsets.only(right: 30, left: 30), // Marge à droite
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              "Pour en savoir plus sur l’utilisation de tes données, consulte notre ",
                          style: TextStyle(
                            color: Colors.black, // Couleur du texte
                            fontSize: 15,
                            decoration:
                                TextDecoration.none, // Pas de décoration
                          ),
                        ),
                        TextSpan(
                          text: " Politique de confidentialité.",
                          style: TextStyle(
                            color: Colors.black, // Couleur du texte cliquable
                            fontSize: 15,
                            decoration:
                                TextDecoration.underline, // Souligner le texte
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Action à effectuer lors du clic sur "inscrivez-vous"
                              // ignore: deprecated_member_use
                              launch(
                                  'https://www.google.com/'); // Lien URL de votre politique de confidentialité
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // SizedBox(
              //   height: 20,
              // ),
              SizedBox(height: spaceBetweenSections),
              // Partie des buttons
              SizedBox(
                height: 50,
                width: MediaQuery.of(context).size.width *
                    0.85, // Définissez la largeur du bouton en fonction de la largeur de l'écran
                child: ElevatedButton(
                  onPressed: () {
                    // Action à effectuer lors du clic sur le texte
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(
                        255, 206, 163, 5), // Couleur or du bouton
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(100), // Bord arrondi du bouton
                    ),
                  ),
                  child: Text(
                    "Se connecter",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              SizedBox(
                height: 50,
                width: MediaQuery.of(context).size.width *
                    0.85, // Définissez la largeur du bouton en fonction de la largeur de l'écran
                child: ElevatedButton(
                  onPressed: () {
                    // Action à effectuer lors du clic sur le texte
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(
                        255, 206, 163, 5), // Couleur or du bouton
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(100), // Bord arrondi du bouton
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.2),
                  ),
                  child: Text(
                    "S'inscrire",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // ],
              // ),
              // ),
            ],
          ),
        ),
      ]),
    );
  }
}
