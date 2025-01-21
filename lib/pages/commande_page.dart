import 'dart:convert';

import 'package:Metre/models/commande_model.dart';
import 'package:Metre/widgets/CustomSnackBar.dart';
import 'package:Metre/widgets/logo.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'commande_detail_page.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CommandePage extends StatefulWidget {
  @override
  _CommandePageState createState() => _CommandePageState();
}

class _CommandePageState extends State<CommandePage>
    with SingleTickerProviderStateMixin {
  // List<Map<String, dynamic>> _commandes = [];
  List<Commande> _commandes = [];
  late TabController _tabController;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true; // Ajout d'un état de chargement
  String? _id;
  String? _token;

  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

  @override
  void initState() {
    super.initState();
    _loadUserData().then((_) {
      _fetchCommandes();
    });
    _tabController = TabController(length: 5, vsync: this);
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _id = prefs.getString('id');
      _token = prefs.getString('token');
    });
  }

  Future<void> _fetchCommandes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_id != null) {
        final String url =
            'http://192.168.56.1:8010/api/commandes/getByUser/$_id';

        if (_token != null) {
          final response = await http.get(
            Uri.parse(url),
            headers: {'Authorization': 'Bearer $_token'},
          );
          if (response.statusCode == 202) {
            final data = json.decode(response.body)['data']['content'];
            // var decodedJson = json.decode(response.body);
            setState(() {
              _commandes = data
                  .map<Commande>((item) => Commande.fromJson(item))
                  .toList();
              _isLoading = false;
            });
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
              message: 'Token invalide', isError: true);
          // _showError('Token invalide');
        }
      } else {
        CustomSnackBar.show(context,
            message: 'L\'identifiant utilisateur est null', isError: true);
        // _showError('L\'identifiant utilisateur est null');
      }
    } catch (e) {
      CustomSnackBar.show(context,
          message: "Une erreur s'est produite : $e", isError: true);
      // _showError("Une erreur s'est produite : $e");
      // print("Une erreur s'est produite : $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.red,
    ));
  }

  // Filtrer les commandes par statut
  List<Commande> _filterCommandes(String statut) {
    List<Commande> filtered = statut == "Tout"
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
                  .contains(searchQuery.toLowerCase()))
          .toList();
    }
    return filtered;
  }

  // Fonction pour afficher la couleur en fonction du statut
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
      default:
        return Colors.grey;
    }
  }

  Widget _buildCommandeList(List<Commande> filteredCommandes) {
    return filteredCommandes.isEmpty
        ? const Center(
            child: Text(
              "Aucune commande trouvée.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
        : ListView.builder(
            itemCount: filteredCommandes.length,
            itemBuilder: (context, index) {
              final commande = filteredCommandes[index];
              return Card(
                color: Theme.of(context).colorScheme.surface,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nouveau titre pour la carte
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ref: ${commande.reference}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.background,
                              border: Border.all(
                                  color:
                                      _getStatutColor(commande.status ?? '')),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 3.5.w, vertical: 1.h),
                            child: Text(
                              commande.status ?? '',
                              style: TextStyle(
                                color: _getStatutColor(commande.status ?? ''),
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
                                    commande
                                        .tissus![0].fichiersTissus!.isNotEmpty
                                ? Image.network(
                                    commande.tissus![0].fichiersTissus![0]
                                        .urlfichier!,
                                    width: 10.h,
                                    height: 20.w,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    'assets/image/logo2.png',
                                    width: 10.h,
                                    height: 20.w,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(height: 0.8.h),
                              Text(
                                '${commande.prix ?? 0} CFA',
                                style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.tertiary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    color: Colors.grey, size: 14.sp),
                                SizedBox(width: 0.5.w),
                                Text(
                                  'Créée le : ${dateFormat.format(commande.datecreation!)}',
                                  style: TextStyle(
                                      fontSize: 10.sp, color: Colors.grey),
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
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 1.w),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 0.5.h),
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Color.fromARGB(255, 206, 136,
                                              5), // Couleur de la bordure
                                          width: 0.4.w, // Largeur de la bordure
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Voir plus",
                                          style: TextStyle(
                                            fontSize: 10.sp,
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
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: LogoWidget(),
        backgroundColor: Theme.of(context).colorScheme.background,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Color.fromARGB(255, 206, 136, 5),
          indicatorColor: Color.fromARGB(255, 206, 136, 5),
          tabs: const [
            Tab(text: 'Tout'),
            Tab(text: 'CREER'),
            Tab(text: 'ENCOUR'),
            Tab(text: 'TERMINER'),
            Tab(text: 'LIVRER'),
          ],
        ),
      ),
      body: _isLoading
          // ? const Center(
          //     child: CircularProgressIndicator(),
          //   )
          ? ListView.builder(
              itemCount: 5, // Nombre de skeleton items à afficher
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
                        borderRadius: BorderRadius.circular(
                            15), // même rayon que ClipRRect
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCommandeList(_filterCommandes("Tout")),
                      _buildCommandeList(_filterCommandes("CREER")),
                      _buildCommandeList(_filterCommandes("ENCOUR")),
                      _buildCommandeList(_filterCommandes("TERMINER")),
                      _buildCommandeList(_filterCommandes("LIVRER")),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
