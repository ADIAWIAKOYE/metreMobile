import 'dart:convert';

import 'package:Metre/widgets/CustomSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;

class ChangerPasswordPage extends StatefulWidget {
  const ChangerPasswordPage({super.key});

  @override
  State<ChangerPasswordPage> createState() => _ChangerPasswordPageState();
}

class _ChangerPasswordPageState extends State<ChangerPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var _isObscured = true;

  // TextEditingController ancienPassword = TextEditingController();
  TextEditingController nouveauPassword = TextEditingController();
  TextEditingController confirmeNewPassword = TextEditingController();

  bool isLoading = true;

  String? _id;
  String? _token;

  @override
  void initState() {
    super.initState();
    // Ajoute un délai de 2 secondes avant de charger les données utilisateur
    // Future.delayed(Duration(seconds: 2), () {
    _loadUserData().then((_) {});
    // });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _id = prefs.getString('id');
      _token = prefs.getString('token');
    });
    // print('ID: $_id, Token: $_token'); // Débogage
  }

  Future<void> _submitForm() async {
    String _nouveauPassword = nouveauPassword.text;
    String _confirmeNewPassword = confirmeNewPassword.text;
    print("modepasse est $_nouveauPassword");
    print("comfirmermodepasse est $_confirmeNewPassword");
    // Vérifier si les mots de passe correspondent
    if (_nouveauPassword != _confirmeNewPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Les mots de passe ne correspondent pas"),
        ),
      );
      return;
    }

    if (_id != null && _token != null) {
      final url = 'http://192.168.56.1:8010/user/changepassword/$_id';

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          },
          body: jsonEncode({
            "password": _nouveauPassword,
            "confirmPassword": _confirmeNewPassword,
          }),
        );

        if (response.statusCode == 202 || response.statusCode == 200) {
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
                    Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Success :",
                              style: TextStyle(
                                  fontSize: 14.sp, color: Colors.white)),
                          Spacer(),
                          Text("Mot de passe modifié avec succès",
                              style: TextStyle(
                                  fontSize: 12.sp, color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          );
          // Attendre 3 secondes avant de réinitialiser le formulaire
          Future.delayed(Duration(seconds: 1), () {
            _resetForm();
            nouveauPassword.clear();
            confirmeNewPassword.clear();
          });
        } else {
          final responseData = jsonDecode(response.body);
          String message = responseData['data'];
          CustomSnackBar.show(context, message: '$message', isError: true);
        }
      } catch (e) {
        CustomSnackBar.show(context,
            message:
                'Une erreur s\'est produite. Veuillez vérifier votre connexion.',
            isError: true);
      }
    } else {
      CustomSnackBar.show(context,
          message: 'Une erreur s\'est produite....!', isError: true);
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
      appBar: AppBar(
        backgroundColor: Theme.of(context)
            .colorScheme
            .background, // Changez cette couleur selon vos besoins
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
          SizedBox(
            height: 2.h,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "L\'ancien mot de passe séra remplacer par le nouveau",
                style: TextStyle(fontSize: 10.sp),
              ),
            ),
          ),
          Container(
            // margin: EdgeInsets.all(15),
            padding: EdgeInsets.only(left: 2.w, top: 5.h, right: 2.w),
            child: Form(
              key: _formKey, // Clé pour le formulaire
              child: Column(
                children: [
                  TextFormField(
                    controller: nouveauPassword,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: _isObscured,
                    obscuringCharacter: "*",
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      // prefixIconColor: Color.fromARGB(255, 95, 95, 96),
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
                      labelStyle: TextStyle(
                          color: Color.fromARGB(255, 132, 134, 135),
                          fontSize: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color.fromARGB(
                              255, 206, 136, 5), // Couleur de la bordure
                          width: 1.5, // Largeur de la bordure
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 206, 136, 5),
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
                      // prefixIconColor: Color.fromARGB(255, 95, 95, 96),
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
                      labelStyle: TextStyle(
                          color: Color.fromARGB(255, 132, 134, 135),
                          fontSize: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color.fromARGB(
                              255, 206, 136, 5), // Couleur de la bordure
                          width: 1.5, // Largeur de la bordure
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 206, 136, 5),
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          _resetForm();
                          // ancienPassword.clear();
                          nouveauPassword.clear();
                          confirmeNewPassword.clear();
                          // Ajoutez d'autres méthodes de réinitialisation pour d'autres champs si nécessaire
                        },
                        child: Text(
                          'Annuler',
                          style: TextStyle(
                            fontSize: 13,
                            letterSpacing: 2,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
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
                            print('Submit');
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
                            backgroundColor: Color.fromARGB(255, 206, 136, 5),
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
