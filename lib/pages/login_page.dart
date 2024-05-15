import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:Metre/bottom_navigationbar/navigation_page.dart';
import 'package:Metre/pages/signup_page.dart';

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

  void _submitFormLogin() {
    String _phone = phone.text;
    String _password = password.text;
    // Check if the form is valid
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save the form data
      // You can perform actions with the form data here and extract the detail
      print('Numero de telephone: $_phone');
      print('le mot de passe : $_password');
    }
  }

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

                    SizedBox(
                      height: 45,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Action à effectuer lors du clic sur le texte
                          // if (_formKey.currentState!.validate()) {
                          //   _submitFormLogin();
                          // }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NavigationBarPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(
                              255, 206, 136, 5), // Couleur or du bouton
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10), // Bord arrondi du bouton
                          ),
                        ),
                        child: Text(
                          "Se connecter",
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
                    _fieldsEnabled =
                        !_showResetPasswordForm; // Disable fields if form is shown

                    _resetForm();
                    phone.clear();
                    password.clear();

                    _resetFormMO();
                    phoneMO.clear();
                    email.clear();
                  });
                },
                child: Text(
                  "mot de passe oublier",
                  style: TextStyle(
                    color: Colors.blue, // Couleur du texte cliquable
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
                key: _formKeyMO,
                child: Column(
                  children: [
                    // le numero de telephone de l'entreprise

                    TextFormField(
                      controller: phoneMO,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.phone),
                        hintText: "Entrez le numéro votre entreprise",
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),

                        labelText: "téléphone de l'entreprise",
                        labelStyle: TextStyle(
                          color: Colors.grey,
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
                      height: 15,
                    ),

                    // l'email de l'entreprise

                    TextFormField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.mail),
                        hintText: "Entrez l'email votre entreprise",
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),

                        labelText: "email de l'entreprise",
                        labelStyle: TextStyle(color: Colors.grey, fontSize: 12),
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
                          return 'Veuillez entrer votre email';
                        } else if (!validateEmail(value)) {
                          return "Email invalide";
                        }
                        return null;
                      },
                    ),

                    SizedBox(
                      height: 20,
                    ),

                    SizedBox(
                      height: 45,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKeyMO.currentState!.validate()) {
                            _submitFormOubliPassword();
                          }
                          print("BUTTON cliqué !");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(
                              255, 206, 136, 5), // Couleur or du bouton
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10), // Bord arrondi du bouton
                          ),
                        ),
                        child: Text(
                          "Envoyer",
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
                        color: Theme.of(context)
                            .colorScheme
                            .tertiary, // Couleur du texte
                        decoration: TextDecoration.none, // Pas de décoration
                      ),
                    ),
                    TextSpan(
                      text: "inscrivez-vous",
                      style: TextStyle(
                        color: Colors.blue, // Couleur du texte cliquable
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
