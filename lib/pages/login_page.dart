import 'dart:async';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:Metre/bottom_navigationbar/navigation_page.dart';
import 'package:Metre/pages/signup_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

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
    RegExp regExp = RegExp(r'^\+\d{11}$');
    return regExp.hasMatch(input);
  }

  bool _showResetPasswordForm = false;
  bool _fieldsEnabled = true;
  bool _isLoading = false;

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

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => NavigationBarPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('Erreur de connexion. numero ou mot de passe incorrect.'),
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
    Timer.periodic(Duration(milliseconds: 360000), (timer) async {
      final String url = 'http://192.168.56.1:8010/user/refreshtoken';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String newToken = data['accessToken'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', newToken);
      } else {
        // Handle token refresh error
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //   content: Text('votre token est expirer .'),
        // ));
        print('votre token est expirer .');
      }
    });
  }

  void _submitFormOubliPassword() {
    String _phone = phoneMO.text;
    String _email = email.text;
    if (_formKeyMO.currentState!.validate()) {
      _formKeyMO.currentState!.save();
      print('Numero de telephone: $_phone');
      print('l\'email : $_email');
    }
  }

  void _resetForm() {
    if (_formKey.currentState != null) {
      _formKey.currentState!.reset();
    }
  }

  void _resetFormMO() {
    if (_formKeyMO.currentState != null) {
      _formKeyMO.currentState!.reset();
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
              SizedBox(
                width: 37.5.w,
                child: Image.asset("assets/image/logo4.png"),
              ),
              SizedBox(height: 2.h),
              Text(
                "Connectez-vous",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          if (!_showResetPasswordForm)
            Container(
              margin: EdgeInsets.all(3.h),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: phone,
                      enabled: _fieldsEnabled,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.phone),
                        hintText: "Entrez le numéro de votre entreprise",
                        hintStyle: TextStyle(
                          color: Color.fromARGB(255, 132, 134, 135),
                          fontSize: 10.sp,
                        ),
                        labelText: "téléphone de l'entreprise",
                        labelStyle: TextStyle(
                          color: Color.fromARGB(255, 132, 134, 135),
                          fontSize: 10.sp,
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre numéro de téléphone';
                        }
                        if (!isValidPhoneNumber(value)) {
                          return 'Le téléphone n\'est pas valide !';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 2.h),
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
                          fontSize: 10.sp,
                        ),
                        labelText: "mot de passe",
                        labelStyle: TextStyle(
                          color: Color.fromARGB(255, 132, 134, 135),
                          fontSize: 10.sp,
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre mot de passe';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 2.h),
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
                                  fontSize: 10.sp,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    setState(() {
                                      _showResetPasswordForm =
                                          !_showResetPasswordForm;
                                    });
                                  },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    SizedBox(
                      height: 6.h,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: Color.fromARGB(255, 206, 136, 5),
                          minimumSize: Size.fromHeight(5.h),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : Text(
                                'Se connecter',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_showResetPasswordForm)
            Container(
              margin: EdgeInsets.all(3.h),
              child: Form(
                key: _formKeyMO,
                child: Column(
                  children: [
                    TextFormField(
                      controller: phoneMO,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.phone),
                        hintText: "Entrez le numéro de votre entreprise",
                        hintStyle: TextStyle(
                          color: Color.fromARGB(255, 132, 134, 135),
                          fontSize: 10.sp,
                        ),
                        labelText: "téléphone de l'entreprise",
                        labelStyle: TextStyle(
                          color: Color.fromARGB(255, 132, 134, 135),
                          fontSize: 10.sp,
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre numéro de téléphone';
                        }
                        if (!isValidPhoneNumber(value)) {
                          return 'Le téléphone n\'est pas valide !';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 2.h),
                    TextFormField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.mail),
                        hintText: "Entrez votre adresse mail",
                        hintStyle: TextStyle(
                          color: Color.fromARGB(255, 132, 134, 135),
                          fontSize: 10.sp,
                        ),
                        labelText: "Adresse mail",
                        labelStyle: TextStyle(
                          color: Color.fromARGB(255, 132, 134, 135),
                          fontSize: 10.sp,
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
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Se connecter?',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 206, 136, 5),
                                  fontSize: 12.sp,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    setState(() {
                                      _showResetPasswordForm =
                                          !_showResetPasswordForm;
                                    });
                                  },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    SizedBox(
                      height: 6.h,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitFormOubliPassword,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: Color.fromARGB(255, 206, 136, 5),
                          minimumSize: Size.fromHeight(40),
                        ),
                        child: Text(
                          'Envoyer',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(height: 2.h),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "vous n'avez pas de compte?",
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Color.fromARGB(255, 132, 134, 135),
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'S\'inscrire',
                      style: TextStyle(
                        color: Color.fromARGB(255, 206, 136, 5),
                        fontSize: 10.sp,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushReplacement(
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
    );
  }
}
