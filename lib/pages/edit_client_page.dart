import 'dart:convert';

import 'package:Metre/models/clients_model.dart';
import 'package:Metre/services/CustomIntercepter.dart';
import 'package:Metre/widgets/CustomSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';

class EditClientPage extends StatefulWidget {
  final String clientId;
  final Utilisateur client;
  final Function(Utilisateur) onClientUpdated;

  const EditClientPage({
    Key? key,
    required this.clientId,
    required this.client,
    required this.onClientUpdated,
  }) : super(key: key);

  @override
  State<EditClientPage> createState() => _EditClientPageState();
}

class _EditClientPageState extends State<EditClientPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nomController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telephoneController = TextEditingController();
  final TextEditingController adresseController = TextEditingController();
  final TextEditingController professionController = TextEditingController();
  final http.Client client = CustomIntercepter(http.Client());

  bool _isModified = false; // Nouvelle variable d'état

  @override
  void initState() {
    super.initState();
    // Initialiser les contrôleurs avec les valeurs actuelles du client
    nomController.text = widget.client.nom;
    emailController.text = widget.client.email;
    telephoneController.text = widget.client.username;
    adresseController.text = widget.client.adresse;
    professionController.text = widget.client.specialite;
  }

  @override
  void dispose() {
    nomController.dispose();
    emailController.dispose();
    telephoneController.dispose();
    adresseController.dispose();
    professionController.dispose();
    super.dispose();
  }

  // Fonction pour vérifier si un champ a été modifié
  bool _isFormModified() {
    return nomController.text != widget.client.nom ||
        emailController.text != widget.client.email ||
        telephoneController.text != widget.client.username ||
        adresseController.text != widget.client.adresse;
  }

  Future<void> updateClient() async {
    if (_formKey.currentState!.validate()) {
      final updatedFields = <String, String>{};

      if (nomController.text != widget.client.nom) {
        updatedFields['nom'] = nomController.text;
      }
      if (emailController.text != widget.client.email) {
        updatedFields['email'] = emailController.text;
      }
      if (telephoneController.text != widget.client.username) {
        updatedFields['numero'] = telephoneController.text;
      }
      if (adresseController.text != widget.client.adresse) {
        updatedFields['adresse'] = adresseController.text;
      }

      final url = 'http://192.168.56.1:8010/user/update/${widget.clientId}';
      try {
        final response = await client.put(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(updatedFields),
        );

        if (response.statusCode == 202) {
          final responseData = jsonDecode(response.body);
          CustomSnackBar.show(context,
              message: 'Client modifié avec succès !', isError: false);

          // Créer un nouveau client avec les valeurs mises à jour
          final updatedClient = Utilisateur(
            id: widget.clientId,
            nom: nomController.text,
            email: emailController.text,
            username: telephoneController.text,
            adresse: adresseController.text,
            specialite: professionController.text,
            profile: widget.client.profile,
          );

          // Appeler la fonction de rappel pour mettre à jour l'UI
          widget.onClientUpdated(updatedClient);
          Navigator.pop(context); // Retourner à la page précédente
        } else if (response.statusCode == 400) {
          CustomSnackBar.show(context,
              message: 'Ce téléphone appartient à un autre client !',
              isError: true);
        } else {
          CustomSnackBar.show(context,
              message: 'Erreur lors de la mise à jour !', isError: true);
        }
      } catch (e) {
        CustomSnackBar.show(context,
            message: 'Erreur de connexion. Veuillez réessayer.', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Modifier le Client',
          style: TextStyle(fontSize: 11.sp),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nomController,
                // decoration: const InputDecoration(labelText: 'Nom'),
                keyboardType: TextInputType.name,
                style: TextStyle(fontSize: 10.sp),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.account_circle,
                    size: 15.sp,
                  ),
                  prefixIconColor: Color.fromARGB(255, 95, 95, 96),
                  hintText: "Entrez le nom ",
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 132, 134, 135),
                    fontSize: 10.sp,
                  ),
                  labelText: "Nom",
                  labelStyle: TextStyle(
                    color: Color.fromARGB(255, 132, 134, 135),
                    fontSize: 10.sp,
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
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 1.w,
                  ), // Ajustez la valeur de la marge verticale selon vos besoins
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _isModified = _isFormModified();
                  });
                },
              ),
              SizedBox(height: 1.5.h),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                    fontSize:
                        10.sp), // Taille de police pour la valeur par défaut
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.email,
                    size: 15.sp,
                  ),
                  prefixIconColor: Color.fromARGB(255, 95, 95, 96),
                  hintText: "exemple@gmail.com",
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 132, 134, 135),
                    fontSize: 10.sp,
                  ),
                  labelText: "Email",
                  labelStyle: TextStyle(
                    color: Color.fromARGB(255, 132, 134, 135),
                    fontSize: 10.sp,
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
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 1.w,
                  ), // Ajustez la valeur de la marge verticale selon vos besoins
                ),
                onChanged: (value) {
                  setState(() {
                    _isModified = _isFormModified();
                  });
                },
              ),
              SizedBox(height: 1.5.h),
              TextFormField(
                controller: telephoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(
                    fontSize:
                        10.sp), // Taille de police pour la valeur par défaut
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.phone,
                    size: 15.sp,
                  ),
                  prefixIconColor: Color.fromARGB(255, 95, 95, 96),
                  hintText: "+XXXXXXXXXXX",
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 132, 134, 135),
                    fontSize: 10.sp,
                  ),
                  labelText: "Téléphone",
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
                    ), // Couleur de la bordure lorsqu'elle est en état de focus
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 1.w,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le numéro de téléphone';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _isModified = _isFormModified();
                  });
                },
              ),
              SizedBox(height: 1.5.h),
              TextFormField(
                controller: adresseController,
                keyboardType: TextInputType.text,
                style: TextStyle(
                    fontSize:
                        10.sp), // Taille de police pour la valeur par défaut
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.location_on,
                    size: 15.sp,
                  ),
                  prefixIconColor: Color.fromARGB(255, 95, 95, 96),
                  hintText: "Entrer l'adresse",
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 132, 134, 135),
                    fontSize: 10.sp,
                  ),
                  labelText: "Adresse",
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
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 1.w,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _isModified = _isFormModified();
                  });
                },
              ),
              SizedBox(height: 2.h),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Color.fromARGB(255, 206, 136, 5), // background
                  foregroundColor: Colors.white, // foreground
                ),
                onPressed: _isModified ? updateClient : null,
                child: Text('Modifier'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
