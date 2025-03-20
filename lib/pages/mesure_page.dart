import 'dart:async';
import 'dart:convert';
import 'package:Metre/models/clients_model.dart';
import 'package:Metre/models/user_model.dart';
import 'package:Metre/models/utilisateur_model.dart';
import 'package:Metre/pages/add_mesure_page.dart';
import 'package:Metre/pages/login_page.dart';
import 'package:Metre/services/CustomIntercepter.dart';
import 'package:Metre/widgets/CustomSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:Metre/pages/detail_mesure_page.dart';
import 'package:Metre/widgets/logo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class MesurePage extends StatefulWidget {
  const MesurePage({Key? key}) : super(key: key);

  @override
  State<MesurePage> createState() => _MesurePageState();
}

class _MesurePageState extends State<MesurePage> {
  Utilisateur_model? user;
  bool isActive = false;
  bool isDeleted = false;

  List<UtilisateurModel> listeDesClients = [];
  List<UtilisateurModel> displayedListe = [];
  final http.Client client = CustomIntercepter(http.Client());
  bool isLoading = true; // Indicateur de chargement
  bool isLoadingMore =
      false; // Indicateur de chargement des pages supplémentaires
  bool isLastPage = false; // Indicateur si nous avons atteint la dernière page

  int currentPage = 0; // La page actuelle
  int pageSize = 10; // Le nombre d'éléments à afficher par page
  final ScrollController _scrollController = ScrollController();

  String? _id;
  String? _token;
  String? _refreshToken;
  Timer? _refreshTimer; // Timer pour le rafraîchissement du token

  @override
  void initState() {
    super.initState();
    _loadUserData().then((_) {
      _fetchClients();
      _scrollController.removeListener(
          _onScroll); // Retirer le listener à la destruction du widget
      // if (_refreshToken != null) {
      //   _startTokenRefreshTimer(_refreshToken!); // Démarrer le timer
      // }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Appeler _refreshCommande ici pour charger les données à chaque fois que le widget revient en premier plan
    _fetchClients(); // Appel à la récupération des clients chaque fois que la page est visible
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _id = prefs.getString('id');
      _token = prefs.getString('token');
      _refreshToken =
          prefs.getString('refreshToken'); // Charger le refreshToken
    });
  }

  Future<void> _fetchClients({bool isLoadMore = false}) async {
    if (_id != null) {
      final url = 'http://192.168.56.1:8010/user/getallclient/client/$_id';

      setState(() {
        if (isLoadMore) {
          isLoadingMore = true;
        } else {
          isLoading = true;
        }
      });

      try {
        final response = await client.get(
          Uri.parse(url),
          headers: {
            // 'Authorization': 'Bearer $_token'
          },
        );

        if (response.statusCode == 202) {
          final data = jsonDecode(response.body);
          final clientsData = data['data'] as List;

          if (clientsData.isNotEmpty) {
            setState(() {
              listeDesClients.addAll(clientsData
                  .map((clientJson) => UtilisateurModel.fromJson(clientJson))
                  .toList());
              displayedListe = List.from(listeDesClients);
              currentPage++; // Incrémenter la page
              isLastPage = clientsData.length <
                  pageSize; // Si moins d'éléments que pageSize, dernière page
              isLoading = false;
              isLoadingMore = false;
            });
          } else {
            setState(() {
              isLastPage = true; // Aucune donnée supplémentaire à charger
              isLoadingMore = false;
            });
          }
        } else {
          CustomSnackBar.show(context,
              message: 'Erreur lors du chargement des clients.', isError: true);
          setState(() {
            isLoading = false; // Fin du chargement même en cas d'erreur
          });
        }
      } catch (e) {
        // print('Error: $e');

        CustomSnackBar.show(context,
            message:
                'Une erreur s\'est produite. Veuillez vérifier votre connexion.',
            isError: true);
      } finally {
        setState(() {
          isLoading = false;
          isLoadingMore = false;
        });
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !isLastPage &&
        !isLoadingMore) {
      _fetchClients(isLoadMore: true); // Charger plus de clients
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

  Future<void> _getUserById(String token) async {
    final url = 'http://192.168.56.1:8010/user/loadById/$_id';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 202) {
        final jsonData = json.decode(response.body)['data'];

        Utilisateur_model utilisateur = Utilisateur_model.fromJson(jsonData);
        bool active = utilisateur.isActive;
        bool deleted = utilisateur.isDeleted;

        // Vérifier si le widget est monté avant d'appeler setState
        if (mounted) {
          setState(() {
            user = utilisateur;
            isActive = active;
            isDeleted = deleted;
          });
        }

        if (!isActive || isDeleted) {
          if (mounted) {
            // Utiliser un délai pour s'assurer que la navigation est bien déclenchée
            Future.delayed(Duration.zero, () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            });
          }

          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();

          if (mounted) {
            CustomSnackBar.show(
              context,
              message: 'Désolé, votre compte a été supprimé ou désactivé !',
              isError: false,
            );
          }
        }
      } else {
        if (mounted) {
          CustomSnackBar.show(
            context,
            message:
                'Une erreur s\'est produite. Veuillez vérifier votre connexion.',
            isError: true,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context,
          message:
              'Une erreur s\'est produite. Veuillez vérifier votre connexion.',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: LogoWidget(),
        backgroundColor: Theme.of(context)
            .colorScheme
            .background, // Changez cette couleur selon vos besoins
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
          child:
              isLoading // Affichage du skeleton loader si les données sont en cours de chargement
                  ? ListView.builder(
                      itemCount: 10, // Nombre de skeleton items à afficher
                      itemBuilder: (context, index) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          margin: EdgeInsets.symmetric(
                              vertical: 1.h, horizontal: 5.w),
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
                            "Aucun résultat trouvé ! ",
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700),
                          ),
                        )
                      : ListView.builder(
                          itemCount: displayedListe.length,
                          itemBuilder: (context, index) {
                            final collaborator = displayedListe[index];
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailMesurePage(
                                      // client: displayedListe[index],
                                      clientId: displayedListe[index].id!,
                                      onClientDeleted: (String clientId) {
                                        setState(() {
                                          listeDesClients.removeWhere(
                                              (client) =>
                                                  client.id == clientId);
                                          displayedListe.removeWhere((client) =>
                                              client.id == clientId);
                                        });
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 3,
                                margin: EdgeInsets.symmetric(
                                    vertical: 1.5.h, horizontal: 3.w),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(4.w),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Color.fromARGB(
                                                255, 206, 136, 5),
                                            radius: 4.w,
                                            child: Text(
                                              collaborator.nom != null &&
                                                      collaborator
                                                          .nom!.isNotEmpty
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
                                                fontSize: 10.sp,
                                                color: Colors.grey),
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            collaborator.isDeleted == true
                                                ? "Supprimer"
                                                : "",
                                            style: TextStyle(
                                                fontSize: 10.sp,
                                                color: Colors.red),
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
                                                SizedBox(height: 1.h),
                                                Row(
                                                  children: [
                                                    Icon(Icons.mark_email_read,
                                                        color: Color.fromARGB(
                                                            255, 206, 136, 5),
                                                        size: 12.sp),
                                                    SizedBox(width: 2.w),
                                                    Text(
                                                      'Email : ${collaborator.email}',
                                                      style: TextStyle(
                                                        color: Colors.grey[800],
                                                        fontSize: 8.sp,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ),
                                                    ),
                                                  ],
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
                                                  // child: InkWell(
                                                  //   onTap: () {
                                                  //     // Action à effectuer lors du tapotement
                                                  //     Navigator.push(
                                                  //       context,
                                                  //       MaterialPageRoute(
                                                  //         builder: (context) =>
                                                  //             DetailMesurePage(
                                                  //           // client: displayedListe[index],
                                                  //           clientId:
                                                  //               displayedListe[
                                                  //                       index]
                                                  //                   .id!,
                                                  //           onClientDeleted:
                                                  //               (String
                                                  //                   clientId) {
                                                  //             setState(() {
                                                  //               listeDesClients.removeWhere(
                                                  //                   (client) =>
                                                  //                       client
                                                  //                           .id ==
                                                  //                       clientId);
                                                  //               displayedListe.removeWhere(
                                                  //                   (client) =>
                                                  //                       client
                                                  //                           .id ==
                                                  //                       clientId);
                                                  //             });
                                                  //           },
                                                  //         ),
                                                  //       ),
                                                  //     );
                                                  //   },
                                                  child: Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 3.w),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 0.5.h),
                                                    decoration: BoxDecoration(
                                                      color: Colors.transparent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
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
                                                        "Voir plus",
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
                          },
                        ),
        ),
      ]),
      floatingActionButton: SizedBox(
        width: 35
            .w, // Ajustez la largeur selon vos besoins (par exemple en utilisant .w pour la rendre responsive)
        height: 5
            .h, // Ajustez la hauteur selon vos besoins (par exemple en utilisant .h pour la rendre responsive)
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddMesurePage(),
              ),
            );
          },
          backgroundColor: Color.fromARGB(255, 206, 136, 5),
          icon: Icon(Icons.add, size: 15.sp),
          label: Text(
            "Ajouter un Client",
            style: TextStyle(fontSize: 8.sp),
          ),
        ),
      ),
    );
  }
}
