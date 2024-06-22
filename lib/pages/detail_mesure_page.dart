import 'dart:convert';

import 'package:Metre/models/clients_model.dart';
import 'package:Metre/models/mesure_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:Metre/bottom_navigationbar/navigation_page.dart';
import 'package:Metre/models/client_model.dart';
import 'package:Metre/models/product.dart';
import 'package:Metre/widgets/logo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
  final List<Product> _products = Product.generateItems(2);
  bool _showDetailClient = true;
  bool _showProprioMesures = true;
  bool _isLoading = true;
  late Client _client;
  List<ProprietaireMesure> listeDesprorios = [];
  List<ProprietaireMesure> displayedprorios = [];

  List<bool> _isExpandedList =
      []; // Liste pour garder l'état d'ouverture de chaque ExpansionTile

  String? _id;
  String? _token;

  @override
  void initState() {
    super.initState();
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
    final url = 'http://192.168.56.1:8010/clients/loadbyid/${widget.clientId}';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 202) {
      final data = json.decode(response.body)['data'];
      setState(() {
        _client = Client.fromJson(data);
        _isLoading = false;
      });
    } else {
      throw Exception('Échec du chargement du client');
    }
  }

  // pour afficher les proprietaire mesure
  Future<List<ProprietaireMesure>> _fetchProprietaireMesure() async {
    final url =
        'http://192.168.56.1:8010/proprio/getByClients/${widget.clientId}';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 202) {
      final data = jsonDecode(response.body);
      final proprioData = data['data']['content'] as List;
      listeDesprorios = proprioData
          .map((proproJson) => ProprietaireMesure.fromJson(proproJson))
          .toList();

      // Maintenant pour chaque ProprietaireMesure, chargez les mesures depuis l'API
      for (var proprietaire in listeDesprorios) {
        final mesureUrl =
            'http://192.168.56.1:8010/mesure/loadByProprio/${proprietaire.id}';
        final mesureResponse = await http.get(
          Uri.parse(mesureUrl),
          headers: {
            'Authorization': 'Bearer $_token',
          },
        );

        if (mesureResponse.statusCode == 202) {
          final mesureData = jsonDecode(mesureResponse.body);
          final mesures = (mesureData['data'] as List)
              .map((mesureJson) => Mesure.fromJson(mesureJson))
              .toList();

          proprietaire.mesures = mesures;
        } else {
          throw Exception(
              'Échec du chargement des mesures pour le propriétaire: ${proprietaire.id}');
        }
      }

      return listeDesprorios;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur lors du chargement des propros.'),
      ));
      throw Exception('Échec du chargement du client');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.keyboard_backspace,
            size: 30,
          ),
        ),
        backgroundColor: Theme.of(context)
            .colorScheme
            .background, // Changez cette couleur selon vos besoins
      ),
      body: ListView(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LogoWidget(),
          // Align(
          //   alignment: Alignment.centerLeft,
          //   child: IconButton(
          //     onPressed: () {
          //       // Action à effectuer lors du tapotement
          //       // Navigator.push(
          //       //   context,
          //       //   MaterialPageRoute(
          //       //     builder: (context) => NavigationBarPage(),
          //       //   ),
          //       // );
          //       Navigator.pop(context);
          //     },
          //     icon: Icon(
          //       Icons.keyboard_backspace,
          //       size: 30,
          //     ),
          //   ),
          // ),
          // Center(
          // Centrer le texte
          SizedBox(
            height: 20,
          ),
          SizedBox(
            // height: 50,
            width: double.infinity,
            child: Container(
              margin: const EdgeInsets.only(left: 10.0, right: 10.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                border: Border.all(
                  color:
                      Color.fromARGB(255, 206, 136, 5), // Couleur de la bordure
                  width: 1, // Largeur de la bordure
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                      fontSize: 15,
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
            height: 20,
          ),
          if (_showDetailClient)
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      for (var detail in [
                        {'label': 'Nom', 'value': _client.nom},
                        {'label': 'Prénom', 'value': _client.prenom},
                        {'label': 'Téléphone', 'value': _client.numero},
                        {'label': 'Adresse', 'value': _client.adresse},
                        {'label': 'Email', 'value': _client.email},
                      ])
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${detail['label']}:',
                                  style: TextStyle(
                                    fontSize: 12,
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
                                    fontSize: 11,
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
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 5.0),
                            child: InkWell(
                              onTap: () {
                                print("BUTTON cliqué !");
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                padding: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Color.fromARGB(255, 206, 163,
                                        5), // Couleur de la bordure
                                    width: 1, // Largeur de la bordure
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "Modifier",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 206, 136, 5),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(left: 5.0),
                                      child: Icon(
                                        Icons.border_color,
                                        color: Color.fromARGB(255, 206, 136, 5),
                                        size: 17,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin:
                                const EdgeInsets.only(left: 5.0, right: 10.0),
                            child: InkWell(
                              onTap: () {
                                print("BUTTON cliqué !");
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                padding: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.red, // Couleur de la bordure
                                    width: 1, // Largeur de la bordure
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "Supprimer",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(left: 5.0),
                                      child: Icon(
                                        Icons.delete_forever,
                                        color: Colors.red,
                                        size: 17,
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
              margin: const EdgeInsets.only(left: 20.0, right: 20.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                border: Border.all(
                  color:
                      Color.fromARGB(255, 206, 136, 5), // Couleur de la bordure
                  width: 1, // Largeur de la bordure
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Text(
                  'les Mésures du client', // Ajoutez votre texte personnalisé ici
                  textAlign: TextAlign.center, // Centrer le texte
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ),
            ),
          ),
// ici la liste des mesures
          SizedBox(height: 20),
          if (_showProprioMesures)
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : FutureBuilder<List<ProprietaireMesure>>(
                    future: _fetchProprietaireMesure(),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<ProprietaireMesure>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Erreur: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('Aucune mesure trouvée.'));
                      } else {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: listeDesprorios.length,
                          itemBuilder: (BuildContext context, int index) {
                            final mesure = listeDesprorios[index];
                            // Initialiser l'état d'expansion pour chaque ExpansionTile
                            if (_isExpandedList.length <= index) {
                              _isExpandedList.add(false);
                            }
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2.0, horizontal: 16.0),
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
                                    vertical:
                                        1.0), // Marge verticale autour du Card
                                child: ExpansionTile(
                                  key:
                                      GlobalKey(), // Clé globale pour gérer l'état de cet ExpansionTile
                                  // onExpansionChanged: (bool isExpanded) {
                                  //   // Lorsque cet ExpansionTile est ouvert, fermer tous les autres
                                  //   setState(() {
                                  //     _isExpandedList = List.filled(
                                  //         listeDesprorios.length, false);
                                  //     _isExpandedList[index] = isExpanded;
                                  //   });
                                  // },
                                  initiallyExpanded: _isExpandedList[index],
                                  tilePadding:
                                      EdgeInsets.symmetric(horizontal: 16.0),
                                  title: Row(
                                    children: [
                                      Text(
                                        mesure.proprio ?? 'Sans Nom',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          print(
                                              'Vous allez modifier le nom du proprietaire  !');
                                        },
                                        icon: Icon(
                                          Icons.edit,
                                          size: 20,
                                          color:
                                              Color.fromARGB(255, 206, 136, 5),
                                        ),
                                      ),
                                    ],
                                  ),
                                  collapsedTextColor:
                                      Theme.of(context).colorScheme.tertiary,
                                  textColor:
                                      Theme.of(context).colorScheme.tertiary,
                                  iconColor:
                                      Theme.of(context).colorScheme.tertiary,
                                  childrenPadding: EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 1.0),
                                  children: [
                                    for (var mesureS in mesure.mesures)
                                      ListTile(
                                        title:
                                            // Padding(
                                            //   padding: EdgeInsets.symmetric(
                                            //       vertical: 5, horizontal: 20),
                                            //   child:
                                            Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              flex: 4,
                                              child: Text(
                                                '${mesureS.libelle}:',
                                                style: TextStyle(
                                                  fontSize: 12,
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
                                                  fontSize: 11,
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
                                                  print('Mesure supprimer !');
                                                },
                                                icon: Icon(
                                                  Icons.delete,
                                                  size: 20,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          margin:
                                              const EdgeInsets.only(right: 5.0),
                                          child: InkWell(
                                            onTap: () {
                                              print("BUTTON cliqué !");
                                            },
                                            child: Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 10),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 6, horizontal: 20),
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
                                                  width:
                                                      1, // Largeur de la bordure
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "Ajouter",
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color.fromARGB(
                                                          255, 206, 136, 5),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 5.0),
                                                    child: Icon(
                                                      Icons.add_circle,
                                                      color: Color.fromARGB(
                                                          255, 206, 136, 5),
                                                      size: 17,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 5.0, right: 10.0),
                                          child: InkWell(
                                            onTap: () {
                                              print("BUTTON cliqué !");
                                            },
                                            child: Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 10),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 6, horizontal: 10),
                                              decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: Colors
                                                      .red, // Couleur de la bordure
                                                  width:
                                                      1, // Largeur de la bordure
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "Supprimer",
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 5.0),
                                                    child: Icon(
                                                      Icons.delete_forever,
                                                      color: Colors.red,
                                                      size: 17,
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
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),

          SizedBox(
            height: 20,
          ),
          Container(
            margin: const EdgeInsets.only(left: 5.0, right: 10.0),
            child: InkWell(
              onTap: () {
                print("BUTTON cliqué !");
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Ajouter un autre mesure pour ce client ",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 206, 136, 5),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 5.0),
                    child: Icon(
                      Icons.add_circle,
                      color: Color.fromARGB(255, 206, 136, 5),
                      size: 20,
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
