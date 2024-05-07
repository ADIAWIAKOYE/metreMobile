import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:Metre/pages/login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: ListView(
        children: [
          Container(
            margin: EdgeInsets.all(15),
            child: Form(
              child: Column(
                children: [
                  // Image(
                  //   image: AssetImage('assets/image/logo1.pnd'),
                  //   width: 100,
                  //   height: 100,
                  // ),
                  // SizedBox(
                  //   height: 38,
                  // ),
                  SizedBox(
                    width: 150,
                    child: Image.asset('assets/image/logo4.png'),
                  ),
                  // SizedBox(
                  //   height: 10,
                  // ),

                  Text(
                    "Inscrivez-vous",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(
                    height: 15,
                  ),

                  // nom de l'entreprise

                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.account_circle),
                      hintText: "Entrez votre nom de l'entreprise",
                      hintStyle: TextStyle(
                        color: Color.fromARGB(255, 132, 134, 135),
                      ),

                      labelText: "nom de l'entreprise",
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
                              10), // Ajustez la valeur de la marge verticale selon vos besoins
                    ),
                  ),

                  SizedBox(
                    height: 15,
                  ),

                  // adresse de l'entreprise

                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.location_on),
                      hintText: "Entrez l'adresse de votre entreprise",
                      hintStyle: TextStyle(
                        color: Color.fromARGB(255, 132, 134, 135),
                      ),

                      labelText: "Adresse de l'entreprise",
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
                              10), // Ajustez la valeur de la marge verticale selon vos besoins
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
                              10), // Ajustez la valeur de la marge verticale selon vos besoins
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
                              10), // Ajustez la valeur de la marge verticale selon vos besoins
                    ),
                  ),

                  SizedBox(
                    height: 15,
                  ),

                  // la specialité de l'entreprise

                  DropdownButtonFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.category),
                      hintText: "Choisissez votre specialité ",
                      hintStyle: TextStyle(
                        color: Color.fromARGB(255, 132, 134, 135),
                      ),
                      labelText: "Specialité de l'entreprise",
                      labelStyle: TextStyle(color: Colors.black),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color.fromARGB(
                            255,
                            195,
                            154,
                            5,
                          ), // Couleur de la bordure
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
                        vertical: 10,
                      ), // Ajustez la valeur de la marge verticale selon vos besoins
                    ),
                    items: [
                      DropdownMenuItem(
                        child: Text("Option 1"),
                        value: "option1",
                      ),
                      DropdownMenuItem(
                        child: Text("Option 2"),
                        value: "option2",
                      ),
                      DropdownMenuItem(
                        child: Text("Option 3"),
                        value: "option3",
                      ),
                    ],
                    onChanged: (value) {
                      // Ajoutez votre logique pour traiter la sélection ici
                    },
                  ),

                  SizedBox(
                    height: 15,
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
                              10), // Ajustez la valeur de la marge verticale selon vos besoins
                    ),
                  ),

                  SizedBox(
                    height: 15,
                  ),

                  // le mot de passe confirmer

                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      hintText: "Confirmer votre mot de passe",
                      hintStyle: TextStyle(
                        color: Color.fromARGB(255, 132, 134, 135),
                      ),

                      labelText: "mot de passe confirmer",
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
                              10), // Ajustez la valeur de la marge verticale selon vos besoins
                    ),
                  ),

                  SizedBox(
                    height: 20,
                  ),

                  SizedBox(
                    height: 45,
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
                        "S'inscrire",
                        style: TextStyle(
                          fontSize: 14,
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
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: EdgeInsets.only(right: 30), // Marge à droite
              child: GestureDetector(
                onTap: () {
                  // Action à effectuer lors du clic sur le texte
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text(
                  "Se connecter",
                  style: TextStyle(
                    color: Color.fromARGB(
                        255, 1, 62, 111), // Couleur du texte cliquable
                    decoration: TextDecoration.none, // Souligner le texte
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
