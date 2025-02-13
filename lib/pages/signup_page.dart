import 'dart:convert';

import 'package:Metre/widgets/CustomSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:Metre/pages/login_page.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var _isObscuredP = true;
  var _isObscuredC = true;

  TextEditingController nomEntre = TextEditingController();
  TextEditingController adresse = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController email = TextEditingController();
  // TextEditingController specialite = TextEditingController();
  String? specialite;
  TextEditingController password = TextEditingController();
  TextEditingController confirmePassword = TextEditingController();

  bool validateEmail(String value) {
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value);
    return emailValid;
  }

  bool isValidPhoneNumber(String input) {
    // Expression régulière pour valider le numéro de téléphone au format international
    // La syntaxe utilisée ici correspond à un numéro de téléphone de la forme +XXX XXXXXXXX, où X est un chiffre.
    RegExp regExp = RegExp(r'^\+\d{11}$');
    return regExp.hasMatch(input);
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  void _submitForm() async {
    String _nomEntre = nomEntre.text;
    String _adresse = adresse.text;
    String _phone = phone.text;
    String _email = email.text;
    String? _specialite = specialite ?? "";
    String _password = password.text;

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      showLoadingDialog(context);

      try {
        final response = await http.post(
          Uri.parse('http://192.168.56.1:8010/user/newutilisateur'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'nom': _nomEntre,
            'adresse': _adresse,
            'specialite': _specialite,
            'email': _email,
            'username': _phone,
            'password': _password,
            'role': 'UTILISATEUR',
          }),
        );

        Navigator.of(context).pop();

        if (response.statusCode == 200) {
          CustomSnackBar.show(context,
              message: 'Inscription réussie. Veuillez vous connectés',
              isError: false);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        } else {
          final message = json.decode(response.body)['data'];
          CustomSnackBar.show(context, message: '$message', isError: true);
        }
      } catch (e) {
        Navigator.of(context).pop();
        CustomSnackBar.show(context,
            message:
                'Une erreur s\'est produite. Veuillez vérifier votre connexion.',
            isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: ListView(
        children: [
          Container(
            margin: EdgeInsets.all(2.h),
            child: Form(
              key: _formKey, // Clé pour le formulaire
              child: Column(
                children: [
                  SizedBox(
                    width: 37.5.w,
                    child: Image.asset('assets/image/logo4.png'),
                  ),

                  Text(
                    "Inscrivez-vous",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(
                    height: 2.h,
                  ),

                  // nom de l'entreprise

                  TextFormField(
                    controller: nomEntre,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.account_circle,
                        size: 15.sp,
                      ),
                      hintText: "Exp: MonStyl Couture",
                      hintStyle: TextStyle(
                        color: Color.fromARGB(255, 132, 134, 135),
                        fontSize: 8.sp,
                      ),

                      labelText: "nom de l'entreprise",
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 132, 134, 135),
                        fontSize: 8.sp,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color.fromARGB(
                              255, 206, 136, 5), // Couleur de la bordure
                          width: 0.4.w, // Largeur de la bordure
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 206, 136, 5),
                          width: 0.4.w,
                        ), // Couleur de la bordure lorsqu'elle est en état de focus
                      ),

                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 0.4.w,
                        ), // Couleur de la bordure lorsqu'elle est en état de focus
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 1
                              .h), // Ajustez la valeur de la marge verticale selon vos besoins
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le nom de votre atelier';
                      }
                      return null;
                    },
                  ),

                  SizedBox(
                    height: 2.h,
                  ),

                  // adresse de l'entreprise

                  TextFormField(
                    controller: adresse,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.location_on,
                        size: 15.sp,
                      ),
                      hintText: "Exp: Bamako, yirimadio, 1008logt",
                      hintStyle: TextStyle(
                        color: Color.fromARGB(255, 132, 134, 135),
                        fontSize: 8.sp,
                      ),

                      labelText: "Adresse de l'entreprise",
                      labelStyle: TextStyle(
                          color: Color.fromARGB(255, 132, 134, 135),
                          fontSize: 8.sp),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color.fromARGB(
                              255, 206, 136, 5), // Couleur de la bordure
                          width: 0.4.w, // Largeur de la bordure
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 206, 136, 5),
                          width: 0.4.w,
                        ), // Couleur de la bordure lorsqu'elle est en état de focus
                      ),

                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 0.4.w,
                        ), // Couleur de la bordure lorsqu'elle est en état de focus
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 1
                              .h), // Ajustez la valeur de la marge verticale selon vos besoins
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer l\'adresse de votre atelier';
                      }
                      return null;
                    },
                  ),

                  SizedBox(
                    height: 2.h,
                  ),

                  // le numero de telephone de l'entreprise

                  TextFormField(
                    controller: phone,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.phone,
                        size: 15.sp,
                      ),
                      hintText: "Exp: +22375468913",
                      hintStyle: TextStyle(
                        color: Color.fromARGB(255, 132, 134, 135),
                        fontSize: 8.sp,
                      ),

                      labelText: "téléphone de l'entreprise",
                      labelStyle: TextStyle(
                          color: Color.fromARGB(255, 132, 134, 135),
                          fontSize: 8.sp),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color.fromARGB(
                              255, 206, 136, 5), // Couleur de la bordure
                          width: 0.4.w, // Largeur de la bordure
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 206, 136, 5),
                          width: 0.4.w,
                        ), // Couleur de la bordure lorsqu'elle est en état de focus
                      ),

                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 0.4.w,
                        ), // Couleur de la bordure lorsqu'elle est en état de focus
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 1
                              .h), // Ajustez la valeur de la marge verticale selon vos besoins
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre numero de telephone';
                      }
                      String phoneNumber = phone.text;
                      if (!isValidPhoneNumber(phoneNumber)) {
                        // Affichez un message d'erreur indiquant que le numéro de téléphone est invalide
                        return 'le telephone nest pas valide !';
                      }
                      return null;
                    },
                  ),

                  SizedBox(
                    height: 2.h,
                  ),

                  // l'email de l'entreprise

                  TextFormField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.mail,
                        size: 15.sp,
                      ),
                      hintText: "Exp: exemple@gmail.com",
                      hintStyle: TextStyle(
                        color: Color.fromARGB(255, 132, 134, 135),
                        fontSize: 8.sp,
                      ),

                      labelText: "email de l'entreprise",
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 132, 134, 135),
                        fontSize: 8.sp,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color.fromARGB(
                              255, 206, 136, 5), // Couleur de la bordure
                          width: 0.4.w, // Largeur de la bordure
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 206, 136, 5),
                          width: 0.4.w,
                        ), // Couleur de la bordure lorsqu'elle est en état de focus
                      ),

                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 0.4.w,
                        ), // Couleur de la bordure lorsqu'elle est en état de focus
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 1
                              .h), // Ajustez la valeur de la marge verticale selon vos besoins
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre email';
                      } else if (!validateEmail(value)) {
                        return "Email invalide ";
                      }
                      return null;
                    },
                  ),

                  SizedBox(
                    height: 2.h,
                  ),

                  // la specialité de l'entreprise

                  DropdownButtonFormField<String>(
                    value:
                        specialite, // Assurez-vous de définir la valeur initiale
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.category,
                        size: 15.sp,
                      ),
                      hintText: "Choisissez votre spécialité",
                      hintStyle: TextStyle(
                        color: Color.fromARGB(255, 132, 134, 135),
                        fontSize: 8.sp,
                      ),
                      labelText: "Spécialité de l'entreprise",
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 132, 134, 135),
                        fontSize: 8.sp,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 206, 136, 5),
                          width: 0.4.w,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 206, 136, 5),
                          width: 0.4.w,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 0.4.w,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                    ),
                    items: [
                      "Couture Homme & Enfant",
                      "Couture Femme & Enfant",
                      "Couture Homme, Femme & Enfant"
                    ].map((label) {
                      return DropdownMenuItem<String>(
                        value: label,
                        child: Text(
                          label,
                          style: TextStyle(fontSize: 8.sp),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        specialite =
                            value!; // Mettre à jour la valeur sélectionnée
                      });
                      // Ajoutez votre logique pour traiter la sélection ici
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez sélectionner une spécialité';
                      }
                      return null;
                    },
                  ),

                  SizedBox(
                    height: 2.h,
                  ),

                  // le mot de passe

                  TextFormField(
                    controller: password,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: _isObscuredP,
                    obscuringCharacter: "*",
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock,
                        size: 15.sp,
                      ),
                      suffixIcon: IconButton(
                        icon: _isObscuredP
                            ? Icon(
                                Icons.visibility,
                                size: 15.sp,
                              )
                            : Icon(
                                Icons.visibility_off,
                                size: 15.sp,
                              ),
                        onPressed: () {
                          setState(() {
                            _isObscuredP = !_isObscuredP;
                          });
                        },
                      ),
                      hintText: "Entrez votre mot de passe",
                      hintStyle: TextStyle(
                        color: Color.fromARGB(255, 132, 134, 135),
                        fontSize: 8.sp,
                      ),

                      labelText: "mot de passe",
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 132, 134, 135),
                        fontSize: 8.sp,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color.fromARGB(
                              255, 206, 136, 5), // Couleur de la bordure
                          width: 0.4.w, // Largeur de la bordure
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 206, 136, 5),
                          width: 0.4.w,
                        ), // Couleur de la bordure lorsqu'elle est en état de focus
                      ),

                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 0.4.w,
                        ), // Couleur de la bordure lorsqu'elle est en état de focus
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 1
                              .h), // Ajustez la valeur de la marge verticale selon vos besoins
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre mot de passe';
                      } else if (value.length < 6) {
                        return "Le mot de passe doit être supérieur à 6 carractères";
                      }
                      return null;
                    },
                  ),

                  SizedBox(
                    height: 2.h,
                  ),

                  // le mot de passe confirmer

                  TextFormField(
                    controller: confirmePassword,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: _isObscuredC,
                    obscuringCharacter: "*",
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock,
                        size: 15.sp,
                      ),
                      suffixIcon: IconButton(
                        icon: _isObscuredC
                            ? Icon(
                                Icons.visibility,
                                size: 15.sp,
                              )
                            : Icon(
                                Icons.visibility_off,
                                size: 15.sp,
                              ),
                        onPressed: () {
                          setState(() {
                            _isObscuredC = !_isObscuredC;
                          });
                        },
                      ),
                      hintText: "Confirmer votre mot de passe",
                      hintStyle: TextStyle(
                        color: Color.fromARGB(255, 132, 134, 135),
                        fontSize: 8.sp,
                      ),

                      labelText: "mot de passe confirmer",
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 132, 134, 135),
                        fontSize: 8.sp,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color.fromARGB(
                              255, 206, 136, 5), // Couleur de la bordure
                          width: 0.4.w, // Largeur de la bordure
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 206, 136, 5),
                          width: 0.4.w,
                        ), // Couleur de la bordure lorsqu'elle est en état de focus
                      ),

                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 0.4.w,
                        ), // Couleur de la bordure lorsqu'elle est en état de focus
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 1
                              .h), // Ajustez la valeur de la marge verticale selon vos besoins
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer mot de passe confirmer';
                      }
                      if (confirmePassword.text != password.text) {
                        return 'les mots de passes ne sont pas egales !';
                      }
                      return null;
                    },
                  ),

                  SizedBox(
                    height: 3.h,
                  ),

                  SizedBox(
                    height: 5.h,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (confirmePassword.text == password.text) {
                            _submitForm();
                          } else {
                            // Afficher une erreur indiquant que les mots de passe ne correspondent pas
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Les mots de passe ne correspondent pas.'),
                            ));
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(
                            255, 206, 136, 5), // Couleur or du bouton
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              100), // Bord arrondi du bouton
                        ),
                      ),
                      child: Text(
                        "S'inscrire",
                        style: TextStyle(
                          fontSize: 8.sp,
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
              margin: EdgeInsets.only(right: 4.h), // Marge à droite
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
                    fontSize: 8.sp,
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
