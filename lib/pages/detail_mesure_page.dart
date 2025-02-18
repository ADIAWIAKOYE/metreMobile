import 'dart:convert';

import 'package:Metre/models/clients_model.dart';
import 'package:Metre/models/mesure_model.dart';
import 'package:Metre/models/proprioMesures_model.dart';
import 'package:Metre/pages/CreateCommandePage.dart';
import 'package:Metre/pages/add_proprio_mesure_page.dart';
import 'package:Metre/pages/edit_client_page.dart';
import 'package:Metre/services/CustomIntercepter.dart';
import 'package:Metre/widgets/CustomSnackBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:Metre/bottom_navigationbar/navigation_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';

class Item {
  Item({
    required this.expandedValue,
    required this.headerValue,
    this.isExpanded = false,
  });

  String expandedValue;
  String headerValue;
  bool isExpanded;
}

class DetailMesurePage extends StatefulWidget {
  final String clientId;
  const DetailMesurePage({Key? key, required this.clientId}) : super(key: key);

  @override
  State<DetailMesurePage> createState() => _DetailMesurePageState();
}

class _DetailMesurePageState extends State<DetailMesurePage> {
  bool _showDetailClient = true;
  bool _showProprioMesures = true;
  bool _isLoadingp = true;
  bool _isLoading = true;
  late Utilisateur _client;
  late Proprio _proprio;
  bool _isLoadingproprio =
      true; // Ajoutez une variable pour gérer l'état de chargement
  List<ProprietaireMesure> listeDesprorios = [];
  List<ProprietaireMesure> displayedprorios = [];
  final http.Client client = CustomIntercepter(http.Client());

  List<bool> _isExpandedList =
      []; // Liste pour garder l'état d'ouverture de chaque ExpansionTile

  String? _id;
  String? _token;

  @override
  void initState() {
    super.initState();
    // selectedItem = items.first; // Sélectionner la première option par défaut
    _loadUserData().then((_) {
      _fetchClientDetails();
      _fetchProprietaireMesure();
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _id = prefs.getString('id');
      _token = prefs.getString('token');
    });
  }

// pour afficher le client
  Future<void> _fetchClientDetails() async {
    final url = 'http://192.168.56.1:8010/user/loadById/${widget.clientId}';
    try {
      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 202) {
        final data = json.decode(response.body)['data'];
        setState(() {
          _client = Utilisateur.fromJson(data);
          _isLoading = false;
        });
      } else {
        CustomSnackBar.show(context,
            message: 'Échec du chargement du client', isError: true);
      }
    } catch (e) {
      CustomSnackBar.show(context,
          message:
              'Une erreur s\'est produite. Veuillez vérifier votre connexion.',
          isError: true);
    }
  }

  // pour afficher les proprietaire mesure
  Future<void> _fetchProprietaireMesure() async {
    final url =
        'http://192.168.56.1:8010/proprio/getByClients/${widget.clientId}';

    try {
      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $_token'
        },
      );

      if (response.statusCode == 202) {
        final data = jsonDecode(response.body);

        if (data == null ||
            data['data'] == null ||
            data['data']['content'] == null) {
          throw Exception('Contenu JSON manquant ou incorrect');
        }

        final proprioData = data['data']['content'] as List;

        listeDesprorios = proprioData
            .map((proproJson) => ProprietaireMesure.fromJson(proproJson))
            .toList();

        for (var proprietaire in listeDesprorios) {
          final mesureUrl =
              'http://192.168.56.1:8010/mesure/loadByProprio/${proprietaire.id}';
          final mesureResponse = await client.get(
            Uri.parse(mesureUrl),
            headers: {
              'Content-Type': 'application/json',
              // 'Authorization': 'Bearer $_token'
            },
          );

          if (mesureResponse.statusCode == 202) {
            final mesureData = jsonDecode(mesureResponse.body);

            if (mesureData == null || mesureData['data'] == null) {
              CustomSnackBar.show(context,
                  message:
                      'Une erreur s\'est produite.  mesures manquantes ou incorrectes .',
                  isError: true);
            }

            final mesures = (mesureData['data'] as List)
                .map((mesureJson) => Mesure.fromJson(mesureJson))
                .toList();

            proprietaire.mesures = mesures;
          }
          // else {
          //   CustomSnackBar.show(context,
          //       message:
          //           'Une erreur s\'est produite. du chargement des mesures.',
          //       isError: true);
          // }
        }

        setState(() {
          _isLoadingp = false;
          // _isLoadingproprio = false;
        });
      } else {
        CustomSnackBar.show(context,
            message: 'Erreur lors du chargement !', isError: true);
      }
    } catch (e) {
      CustomSnackBar.show(context,
          message:
              'Une erreur s\'est produite. Veuillez vérifier votre connexion.',
          isError: true);
      setState(() {
        _isLoadingp = false;
        // _isLoadingproprio = false;
      });
    }
  }

// pour afficher le proprio
  Future<void> _fetchProprio(String idProprio) async {
    final url = 'http://192.168.56.1:8010/proprio/loadbyid/${idProprio}';
    final response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 202) {
      final data = json.decode(response.body)['data'];
      setState(() {
        _proprio = Proprio.fromJson(data);
        _isLoadingproprio = false;
      });
    } else {
      CustomSnackBar.show(context,
          message: 'Erreur lors du chargement !', isError: true);
    }
  }

  // delete
  Future<void> _delete(String id, String libelleurl) async {
    final url = 'http://192.168.56.1:8010/${libelleurl}/${id}';
    try {
      final response = await client.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 202) {
        setState(() {
          _fetchProprietaireMesure();
        });
        final message = json.decode(response.body)['message'];
        CustomSnackBar.show(context, message: '$message', isError: false);
      } else {
        final message = json.decode(response.body)['message'];
        CustomSnackBar.show(context, message: '$message', isError: true);
      }
    } catch (e) {
      CustomSnackBar.show(context,
          message:
              'Une erreur s\'est produite. Veuillez vérifier votre connexion.',
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            // Navigator.pop(context);
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(builder: (context) => NavigationBarPage()),
            // );
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => NavigationBarPage(
                  initialIndex: 1, // Rediriger vers la page des clients
                ),
              ),
            );
            // Navigator.pop(context, true);
          },
          icon: Icon(
            Icons.keyboard_backspace,
            size: 22.sp,
          ),
        ),
        backgroundColor: Theme.of(context)
            .colorScheme
            .background, // Changez cette couleur selon vos besoins
      ),
      body: ListView(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Centrer le texte
          SizedBox(
            height: 2.h,
          ),
          SizedBox(
            // height: 50,
            width: double.infinity,
            child: Container(
              margin: EdgeInsets.only(left: 1.h, right: 1.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                border: Border.all(
                  color:
                      Color.fromARGB(255, 206, 136, 5), // Couleur de la bordure
                  width: 0.4.w, // Largeur de la bordure
                ),
                borderRadius: BorderRadius.circular(1), // Bord arrondi
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 1,
                    offset: Offset(1, 2), // Shadow position
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.h),
                child: GestureDetector(
                  onTap: () {
                    // Action à effectuer lors du clic sur le texte
                    setState(() {
                      _showDetailClient = !_showDetailClient;
                    });
                  },
                  child: Text(
                    'Les informations personnels Client', // Ajoutez votre texte personnalisé ici
                    textAlign: TextAlign.center, // Centrer le texte
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // ),
          SizedBox(
            height: 2.h,
          ),
          if (_showDetailClient)
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      for (var detail in [
                        {'label': 'Nom', 'value': _client.nom},
                        // {'label': 'Prénom', 'value': _client.prenom},
                        {'label': 'Téléphone', 'value': _client.username},
                        {'label': 'Adresse', 'value': _client.adresse},
                        {'label': 'Email', 'value': _client.email},
                        {'label': 'Profession', 'value': _client.specialite},
                        // {
                        //   'label': 'Créer par',
                        //   'value': _client.utilisateur.nom
                        // },
                      ])
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 0.5.h, horizontal: 3.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${detail['label']}:',
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  '${detail['value']}',
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(
                        height: 0.5.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 0.5.h, right: 1.h),
                            child: InkWell(
                              onTap: () {
                                // print("BUTTON cliqué !");
                                deleteClient();
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 1.w),
                                padding: EdgeInsets.symmetric(
                                    vertical: 0.5.h, horizontal: 1.w),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.red, // Couleur de la bordure
                                    width: 0.4.w, // Largeur de la bordure
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "Supprimer",
                                      style: TextStyle(
                                        fontSize: 8.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 0.5.h),
                                      child: Icon(
                                        Icons.delete_forever,
                                        color: Colors.white,
                                        size: 12.sp,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(right: 2.h),
                            child: InkWell(
                              onTap: () {
                                // print("BUTTON cliqué !");
                                modifierClient();
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 1.w),
                                padding: EdgeInsets.symmetric(
                                    vertical: 0.5.h, horizontal: 2.w),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 206, 136, 5),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Color.fromARGB(255, 206, 136,
                                        5), // Couleur de la bordure
                                    width: 0.4.w, // Largeur de la bordure
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "Modifier",
                                      style: TextStyle(
                                        fontSize: 8.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(left: 5.0),
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 12.sp,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

          // ),
          SizedBox(
            height: 20,
          ),
          SizedBox(
            // height: 50,
            width: double.infinity,
            child: Container(
              margin: EdgeInsets.only(left: 2.h, right: 2.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                border: Border.all(
                  color:
                      Color.fromARGB(255, 206, 136, 5), // Couleur de la bordure
                  width: 0.4.w, // Largeur de la bordure
                ),
                borderRadius: BorderRadius.circular(1), // Bord arrondi
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 1,
                    offset: Offset(1, 2), // Shadow position
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                child: Text(
                  'les Mésures du client', // Ajoutez votre texte personnalisé ici
                  textAlign: TextAlign.center, // Centrer le texte
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ),
            ),
          ),
// ici la liste des mesures
          SizedBox(height: 2.h),
          if (_showProprioMesures)
            _isLoadingp
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: listeDesprorios.length,
                    itemBuilder: (BuildContext context, int index) {
                      final mesure = listeDesprorios[index];
                      if (_isExpandedList.length <= index) {
                        _isExpandedList.add(false);
                      }
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 1.h, horizontal: 4.w),
                        child: Card(
                          elevation: 2, // Ombre légère pour le card
                          shadowColor: Color.fromARGB(255, 206, 136, 5),
                          // margin: EdgeInsets.all(
                          //     0), // Marges nulle pour éviter les bordures autour du Card
                          color: Theme.of(context).colorScheme.background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          margin: EdgeInsets.symmetric(
                              vertical: 1.h), // Marge verticale autour du Card
                          child: ExpansionTile(
                            key:
                                GlobalKey(), // Clé globale pour gérer l'état de cet ExpansionTile
                            initiallyExpanded: _isExpandedList[index],
                            tilePadding: EdgeInsets.symmetric(horizontal: 4.w),
                            title: Row(
                              children: [
                                Text(
                                  mesure.proprio ?? 'Sans Nom',
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    setState(() {
                                      _isLoadingproprio = true;
                                    });
                                    await _fetchProprio(mesure.id ?? 'Sans id');
                                    if (!_isLoadingproprio) {
                                      modifierProprio();
                                    }
                                    // print(
                                    //     'Vous allez modifier le nom du proprietaire !');
                                  },
                                  icon: Icon(
                                    Icons.edit,
                                    size: 14.sp,
                                    color: Color.fromARGB(255, 206, 136, 5),
                                  ),
                                ),

                                // :::::::::::::::::::
                                Container(
                                  margin: EdgeInsets.only(right: 0.5.h),
                                  child: InkWell(
                                    onTap: () {
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) =>
                                      //         CreateCommandePage(),
                                      //   ),
                                      // );
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CreateCommandePage(
                                            // client: displayedListe[index],
                                            proprioId: mesure.id!,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 1.w),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 0.5.h, horizontal: 2.w),
                                      decoration: BoxDecoration(
                                        color: Color.fromARGB(255, 206, 136, 5),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Color.fromARGB(255, 206, 136,
                                              5), // Couleur de la bordure
                                          width: 0.4.w, // Largeur de la bordure
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            "Commander",
                                            style: TextStyle(
                                                fontSize: 8.sp,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white),
                                          ),
                                          // Container(
                                          //   margin:
                                          //       EdgeInsets.only(left: 0.5.h),
                                          //   child: Icon(
                                          //     Icons.add_circle,
                                          //     color: Color.fromARGB(
                                          //         255, 206, 136, 5),
                                          //     size: 12.sp,
                                          //   ),
                                          // )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // ::::::::::::::::::::::
                              ],
                            ),
                            collapsedTextColor:
                                Theme.of(context).colorScheme.tertiary,
                            textColor: Theme.of(context).colorScheme.tertiary,
                            iconColor: Theme.of(context).colorScheme.tertiary,
                            childrenPadding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                            ),
                            children: [
                              for (var mesureS in mesure.mesures)
                                // Padding(
                                //   padding: EdgeInsets.symmetric(
                                //       vertical: 0
                                //           .h), // Ajuster ici pour réduire l'espacement
                                //   child:
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Text(
                                        '${mesureS.libelle} :',
                                        style: TextStyle(
                                          fontSize: 8.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        '${mesureS.valeur}',
                                        style: TextStyle(
                                          fontSize: 8.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: IconButton(
                                        onPressed: () {
                                          _delete(mesureS.id ?? 'Sans id',
                                              'mesure/supprimer');
                                        },
                                        icon: Icon(
                                          Icons.delete,
                                          size: 14.sp,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              // ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 1.h),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: 0.5.h, right: 1.h),
                                      child: InkWell(
                                        onTap: () {
                                          // print("BUTTON cliqué !");
                                          _delete(mesure.id ?? 'Sans id',
                                              'proprio/supprimer');
                                          // setState(() {
                                          //   _fetchProprietaireMesure();
                                          // });
                                        },
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 0.5.w),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 0.5.h, horizontal: 1.w),
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: Colors
                                                  .red, // Couleur de la bordure
                                              width: 0.4
                                                  .w, // Largeur de la bordure
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                "Supprimer",
                                                style: TextStyle(
                                                  fontSize: 8.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red,
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(
                                                    left: 0.5.h),
                                                child: Icon(
                                                  Icons.delete_forever,
                                                  color: Colors.red,
                                                  size: 12.sp,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(right: 0.5.h),
                                      child: InkWell(
                                        onTap: () {
                                          addmesure(mesure.id ?? "not id");
                                          // print(
                                          //     "BUTTON cliqué ! ajouter mesure");
                                        },
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 1.w),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 0.5.h, horizontal: 2.w),
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: Color.fromARGB(
                                                  255,
                                                  206,
                                                  163,
                                                  5), // Couleur de la bordure
                                              width: 0.4
                                                  .w, // Largeur de la bordure
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                "Ajouter un mesure",
                                                style: TextStyle(
                                                  fontSize: 8.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                      255, 206, 136, 5),
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(
                                                    left: 0.5.h),
                                                child: Icon(
                                                  Icons.add_circle,
                                                  color: Color.fromARGB(
                                                      255, 206, 136, 5),
                                                  size: 12.sp,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

          SizedBox(
            height: 2.h,
          ),
          Container(
            margin: EdgeInsets.only(left: 0.5.h, right: 1.h),
            child: InkWell(
              onTap: () {
                // showBottomSheet(context);
                //   // print("BUTTON cliqué !");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddProprioMesurePage(clientId: widget.clientId),
                  ),
                ).then((value) {
                  if (value == true) {
                    setState(() {
                      _fetchProprietaireMesure();
                    });
                  }
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Ajouter un autre mesure pour ce client ",
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 206, 136, 5),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 5.0),
                    child: Icon(
                      Icons.add_circle,
                      color: Color.fromARGB(255, 206, 136, 5),
                      size: 14.sp,
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 2.h,
          ),
        ],
      ),
    );
  }

// ajouter un nouveau proprietaireMesure et mesure

  // List<String> items = [
  //   'Longueur_Pantalon',
  //   'Toure_Ceinture',
  //   'Toure_Fesse',
  //   'Toure_Cuisse',
  //   'Toure_Patte',
  //   'Longueur_Chemise',
  //   'Longueur_Boubou',
  //   'Toure_Poitrine',
  //   'Epaule',
  //   'Manche.Long',
  //   'Manche.Courte',
  //   'Toure_Manche',
  //   'Encolure'
  // ]; // Options du DropdownButton
  // String? selectedItem; // Valeur sélectionnée du DropdownButton

  // bool isOwnerFilled = false;
  // bool isTextFieldWidgetAdded = false;
  // bool isAddButtonEnabled = false;
  // String? textFieldValue; // Définir la variable textFieldValue
  // List<String> selectedItems = []; // Définir la liste selectedItems
  // TextEditingController textFieldController =
  //     TextEditingController(); // Contrôleur de champ de texte

  // // Déclarez textFieldsControllers pour stocker les contrôleurs de champ de texte
  // Map<String, TextEditingController> textFieldsControllers = {};
  // Map<String, String> textFieldsValues =
  //     {}; // Déclaration de la variable textFieldsValues
  // List<Widget> textFieldsWidgets =
  //     []; // Liste pour stocker les widgets des champs de texte dynamiques
  // TextEditingController proprioownerController = TextEditingController();

  // Future<void> sendPostRequest(Map<String, dynamic> body) async {
  //   final response = await client.post(
  //     Uri.parse('http://192.168.56.1:8010/proprio/ajouter'),
  //     headers: {
  //       'Content-Type': 'application/json',
  //       // 'Authorization':
  //       //     'Bearer $_token', // Assurez-vous que $_token est défini et valide
  //     },
  //     body: json.encode(body),
  //   );

  //   if (response.statusCode == 202) {
  //     // final responseData = jsonDecode(response.body);
  //     // print('Mise à jour réussie: ${responseData['message']}');
  //     // print('Données mises à jour: ${responseData['data']}');
  //     // Afficher un message de succès
  //     CustomSnackBar.show(context,
  //         message: 'Mesure ajoutée avec succès.', isError: false);
  //     ;
  //   } else if (response.statusCode == 400) {
  //     final responseData = jsonDecode(response.body);

  //     String message = responseData['message'];
  //     CustomSnackBar.show(context, message: '$message', isError: true);
  //   } else {
  //     // print('Erreur lors de l\'ajout de la mesure: ${response.statusCode}');
  //     // print('Message: ${response.body}');
  //     // Afficher un message d'erreur
  //     CustomSnackBar.show(context,
  //         message: 'Erreur lors de l\'ajout de la mesure', isError: true);
  //   }
  // }

  // void showBottomSheet(BuildContext context) async {
  //   bool isModalClosed = await showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(
  //         builder: (BuildContext context, StateSetter setModalState) {
  //           // bool isOwnerFilled = false;
  //           bool isTextFieldWidgetAdded = false;

  //           return SizedBox(
  //             height: 52.08.h,
  //             child: ListView(
  //               children: [
  //                 SizedBox(height: 1.h),
  //                 Padding(
  //                   padding: EdgeInsets.all(1.h),
  //                   child: Text(
  //                     'Ajouter un nouveau mesure pour ce client',
  //                     textAlign: TextAlign.center,
  //                     style: TextStyle(
  //                       fontSize: 12.sp,
  //                       fontWeight: FontWeight.bold,
  //                       color: Color.fromARGB(255, 206, 136, 5),
  //                     ),
  //                   ),
  //                 ),
  //                 Padding(
  //                   padding: EdgeInsets.all(0.8.h),
  //                   child: Form(
  //                     child: Column(
  //                       children: <Widget>[
  //                         TextFormField(
  //                           controller: proprioownerController,
  //                           keyboardType: TextInputType.text,
  //                           decoration: InputDecoration(
  //                             prefixIcon: Icon(Icons.location_on),
  //                             prefixIconColor: Colors.transparent,
  //                             hintText: "Entrer nom propriétaire",
  //                             hintStyle: TextStyle(
  //                               color: Color.fromARGB(255, 132, 134, 135),
  //                               fontSize: 10.sp,
  //                             ),
  //                             labelText: "Propriétaire",
  //                             labelStyle: TextStyle(
  //                               color: Color.fromARGB(255, 132, 134, 135),
  //                               fontSize: 8.sp,
  //                             ),
  //                             enabledBorder: OutlineInputBorder(
  //                               borderSide: BorderSide(
  //                                 color: Color.fromARGB(255, 206, 136, 5),
  //                                 width: 0.4.w,
  //                               ),
  //                             ),
  //                             focusedBorder: OutlineInputBorder(
  //                               borderRadius: BorderRadius.circular(10),
  //                               borderSide: BorderSide(
  //                                 color: Color.fromARGB(255, 206, 136, 5),
  //                                 width: 0.4.w,
  //                               ),
  //                             ),
  //                             contentPadding:
  //                                 EdgeInsets.symmetric(vertical: 10),
  //                           ),
  //                           onChanged: (value) {
  //                             setModalState(() {
  //                               isOwnerFilled = value.isNotEmpty;
  //                             });
  //                           },
  //                         ),
  //                         SizedBox(height: 1.h),
  //                         Column(
  //                           crossAxisAlignment: CrossAxisAlignment.stretch,
  //                           children: [
  //                             Row(
  //                               children: [
  //                                 Expanded(
  //                                   flex: 2,
  //                                   child: DropdownButtonFormField<String>(
  //                                     decoration: InputDecoration(
  //                                       prefixIconColor: Colors.transparent,
  //                                       hintText: "Sélectionner",
  //                                       hintStyle: TextStyle(
  //                                         color: Color.fromARGB(
  //                                             255, 132, 134, 135),
  //                                         fontSize: 8.sp,
  //                                       ),
  //                                       labelText: "Sélectionner",
  //                                       labelStyle: TextStyle(
  //                                         color: Color.fromARGB(
  //                                             255, 132, 134, 135),
  //                                         fontSize: 8.sp,
  //                                       ),
  //                                       enabledBorder: OutlineInputBorder(
  //                                         borderSide: BorderSide(
  //                                           color: Color.fromARGB(
  //                                               255, 206, 136, 5),
  //                                           width: 0.4.w,
  //                                         ),
  //                                       ),
  //                                       focusedBorder: OutlineInputBorder(
  //                                         borderRadius:
  //                                             BorderRadius.circular(5),
  //                                         borderSide: BorderSide(
  //                                           color: Color.fromARGB(
  //                                               255, 206, 136, 5),
  //                                           width: 0.4.w,
  //                                         ),
  //                                       ),
  //                                       contentPadding: EdgeInsets.symmetric(
  //                                           horizontal: 1.h),
  //                                     ),
  //                                     value: selectedItem,
  //                                     onChanged: (newValue) {
  //                                       setModalState(() {
  //                                         selectedItem = newValue!;
  //                                         isAddButtonEnabled =
  //                                             (selectedItem != null &&
  //                                                 selectedItem!.isNotEmpty &&
  //                                                 textFieldValue != null &&
  //                                                 textFieldValue!.isNotEmpty &&
  //                                                 !selectedItems
  //                                                     .contains(selectedItem));
  //                                       });
  //                                     },
  //                                     items: items.map((String value) {
  //                                       return DropdownMenuItem<String>(
  //                                         value: value,
  //                                         child: Text(value,
  //                                             style: TextStyle(fontSize: 8.sp)),
  //                                       );
  //                                     }).toList(),
  //                                   ),
  //                                 ),
  //                                 SizedBox(width: 1.w),
  //                                 Expanded(
  //                                   child: TextFormField(
  //                                     onChanged: (value) {
  //                                       setModalState(() {
  //                                         textFieldValue = value;
  //                                         isAddButtonEnabled =
  //                                             (selectedItem != null &&
  //                                                 selectedItem!.isNotEmpty &&
  //                                                 textFieldValue != null &&
  //                                                 textFieldValue!.isNotEmpty &&
  //                                                 !selectedItems
  //                                                     .contains(selectedItem));
  //                                       });
  //                                     },
  //                                     controller: textFieldController,
  //                                     keyboardType: TextInputType.number,
  //                                     decoration: InputDecoration(
  //                                       prefixIconColor: Colors.transparent,
  //                                       hintText: "Valeur",
  //                                       hintStyle: TextStyle(
  //                                         color: Color.fromARGB(
  //                                             255, 132, 134, 135),
  //                                         fontSize: 8.sp,
  //                                       ),
  //                                       labelText: "Valeur",
  //                                       labelStyle: TextStyle(
  //                                         color: Color.fromARGB(
  //                                             255, 132, 134, 135),
  //                                         fontSize: 8.sp,
  //                                       ),
  //                                       enabledBorder: OutlineInputBorder(
  //                                         borderSide: BorderSide(
  //                                           color: Color.fromARGB(
  //                                               255, 206, 136, 5),
  //                                           width: 1.5,
  //                                         ),
  //                                       ),
  //                                       focusedBorder: OutlineInputBorder(
  //                                         borderRadius:
  //                                             BorderRadius.circular(5),
  //                                         borderSide: BorderSide(
  //                                           color: Color.fromARGB(
  //                                               255, 206, 136, 5),
  //                                           width: 0.4.w,
  //                                         ),
  //                                       ),
  //                                       contentPadding: EdgeInsets.symmetric(
  //                                           horizontal: 1.h),
  //                                     ),
  //                                   ),
  //                                 ),
  //                                 IconButton(
  //                                   onPressed: isAddButtonEnabled
  //                                       ? () {
  //                                           setModalState(() {
  //                                             String? dropdownValue =
  //                                                 selectedItem;
  //                                             String textValue =
  //                                                 textFieldController.text;

  //                                             if (dropdownValue != null &&
  //                                                 dropdownValue.isNotEmpty &&
  //                                                 textValue.isNotEmpty &&
  //                                                 !selectedItems.contains(
  //                                                     dropdownValue)) {
  //                                               selectedItems
  //                                                   .add(dropdownValue);

  //                                               String fieldValue =
  //                                                   '$textValue cm';
  //                                               textFieldsControllers[
  //                                                       dropdownValue] =
  //                                                   TextEditingController(
  //                                                       text: textValue);
  //                                               textFieldsValues[
  //                                                   dropdownValue] = fieldValue;

  //                                               textFieldsWidgets.add(
  //                                                 Row(
  //                                                   key: ValueKey(
  //                                                       dropdownValue), // Ajouter une clé unique
  //                                                   children: [
  //                                                     Expanded(
  //                                                       flex: 2,
  //                                                       child: Container(
  //                                                         margin:
  //                                                             EdgeInsets.only(
  //                                                                 left: 1.h),
  //                                                         decoration:
  //                                                             BoxDecoration(
  //                                                           color: Colors.white,
  //                                                           border: Border.all(
  //                                                             color: Color
  //                                                                 .fromARGB(
  //                                                                     255,
  //                                                                     206,
  //                                                                     136,
  //                                                                     5),
  //                                                             width: 0.4.w,
  //                                                           ),
  //                                                           borderRadius:
  //                                                               BorderRadius
  //                                                                   .circular(
  //                                                                       1),
  //                                                         ),
  //                                                         child: Padding(
  //                                                           padding: EdgeInsets
  //                                                               .symmetric(
  //                                                                   horizontal:
  //                                                                       1.w,
  //                                                                   vertical:
  //                                                                       0.8.h),
  //                                                           child: Text(
  //                                                             dropdownValue,
  //                                                             style: TextStyle(
  //                                                                 fontSize:
  //                                                                     10.sp),
  //                                                           ),
  //                                                         ),
  //                                                       ),
  //                                                     ),
  //                                                     SizedBox(width: 1.w),
  //                                                     Expanded(
  //                                                       child: Container(
  //                                                         decoration:
  //                                                             BoxDecoration(
  //                                                           color: Colors.white,
  //                                                           border: Border.all(
  //                                                             color: Color
  //                                                                 .fromARGB(
  //                                                                     255,
  //                                                                     206,
  //                                                                     136,
  //                                                                     5),
  //                                                             width: 0.4.w,
  //                                                           ),
  //                                                           borderRadius:
  //                                                               BorderRadius
  //                                                                   .circular(
  //                                                                       1),
  //                                                         ),
  //                                                         child: Padding(
  //                                                           padding: EdgeInsets
  //                                                               .symmetric(
  //                                                                   horizontal:
  //                                                                       1.w,
  //                                                                   vertical:
  //                                                                       0.8.h),
  //                                                           child: Text(
  //                                                             fieldValue,
  //                                                             style: TextStyle(
  //                                                                 fontSize:
  //                                                                     8.sp),
  //                                                           ),
  //                                                         ),
  //                                                       ),
  //                                                     ),
  //                                                     SizedBox(width: 1.w),
  //                                                     IconButton(
  //                                                       onPressed: () {
  //                                                         setModalState(() {
  //                                                           print(
  //                                                               "Dropdown value to delete: $dropdownValue");
  //                                                           textFieldsWidgets
  //                                                               .removeWhere(
  //                                                                   (widget) {
  //                                                             if (widget
  //                                                                 is Row) {
  //                                                               return widget
  //                                                                       .key ==
  //                                                                   ValueKey(
  //                                                                       dropdownValue);
  //                                                             }
  //                                                             return false;
  //                                                           });

  //                                                           selectedItems.remove(
  //                                                               dropdownValue);
  //                                                           print(
  //                                                               "Selected items after deletion: $selectedItems");
  //                                                         });
  //                                                       },
  //                                                       icon: Icon(
  //                                                         Icons.delete,
  //                                                         size: 20.sp,
  //                                                         color: Colors.red,
  //                                                       ),
  //                                                     ),
  //                                                   ],
  //                                                 ),
  //                                               );

  //                                               textFieldController.clear();
  //                                             }
  //                                           });
  //                                         }
  //                                       : null,
  //                                   icon: Icon(
  //                                     Icons.add_box,
  //                                     size: 30.sp,
  //                                     color: Color.fromARGB(255, 206, 136, 5),
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                             SizedBox(height: 1.h),
  //                             Container(
  //                               decoration: BoxDecoration(
  //                                 border: Border.all(
  //                                   color: Color.fromARGB(255, 206, 136, 5),
  //                                   width: 0.4.w,
  //                                 ),
  //                               ),
  //                               child: Column(
  //                                 children: textFieldsWidgets,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //                 SizedBox(height: 1.h),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     Padding(
  //                       padding: const EdgeInsets.all(8.0),
  //                       child: ElevatedButton(
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: Colors.red,
  //                           foregroundColor: Colors.white,
  //                         ),
  //                         child: Text(
  //                           "Fermer",
  //                           style: TextStyle(
  //                             fontSize: 8.sp,
  //                             letterSpacing: 2,
  //                           ),
  //                         ),
  //                         onPressed: () {
  //                           Navigator.of(context)
  //                               .pop(true); // Fermer le modal et retourner true
  //                         },
  //                       ),
  //                     ),
  //                     Padding(
  //                       padding: EdgeInsets.all(0.8.h),
  //                       child: ElevatedButton(
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: Color.fromARGB(255, 206, 136, 5),
  //                           foregroundColor: Colors.white,
  //                         ),
  //                         child: Text("Ajouter"),
  //                         onPressed: isOwnerFilled || isTextFieldWidgetAdded
  //                             ? () async {
  //                                 Map<String, dynamic> body = {
  //                                   "proprietaireMesures": {
  //                                     "proprio": proprioownerController.text,
  //                                     "client": {
  //                                       "id": widget
  //                                           .clientId // Remplacez par l'ID approprié
  //                                     }
  //                                   },
  //                                   "mesuresList": selectedItems.map((item) {
  //                                     return {
  //                                       "libelle": item,
  //                                       "valeur": textFieldsValues[item]
  //                                     };
  //                                   }).toList()
  //                                 };

  //                                 await sendPostRequest(
  //                                     body); // Utilisez la fonction de requête ici
  //                                 setState(() {
  //                                   _fetchProprietaireMesure();
  //                                 });
  //                                 Navigator.of(context).pop(
  //                                     true); // Fermer le modal et retourner true
  //                               }
  //                             : null,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  //   // Après la fermeture du modal, isModalClosed sera true si le modal a été fermé
  //   if (isModalClosed) {
  //     // Réinitialisation de l'état ou autres actions après la fermeture du modal
  //     setState(() {
  //       // Réinitialisation des variables et des listes si nécessaire
  //       selectedItem = null;
  //       isOwnerFilled = false;
  //       isAddButtonEnabled = false;
  //       textFieldValue = null;
  //       selectedItems.clear();
  //       textFieldController.clear();
  //       textFieldsControllers.clear();
  //       textFieldsWidgets.clear();
  //     });
  //   }
  // }

//Ajouter un mesure a un proprio

  Future<void> fonctionaddmesure(
      String idproprio, String libelle, String valeur) async {
    valeur = valeur + " cm";
    final url = 'http://192.168.56.1:8010/mesure/newMesure';
    try {
      final response = await client.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization':
          //     'Bearer $_token', // Assurez-vous que $_token est défini et valide
        },
        body: jsonEncode({
          "libelle": libelle,
          "valeur": valeur,
          "proprietaireMesures": {
            "id": idproprio,
          },
        }),
      );
      if (response.statusCode == 202) {
        // final responseData = jsonDecode(response.body);
        // print('Mise à jour réussie: ${responseData['message']}');
        // print('Données mises à jour: ${responseData['data']}');
        // Afficher un message de succès
        setState(() {
          _fetchProprietaireMesure();
        });
        CustomSnackBar.show(context,
            message: 'Mesure ajoutée avec succès', isError: false);
      } else if (response.statusCode == 400) {
        final responseData = jsonDecode(response.body);
        String message = responseData['message'];
        CustomSnackBar.show(context, message: '$message', isError: true);
      } else {
        // print('Erreur lors de l\'ajout de la mesure: ${response.statusCode}');
        // print('Message: ${response.body}');
        // Afficher un message d'erreur
        CustomSnackBar.show(context,
            message: 'Erreur lors de l\'ajout de la mesure', isError: true);
      }
    } catch (e) {
      CustomSnackBar.show(context,
          message:
              'Une erreur s\'est produite. Veuillez vérifier votre connexion.',
          isError: true);
    }
  }

  void addmesure(String idproprio) {
    String? libelle;
    TextEditingController valeurController = TextEditingController();
    final _formKeyaddmesure = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: Text(
            'Ajouter un mesure pour le proprio',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
          ),
          content: Padding(
            padding: EdgeInsets.all(0.8.h),
            child: Form(
              key: _formKeyaddmesure,
              child: Column(
                children: <Widget>[
                  DropdownButtonFormField<String>(
                    value:
                        libelle, // Assurez-vous de définir la valeur initiale
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.category),
                      hintText: "selectionner",
                      hintStyle: TextStyle(
                        color: Color.fromARGB(255, 132, 134, 135),
                        fontSize: 8.sp,
                      ),
                      labelText: "selectionner",
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 132, 134, 135),
                        fontSize: 8.sp,
                      ),
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
                      contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                    ),
                    items: [
                      'Longueur_Pantalon',
                      'Toure_Ceinture',
                      'Toure_Fesse',
                      'Toure_Cuisse',
                      'Toure_Patte',
                      'Longueur_Chemise',
                      'Longueur_Boubou',
                      'Toure_Poitrine',
                      'Epaule',
                      'Manche.Long',
                      'Manche.Courte',
                      'Toure_Manche',
                      'Encolure'
                    ].map((label) {
                      return DropdownMenuItem<String>(
                        value: label,
                        child: Text(
                          label,
                          style: TextStyle(fontSize: 8.sp),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        libelle =
                            value!; // Mettre à jour la valeur sélectionnée
                      });
                      // Ajoutez votre logique pour traiter la sélection ici
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez sélectionner une spécialité';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 1.h),
                  TextFormField(
                    controller: valeurController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                        fontSize:
                            8.sp), // Taille de police pour la valeur par défaut
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.account_circle),
                      prefixIconColor: Color.fromARGB(255, 95, 95, 96),
                      hintText: "valeur ",
                      hintStyle: TextStyle(
                        color: Color.fromARGB(255, 132, 134, 135),
                        fontSize: 8.sp,
                      ),
                      labelText: "Valeur",
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 132, 134, 135),
                        fontSize: 8.sp,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color.fromARGB(
                              255, 206, 136, 5), // Couleur de la bordure
                          width: 0.4.w, // Largeur de la bordure
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 206, 136, 5),
                          width: 0.4.w,
                        ), // Couleur de la bordure lorsqu'elle est en état de focus
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 0.4.w,
                        ), // Couleur de la bordure lorsqu'elle est en état de focus
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 1.w,
                      ), // Ajustez la valeur de la marge verticale selon vos besoins
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le prénom';
                      }
                      return null;
                    },
                    // onChanged: (value) {
                    //   setState(() {});
                    // },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // background
                foregroundColor: Colors.white, // foreground
              ),
              child: Text(
                "Fermer",
                style: TextStyle(
                  fontSize: 8.sp,
                  letterSpacing: 2,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              }, // Désactive le bouton si aucun champ n'est modifié
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Color.fromARGB(255, 206, 136, 5), // background
                  foregroundColor: Colors.white, // foreground
                ),
                child: Text("Ajouter"),
                onPressed: () {
                  if (_formKeyaddmesure.currentState!.validate()) {
                    // Les champs sont valides, récupérez les données ici
                    String valeur = valeurController.text;
                    fonctionaddmesure(idproprio, libelle!, valeur);

                    // Ajoutez ici votre logique pour traiter les données
                    Navigator.of(context).pop();
                  }
                  // print("vous aller Ajouter un mesure pour le proprio");
                  // your code
                })
          ],
        );
      },
    );
  }

// MOdifier le proprio

  Future<void> updateProprios(
      String id, Map<String, dynamic> updatedFields) async {
    final url = 'http://192.168.56.1:8010/proprio/update/$id';
    final response = await client.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        // 'Authorization':
        //     'Bearer $_token', // Assurez-vous que $_token est défini et valide
      },
      body: jsonEncode(updatedFields),
    );

    if (response.statusCode == 202) {
      final responseData = jsonDecode(response.body);
      String message = responseData['message'];
      CustomSnackBar.show(context, message: '$message', isError: false);
      // Faites quelque chose avec les données mises à jour, comme mettre à jour l'état de l'application
    } else if (response.statusCode == 400) {
      final responseData = jsonDecode(response.body);
      String message = responseData['message'];
      CustomSnackBar.show(context, message: '$message', isError: true);
    } else {
      // print('Erreur lors de la mise à jour du client: ${response.statusCode}');
      // print('Message: ${response.body}');
      // Gérez l'erreur comme nécessaire
      CustomSnackBar.show(context,
          message: 'Erreur lors de la mise à jour !', isError: true);
    }
  }

  void _updateProprioInfo(Proprio updateProprios) {
    setState(() {
      _proprio = updateProprios;
    });
  }

  void modifierProprio() {
    // Valeurs par défaut pour les champs
    String id = _proprio.id;
    final proprioController = TextEditingController(text: _proprio.proprio);
    // Déclarer la variable ici
    Proprio? updatedProprios;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          bool isModified() {
            return proprioController.text != _proprio.proprio;
          }

          return AlertDialog(
            scrollable: true,
            title: Text(
              'Le proprietaire de mesure',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
            ),
            content: Padding(
              padding: EdgeInsets.all(0.8.h),
              child: Form(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: proprioController,
                      keyboardType: TextInputType.name,
                      style: TextStyle(
                          fontSize: 8
                              .sp), // Taille de police pour la valeur par défaut
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.account_circle),
                        prefixIconColor: Color.fromARGB(255, 95, 95, 96),
                        hintText: "Entrez le proprio ",
                        hintStyle: TextStyle(
                          color: Color.fromARGB(255, 132, 134, 135),
                          fontSize: 8.sp,
                        ),
                        labelText: "Proprio",
                        labelStyle: TextStyle(
                          color: Color.fromRGBO(132, 134, 135, 1),
                          fontSize: 8.sp,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Color.fromARGB(
                                255, 206, 136, 5), // Couleur de la bordure
                            width: 0.4.w, // Largeur de la bordure
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 206, 136, 5),
                            width: 0.4.w,
                          ), // Couleur de la bordure lorsqu'elle est en état de focus
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 0.4.w,
                          ), // Couleur de la bordure lorsqu'elle est en état de focus
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 1.w,
                        ), // Ajustez la valeur de la marge verticale selon vos besoins
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le prénom';
                        }
                        return null;
                      },
                      // onChanged: (value) {
                      //   setState(() {});
                      // },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // background
                  foregroundColor: Colors.white, // foreground
                ),
                child: Text(
                  "Fermer",
                  style: TextStyle(
                    fontSize: 8.sp,
                    letterSpacing: 2,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                }, // Désactive le bouton si aucun champ n'est modifié
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Color.fromARGB(255, 206, 136, 5), // background
                  foregroundColor: Colors.white, // foreground
                ),
                child: Text("Modifier"),
                onPressed: isModified()
                    ? () async {
                        final updatedFields = <String, String>{};

                        if (proprioController.text != _proprio.proprio) {
                          updatedFields['proprio'] = proprioController.text;
                        }

                        // Appel de la méthode pour mettre à jour le propriétaire
                        await updateProprios(id, updatedFields);

                        // Crée un nouveau propriétaire avec les nouvelles valeurs
                        updatedProprios = Proprio(
                          id: id,
                          proprio: proprioController.text,
                        );

                        // Met à jour les informations affichées
                        if (updatedProprios != null) {
                          _updateProprioInfo(updatedProprios!);
                          setState(() {
                            _fetchProprietaireMesure();
                          });
                        }
                        Navigator.of(context).pop();
                      }
                    : null, // Désactive le bouton si aucun champ n'est modifié
              )
            ],
          );
        });
      },
    );
  }

  // delete
  Future<void> _FunctiondeleteClient() async {
    final url =
        'http://192.168.56.1:8010/user/$_id/deleteclients/${widget.clientId}';
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

  // supprimer un  client
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
            "Vous allez supprimer ce client",
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
                    _FunctiondeleteClient();
                    //:::::::::::::::::::::::::::::::::::::::::::
                    Navigator.of(context).pop(); // Fermer la boîte de dialogue
                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => NavigationBarPage()),
                    // );
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

//modifier un client

  Future<void> updateClient(Map<String, dynamic> updatedFields) async {
    final url = 'http://192.168.56.1:8010/user/update/${widget.clientId}';
    final response = await client.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        // 'Authorization':
        //     'Bearer $_token', // Assurez-vous que $_token est défini et valide
      },
      body: jsonEncode(updatedFields),
    );

    if (response.statusCode == 202) {
      final responseData = jsonDecode(response.body);
      // _fetchClientDetails();
      CustomSnackBar.show(context,
          message: 'Client modifier avec success ...!', isError: false);
      print("$responseData['message']");
    } else if (response.statusCode == 400) {
      CustomSnackBar.show(context,
          message: 'Cet téléphone appartient à autre client...!',
          isError: true);
    } else {
      // Gérez l'erreur comme nécessaire
      CustomSnackBar.show(context,
          message: 'Erreur lors de la mise à jour...!', isError: true);
    }
  }

  // void _updateClientInfo(Utilisateur updatedClient) {
  //   setState(() {
  //     _client = updatedClient;
  //   });
  // }

  void modifierClient() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditClientPage(
          clientId: widget.clientId,
          client: _client,
          onClientUpdated: (Utilisateur updatedClient) {
            setState(() {
              _client = updatedClient;
            });
          },
        ),
      ),
    );
  }

  // void modifierCliente() {
  //   // Valeurs par défaut pour les champs
  //   final nomController = TextEditingController(text: _client.nom);
  //   // final prenomController = TextEditingController(text: _client.prenom);
  //   final emailController = TextEditingController(text: _client.email);
  //   final telephoneController = TextEditingController(text: _client.username);
  //   final adresseController = TextEditingController(text: _client.adresse);
  //   final professionController =
  //       TextEditingController(text: _client.specialite);

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(
  //         builder: (BuildContext context, StateSetter setState) {
  //           bool isModified() {
  //             return nomController.text != _client.nom ||
  //                 // prenomController.text != _client.prenom ||
  //                 emailController.text != _client.email ||
  //                 telephoneController.text != _client.username ||
  //                 adresseController.text != _client.adresse;
  //           }

  //           return AlertDialog(
  //             scrollable: true,
  //             title: Text(
  //               'Modifier le client',
  //               textAlign: TextAlign.center,
  //               style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
  //             ),
  //             content: SizedBox(
  //               width: 52.08.w, // Ajustez la largeur ici
  //               child: Padding(
  //                 padding: EdgeInsets.all(0.8.h),
  //                 child: Form(
  //                   child: Column(
  //                     children: <Widget>[
  //                       TextFormField(
  //                         controller: nomController,
  //                         keyboardType: TextInputType.name,
  //                         style: TextStyle(
  //                             fontSize: 8
  //                                 .sp), // Taille de police pour la valeur par défaut
  //                         decoration: InputDecoration(
  //                           prefixIcon: Icon(
  //                             Icons.account_circle,
  //                             size: 15.sp,
  //                           ),
  //                           prefixIconColor: Color.fromARGB(255, 95, 95, 96),
  //                           hintText: "Entrez le nom ",
  //                           hintStyle: TextStyle(
  //                             color: Color.fromARGB(255, 132, 134, 135),
  //                             fontSize: 1.sp,
  //                           ),
  //                           labelText: "Nom",
  //                           labelStyle: TextStyle(
  //                             color: Color.fromARGB(255, 132, 134, 135),
  //                             fontSize: 8.sp,
  //                           ),
  //                           enabledBorder: OutlineInputBorder(
  //                             borderRadius: BorderRadius.circular(10),
  //                             borderSide: BorderSide(
  //                               color: Color.fromARGB(
  //                                   255, 206, 136, 5), // Couleur de la bordure
  //                               width: 0.4.w, // Largeur de la bordure
  //                             ),
  //                           ),
  //                           focusedBorder: OutlineInputBorder(
  //                             borderRadius: BorderRadius.circular(10),
  //                             borderSide: BorderSide(
  //                               color: Color.fromARGB(255, 206, 136, 5),
  //                               width: 0.4.w,
  //                             ), // Couleur de la bordure lorsqu'elle est en état de focus
  //                           ),
  //                           contentPadding: EdgeInsets.symmetric(
  //                             vertical: 1.w,
  //                           ), // Ajustez la valeur de la marge verticale selon vos besoins
  //                         ),
  //                         validator: (value) {
  //                           if (value == null || value.isEmpty) {
  //                             return 'Veuillez entrer le nom';
  //                           }
  //                           return null;
  //                         },
  //                         onChanged: (value) {
  //                           setState(() {});
  //                         },
  //                       ),
  //                       SizedBox(height: 1.h),
  //                       // TextFormField(
  //                       //   controller: prenomController,
  //                       //   keyboardType: TextInputType.name,
  //                       //   style: TextStyle(
  //                       //       fontSize: 8
  //                       //           .sp), // Taille de police pour la valeur par défaut
  //                       //   decoration: InputDecoration(
  //                       //     prefixIcon: Icon(Icons.account_circle),
  //                       //     prefixIconColor: Color.fromARGB(255, 95, 95, 96),
  //                       //     hintText: "Entrez le prénom ",
  //                       //     hintStyle: TextStyle(
  //                       //       color: Color.fromARGB(255, 132, 134, 135),
  //                       //       fontSize: 8.sp,
  //                       //     ),
  //                       //     labelText: "Prénom",
  //                       //     labelStyle: TextStyle(
  //                       //       color: Color.fromARGB(255, 132, 134, 135),
  //                       //       fontSize: 8.sp,
  //                       //     ),
  //                       //     enabledBorder: OutlineInputBorder(
  //                       //       borderRadius: BorderRadius.circular(10),
  //                       //       borderSide: BorderSide(
  //                       //         color: Color.fromARGB(
  //                       //             255, 206, 136, 5), // Couleur de la bordure
  //                       //         width: 0.4.w, // Largeur de la bordure
  //                       //       ),
  //                       //     ),
  //                       //     focusedBorder: OutlineInputBorder(
  //                       //       borderRadius: BorderRadius.circular(10),
  //                       //       borderSide: BorderSide(
  //                       //         color: Color.fromARGB(255, 206, 136, 5),
  //                       //         width: 0.4.w,
  //                       //       ), // Couleur de la bordure lorsqu'elle est en état de focus
  //                       //     ),
  //                       //     errorBorder: OutlineInputBorder(
  //                       //       borderRadius: BorderRadius.circular(10),
  //                       //       borderSide: BorderSide(
  //                       //         color: Colors.red,
  //                       //         width: 0.4.w,
  //                       //       ), // Couleur de la bordure lorsqu'elle est en état de focus
  //                       //     ),
  //                       //     contentPadding: EdgeInsets.symmetric(
  //                       //       vertical: 1.w,
  //                       //     ), // Ajustez la valeur de la marge verticale selon vos besoins
  //                       //   ),
  //                       //   validator: (value) {
  //                       //     if (value == null || value.isEmpty) {
  //                       //       return 'Veuillez entrer le prénom';
  //                       //     }
  //                       //     return null;
  //                       //   },
  //                       //   onChanged: (value) {
  //                       //     setState(() {});
  //                       //   },
  //                       // ),
  //                       SizedBox(height: 1.h),
  //                       TextFormField(
  //                         controller: emailController,
  //                         keyboardType: TextInputType.emailAddress,
  //                         style: TextStyle(
  //                             fontSize: 8
  //                                 .sp), // Taille de police pour la valeur par défaut
  //                         decoration: InputDecoration(
  //                           prefixIcon: Icon(
  //                             Icons.email,
  //                             size: 15.sp,
  //                           ),
  //                           prefixIconColor: Color.fromARGB(255, 95, 95, 96),
  //                           hintText: "exemple@gmail.com",
  //                           hintStyle: TextStyle(
  //                             color: Color.fromARGB(255, 132, 134, 135),
  //                             fontSize: 8.sp,
  //                           ),
  //                           labelText: "Email",
  //                           labelStyle: TextStyle(
  //                             color: Color.fromARGB(255, 132, 134, 135),
  //                             fontSize: 8.sp,
  //                           ),
  //                           enabledBorder: OutlineInputBorder(
  //                             borderRadius: BorderRadius.circular(10),
  //                             borderSide: BorderSide(
  //                               color: Color.fromARGB(
  //                                   255, 206, 136, 5), // Couleur de la bordure
  //                               width: 0.4.w, // Largeur de la bordure
  //                             ),
  //                           ),
  //                           focusedBorder: OutlineInputBorder(
  //                             borderRadius: BorderRadius.circular(10),
  //                             borderSide: BorderSide(
  //                               color: Color.fromARGB(255, 206, 136, 5),
  //                               width: 0.4.w,
  //                             ), // Couleur de la bordure lorsqu'elle est en état de focus
  //                           ),
  //                           contentPadding: EdgeInsets.symmetric(
  //                             vertical: 1.w,
  //                           ), // Ajustez la valeur de la marge verticale selon vos besoins
  //                         ),
  //                         onChanged: (value) {
  //                           setState(() {});
  //                         },
  //                       ),
  //                       SizedBox(height: 1.h),
  //                       TextFormField(
  //                         controller: telephoneController,
  //                         keyboardType: TextInputType.phone,
  //                         style: TextStyle(
  //                             fontSize: 8
  //                                 .sp), // Taille de police pour la valeur par défaut
  //                         decoration: InputDecoration(
  //                           prefixIcon: Icon(
  //                             Icons.phone,
  //                             size: 15.sp,
  //                           ),
  //                           prefixIconColor: Color.fromARGB(255, 95, 95, 96),
  //                           hintText: "+XXXXXXXXXXX",
  //                           hintStyle: TextStyle(
  //                             color: Color.fromARGB(255, 132, 134, 135),
  //                             fontSize: 8.sp,
  //                           ),
  //                           labelText: "Téléphone",
  //                           labelStyle: TextStyle(
  //                             color: Color.fromARGB(255, 132, 134, 135),
  //                             fontSize: 8.sp,
  //                           ),
  //                           enabledBorder: OutlineInputBorder(
  //                             borderRadius: BorderRadius.circular(10),
  //                             borderSide: BorderSide(
  //                               color: Color.fromARGB(255, 206, 136, 5),
  //                               width: 0.4.w,
  //                             ),
  //                           ),
  //                           focusedBorder: OutlineInputBorder(
  //                             borderRadius: BorderRadius.circular(10),
  //                             borderSide: BorderSide(
  //                               color: Color.fromARGB(255, 206, 136, 5),
  //                               width: 0.4.w,
  //                             ),
  //                           ),
  //                           errorBorder: OutlineInputBorder(
  //                             borderRadius: BorderRadius.circular(10),
  //                             borderSide: BorderSide(
  //                               color: Colors.red,
  //                               width: 0.4.w,
  //                             ), // Couleur de la bordure lorsqu'elle est en état de focus
  //                           ),
  //                           contentPadding: EdgeInsets.symmetric(
  //                             vertical: 1.w,
  //                           ),
  //                         ),
  //                         validator: (value) {
  //                           if (value == null || value.isEmpty) {
  //                             return 'Veuillez entrer le numéro de téléphone';
  //                           }
  //                           return null;
  //                         },
  //                         onChanged: (value) {
  //                           setState(() {});
  //                         },
  //                       ),
  //                       SizedBox(height: 1.h),
  //                       TextFormField(
  //                         controller: adresseController,
  //                         keyboardType: TextInputType.text,
  //                         style: TextStyle(
  //                             fontSize: 8
  //                                 .sp), // Taille de police pour la valeur par défaut
  //                         decoration: InputDecoration(
  //                           prefixIcon: Icon(
  //                             Icons.location_on,
  //                             size: 15.sp,
  //                           ),
  //                           prefixIconColor: Color.fromARGB(255, 95, 95, 96),
  //                           hintText: "Entrer l'adresse",
  //                           hintStyle: TextStyle(
  //                             color: Color.fromARGB(255, 132, 134, 135),
  //                             fontSize: 8.sp,
  //                           ),
  //                           labelText: "Adresse",
  //                           labelStyle: TextStyle(
  //                             color: Color.fromARGB(255, 132, 134, 135),
  //                             fontSize: 8.sp,
  //                           ),
  //                           enabledBorder: OutlineInputBorder(
  //                             borderRadius: BorderRadius.circular(10),
  //                             borderSide: BorderSide(
  //                               color: Color.fromARGB(255, 206, 136, 5),
  //                               width: 0.4.w,
  //                             ),
  //                           ),
  //                           focusedBorder: OutlineInputBorder(
  //                             borderRadius: BorderRadius.circular(10),
  //                             borderSide: BorderSide(
  //                               color: Color.fromARGB(255, 206, 136, 5),
  //                               width: 0.4.w,
  //                             ),
  //                           ),
  //                           contentPadding: EdgeInsets.symmetric(
  //                             vertical: 1.w,
  //                           ),
  //                         ),
  //                         onChanged: (value) {
  //                           setState(() {});
  //                         },
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             actions: [
  //               ElevatedButton(
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: Colors.red, // background
  //                   foregroundColor: Colors.white, // foreground
  //                 ),
  //                 child: Text(
  //                   "Fermer",
  //                   style: TextStyle(
  //                     fontSize: 8.sp,
  //                     letterSpacing: 2,
  //                   ),
  //                 ),
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 }, // Désactive le bouton si aucun champ n'est modifié
  //               ),
  //               ElevatedButton(
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor:
  //                       Color.fromARGB(255, 206, 136, 5), // background
  //                   foregroundColor: Colors.white, // foreground
  //                 ),
  //                 child: Text(
  //                   "Modifier",
  //                   style: TextStyle(
  //                     fontSize: 8.sp,
  //                     letterSpacing: 2,
  //                   ),
  //                 ),
  //                 onPressed: isModified()
  //                     ? () async {
  //                         final updatedFields = <String, String>{};

  //                         if (nomController.text != _client.nom) {
  //                           updatedFields['nom'] = nomController.text;
  //                         }
  //                         // if (prenomController.text != _client.prenom) {
  //                         //   updatedFields['prenom'] = prenomController.text;
  //                         // }
  //                         if (emailController.text != _client.email) {
  //                           updatedFields['email'] = emailController.text;
  //                         }
  //                         if (telephoneController.text != _client.username) {
  //                           updatedFields['numero'] = telephoneController.text;
  //                         }
  //                         if (adresseController.text != _client.adresse) {
  //                           updatedFields['adresse'] = adresseController.text;
  //                         }

  //                         // Appel de la méthode pour mettre à jour le client
  //                         await updateClient(updatedFields);
  //                         Navigator.of(context).pop();
  //                         // Crée un nouveau client avec les nouvelles valeurs

  //                         final updatedClient = Utilisateur(
  //                           id: widget.clientId,
  //                           nom: nomController.text,
  //                           // prenom: prenomController.text,
  //                           email: emailController.text,
  //                           username: telephoneController.text,
  //                           adresse: adresseController.text,
  //                           specialite: professionController.text,
  //                           profile: '',

  //                           // utilisateur: Utilisateur(
  //                           //     id: "id",
  //                           //     nom: "nom",
  //                           //     adresse: "adresse",
  //                           //     specialite: "specialite",
  //                           //     profile: "profile",
  //                           //     email: "email",
  //                           //     username: "username"),
  //                         );

  //                         // Appelle le callback pour mettre à jour les informations affichées
  //                         _updateClientInfo(updatedClient);
  //                       }
  //                     : null, // Désactive le bouton si aucun champ n'est modifié
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
}
