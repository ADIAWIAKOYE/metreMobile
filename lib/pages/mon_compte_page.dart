import 'dart:convert';

import 'package:Metre/models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// import 'package:Metre/bottom_navigationbar/navigation_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';

class MonComptePage extends StatefulWidget {
  const MonComptePage({super.key});

  @override
  State<MonComptePage> createState() => _MonComptePageState();
}

class _MonComptePageState extends State<MonComptePage> {
  bool isObscurePassword = true;

  String? selectedSpeciality;
// String selectedSpeciality;

// :::::::::::::::::::::::::::::::::::::::::::::::::::::
  Utilisateur_model? user;
  bool isLoading = true;

  String? _id;
  String? _token;

  // Controllers pour chaque champ
  final TextEditingController nomController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController adresseController = TextEditingController();
  final TextEditingController specialiteController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // Valeurs initiales pour comparaison
  String? initialNom;
  String? initialUsername;
  String? initialAdresse;
  String? initialSpecialite;
  String? initialEmail;

  @override
  void initState() {
    super.initState();
    // Ajoute un délai de 2 secondes avant de charger les données utilisateur
    // Future.delayed(Duration(seconds: 2), () {
    _loadUserData().then((_) {
      _getUserById();
    });
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

  Future<void> _getUserById() async {
    final url = 'http://192.168.56.1:8010/user/loadById/$_id';

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $_token'},
    );
    // print('Code de statut: ${response.statusCode}');
    // print(
    //     'Contenu de la réponse : ${response.body}'); // Ajoute ceci pour déboguer
    if (response.statusCode == 202) {
      final jsonData = json.decode(response.body)['data'];
      setState(() {
        user = Utilisateur_model.fromJson(jsonData);
        isLoading = false;

        // Initialiser les controllers avec les valeurs actuelles de l'utilisateur
        nomController.text = user?.nom ?? '';
        usernameController.text = user?.username ?? '';
        adresseController.text = user?.adresse ?? '';
        emailController.text = user?.email ?? '';
        specialiteController.text = user?.specialite ?? '';

        // Stocker les valeurs initiales
        initialNom = nomController.text;
        initialUsername = usernameController.text;
        initialAdresse = adresseController.text;
        initialSpecialite = specialiteController.text;
        initialEmail = emailController.text;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print(
          'Erreur lors du chargement des données utilisateur : ${response.statusCode}');
    }
  }

  Future<void> _updateUserField(Map<String, String> updatedFields) async {
    final url = 'http://192.168.56.1:8010/user/update/$_id';
    // print(
    //     'Envoi de la requête de mise à jour avec les données : $updatedFields');
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: json.encode(updatedFields),
    );

    if (response.statusCode == 200 || response.statusCode == 202) {
      print('Mise à jour réussie');
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
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20.sp,
                ),
                SizedBox(
                  width: 3.w,
                ),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Success :",
                      style: TextStyle(fontSize: 14.sp, color: Colors.white),
                    ),
                    Spacer(),
                    Text(
                      'Mise à jour réussie',
                      style: TextStyle(fontSize: 12.sp, color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ))
              ],
            ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
    } else {
      final message = json.decode(response.body)['message'];
      print('Erreur lors de la mise à jour : ${response.statusCode}');
      print('Erreur : ${message}');
    }
  }

  void _saveChanges() async {
    // Map<String, String> updatedFields = {};
    final updatedFields = <String, String>{};

    // Vérifier chaque champ et ajouter à updatedFields si modifié
    if (user!.nom != nomController.text) {
      updatedFields['nom'] = nomController.text;
    }
    if (user!.username != usernameController.text) {
      updatedFields['username'] = usernameController.text;
    }
    if (user!.adresse != adresseController.text) {
      updatedFields['adresse'] = adresseController.text;
    }
    if (user!.email != emailController.text) {
      updatedFields['email'] = emailController.text;
    }
    if (user!.specialite != specialiteController.text) {
      updatedFields['specialite'] = specialiteController.text;
    }

    // Log les champs modifiés
    // print('Champs modifiés: $updatedFields');

    // Si des champs ont été modifiés, envoyez la requête
    if (updatedFields.isNotEmpty) {
      await _updateUserField(updatedFields);
    } else {
      print('Aucune modification détectée');
    }
  }

  // :::::::::::::::::::::::::::::::::::::::::::::::::

  @override
  Widget build(BuildContext context) {
    // var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

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
          title: Text(
            'Mon Compte',
            // style: Theme.of(context).textTheme.headline4,
            // textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          )),
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Affiche un loader si en cours de chargement
          : Container(
              padding: EdgeInsets.only(left: 15, top: 20, right: 15),
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: ListView(
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              border: Border.all(width: 4, color: Colors.white),
                              boxShadow: [
                                BoxShadow(
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  color: Color.fromARGB(255, 206, 136, 5)
                                      .withOpacity(0.1),
                                ),
                              ],
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: user != null && user!.profile.isNotEmpty
                                    ? NetworkImage(user!.profile)
                                        as ImageProvider
                                    : AssetImage('assets/image/avatar.png'),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(width: 4, color: Colors.white),
                                color: Color.fromARGB(255, 206, 136, 5),
                              ),
                              child: IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    buildTextField('Nom :', nomController),
                    buildTextField('Téléphone :', usernameController),
                    buildTextField('Adresse :', adresseController),
                    buildTextField('Email :', emailController),
                    buildTextField('Spécialité :', specialiteController),
                    SizedBox(height: 30),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildTextField(String labelText, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              labelText,
              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              margin: EdgeInsets.only(right: 1.w),
              child: TextField(
                controller: controller,
                style: TextStyle(fontSize: 10.sp),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(bottom: 0.5.h),
                  hintText: labelText,
                  hintStyle: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        OutlinedButton(
          onPressed: () {
            setState(() {
              _getUserById();
            });
          },
          child: Text(
            'Annuler',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 2,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20))),
        ),
        ElevatedButton(
          onPressed: _saveChanges,
          child: const Text(
            'Modifier',
            style:
                TextStyle(fontSize: 12, letterSpacing: 2, color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 206, 136, 5),
              padding: const EdgeInsets.symmetric(horizontal: 40),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20))),
        ),
      ],
    );
  }

  // Widget buildTextField(
  //     String labelText, String placeholder, bool isPassWordTextField) {
  //   if (labelText == 'Specialité :') {
  //     return Padding(
  //       padding: EdgeInsets.only(bottom: 10),
  //       child: Row(
  //         // Utilisation d'une rangée
  //         children: [
  //           Expanded(
  //             flex: 1,
  //             // Pour le label à gauche
  //             child: Text(
  //               labelText,
  //               style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
  //             ),
  //           ),
  //           Expanded(
  //             flex: 3,
  //             // Pour le champ de saisie à droite avec le placeholder
  //             child: Container(
  //               margin: EdgeInsets.only(right: 10),
  //               child: DropdownButtonFormField<String>(
  //                 value:
  //                     selectedSpeciality, // Remplacez selectedSpeciality par votre variable pour suivre la valeur sélectionnée
  //                 onChanged: (newValue) {
  //                   setState(() {
  //                     selectedSpeciality = newValue;
  //                   });
  //                 },
  //                 items: <String>[
  //                   'Couture Homme & Enfant',
  //                   'Couture Femme & Enfant',
  //                   'Couture Homme, Femme & Enfant',
  //                   // Ajoutez d'autres spécialités ici
  //                 ].map<DropdownMenuItem<String>>((String value) {
  //                   return DropdownMenuItem<String>(
  //                     value: value,
  //                     child: Text(
  //                       value,
  //                       style: TextStyle(fontSize: 10),
  //                     ),
  //                   );
  //                 }).toList(),
  //                 decoration: InputDecoration(
  //                   contentPadding: EdgeInsets.only(bottom: 5),
  //                   hintText: placeholder,
  //                   hintStyle: TextStyle(
  //                     fontSize: 10,
  //                     fontWeight: FontWeight.bold,
  //                     color: Theme.of(context).colorScheme.tertiary,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   } else {
  //     return Padding(
  //       padding: EdgeInsets.only(bottom: 10),
  //       child: Row(
  //         // Utilisation d'une rangée
  //         children: [
  //           Expanded(
  //             flex: 1,
  //             // Pour le label à gauche
  //             child: Text(
  //               labelText,
  //               style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
  //             ),
  //           ),
  //           Expanded(
  //             flex: 3,
  //             // Pour le champ de saisie à droite avec le placeholder
  //             child: Container(
  //               margin: EdgeInsets.only(right: 10),
  //               child: TextField(
  //                 obscureText: isPassWordTextField ? isObscurePassword : false,
  //                 decoration: InputDecoration(
  //                   suffixIcon: isPassWordTextField
  //                       ? IconButton(
  //                           onPressed: () {},
  //                           icon: Icon(
  //                             Icons.remove_red_eye,
  //                             color: Colors.grey,
  //                             size: 10,
  //                           ),
  //                         )
  //                       : null,
  //                   contentPadding: EdgeInsets.only(bottom: 5),
  //                   hintText: placeholder,
  //                   hintStyle: TextStyle(
  //                     fontSize: 10,
  //                     fontWeight: FontWeight.bold,
  //                     color: Theme.of(context).colorScheme.tertiary,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  // }
}
