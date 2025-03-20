import 'dart:convert';

import 'package:Metre/models/commande_model.dart';
import 'package:Metre/services/CustomIntercepter.dart';
import 'package:Metre/widgets/CustomSnackBar.dart';
import 'package:Metre/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'commande_detail_page.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CommandeAnnuleePage extends StatefulWidget {
  @override
  _CommandeAnnuleePageState createState() => _CommandeAnnuleePageState();
}

class _CommandeAnnuleePageState extends State<CommandeAnnuleePage> {
  List<Commande> _commandesAnnulees = [];
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

  @override
  void initState() {
    super.initState();
    _loadUserData().then((_) {
      _fetchInitialCommandesAnnulees();
    });
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_isLoading || _loadingMore || !_hasMore) return;
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _fetchMoreCommandesAnnulees();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _id = prefs.getString('id');
      _token = prefs.getString('token');
    });
  }

  Future<void> _fetchInitialCommandesAnnulees() async {
    _page = 0;
    _commandesAnnulees.clear();
    _hasMore = true;
    await _fetchCommandesAnnulees();
  }

  Future<void> _fetchMoreCommandesAnnulees() async {
    if (_loadingMore || !_hasMore) return;
    setState(() {
      _loadingMore = true;
    });
    _page++;
    await _fetchCommandesAnnulees();
    setState(() {
      _loadingMore = false;
    });
  }

  final http.Client client = CustomIntercepter(http.Client());
  Future<void> _fetchCommandesAnnulees() async {
    setState(() {
      if (_page == 0) {
        _isLoading = true;
      }
    });

    try {
      if (_id != null) {
        final String url =
            'http://192.168.56.1:8010/api/commandes/commandes/annulees/$_id?page=$_page&size=$_pageSize&status=ANNULER'; // Filtrer directement à l'API

        final response = await client.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
          },
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body)['data']['content'];
          setState(() {
            List<Commande> newCommandes =
                data.map<Commande>((item) => Commande.fromJson(item)).toList();
            _commandesAnnulees.addAll(newCommandes);
            if (newCommandes.isEmpty || newCommandes.length < _pageSize) {
              _hasMore = false;
            }
            if (_page == 0) {
              _isLoading = false;
            }
          });
        } else {
          var decodedJson = json.decode(response.body);
          _showError("Erreur lors du chargement des commandes annulées");
          CustomSnackBar.show(context,
              message: '${decodedJson['message']}', isError: true);
          print(
              'Erreur lors de la récupération des commandes annulées: ${response.statusCode} : ${response.body}');
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

  List<Commande> _filterCommandes(List<Commande> commandes) {
    // Optimisation : filtrer la liste déjà reçue depuis l'API.
    List<Commande> filtered = commandes;

    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((commande) =>
              commande.daterdv!
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              commande.proprietaire!.client!.nom!
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()))
          .toList();
    }
    return filtered;
  }

  Widget _buildCommandeList(List<Commande> commandes) {
    List<Commande> filteredCommandes =
        _filterCommandes(commandes); // Filtrer ici

    return filteredCommandes.isEmpty
        ? const Center(
            child: Text(
              "Aucune commande annulée trouvée.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
        : ListView.builder(
            controller: _scrollController,
            itemCount: filteredCommandes.length + (_hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < filteredCommandes.length) {
                final commande = filteredCommandes[index];
                return Card(
                  color: Theme.of(context).colorScheme.surface,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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
                                color: Theme.of(context).colorScheme.background,
                                border: Border.all(color: Colors.red),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 0.5.h),
                              child: Text(
                                'ANNULER', // On sait déjà que le statut est "ANNULER"
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10.sp,
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
                                      commande
                                          .tissus![0].fichiersTissus!.isNotEmpty
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
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CommandeDetailsPage(
                                                    commande: commande),
                                          ),
                                        );
                                      },
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
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
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
        automaticallyImplyLeading: true, // Affiche la flèche de retour
        title: Text(
          "Commandes Annulées",
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
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
                    },
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                        decoration: TextDecoration.none,
                        fontSize: 10.sp),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.primary,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 206, 136, 5),
                          width: 0.4.w,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 206, 136, 5),
                          width: 0.4.w,
                        ),
                      ),
                      hintText: 'Rechercher une commande annulée...',
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
                  child: _buildCommandeList(_commandesAnnulees),
                ),
              ],
            ),
    );
  }
}
