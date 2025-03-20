import 'dart:convert';

import 'package:Metre/models/commande_model.dart';
import 'package:Metre/pages/commandes/commande_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:Metre/services/CustomIntercepter.dart';

class RevenueActionPage extends StatefulWidget {
  final String transactionId;

  const RevenueActionPage({Key? key, required this.transactionId})
      : super(key: key);

  @override
  _RevenueActionPageState createState() => _RevenueActionPageState();
}

class _RevenueActionPageState extends State<RevenueActionPage> {
  PayementCommande? _revenue;
  Commande? _commande;
  bool _isLoading = true;
  String _errorMessage = '';
  String? _token;

  final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'CFA');

  @override
  void initState() {
    super.initState();
    _loadToken().then((_) => _loadRevenueAndCommandeDetails());
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
    });
  }

  Future<void> _loadRevenueAndCommandeDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final String revenueId = widget.transactionId;
    final String revenueApiUrl =
        'http://192.168.56.1:8010/api/payementcommande/loadbyid/$revenueId';
    final String commandeApiUrl =
        'http://192.168.56.1:8010/api/payementcommande/loadCommande/$revenueId';

    try {
      final http.Client client = CustomIntercepter(http.Client());

      // Effectuer les requêtes en parallèle
      final responses = await Future.wait([
        client.get(
          Uri.parse(revenueApiUrl),
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        client.get(
          Uri.parse(commandeApiUrl),
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      ]);

      final revenueResponse = responses[0];
      final commandeResponse = responses[1];

      if (revenueResponse.statusCode == 202 &&
          commandeResponse.statusCode == 202) {
        final Map<String, dynamic> revenueData =
            jsonDecode(revenueResponse.body)['data'];
        final Map<String, dynamic> commandeData =
            jsonDecode(commandeResponse.body)['data'];

        setState(() {
          _revenue = PayementCommande.fromJson(revenueData);
          _commande = Commande.fromJson(commandeData);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Erreur lors de la récupération des données: ${revenueResponse.statusCode}, ${commandeResponse.statusCode}';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Détails du Revenu',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.tertiary),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Padding(
                  padding: EdgeInsets.all(4.w),
                  // child: Card(
                  //   elevation: 4,
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(12.sp),
                  //   ),
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informations du Revenu',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        _buildDetailRow(
                            'Montant',
                            currencyFormat.format(_revenue?.montant ?? 0),
                            Icons.attach_money,
                            Theme.of(context).colorScheme.secondary),
                        SizedBox(height: 2.h),
                        _buildDetailRow(
                            'Date',
                            _formatDate(_revenue?.date) ?? 'N/A',
                            Icons.calendar_today,
                            Theme.of(context).colorScheme.secondary),
                        SizedBox(height: 2.h),
                        _buildDetailRow(
                            'Référence',
                            _revenue?.reference ?? 'N/A',
                            Icons.confirmation_number,
                            Theme.of(context).colorScheme.secondary),
                        SizedBox(height: 4.h),
                        if (_commande != null)
                          Center(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(
                                    255, 206, 136, 5), // Couleur du bouton
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5.w, vertical: 1.5.h),
                                textStyle: TextStyle(fontSize: 12.sp),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10.sp), // Bords arrondis
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CommandeDetailsPage(
                                        commande: _commande!),
                                  ),
                                );
                              },
                              icon: Icon(Icons.shopping_cart,
                                  size: 14.sp, color: Colors.white),
                              label: Text(
                                'Voir les détails de la commande',
                                style: TextStyle(
                                    fontSize: 10.sp, color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // ),
                ),
    );
  }

  Widget _buildDetailRow(
      String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14.sp),
        SizedBox(width: 2.w),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 10.sp),
          ),
        ),
      ],
    );
  }

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
}
