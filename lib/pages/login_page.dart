import 'dart:async';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:Metre/bottom_navigationbar/navigation_page.dart';
import 'package:Metre/pages/signup_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyMO = GlobalKey<FormState>();
  var _isObscured = true;

  TextEditingController phone = TextEditingController();
  TextEditingController phoneMO = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController email = TextEditingController();

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

  bool _showResetPasswordForm = false;
  bool _fieldsEnabled = true;
  bool _isLoading = false;

  // void _submitFormLogin() {
  //   String _username = phone.text;
  //   String _password = password.text;
  //   // Check if the form is valid
  //   if (_formKey.currentState!.validate()) {
  //     _formKey.currentState!.save(); // Save the form data
  //     // You can perform actions with the form data here and extract the detail
  //     print('Numero de telephone: $_username');
  //     print('le mot de passe : $_password');
  //   }
  // }

// uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String _username = phone.text;
      String _password = password.text;
      final String url = 'http://192.168.56.1:8010/user/login';

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': _username, 'password': _password}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          final String token = data['token'];
          final String refreshToken = data['refreshToken'];
          final String id = data['id'];

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('refreshToken', refreshToken);
          await prefs.setString('username', _username);
          await prefs.setString('id', id);

          _startTokenRefreshTimer(refreshToken);

          // print("l\'id de l\'utilisateur est " + id);
          // print("les données de retour sont " + jsonEncode(data));
          // print("le token est " + token);
          // print("le Refresh Token est " + refreshToken);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => NavigationBarPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erreur de connexion. Veuillez réessayer.'),
          ));
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Une erreur s\'est produite. Veuillez réessayer.'),
        ));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _startTokenRefreshTimer(String refreshToken) {
    Timer.periodic(Duration(milliseconds: 3600000), (timer) async {
      final String url = 'http://192.168.56.1:8010/user/refreshtoken';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String newToken = data['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', newToken);
      } else {
        // Handle token refresh error
      }
    });
  }

// yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy

  void _submitFormOubliPassword() {
    String _phone = phoneMO.text;
    String _email = email.text;
    // Check if the form is valid
    if (_formKeyMO.currentState!.validate()) {
      _formKeyMO.currentState!.save(); // Save the form data
      // You can perform actions with the form data here and extract the details
      print('Numero de telephone: $_phone');
      print('l\'email : $_email');
    }
  }

  void _resetForm() {
    if (_formKey.currentState != null) {
      _formKey.currentState!.reset(); // Réinitialisation du formulaire
    }
  }

  void _resetFormMO() {
    if (_formKeyMO.currentState != null) {
      _formKeyMO.currentState!.reset(); // Réinitialisation du formulaire
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: ListView(
        children: [
          Column(
            children: [
              // le logo
              SizedBox(
                width: 150,
                child: Image.asset("assets/image/logo4.png"),
              ),
              SizedBox(
                height: 10,
              ),

              Text(
                "Connectez-vous",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          if (!_showResetPasswordForm)
            Container(
              margin: EdgeInsets.all(15),
              child: Form(
                key: _formKey, // Clé pour le formulaire
                child: Column(
                  children: [
                    // le numero de telephone de l'entreprise

                    TextFormField(
                      controller: phone,
                      enabled: _fieldsEnabled,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.phone),
                        hintText: "Entrez le numéro votre entreprise",
                        hintStyle: TextStyle(
                          color: Color.fromARGB(255, 132, 134, 135),
                          fontSize: 12,
                        ),

                        labelText: "téléphone de l'entreprise",
                        labelStyle: TextStyle(
                          color: Color.fromARGB(255, 132, 134, 135),
                          fontSize: 12,
                        ),
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
                      height: 20,
                    ),

                    // le mot de passe

                    TextFormField(
                      controller: password,
                      enabled: _fieldsEnabled,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: _isObscured,
                      obscuringCharacter: "*",
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: _isObscured
                              ? const Icon(Icons.visibility)
                              : const Icon(Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _isObscured = !_isObscured;
                            });
                          },
                        ),
                        hintText: "Entrez votre mot de passe",
                        hintStyle: TextStyle(
                          color: Color.fromARGB(255, 132, 134, 135),
                          fontSize: 12,
                        ),

                        labelText: "mot de passe",
                        labelStyle: TextStyle(
                          color: Color.fromARGB(255, 132, 134, 135),
                          fontSize: 12,
                        ),
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
                          return 'Veuillez entrer votre mot de passe';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Mot de passe oublié?',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 206, 136, 5),
                                  fontSize: 12,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    setState(() {
                                      _showResetPasswordForm = true;
                                      _fieldsEnabled = false;
                                    });
                                  },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: 20,
                    ),

                    if (!_isLoading)
                      SizedBox(
                        width: 200,
                        height: 40,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Color.fromARGB(255, 206, 136, 5)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                          ),
                          onPressed: _login,
                          child: Text(
                            "Se connecter",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                    else
                      CircularProgressIndicator(),

                    SizedBox(
                      height: 10,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Vous navez pas encore de compte?',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              TextSpan(
                                text: ' Inscrivez-vous',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 206, 136, 5),
                                  fontSize: 12,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
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
                      ],
                    ),
                  ],
                ),
              ),
            ),
          if (_showResetPasswordForm)
            Container(
              margin: EdgeInsets.all(15),
              child: Form(
                key: _formKeyMO, // Clé pour le formulaire
                child: Column(
                  children: [
                    // le numero de telephone de l'entreprise
                    SizedBox(
                      height: 20,
                    ),

                    Text(
                      "Mot de passe oublié",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(
                      height: 15,
                    ),

                    Text(
                      "Entrer votre adresse mail et le téléphone de votre entreprise",
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),

                    SizedBox(
                      height: 15,
                    ),

                    TextFormField(
                      controller: phoneMO,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.phone),
                        hintText: "Entrez le numéro votre entreprise",
                        hintStyle: TextStyle(
                          color: Color.fromARGB(255, 132, 134, 135),
                          fontSize: 12,
                        ),

                        labelText: "téléphone de l'entreprise",
                        labelStyle: TextStyle(
                          color: Color.fromARGB(255, 132, 134, 135),
                          fontSize: 12,
                        ),
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
                          return 'Veuillez entrer votre numero de telephone';
                        }
                        String phoneNumber = phoneMO.text;
                        if (!isValidPhoneNumber(phoneNumber)) {
                          // Affichez un message d'erreur indiquant que le numéro de téléphone est invalide
                          return 'le telephone nest pas valide !';
                        }
                        return null;
                      },
                    ),

                    SizedBox(
                      height: 20,
                    ),

                    TextFormField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        hintText: "Entrez votre adresse mail",
                        hintStyle: TextStyle(
                          color: Color.fromARGB(255, 132, 134, 135),
                          fontSize: 12,
                        ),

                        labelText: "Adresse mail",
                        labelStyle: TextStyle(
                          color: Color.fromARGB(255, 132, 134, 135),
                          fontSize: 12,
                        ),
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
                          return 'Veuillez entrer votre adresse mail';
                        }
                        if (!validateEmail(value)) {
                          return 'Adresse mail invalide';
                        }
                        return null;
                      },
                    ),

                    SizedBox(
                      height: 20,
                    ),

                    SizedBox(
                      width: 200,
                      height: 40,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Color.fromARGB(255, 206, 136, 5)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                        ),
                        onPressed: () {
                          _submitFormOubliPassword();
                          Timer(Duration(seconds: 1), () {
                            setState(() {
                              _showResetPasswordForm = false;
                              _fieldsEnabled = true;
                              _resetForm();
                              _resetFormMO();
                            });
                          });
                        },
                        child: Text(
                          "Soumettre",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 20,
                    ),

                    SizedBox(
                      width: 200,
                      height: 40,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.grey),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _showResetPasswordForm = false;
                            _fieldsEnabled = true;
                            _resetForm();
                            _resetFormMO();
                          });
                        },
                        child: Text(
                          "Annuler",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
