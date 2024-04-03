import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:metremobile/pages/signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _showResetPasswordForm = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Container(
            margin: EdgeInsets.all(15),
            child: Form(
              child: Column(
                children: [
                  // le logo
                  SizedBox(
                    width: 100,
                    child: Image.asset("assets/image/logo1.png"),
                  ),
                  SizedBox(
                    height: 15,
                  ),

                  Text(
                    "Connectez-vous",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(
                    height: 15,
                  ),

                  // le numero de telephone de l'entreprise

                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.phone),
                      hintText: "Entrez le numéro votre entreprise",
                      hintStyle: TextStyle(
                        color: Color.fromARGB(255, 132, 134, 135),
                      ),

                      labelText: "téléphone de l'entreprise",
                      labelStyle: TextStyle(color: Colors.black),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color.fromARGB(
                              255, 195, 154, 5), // Couleur de la bordure
                          width: 1.5, // Largeur de la bordure
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 195, 154, 5),
                          width: 1.5,
                        ), // Couleur de la bordure lorsqu'elle est en état de focus
                      ),

                      contentPadding: EdgeInsets.symmetric(
                          vertical:
                              13), // Ajustez la valeur de la marge verticale selon vos besoins
                    ),
                  ),

                  SizedBox(
                    height: 20,
                  ),

                  // le mot de passe

                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      hintText: "Entrez votre mot de passe",
                      hintStyle: TextStyle(
                        color: Color.fromARGB(255, 132, 134, 135),
                      ),

                      labelText: "mot de passe",
                      labelStyle: TextStyle(color: Colors.black),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color.fromARGB(
                              255, 195, 154, 5), // Couleur de la bordure
                          width: 1.5, // Largeur de la bordure
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 195, 154, 5),
                          width: 1.5,
                        ), // Couleur de la bordure lorsqu'elle est en état de focus
                      ),

                      contentPadding: EdgeInsets.symmetric(
                          vertical:
                              13), // Ajustez la valeur de la marge verticale selon vos besoins
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),

                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        print("BUTTON cliqué !");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(
                            255, 206, 163, 5), // Couleur or du bouton
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              10), // Bord arrondi du bouton
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
                ],
              ),
            ),
          ),

          // Lien pour le mot de passe oublier

          Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: EdgeInsets.only(right: 30), // Marge à droite
              child: GestureDetector(
                onTap: () {
                  // Action à effectuer lors du clic sur le texte
                  setState(() {
                    _showResetPasswordForm = !_showResetPasswordForm;
                  });
                },
                child: Text(
                  "mot de passe oublier",
                  style: TextStyle(
                    color: Color.fromARGB(
                        255, 1, 62, 111), // Couleur du texte cliquable
                    decoration: TextDecoration.none, // Souligner le texte
                  ),
                ),
              ),
            ),
          ),

          SizedBox(
            height: 20,
          ),
          // Afficher le formulaire de réinitialisation du mot de passe si _showResetPasswordForm est vrai
          if (_showResetPasswordForm)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                child: Column(
                  children: [
                    // le numero de telephone de l'entreprise

                    TextFormField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.phone),
                        hintText: "Entrez le numéro votre entreprise",
                        hintStyle: TextStyle(
                          color: Color.fromARGB(255, 132, 134, 135),
                        ),

                        labelText: "téléphone de l'entreprise",
                        labelStyle: TextStyle(color: Colors.black),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Color.fromARGB(
                                255, 195, 154, 5), // Couleur de la bordure
                            width: 1.5, // Largeur de la bordure
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 195, 154, 5),
                            width: 1.5,
                          ), // Couleur de la bordure lorsqu'elle est en état de focus
                        ),

                        contentPadding: EdgeInsets.symmetric(
                            vertical:
                                13), // Ajustez la valeur de la marge verticale selon vos besoins
                      ),
                    ),

                    SizedBox(
                      height: 15,
                    ),

                    // l'email de l'entreprise

                    TextFormField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.mail),
                        hintText: "Entrez l'email votre entreprise",
                        hintStyle: TextStyle(
                          color: Color.fromARGB(255, 132, 134, 135),
                        ),

                        labelText: "email de l'entreprise",
                        labelStyle: TextStyle(color: Colors.black),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Color.fromARGB(
                                255, 195, 154, 5), // Couleur de la bordure
                            width: 1.5, // Largeur de la bordure
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 195, 154, 5),
                            width: 1.5,
                          ), // Couleur de la bordure lorsqu'elle est en état de focus
                        ),

                        contentPadding: EdgeInsets.symmetric(
                            vertical:
                                13), // Ajustez la valeur de la marge verticale selon vos besoins
                      ),
                    ),

                    SizedBox(
                      height: 20,
                    ),

                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          print("BUTTON cliqué !");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(
                              255, 206, 163, 5), // Couleur or du bouton
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10), // Bord arrondi du bouton
                          ),
                        ),
                        child: Text(
                          "Envoyer",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          SizedBox(
            height: 20,
          ),

          // Lien pour la page d'inscription

          Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: EdgeInsets.only(right: 30), // Marge à droite
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Je n'ai pas de compte ",
                      style: TextStyle(
                        color: Colors.black, // Couleur du texte
                        decoration: TextDecoration.none, // Pas de décoration
                      ),
                    ),
                    TextSpan(
                      text: "inscrivez-vous",
                      style: TextStyle(
                        color: Color.fromARGB(
                            255, 1, 49, 87), // Couleur du texte cliquable
                        decoration: TextDecoration.none, // Souligner le texte
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // Action à effectuer lors du clic sur "inscrivez-vous"
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignupPage()),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
