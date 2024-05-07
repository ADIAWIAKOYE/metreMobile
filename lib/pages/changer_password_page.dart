import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:Metre/bottom_navigationbar/navigation_page.dart';

class ChangerPasswordPage extends StatefulWidget {
  const ChangerPasswordPage({super.key});

  @override
  State<ChangerPasswordPage> createState() => _ChangerPasswordPageState();
}

class _ChangerPasswordPageState extends State<ChangerPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var _isObscured = true;

  TextEditingController ancienPassword = TextEditingController();
  TextEditingController nouveauPassword = TextEditingController();
  TextEditingController confirmeNewPassword = TextEditingController();

  void _submitForm() {
    String _ancienPassword = ancienPassword.text;
    String _nouveauPassword = nouveauPassword.text;
    String _confirmeNewPassword = confirmeNewPassword.text;
    // Check if the form is valid
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save the form data
      // You can perform actions with the form data here and extract the details
      print(
          'ancien mot de passe: $ancienPassword'); // Print ancien mot de passe
      print(
          'nouveau mot de passe: $nouveauPassword'); // Print nouveau mot de passe
      print(
          'nouveau mot de passe confirmer: $confirmeNewPassword'); // Print nouveau mot de passe confirmer
    }
  }

  void _resetForm() {
    if (_formKey.currentState != null) {
      _formKey.currentState!.reset(); // Réinitialisation du formulaire
    }
  }

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      // body: ListView(
      //   children: [
      //     Align(
      //       alignment: Alignment.centerLeft,
      //       child: IconButton(
      //         onPressed: () {
      //           // Action à effectuer lors du tapotement
      //           Navigator.pop(context);
      //         },
      //         icon: Icon(
      //           Icons.keyboard_backspace,
      //           size: 35,
      //         ),
      //       ),
      //     ),
      //   ],
      // ),

      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.keyboard_backspace,
            size: 30,
          ),
        ),
        title: Align(
          alignment: Alignment.center,
          child: Text(
            'Changer mon mot de passe',
            // style: Theme.of(context).textTheme.headline4,
            // textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              //  Theme.of(context).toggleTheme();
            },
            icon: Icon(isDark ? Icons.sunny : Icons.brightness_3),
            color: Colors.transparent,
          )
        ],
      ),
      body: ListView(
        children: [
          Container(
            // margin: EdgeInsets.all(15),
            padding: EdgeInsets.only(left: 15, top: 90, right: 15),
            child: Form(
              key: _formKey, // Clé pour le formulaire
              child: Column(
                children: [
                  TextFormField(
                    controller: ancienPassword,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: _isObscured,
                    obscuringCharacter: "*",
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      prefixIconColor: Color.fromARGB(255, 95, 95, 96),
                      suffixIcon: IconButton(
                        // padding: EdgeInsetsDirectional.only(end: 12.0),
                        icon: _isObscured
                            ? const Icon(Icons.visibility)
                            : const Icon(Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _isObscured = !_isObscured;
                          });
                        },
                      ),
                      hintText: "Entrez le mot de passe ",
                      hintStyle: TextStyle(
                          color: Color.fromARGB(255, 132, 134, 135),
                          fontSize: 12),

                      labelText: "Ancien mot de passe",
                      labelStyle: TextStyle(color: Colors.black, fontSize: 12),
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
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 1.5,
                        ), // Couleur de la bordure lorsqu'elle est en état de focus
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical:
                              10), // Ajustez la valeur de la marge verticale selon vos besoins
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre ancien mot de passe';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    controller: nouveauPassword,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: _isObscured,
                    obscuringCharacter: "*",
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      prefixIconColor: Color.fromARGB(255, 95, 95, 96),
                      suffixIcon: IconButton(
                        // padding: EdgeInsetsDirectional.only(end: 12.0),
                        icon: _isObscured
                            ? const Icon(Icons.visibility)
                            : const Icon(Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _isObscured = !_isObscured;
                          });
                        },
                      ),
                      hintText: "Entrez le nouveau mot de passe ",
                      hintStyle: TextStyle(
                          color: Color.fromARGB(255, 132, 134, 135),
                          fontSize: 12),

                      labelText: "Nouveau mot de passe",
                      labelStyle: TextStyle(color: Colors.black, fontSize: 12),
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
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 1.5,
                        ), // Couleur de la bordure lorsqu'elle est en état de focus
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical:
                              10), // Ajustez la valeur de la marge verticale selon vos besoins
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre nouveau mot de passe';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    controller: confirmeNewPassword,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: _isObscured,
                    obscuringCharacter: "*",
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      prefixIconColor: Color.fromARGB(255, 95, 95, 96),
                      suffixIcon: IconButton(
                        // padding: EdgeInsetsDirectional.only(end: 12.0),
                        icon: _isObscured
                            ? const Icon(Icons.visibility)
                            : const Icon(Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _isObscured = !_isObscured;
                          });
                        },
                      ),
                      hintText: "Entrez le mot de passe confirmer ",
                      hintStyle: TextStyle(
                          color: Color.fromARGB(255, 132, 134, 135),
                          fontSize: 12),

                      labelText: "confirmer le mot de passe",
                      labelStyle: TextStyle(color: Colors.black, fontSize: 12),
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
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 1.5,
                        ), // Couleur de la bordure lorsqu'elle est en état de focus
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical:
                              10), // Ajustez la valeur de la marge verticale selon vos besoins
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer mot de passe confirmer';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          _resetForm();
                          ancienPassword.clear();
                          nouveauPassword.clear();
                          confirmeNewPassword.clear();
                          // Ajoutez d'autres méthodes de réinitialisation pour d'autres champs si nécessaire
                        },
                        child: Text(
                          'Annuler',
                          style: TextStyle(
                              fontSize: 13,
                              letterSpacing: 2,
                              color: Colors.black),
                        ),
                        style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20))),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _submitForm();
                            child:
                            Text('Submit');
                          }
                        },
                        child: Text(
                          'Modifier',
                          style: TextStyle(
                              fontSize: 13,
                              letterSpacing: 2,
                              color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 195, 154, 5),
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20))),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
