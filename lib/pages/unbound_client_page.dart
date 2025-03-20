import 'dart:convert';

import 'package:Metre/models/utilisateur_model.dart';
import 'package:Metre/services/CustomIntercepter.dart';
import 'package:Metre/widgets/CustomSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class UnboundClientPage extends StatefulWidget {
  const UnboundClientPage({super.key});

  @override
  State<UnboundClientPage> createState() => _UnboundClientPageState();
}

class _UnboundClientPageState extends State<UnboundClientPage> {
  ClientModel? user;
  bool isActive = false;
  bool isDeleted = false;

  List<ClientModel> listeDesClients = [];
  List<ClientModel> displayedListe = [];
  final http.Client client = CustomIntercepter(http.Client());
  bool isLoading = true; // Indicateur de chargement
  bool isLoadingMore =
      false; // Indicateur de chargement des pages supplémentaires
  bool isLastPage = false; // Indicateur si nous avons atteint la dernière page

  int currentPage = 0; // La page actuelle
  int pageSize = 10; // Le nombre d'éléments à afficher par page
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose(); // N'oublie pas de libérer le contrôleur
    super.dispose();
  }

  String? _id;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadUserData().then((_) {
      _fetchClients(); // Charger les clients après avoir récupéré l'ID et le token
    });

    // Ajouter un écouteur pour le défilement
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _fetchClients(); // Charger plus de clients lorsque l'utilisateur atteint la fin de la liste
      }
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _id = prefs.getString('id');
      _token = prefs.getString('token');
    });
  }

  Future<void> _fetchClients() async {
    if (isLoadingMore || isLastPage)
      return; // Ne pas faire de requête si on charge déjà ou si on a atteint la dernière page

    setState(() {
      isLoadingMore = true;
    });

    try {
      final response = await client.get(
        Uri.parse(
            "http://192.168.56.1:8010/user/getallclientninlies/client/$_id?page=$currentPage&size=$pageSize"),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 202) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> clients = data['data']['content'];

        setState(() {
          if (clients.isNotEmpty) {
            listeDesClients.addAll(
                clients.map((client) => ClientModel.fromJson(client)).toList());
            displayedListe = List.from(listeDesClients);
            currentPage++;
          } else {
            isLastPage = true; // Aucun autre client à charger
          }
        });
      } else {
        throw Exception("Erreur lors de la récupération des clients");
      }
    } catch (e) {
      print("Erreur: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la récupération des clients")),
      );
    } finally {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  void updateListe(String value) {
    setState(() {
      displayedListe = listeDesClients.where((element) {
        final fullName = "${element.nom}";
        final searchTerms = value.toLowerCase().split(' ');
        bool containsAllSearchTerms = true;
        for (final term in searchTerms) {
          containsAllSearchTerms = containsAllSearchTerms &&
              (element.nom!.toLowerCase().contains(term));
        }
        return containsAllSearchTerms ||
            fullName.toLowerCase().contains(value.toLowerCase()) ||
            element.username!.toLowerCase().contains(value.toLowerCase());
      }).toList();
    });
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
          'listes des clients non ajouter',
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: EdgeInsets.all(2.h),
          child: TextField(
            onChanged: (value) => updateListe(value),
            style: TextStyle(
                color: Theme.of(context).colorScheme.tertiary,
                decoration: TextDecoration.none,
                fontSize: 12.sp),
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).colorScheme.primary,
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(15), // même rayon que ClipRRect
                borderSide: BorderSide(
                  color:
                      Color.fromARGB(255, 206, 136, 5), // Couleur de la bordure
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
              hintText: "Rechercher un client...",
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 10.sp,
              ),
              prefixIcon: Icon(Icons.search),
              prefixIconColor: Theme.of(context).colorScheme.secondary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 1.h),
            ),
          ),
        ),
        Expanded(
          child: isLoading
              ? ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      margin:
                          EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
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
              : displayedListe.isEmpty
                  ? Center(
                      child: Text(
                        "Aucun résultat trouvé !",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller:
                          _scrollController, // Ajouter le contrôleur de défilement
                      itemCount: displayedListe.length + (isLastPage ? 0 : 1),
                      itemBuilder: (context, index) {
                        if (index == displayedListe.length) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        final collaborator = displayedListe[index];
                        return Card(
                          elevation: 3,
                          margin: EdgeInsets.symmetric(
                              vertical: 1.5.h, horizontal: 3.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: new BorderSide(
                                color: Color.fromARGB(255, 206, 136, 5),
                                width: 1.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(4.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor:
                                          Color.fromARGB(255, 206, 136, 5),
                                      radius: 4.w,
                                      child: Text(
                                        collaborator.nom != null &&
                                                collaborator.nom!.isNotEmpty
                                            ? collaborator.nom!
                                                .substring(0, 1)
                                                .toUpperCase()
                                            : "N", // Met une lettre par défaut si le nom est nul ou vide
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 10.sp,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      collaborator.nom ?? "nom",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10.sp,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      collaborator.isActive == true
                                          ? "Activé"
                                          : "Déactivé",
                                      style: TextStyle(
                                          fontSize: 10.sp, color: Colors.grey),
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      collaborator.isDeleted == true
                                          ? "Supprimer"
                                          : "",
                                      style: TextStyle(
                                          fontSize: 10.sp, color: Colors.red),
                                    )
                                  ],
                                ),
                                SizedBox(height: 1.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Column(
                                        children: [
                                          Text(
                                            'Numéro : ${collaborator.username}',
                                            style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 10.sp),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        children: [
                                          Container(
                                            // margin: EdgeInsets.only(right: 2.h),
                                            child: InkWell(
                                              onTap: () async {
                                                final response =
                                                    await client.post(
                                                  Uri.parse(
                                                      "http://192.168.56.1:8010/user/addClientToUser/$_id/${collaborator.id}"),
                                                  headers: {
                                                    // "Authorization": "Bearer $_token",
                                                  },
                                                );

                                                if (response.statusCode ==
                                                    202) {
                                                  final responseData =
                                                      jsonDecode(response.body);
                                                  CustomSnackBar.show(context,
                                                      message:
                                                          '${responseData['message']}',
                                                      isError: false);
                                                  setState(() {
                                                    listeDesClients.remove(
                                                        collaborator); // Retirer le client de la liste affichée
                                                    displayedListe = List.from(
                                                        listeDesClients);
                                                  });
                                                } else {
                                                  final responseData =
                                                      jsonDecode(response.body);
                                                  CustomSnackBar.show(context,
                                                      message:
                                                          '${responseData['message']}',
                                                      isError: false);
                                                  // ScaffoldMessenger.of(context)
                                                  //     .showSnackBar(
                                                  //   SnackBar(
                                                  //       content: Text(
                                                  //           "Erreur lors de l'ajout du client")),
                                                  // );
                                                }
                                              },
                                              child: Container(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 3.w),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 0.5.h),
                                                decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: Color.fromARGB(
                                                        255,
                                                        206,
                                                        136,
                                                        5), // Couleur de la bordure
                                                    width: 0.4
                                                        .w, // Largeur de la bordure
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    "Ajouter",
                                                    style: TextStyle(
                                                      fontSize: 8.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      // letterSpacing: 2,
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
                    ),
        ),
      ]),
    );
  }
}
