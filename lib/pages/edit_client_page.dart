import 'dart:convert';

import 'package:Metre/models/clients_model.dart';
import 'package:Metre/services/CustomIntercepter.dart';
import 'package:Metre/widgets/CustomSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditClientPage extends StatefulWidget {
  final Utilisateur client;
  final String clientId; // Assurez-vous d'avoir l'ID
  const EditClientPage({Key? key, required this.client, required this.clientId})
      : super(key: key);

  @override
  State<EditClientPage> createState() => _EditClientPageState();
}

class _EditClientPageState extends State<EditClientPage> {
  late TextEditingController nomController;
  // late TextEditingController prenomController;
  late TextEditingController emailController;
  late TextEditingController telephoneController;
  late TextEditingController adresseController;
  late TextEditingController professionController;

  final _formKey = GlobalKey<FormState>();
  final http.Client client = CustomIntercepter(http.Client());
  String? _token;

  @override
  void initState() {
    super.initState();

    nomController = TextEditingController(text: widget.client.nom);
    // prenomController = TextEditingController(text: widget.client.prenom);
    emailController = TextEditingController(text: widget.client.email);
    telephoneController = TextEditingController(text: widget.client.username);
    adresseController = TextEditingController(text: widget.client.adresse);
    professionController =
        TextEditingController(text: widget.client.specialite);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
    });
  }

  @override
  void dispose() {
    nomController.dispose();
    // prenomController.dispose();
    emailController.dispose();
    telephoneController.dispose();
    adresseController.dispose();
    professionController.dispose();
    super.dispose();
  }

  Future<void> updateClient(Map<String, dynamic> updatedFields) async {
    final url = 'http://192.168.56.1:8010/user/update/${widget.clientId}';
    final response = await client.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token', // Assurez-vous d'avoir le token
      },
      body: jsonEncode(updatedFields),
    );

    if (response.statusCode == 202) {
      final responseData = jsonDecode(response.body);
      CustomSnackBar.show(context,
          message: 'Client modifié avec succès!', isError: false);
      Navigator.pop(context,
          true); // Retourne `true` pour indiquer le succès de la modification
    } else if (response.statusCode == 400) {
      CustomSnackBar.show(context,
          message: 'Ce téléphone appartient à un autre client!', isError: true);
    } else {
      CustomSnackBar.show(context,
          message: 'Erreur lors de la mise à jour!', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le client'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nomController,
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom';
                  }
                  return null;
                },
              ),
              SizedBox(height: 1.h),
              // TextFormField(
              //   controller: prenomController,
              //   keyboardType: TextInputType.name,
              //   decoration: const InputDecoration(
              //     labelText: 'Prénom',
              //     border: OutlineInputBorder(),
              //   ),
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Veuillez entrer le prénom';
              //     }
              //     return null;
              //   },
              // ),
              SizedBox(height: 1.h),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 1.h),
              TextFormField(
                controller: telephoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le numéro de téléphone';
                  }
                  return null;
                },
              ),
              SizedBox(height: 1.h),
              TextFormField(
                controller: adresseController,
                keyboardType: TextInputType.streetAddress,
                decoration: const InputDecoration(
                  labelText: 'Adresse',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final updatedFields = <String, String>{};

                    if (nomController.text != widget.client.nom) {
                      updatedFields['nom'] = nomController.text;
                    }
                    // if (prenomController.text != widget.client.prenom) {
                    //   updatedFields['prenom'] = prenomController.text;
                    // }
                    if (emailController.text != widget.client.email) {
                      updatedFields['email'] = emailController.text;
                    }
                    if (telephoneController.text != widget.client.username) {
                      updatedFields['numero'] = telephoneController.text;
                    }
                    if (adresseController.text != widget.client.adresse) {
                      updatedFields['adresse'] = adresseController.text;
                    }

                    await updateClient(updatedFields);
                  }
                },
                child: const Text('Enregistrer les modifications'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
