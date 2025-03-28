import 'dart:convert';

import 'package:Metre/pages/depense_action_page.dart';
import 'package:Metre/pages/revenue_action_page.dart';
import 'package:Metre/services/CustomIntercepter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;

class RevenueDepensePage extends StatefulWidget {
  const RevenueDepensePage({Key? key}) : super(key: key);

  @override
  State<RevenueDepensePage> createState() => _RevenueDepensePageState();
}

class _RevenueDepensePageState extends State<RevenueDepensePage> {
  // Données (à remplacer par vos données réelles)
  double _revenusCeMois = 0;
  int _commandesCeMois = 0;
  int _clientsActifs = 0;

  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Filtres
  String _selectedPeriod = 'mois';
  DateTime _selectedDate = DateTime.now();

  // Fonction pour formater la devise
  final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'CFA');
  final http.Client client = CustomIntercepter(http.Client());

  String? _id;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadUserData().then((_) {
      _loadTransactions();
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _id = prefs.getString('id');
      _token = prefs.getString('token');
    });
  }

  String _formatDateForApi(DateTime date) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final String userId = '$_id';
    // Construction de l'URI avec les paramètres
    Uri uri = Uri.http(
      '192.168.56.1:8010', // Hôte et port
      '/api/transactions/users/$userId', // Chemin
      {
        'periode': _selectedPeriod, // Paramètre période
        'date': _formatDateForApi(_selectedDate), // Paramètre date
      },
    );

    final String apiUrl = uri.toString(); // Convertir l'URI en chaîne

    try {
      final response = await client.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          _transactions = List<Map<String, dynamic>>.from(data['transactions']);
          _isLoading = false;
          //Mettre à jour les statistiques
          _revenusCeMois = calculateRevenue(data['transactions']);
        });
      } else {
        setState(() {
          _errorMessage =
              'Erreur lors de la récupération des données: ${response.statusCode}';
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

  double calculateRevenue(List<dynamic> transactions) {
    double total = 0;
    for (var transaction in transactions) {
      if (transaction['type'] == 'revenu') {
        // Utiliser .toDouble() pour convertir en double
        total += (transaction['montant'] as num).toDouble();
      }
    }
    return total;
  }

  double calculateExpenses(List<dynamic> transactions) {
    double total = 0;
    for (var transaction in transactions) {
      if (transaction['type'] == 'depense') {
        // Utiliser .toDouble() pour convertir en double
        total += (transaction['montant'] as num).toDouble();
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    // Filtrer les transactions en fonction de la période sélectionnée
    //List<Map<String, dynamic>> filteredTransactions = _filterTransactions();

    //Recalculer les statistiques principales en fonction de la periode selectionnée
    //_revenusCeMois = _calculateTotalByType('revenu', _transactions);
    //_commandesCeMois = 15;
    //_clientsActifs = 25;
    double totalRevenue = calculateRevenue(_transactions);
    double totalExpenses = calculateExpenses(_transactions);
    double netProfit = totalRevenue - totalExpenses;
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
          'Taleau de board',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                      height:
                          1.h), // Ajoute un espace entre le cercle et le texte
                  Text(
                    "Patientez ! en cour de traitement...",
                    style: TextStyle(fontSize: 12.sp),
                  ),
                ],
              ),
            )
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DropdownButton<String>(
                            value: _selectedPeriod,
                            items: ['mois', 'annee']
                                .map((period) => DropdownMenuItem(
                                      value: period,
                                      child: Text(period),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPeriod = value!;
                              });
                              _loadTransactions();
                            },
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 206, 136, 5),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2026),
                              );
                              if (pickedDate != null &&
                                  pickedDate != _selectedDate) {
                                setState(() {
                                  _selectedDate = pickedDate;
                                });
                                _loadTransactions();
                              }
                            },
                            child: Text('Sélectionner une date'),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text("Transactions",
                          style: TextStyle(
                              fontSize: 12.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 2.h),
                      _buildDataTable(
                        columns: ['Date', 'Type', 'Montant'],
                        data: _transactions,
                        valueFormat: currencyFormat,
                      ),
                      SizedBox(height: 4.h),
                      Text("Récapitulatif",
                          style: TextStyle(
                              fontSize: 12.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 2.h),
                      Card(
                        elevation: 3,
                        child: Padding(
                          padding: EdgeInsets.all(4.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "Total des revenus: ${currencyFormat.format(totalRevenue)}",
                                  style: TextStyle(fontSize: 10.sp)),
                              Text(
                                  "Total des dépenses: ${currencyFormat.format(totalExpenses)}",
                                  style: TextStyle(fontSize: 10.sp)),
                              Text(
                                  "Profit net: ${currencyFormat.format(netProfit)}",
                                  style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  // Widget pour les cartes de statistiques (cliquables)
  Widget _buildStatCard(String title, String value, Color color,
      VoidCallback onTap, IconData icon) {
    return SizedBox(
      width: 40.w,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.sp),
        child: Card(
          elevation: 3,
          shadowColor: Colors.grey.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.sp),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 3.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 14.sp),
                    SizedBox(width: 1.w),
                    Expanded(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style:
                            TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget pour les tableaux de données

// Widget pour les tableaux de données
  Widget _buildDataTable({
    required List<String> columns,
    required List<Map<String, dynamic>> data,
    NumberFormat? valueFormat,
  }) {
    // Ajouter la colonne "Actions" à la liste des colonnes
    List<String> updatedColumns = List.from(columns)..add('Actions');

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: updatedColumns
            .map((column) => DataColumn(label: Text(column)))
            .toList(),
        rows: data
            .map((row) => DataRow(
                  cells: updatedColumns.map((column) {
                    if (column == 'Actions') {
                      // Afficher les boutons d'action
                      return DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.info_outline,
                                color: Color.fromARGB(255, 206, 136, 5),
                              ),
                              tooltip: 'Détails',
                              onPressed: () {
                                // Redirection vers la page appropriée en fonction du type de transaction
                                if (row['type'] == 'revenu') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RevenueActionPage(
                                          transactionId: row[
                                              'id']), // Passer l'ID de la transaction
                                    ),
                                  );
                                } else if (row['type'] == 'depense') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DepenseActionPage(
                                          transactionId: row[
                                              'id']), // Passer l'ID de la transaction
                                    ),
                                  );
                                } else {
                                  // Gérer les types de transactions inconnus
                                  print(
                                      'Type de transaction inconnu: ${row['type']}');
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    } else {
                      // Afficher les données de la colonne
                      var value;
                      switch (column) {
                        case 'Date':
                          if (row['date'] != null) {
                            value = DateFormat('dd/MM/yyyy')
                                .format(DateTime.parse(row['date'].toString()));
                          } else {
                            value = 'N/A';
                          }
                          break;
                        case 'Type':
                          value = row['type'];
                          break;
                        case 'Montant':
                          value = row['montant'];
                          if (valueFormat != null && value is num) {
                            value = valueFormat.format(value);
                          }
                          break;
                        default:
                          value = 'N/A';
                      }
                      return DataCell(Text(value.toString()));
                    }
                  }).toList(),
                ))
            .toList(),
      ),
    );
  }

  // Fonction pour calculer le total par type et avec les données filtrées
  double _calculateTotalByType(
      String type, List<Map<String, dynamic>> filteredTransactions) {
    return filteredTransactions.where((t) => t['type'] == type).fold(
        0.0,
        (double sum, dynamic item) =>
            sum + (item['montant'] as num).toDouble());
  }

  // Fonction pour filtrer les transactions en fonction de la période sélectionnée
  List<Map<String, dynamic>> _filterTransactions() {
    return _transactions.where((transaction) {
      DateTime transactionDate = DateTime.parse(transaction['date']);
      switch (_selectedPeriod) {
        case 'jour':
          return transactionDate.year == _selectedDate.year &&
              transactionDate.month == _selectedDate.month &&
              transactionDate.day == _selectedDate.day;
        case 'mois':
          return transactionDate.year == _selectedDate.year &&
              transactionDate.month == _selectedDate.month;
        case 'semaine':
          DateTime startOfWeek =
              _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
          return transactionDate.year == startOfWeek.year &&
              transactionDate.month == startOfWeek.month &&
              transactionDate.day >= startOfWeek.day &&
              transactionDate.day <= startOfWeek.add(Duration(days: 6)).day;
        case 'annee':
          return transactionDate.year == _selectedDate.year;
        default:
          return true;
      }
    }).toList();
  }
}
