import 'dart:convert';

import 'package:Metre/pages/revenue_depense_page.dart';
import 'package:Metre/widgets/CustomSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:Metre/services/CustomIntercepter.dart';
import 'package:Metre/models/depenses_model.dart';

class DepenseActionPage extends StatefulWidget {
  final String transactionId;

  const DepenseActionPage({Key? key, required this.transactionId})
      : super(key: key);

  @override
  _DepenseActionPageState createState() => _DepenseActionPageState();
}

class _DepenseActionPageState extends State<DepenseActionPage> {
  Depenses? _depense;
  bool _isLoading = true;
  String _errorMessage = '';
  String? _id;
  String? _token;

  final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'CFA');
  final _formKey = GlobalKey<FormState>(); // Clé pour le formulaire
  final ValueNotifier<bool> _isFormModified =
      ValueNotifier<bool>(false); // Nouveau ValueNotifier
  final TextEditingController _libelleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadToken().then((_) => _loadDepenseDetails());
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _id = prefs.getString('id');
      _token = prefs.getString('token');
    });
  }

  Future<void> _loadDepenseDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final String depenseId = widget.transactionId;
    final String apiUrl =
        'http://192.168.56.1:8010/api/depenses/loadbyid/$depenseId';

    try {
      final http.Client client = CustomIntercepter(http.Client());
      final response = await client.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 202) {
        final Map<String, dynamic> data = jsonDecode(response.body)['data'];
        setState(() {
          _depense = Depenses.fromJson(data);
          _libelleController.text =
              _depense?.libelle ?? ''; // Initialiser le libellé
          _descriptionController.text =
              _depense?.description ?? ''; // Initialiser la description
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Erreur lors de la récupération des détails de la dépense: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de connexion: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateDepenseDetails() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final String depenseId = widget.transactionId;
      final String apiUrl =
          'http://192.168.56.1:8010/api/depenses/update/$depenseId'; // Remplace par ton URL

      try {
        final http.Client client = CustomIntercepter(http.Client());
        final response = await client.put(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'libelle': _libelleController.text,
            'description': _descriptionController.text,
          }),
        );

        if (response.statusCode == 202) {
          // Mettre à jour l'état local
          setState(() {
            if (_depense != null) {
              _depense!.libelle = _libelleController.text;
              _depense!.description = _descriptionController.text;
            }
            _isLoading = false;
          });
          Navigator.pop(context); // Retourner à la page précédente
        } else {
          setState(() {
            _errorMessage =
                'Erreur lors de la mise à jour de la dépense: ${response.statusCode}';
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Erreur de connexion: $e';
          _isLoading = false;
        });
      }
    }
  }

  // delete
  Future<void> _FunctiondeleteModele() async {
    final String depenseId = widget.transactionId;
    final url = 'http://192.168.56.1:8010/api/depenses/deletes/$depenseId/$_id';
    final http.Client client = CustomIntercepter(http.Client());
    final response = await client.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 202) {
      // setState(() {
      //   _fetchProprietaireMesure();
      // });

      final message = json.decode(response.body)['message'];
      CustomSnackBar.show(context, message: '$message', isError: false);

      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text('$message'),
      // ));
    } else {
      final message = json.decode(response.body)['message'];
      CustomSnackBar.show(context, message: '$message', isError: true);
      print(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Détails de la dépense',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.tertiary),
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit,
              size: 15.sp,
              color: Colors.blue,
            ),
            onPressed: () {
              _showEditDialog(context);
            },
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 5.w,
                              backgroundImage: NetworkImage(
                                _depense?.utilisateur?.profile ??
                                    'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y', // URL par défaut
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              _depense?.utilisateur?.nom ?? 'N/A',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        _buildDetailRow('Libellé', _depense?.libelle ?? 'N/A'),
                        SizedBox(height: 2.h),
                        _buildDetailRow('Montant',
                            currencyFormat.format(_depense?.montant ?? 0)),
                        SizedBox(height: 2.h),
                        _buildDetailRow(
                            'Description', _depense?.description ?? 'N/A'),
                        SizedBox(height: 2.h),
                        _buildDetailRow(
                            'Date', _formatDate(_depense?.date) ?? 'N/A'),
                        SizedBox(height: 2.h),
                        _buildDetailRow(
                            'Référence', _depense?.reference ?? 'N/A'),
                        SizedBox(height: 4.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 1.5.h),
                                textStyle: TextStyle(fontSize: 12.sp),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.sp),
                                ),
                              ),
                              onPressed: () {
                                // TODO: Ajouter l'action pour supprimer la dépense
                                deleteClient();
                              },
                              child: Text(
                                'Supprimer',
                                style: TextStyle(
                                    fontSize: 10.sp, color: Colors.white),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 10.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Modifier la dépense',
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _libelleController,
                  style: TextStyle(
                      fontSize: 10.sp,
                      color: Theme.of(context).colorScheme.tertiary),
                  decoration: InputDecoration(
                    labelText: "Libelle",
                    labelStyle: TextStyle(
                        color: Color.fromARGB(255, 132, 134, 135),
                        fontSize: 10.sp),
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
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un libellé';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _isFormModified.value = true;
                  },
                ),
                SizedBox(
                  height: 2.h,
                ),
                TextFormField(
                  controller: _descriptionController,
                  style: TextStyle(
                      fontSize: 10.sp,
                      color: Theme.of(context).colorScheme.tertiary),
                  decoration: InputDecoration(
                    labelText: "Description",
                    labelStyle: TextStyle(
                        color: Color.fromARGB(255, 132, 134, 135),
                        fontSize: 10.sp),
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
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  ),
                  maxLines: 3,
                  onChanged: (value) {
                    _isFormModified.value = true;
                  },
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _isFormModified,
              builder: (context, isFormModified, child) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 206, 136, 5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: isFormModified
                      ? () {
                          if (_formKey.currentState!.validate()) {
                            _updateDepenseDetails();
                          }
                        }
                      : null, // Désactiver le bouton si le formulaire n'est pas modifié
                  child: const Text('Enregistrer'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void deleteClient() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Attention",
            style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          content: Text(
            "Vous allez supprimer cette depenses",
            style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          actions: [
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child:
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 2.h),
                    backgroundColor: Color.fromARGB(255, 206, 136, 5),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    "Annuler",
                    style: TextStyle(
                      fontSize: 8.sp,
                      letterSpacing: 2,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Fermer la boîte de dialogue
                  },
                ),
                // ),
                SizedBox(
                  width: 3.w,
                ),
                // Padding(
                //   padding: EdgeInsets.all(0.8.h),
                // child:
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 2.h),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    "Spprimer",
                    style: TextStyle(
                      fontSize: 8.sp,
                      letterSpacing: 2,
                    ),
                  ),
                  onPressed: () {
                    // ::::::::::::::::::::::::::::::::::::::::
                    _FunctiondeleteModele();

                    //:::::::::::::::::::::::::::::::::::::::::::
                    Navigator.of(context).pop(); // Fermer la boîte de dialogue
                    messageSuppression();
                  },
                ),
                // ),
              ],
            ),
          ],
        );
      },
    );
  }

  void messageSuppression() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Suppression réussie',
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Modèle supprimer avec succès ?',
            style: TextStyle(fontSize: 10.sp),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => RevenueDepensePage(),
                  ),
                );
              },
              child: Text('ok', style: TextStyle(fontSize: 10.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 206, 136, 5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
