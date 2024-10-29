import 'dart:async';
import 'dart:convert';
import 'package:Metre/models/clients_model.dart';
import 'package:Metre/models/user_model.dart';
import 'package:Metre/pages/login_page.dart';
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

  List<ClientsModels> listeDesClients = [];
  List<ClientsModels> displayedListe = [];
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
      if (_refreshToken != null) {
        _startTokenRefreshTimer(_refreshToken!); // Démarrer le timer
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
    if (_id != null && _token != null) {
      final url = 'http://192.168.56.1:8010/clients/getByUser/$_id';

      setState(() {
        if (isLoadMore) {
          isLoadingMore = true;
        } else {
          isLoading = true;
        }
      });

      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {'Authorization': 'Bearer $_token'},
        );

        if (response.statusCode == 202) {
          final data = jsonDecode(response.body);
          final clientsData = data['data']['content'] as List;

          if (clientsData.isNotEmpty) {
            setState(() {
              listeDesClients.addAll(clientsData
                  .map((clientJson) => ClientsModels.fromJson(clientJson))
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
        final fullName = "${element.nom} ${element.prenom}";
        final searchTerms = value.toLowerCase().split(' ');
        bool containsAllSearchTerms = true;
        for (final term in searchTerms) {
          containsAllSearchTerms = containsAllSearchTerms &&
              (element.nom!.toLowerCase().contains(term) ||
                  element.prenom!.toLowerCase().contains(term));
        }
        return containsAllSearchTerms ||
            fullName.toLowerCase().contains(value.toLowerCase()) ||
            element.numero!.toLowerCase().contains(value.toLowerCase());
      }).toList();
    });
  }

  // Fonction pour démarrer le rafraîchissement du token à intervalles réguliers
  void _startTokenRefreshTimer(String refreshToken) {
    _refreshTimer =
        Timer.periodic(Duration(milliseconds: 300000), (timer) async {
      final String url = 'http://192.168.56.1:8010/user/refreshtoken';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String newToken = data['accessToken'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', newToken);

        // _getUserById(newToken);
      } else {
        final message = json.decode(response.body)['message'];
        CustomSnackBar.show(context, message: '$message', isError: true);
      }
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

  // @override
  // void dispose() {
  //   // Annuler le Timer lorsqu'il n'est plus nécessaire
  //   _refreshTimer?.cancel();
  //   super.dispose();
  // }

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
              hintText: "Rechercher",
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 10.sp,
              ),
              prefixIcon: Icon(Icons.search),
              prefixIconColor: Theme.of(context).colorScheme.secondary,
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
                          itemBuilder: (context, index) => Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              border: Border.all(
                                color: Color.fromARGB(
                                    255, 206, 136, 5), // Couleur de la bordure
                                width: 0.4.w, // Largeur de la bordure
                              ),
                              borderRadius:
                                  BorderRadius.circular(5), // Bord arrondi
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 1,
                                  offset: Offset(1, 2), // Shadow position
                                ),
                              ],
                            ),
                            margin: EdgeInsets.symmetric(
                                vertical: 1.h, horizontal: 5.w),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(1.h),
                              title: Text(
                                displayedListe[index].prenom! +
                                    " " +
                                    displayedListe[index].nom!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 9.sp,
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                  Text(
                                    displayedListe[index].numero!,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                      fontSize: 8.sp,
                                    ),
                                  ),
                                  Spacer(), // Ajouter un espace flexible entre les deux éléments

                                  InkWell(
                                    onTap: () {
                                      // Action à effectuer lors du tapotement
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DetailMesurePage(
                                            // client: displayedListe[index],
                                            clientId: displayedListe[index].id!,
                                          ),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 2.h),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 0.5.h, horizontal: 2.w),
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Color.fromARGB(255, 206, 136,
                                              5), // Couleur de la bordure
                                          width: 0.4.w, // Largeur de la bordure
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Voir plus ',
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 206, 136, 5),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 6.sp,
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_forward,
                                            color: Color.fromARGB(
                                                255, 206, 136, 5),
                                            size: 12.sp,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              leading:
                                  Image.asset('assets/image/customer1.png'),
                            ),
                          ),
                        ),
        ),
      ]),
    );
  }
}
