// lib/pages/commandes_page.dart
import 'dart:convert';

import 'package:Metre/models/commande_model.dart';
import 'package:Metre/pages/commandes/commande_detail_page.dart';
import 'package:Metre/services/CustomIntercepter.dart';
import 'package:Metre/widgets/CustomSnackBar.dart';
import 'package:Metre/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class CommandesPage extends StatefulWidget {
  const CommandesPage({Key? key}) : super(key: key);

  @override
  _CommandesPageState createState() => _CommandesPageState();
}

class _CommandesPageState extends State<CommandesPage>
    with SingleTickerProviderStateMixin {
  List<Commande> _commandes = [];
  late TabController _tabController;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _id;
  String? _token;
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

  int _page = 0;
  final int _pageSize = 10;
  bool _hasMore = true;
  bool _loadingMore = false;
  final ScrollController _scrollController = ScrollController();
  List<Commande> _filteredCommandes = []; // Stocker les commandes filtrées
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadUserData().then((_) {
      _fetchInitialCommandes();
    });
    _tabController =
        TabController(length: 5, vsync: this); // 5 tabs, ANNULER est enlevé
    _tabController.addListener(
        _onTabChange); // Ajout d'un listener pour les changements d'onglet
    _scrollController.addListener(_scrollListener);
  }

  // Nouvelle fonction pour gérer les changements d'onglet
  void _onTabChange() {
    _updateFilteredCommandes();
  }

  void _scrollListener() {
    if (_isLoading || _loadingMore || !_hasMore) return;
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _fetchMoreCommandes();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.removeListener(_onTabChange); // Supprimer le listener
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _id = prefs.getString('id');
      _token = prefs.getString('token');
    });
  }

  Future<void> _fetchInitialCommandes() async {
    _page = 0;
    _commandes.clear();
    _hasMore = true;
    await _fetchCommandes();
    _updateFilteredCommandes();
  }

  Future<void> _fetchMoreCommandes() async {
    if (_loadingMore || !_hasMore) return;
    setState(() {
      _loadingMore = true;
    });
    _page++;
    await _fetchCommandes();
    setState(() {
      _loadingMore = false;
    });
  }

  final http.Client client = CustomIntercepter(http.Client());
  Future<void> _fetchCommandes() async {
    setState(() {
      if (_page == 0) {
        _isLoading = true;
      }
    });

    try {
      if (_id != null) {
        final String url =
            'http://192.168.56.1:8010/api/commandes/getByUsers/$_id?mois=$_selectedMonth&annee=$_selectedYear&page=$_page&size=$_pageSize';

        final response = await client.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
          },
        );
        if (response.statusCode == 202) {
          final data = json.decode(response.body)['data']['content'];
          List<Commande> newCommandes =
              data.map<Commande>((item) => Commande.fromJson(item)).toList();

          setState(() {
            if (_page == 0) {
              // Effacer les anciennes commandes seulement lors de la première page
              _commandes.clear();
              _commandes.addAll(newCommandes);
            } else {
              _commandes.addAll(newCommandes);
            }
            if (newCommandes.isEmpty || newCommandes.length < _pageSize) {
              _hasMore = false;
            }
            if (_page == 0) {
              _isLoading = false;
            }
          });
          _updateFilteredCommandes(); // Appeler _updateFilteredCommandes ici
        } else {
          var decodedJson = json.decode(response.body);
          _showError("Erreur lors du chargement des commandes");
          CustomSnackBar.show(context,
              message: '${decodedJson['message']}', isError: true);
          print(
              'Erreur lors de la récupération des commandes: ${response.statusCode} : ${response.body}');
        }
      } else {
        CustomSnackBar.show(context,
            message: 'L\'identifiant utilisateur est null', isError: true);
      }
    } catch (e) {
      CustomSnackBar.show(context,
          message: "Une erreur s'est produite : $e", isError: true);
    } finally {
      setState(() {
        if (_page == 0) {
          _isLoading = false;
        }
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.red,
    ));
  }

  void _updateFilteredCommandes() {
    List<Commande> filtered =
        _filterCommandes(_getStatutFromTabIndex(_tabController.index));
    setState(() {
      _filteredCommandes = filtered;
    });
  }

  // Nouvelle fonction pour obtenir le statut en fonction de l'index de l'onglet
  String _getStatutFromTabIndex(int index) {
    switch (index) {
      case 0:
        return "TOUT";
      case 1:
        return 'CREER';
      case 2:
        return 'ENCOUR';
      case 3:
        return 'TERMINER';
      case 4:
        return 'LIVRER';
      default:
        return "TOUT"; // Valeur par défaut si l'index est hors limites
    }
  }

  List<Commande> _filterCommandes(String statut) {
    List<Commande> filtered = statut == "TOUT"
        ? _commandes
        : _commandes.where((commande) => commande.status == statut).toList();
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((commande) =>
              commande.daterdv!
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              commande.proprietaire!.client!.nom!
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              commande.reference!
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()))
          .toList();
    }
    return filtered;
  }

  // Fonction pour la couleur du statut
  Color _getStatutColor(String statut) {
    switch (statut) {
      case 'CREER':
        return const Color.fromARGB(255, 142, 127, 1);
      case 'ENCOUR':
        return Colors.orange;
      case 'TERMINER':
        return Colors.blue;
      case 'LIVRER':
        return Colors.green;
      case 'ANNULER':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  //Fonction pour afficher un dialogue pour la selection du mois et de l'année
  Future<void> _selectDate(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          int selectedMonth = _selectedMonth;
          int selectedYear = _selectedYear;

          return AlertDialog(
            title: Text(
              'Sélectionner le mois et l\'année',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(labelText: 'Mois'),
                  value: selectedMonth,
                  items: List.generate(12, (index) => index + 1)
                      .map((month) => DropdownMenuItem(
                            value: month,
                            child: Text(DateFormat('MMMM', 'fr_FR')
                                .format(DateTime(selectedYear, month))),
                          ))
                      .toList(),
                  onChanged: (value) {
                    selectedMonth = value!;
                  },
                ),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(labelText: 'Année'),
                  value: selectedYear,
                  items:
                      List.generate(5, (index) => DateTime.now().year - index)
                          .map((year) => DropdownMenuItem(
                                value: year,
                                child: Text(year.toString()),
                              ))
                          .toList(),
                  onChanged: (value) {
                    selectedYear = value!;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 2.h),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text('Annuler'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 2.h),
                  backgroundColor: Color.fromARGB(255, 206, 136, 5),
                  foregroundColor: Colors.white,
                ),
                child: Text('Valider'),
                onPressed: () {
                  setState(() {
                    _selectedMonth = selectedMonth;
                    _selectedYear = selectedYear;
                    _page = 0;
                    _hasMore = true;
                  });
                  _fetchCommandes();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  //  Ajouter cette fonction pour supprimer une commande de la liste
  void _removeCommande(String commandeId) {
    setState(() {
      _commandes.removeWhere((commande) => commande.id == commandeId);
      _updateFilteredCommandes(); // Mise à jour après suppression
    });
  }

  Color _getBorderColor(Commande commande) {
    if (commande.daterdv == null || commande.daterdv!.isEmpty) {
      return _getStatutColor(commande.status ?? '');
    }

    try {
      // Extraction des composants de la date
      List<String> dateParts =
          commande.daterdv!.split('-'); // Sépare l'année, le mois et le jour

      if (dateParts.length != 3) {
        print("Format de date incorrect: ${commande.daterdv}");
        return _getStatutColor(
            commande.status ?? ''); // Gérer le format incorrect
      }

      int year = int.parse(dateParts[0]);
      int month = int.parse(dateParts[1]);
      int day = int.parse(dateParts[2]);

      // Création de l'objet DateTime (à 00:00:00 par défaut)
      DateTime dateRDV = DateTime(year, month, day);
      DateTime now = DateTime.now();

      if (now.isAfter(dateRDV) && (commande.status ?? '') != "TERMINER") {
        return Color.fromARGB(
            255, 238, 219, 217); // Date dépassée et commande non terminée
      } else {
        return Theme.of(context)
            .colorScheme
            .surface; // Couleur par défaut du statut
      }
    } catch (e) {
      print(
          "Erreur lors de la conversion de la date: $e, dateRDV = ${commande.daterdv}");
      return _getStatutColor(commande.status ??
          ''); // Retourner la couleur du statut en cas d'erreur
    }
  }

  void _updateCommandeInList(Commande updatedCommande) {
    setState(() {
      final index = _commandes.indexWhere((c) => c.id == updatedCommande.id);
      if (index != -1) {
        _commandes[index] = updatedCommande;
      }
      _updateFilteredCommandes(); // Mettre à jour la liste filtrée
    });
  }

  Widget _buildCommandeList(List<Commande> commandes) {
    return commandes.isEmpty
        ? const Center(
            child: Text(
              "Aucune commande trouvée.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
        : ListView.builder(
            controller: _scrollController,
            itemCount: commandes.length + (_hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < commandes.length) {
                final commande = commandes[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommandeDetailsPage(
                          commande: commande,
                          onCommandeAnnulee: _removeCommande,
                          onCommandeUpdated: _updateCommandeInList,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    // color: Theme.of(context).colorScheme.surface,
                    color: _getBorderColor(commande),
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                            //
                            //// Utiliser la fonction pour la couleur,
                            color: _getStatutColor(commande.status ?? ''),
                            width: 0.5.w)),
                    child: Padding(
                      padding: EdgeInsets.all(2.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Ref: ${commande.reference}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10.sp,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).colorScheme.background,
                                  border: Border.all(
                                      color: _getStatutColor(
                                          commande.status ?? '')),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: 0.5.h),
                                child: Text(
                                  commande.status ?? '',
                                  style: TextStyle(
                                    color:
                                        _getStatutColor(commande.status ?? ''),
                                    fontSize: 10
                                        .sp, // Ajustez la taille selon vos besoins
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: commande.tissus != null &&
                                        commande.tissus!.isNotEmpty &&
                                        commande.tissus![0].fichiersTissus !=
                                            null &&
                                        commande.tissus![0].fichiersTissus!
                                            .isNotEmpty
                                    ? Image.network(
                                        commande.tissus![0].fichiersTissus![0]
                                            .urlfichier!,
                                        width: 10.h,
                                        height: 22.w,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        'assets/image/logo2.png',
                                        width: 10.h,
                                        height: 22.w,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Prix: ${commande.prix ?? 0} CFA',
                                      style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    SizedBox(height: 0.5.h),
                                    Text(
                                      'Client: ${commande.proprietaire?.client?.nom ?? "Inconnu"}',
                                      style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    SizedBox(height: 0.5.h),
                                    Text(
                                      'Pour: ${commande.proprietaire?.proprio ?? "Inconnu"}',
                                      style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    SizedBox(height: 0.5.h),
                                    Text(
                                      'Date RDV: ${commande.daterdv ?? "Inconnu"}',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 4,
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        color: Colors.grey, size: 10.sp),
                                    SizedBox(width: 0.5.w),
                                    Text(
                                      'Créée le : ${dateFormat.format(commande.datecreation!)}',
                                      style: TextStyle(
                                          fontSize: 8.sp, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    Container(
                                      // child: InkWell(
                                      //   onTap: () {
                                      //     Navigator.push(
                                      //       context,
                                      //       MaterialPageRoute(
                                      //         builder: (context) =>
                                      //             CommandeDetailsPage(
                                      //                 commande: commande,
                                      //                 onCommandeAnnulee:
                                      //                     _removeCommande),
                                      //       ),
                                      //     );
                                      //   },
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 1.w),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 0.5.h),
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Color.fromARGB(255, 206, 136,
                                                5), // Couleur de la bordure
                                            width:
                                                0.4.w, // Largeur de la bordure
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Voir plus",
                                            style: TextStyle(
                                              fontSize: 8.sp,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 1,
                                              color: Color.fromARGB(
                                                  255, 206, 136, 5),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // ),
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
                );
              } else {
                return _buildLoadingIndicator();
              }
            },
          );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: _loadingMore
              ? CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.tertiary)
              : null,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: LogoWidget(),
        backgroundColor: Theme.of(context).colorScheme.background,
        actions: [
          IconButton(
            icon: Icon(
              Icons.calendar_month,
              size: 20.sp,
              // color: Color.fromARGB(255, 206, 136, 5),
            ),
            onPressed: () => _selectDate(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Color.fromARGB(255, 206, 136, 5),
          indicatorColor: Color.fromARGB(255, 206, 136, 5),
          onTap: (index) {
            // Suppression de _fetchInitialCommandes() ici
          },
          tabs: [
            // Notez qu'on utilise [] et non const []
            Tab(
              child: Text(
                'TOUT',
                style: TextStyle(
                    fontSize: 10.sp), // Définissez la taille de la police ici
              ),
            ),
            Tab(
              child: Text(
                'CREER',
                style: TextStyle(fontSize: 10.sp),
              ),
            ),
            Tab(
              child: Text(
                'ENCOUR',
                style: TextStyle(fontSize: 10.sp),
              ),
            ),
            Tab(
              child: Text(
                'TERMINER',
                style: TextStyle(fontSize: 10.sp),
              ),
            ),
            Tab(
              child: Text(
                'LIVRER',
                style: TextStyle(fontSize: 10.sp),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(1.h),
                    title: Container(
                      height: 10.sp,
                      width: 40.w,
                      color: Colors.white,
                    ),
                    subtitle: Container(
                      height: 8.sp,
                      width: 20.w,
                      color: Colors.white,
                      margin: EdgeInsets.only(top: 0.5.h),
                    ),
                    leading: Container(
                      width: 10.w,
                      height: 10.w,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                      _updateFilteredCommandes();
                    },
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                        decoration: TextDecoration.none,
                        fontSize: 10.sp),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.primary,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            10), // même rayon que ClipRRect
                        borderSide: BorderSide(
                          color: Color.fromARGB(
                              255, 206, 136, 5), // Couleur de la bordure
                          width: 0.4.w, // Largeur de la bordure
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 206, 136, 5),
                          width: 0.4.w,
                        ), // Couleur de la bordure lorsqu'elle est en état de focus
                      ),
                      hintText: 'Rechercher une commande...',
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 10.sp,
                      ),
                      prefixIcon: const Icon(Icons.search),
                      prefixIconColor: Theme.of(context).colorScheme.secondary,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCommandeList(_filteredCommandes),
                      _buildCommandeList(_filteredCommandes),
                      _buildCommandeList(_filteredCommandes),
                      _buildCommandeList(_filteredCommandes),
                      _buildCommandeList(_filteredCommandes),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
