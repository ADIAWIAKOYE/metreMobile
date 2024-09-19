import 'package:Metre/utilitaires/taille_des_polices.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:Metre/pages/login_page.dart';
import 'package:Metre/pages/signup_page.dart';
import 'package:sizer/sizer.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  // URL à ouvrir lorsque le lien est cliqué
  final String _url1 = 'https://www.google.com';
  final String _url2 = 'https://flutter.dev/';

  @override
  Widget build(BuildContext context) {
    // Obtenir la taille de l'écran
    final screenHeight = MediaQuery.of(context).size.height;
    // Calculer l'espace entre les parties en fonction de la hauteur de l'écran
    final spaceBetweenSections = screenHeight * 0.06;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: ListView(children: [
        Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: spaceBetweenSections),
              // Partie de l'image
              SizedBox(
                width: 85.w,
                child: Image.asset("assets/image/tailleur.png"),
              ),
              SizedBox(height: spaceBetweenSections),
              // Partie des textes
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin:
                      EdgeInsets.symmetric(horizontal: 7.5.w), // Marge à droite
                  child: Text(
                    "Bienvenue sur Mètre pour la gestion des mesures de vos clients en toute facilité ...... ",
                    style: TextStyle(
                      fontSize: 12.sp,
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
                      EdgeInsets.symmetric(horizontal: 7.5.w), // Marge à droite
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              "En appuyant sur se Connecter ou s’inscrire, vous acceptez nos ",
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .tertiary, // Couleur du texte
                            fontSize: 10.sp,
                            decoration:
                                TextDecoration.none, // Pas de décoration
                          ),
                        ),
                        TextSpan(
                          text: "Conditions générales.",
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .tertiary, // Couleur du texte cliquable
                            fontSize: 10.sp,
                            decoration:
                                TextDecoration.underline, // Souligner le texte
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Action à effectuer lors du clic sur "inscrivez-vous"
                              // ignore: deprecated_member_use
                              launch(
                                  _url2); // Lien URL de vos conditions générales
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
                      EdgeInsets.symmetric(horizontal: 7.5.w), // Marge à droite
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              "Pour en savoir plus sur l’utilisation de tes données, consulte notre ",
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .tertiary, // Couleur du texte
                            fontSize: 10.sp,
                            decoration:
                                TextDecoration.none, // Pas de décoration
                          ),
                        ),
                        TextSpan(
                          text: " Politique de confidentialité.",
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .tertiary, // Couleur du texte cliquable
                            fontSize: 10.sp,
                            decoration:
                                TextDecoration.underline, // Souligner le texte
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Action à effectuer lors du clic sur "inscrivez-vous"
                              // ignore: deprecated_member_use
                              launch(
                                  _url1); // Lien URL de votre politique de confidentialité
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
                height: 5.h,
                width: 85
                    .w, // Définissez la largeur du bouton en fonction de la largeur de l'écran
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
                        255, 206, 136, 5), // Couleur or du bouton
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(100), // Bord arrondi du bouton
                    ),
                  ),
                  child: Text(
                    "Se connecter",
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 2.5.h),
              SizedBox(
                height: 5.h,
                width: 85
                    .w, // Définissez la largeur du bouton en fonction de la largeur de l'écran
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
                        255, 206, 136, 5), // Couleur or du bouton
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(100), // Bord arrondi du bouton
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                  ),
                  child: Text(
                    "S'inscrire",
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
