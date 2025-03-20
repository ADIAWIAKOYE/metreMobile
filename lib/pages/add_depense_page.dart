import 'dart:convert';

import 'package:Metre/services/CustomIntercepter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';

class AddDepensesPage extends StatefulWidget {
  const AddDepensesPage({super.key});

  @override
  State<AddDepensesPage> createState() => _AddDepensesPageState();
}

class _AddDepensesPageState extends State<AddDepensesPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _libelleController = TextEditingController();
  final TextEditingController _montantController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'CFA');

  final http.Client client = CustomIntercepter(http.Client());

  String? _id;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _id = prefs.getString('id');
      _token = prefs.getString('token');
    });
  }

  Future<void> _addExpense() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final String userId = '$_id';
    final String apiUrl =
        'http://192.168.56.1:8010/api/depenses/create/$userId';

    final Map<String, dynamic> requestBody = {
      'libelle': _libelleController.text,
      'montant': _montantController.text,
      'description': _descriptionController.text,
    };

    try {
      final response = await client.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 202) {
        // 201 Created est le code de statut HTTP approprié pour une création réussie
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dépense ajoutée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        // Réinitialiser les champs
        setState(() {
          _libelleController.clear();
          _montantController.clear();
          _descriptionController.clear();
        });
      } else {
        setState(() {
          _errorMessage =
              'Erreur lors de l\'ajout de la dépense: ${response.statusCode} - ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de connexion: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.keyboard_backspace,
            size: 20.sp,
          ),
        ),
        title: Text(
          'Ajouter une dépense',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _montantController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(
                    labelText: 'Montant',
                  ),
                  maxLength: 06,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Veuillez entrer le montant'
                      : null,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(06),
                  ],
                  // decoration: InputDecoration(labelText: 'Montant'),
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Veuillez entrer un montant';
                  //   }
                  //   if (double.tryParse(value) == null) {
                  //     return 'Veuillez entrer un nombre valide';
                  //   }
                  //   return null;
                  // },
                ),
                SizedBox(
                  height: 1.h,
                ),
                TextFormField(
                  controller: _libelleController,
                  decoration: _inputDecoration(
                    labelText: 'Libellé',
                  ),
                  // decoration: InputDecoration(labelText: 'Libellé'),
                  maxLength: 50,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Veuillez entrer un libellé'
                      : null,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(50),
                  ],
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Veuillez entrer un libellé';
                  //   }
                  //   return null;
                  // },
                ),
                SizedBox(
                  height: 1.h,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: _inputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                  ),
                  // decoration: InputDecoration(labelText: 'Description'),
                  maxLength: 200,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Veuillez entrer une description'
                      : null,
                  maxLines: 5,
                  // maxLength: 200,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(50),
                  ],
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Veuillez entrer une description';
                  //   }
                  //   return null;
                  // },
                ),
                SizedBox(height: 4.h),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 206, 136, 5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            _addExpense();
                          }
                        },
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : Text('Ajouter un dépense'),
                ),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
      {String? hintText,
      String? labelText,
      Widget? prefixIcon,
      bool alignLabelWithHint = false}) {
    return InputDecoration(
      prefixIcon: prefixIcon,
      hintText: hintText,
      hintStyle: TextStyle(
        color: Color.fromARGB(255, 132, 134, 135),
        fontSize: 10.sp,
      ),
      labelText: labelText,
      labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.tertiary, fontSize: 10.sp),
      alignLabelWithHint: alignLabelWithHint,
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
      contentPadding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
    );
  }

  @override
  void dispose() {
    _libelleController.dispose();
    _montantController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
