import 'dart:convert';

import 'package:Metre/models/clients_model.dart';
import 'package:Metre/models/mesure_model.dart';
import 'package:Metre/models/proprioMesures_model.dart';
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
  late Proprio _proprio;
  bool _isLoadingproprio =
      true; // Ajoutez une variable pour gérer l'état de chargement
  List<ProprietaireMesure> listeDesprorios = [];
  List<ProprietaireMesure> displayedprorios = [];

  List<bool> _isExpandedList =
      []; // Liste pour garder l'état d'ouverture de chaque ExpansionTile

  String? _id;
  String? _token;

  @override
  void initState() {
    super.initState();
    selectedItem = items.first; // Sélectionner la première option par défaut
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

    // print('Response status: ${response.statusCode}');
    // print('Response body: ${response.body}');

    if (response.statusCode == 202) {
      try {
        final data = jsonDecode(response.body);

        // Vérifiez si les champs attendus existent
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
          final mesureResponse = await http.get(
            Uri.parse(mesureUrl),
            headers: {
              'Authorization': 'Bearer $_token',
            },
          );

          // print('Mesure response status: ${mesureResponse.statusCode}');
          // print('Mesure response body: ${mesureResponse.body}');

          if (mesureResponse.statusCode == 202) {
            final mesureData = jsonDecode(mesureResponse.body);

            // Vérifiez si les champs attendus existent
            if (mesureData == null || mesureData['data'] == null) {
              throw Exception('Données des mesures manquantes ou incorrectes');
            }

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
      } catch (e) {
        print('Erreur lors du décodage JSON: $e');
        throw Exception('Erreur lors du décodage JSON');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur lors du chargement des propros.'),
      ));
      throw Exception('Échec du chargement du client');
    }
  }

// pour afficher le proprio
  Future<void> _fetchProprio(String idProprio) async {
    final url = 'http://192.168.56.1:8010/proprio/loadbyid/${idProprio}';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 202) {
      final data = json.decode(response.body)['data'];
      setState(() {
        _proprio = Proprio.fromJson(data);
        _isLoadingproprio = false;
      });
    } else {
      throw Exception('Échec du chargement du proprio');
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
                                modifierClient();
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
                                        onPressed: () async {
                                          setState(() {
                                            _isLoadingproprio = true;
                                          });
                                          await _fetchProprio(
                                              mesure.id ?? 'Sans id');
                                          if (!_isLoadingproprio) {
                                            modifierProprio();
                                          }
                                          print(
                                              'Vous allez modifier le nom du proprietaire !');
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
                showBottomSheet(context);
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

// ajouter un nouveau proprietaireMesure et mesure

  List<String> items = [
    'L.Pantalon',
    'Ceinture',
    'T.fesse',
    'Cuisse',
    'Patte',
    'L.Chemise',
    'L.Boubou',
    'Poitrine',
    'Epaule',
    'Manche.L',
    'Manche.C',
    'T.Manche',
    'Encolure'
  ]; // Options du DropdownButton
  String? selectedItem; // Valeur sélectionnée du DropdownButton

  bool isOwnerFilled = false;
  bool isTextFieldWidgetAdded = false;
  bool isAddButtonEnabled = false;
  String? textFieldValue; // Définir la variable textFieldValue
  List<String> selectedItems = []; // Définir la liste selectedItems
  TextEditingController textFieldController =
      TextEditingController(); // Contrôleur de champ de texte

  // Déclarez textFieldsControllers pour stocker les contrôleurs de champ de texte
  Map<String, TextEditingController> textFieldsControllers = {};
  Map<String, String> textFieldsValues =
      {}; // Déclaration de la variable textFieldsValues
  List<Widget> textFieldsWidgets =
      []; // Liste pour stocker les widgets des champs de texte dynamiques

  void showBottomSheet(BuildContext context) async {
    bool isModalClosed = await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            bool isOwnerFilled = false;
            bool isTextFieldWidgetAdded = false;
            return SizedBox(
              height: 1000,
              child: ListView(
                children: [
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'Ajouter un nouveau mesure pour ce client',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 206, 136, 5),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.location_on),
                              prefixIconColor: Colors.transparent,
                              hintText: "Entrer nom propriétaire",
                              hintStyle: TextStyle(
                                color: Color.fromARGB(255, 132, 134, 135),
                                fontSize: 12,
                              ),
                              labelText: "Propriétaire",
                              labelStyle: TextStyle(
                                color: Color.fromARGB(255, 132, 134, 135),
                                fontSize: 12,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 206, 136, 5),
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 206, 136, 5),
                                  width: 1.5,
                                ),
                              ),
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 10),
                            ),
                            onChanged: (value) {
                              setModalState(() {
                                isOwnerFilled = value.isNotEmpty;
                              });
                            },
                          ),
                          SizedBox(height: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        prefixIconColor: Colors.transparent,
                                        hintText: "Sélectionner",
                                        hintStyle: TextStyle(
                                          color: Color.fromARGB(
                                              255, 132, 134, 135),
                                          fontSize: 10,
                                        ),
                                        labelText: "Sélectionner",
                                        labelStyle: TextStyle(
                                          color: Color.fromARGB(
                                              255, 132, 134, 135),
                                          fontSize: 10,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color.fromARGB(
                                                255, 206, 136, 5),
                                            width: 1.5,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          borderSide: BorderSide(
                                            color: Color.fromARGB(
                                                255, 206, 136, 5),
                                            width: 1.5,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                      ),
                                      value: selectedItem,
                                      onChanged: (newValue) {
                                        setModalState(() {
                                          selectedItem = newValue!;
                                          isAddButtonEnabled =
                                              (selectedItem != null &&
                                                  selectedItem!.isNotEmpty &&
                                                  textFieldValue != null &&
                                                  textFieldValue!.isNotEmpty &&
                                                  !selectedItems
                                                      .contains(selectedItem));
                                        });
                                      },
                                      items: items.map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value,
                                              style: TextStyle(fontSize: 12)),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      onChanged: (value) {
                                        setModalState(() {
                                          textFieldValue = value;
                                          isAddButtonEnabled =
                                              (selectedItem != null &&
                                                  selectedItem!.isNotEmpty &&
                                                  textFieldValue != null &&
                                                  textFieldValue!.isNotEmpty &&
                                                  !selectedItems
                                                      .contains(selectedItem));
                                        });
                                      },
                                      controller: textFieldController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        prefixIconColor: Colors.transparent,
                                        hintText: "Valeur",
                                        hintStyle: TextStyle(
                                          color: Color.fromARGB(
                                              255, 132, 134, 135),
                                          fontSize: 10,
                                        ),
                                        labelText: "Valeur",
                                        labelStyle: TextStyle(
                                          color: Color.fromARGB(
                                              255, 132, 134, 135),
                                          fontSize: 10,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color.fromARGB(
                                                255, 206, 136, 5),
                                            width: 1.5,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          borderSide: BorderSide(
                                            color: Color.fromARGB(
                                                255, 206, 136, 5),
                                            width: 1.5,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: isAddButtonEnabled
                                        ? () {
                                            setModalState(() {
                                              String? dropdownValue =
                                                  selectedItem;
                                              String textValue =
                                                  textFieldController.text;

                                              if (dropdownValue != null &&
                                                  dropdownValue.isNotEmpty &&
                                                  textValue.isNotEmpty &&
                                                  !selectedItems.contains(
                                                      dropdownValue)) {
                                                selectedItems
                                                    .add(dropdownValue);

                                                String fieldValue =
                                                    '$textValue cm';
                                                textFieldsControllers[
                                                        dropdownValue] =
                                                    TextEditingController(
                                                        text: textValue);
                                                textFieldsValues[
                                                    dropdownValue] = fieldValue;

                                                textFieldsWidgets.add(
                                                  Row(
                                                    key: ValueKey(
                                                        dropdownValue), // Ajouter une clé unique
                                                    children: [
                                                      Expanded(
                                                        flex: 2,
                                                        child: Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 10),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            border: Border.all(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      206,
                                                                      136,
                                                                      5),
                                                              width: 1,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        1),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical:
                                                                        8),
                                                            child: Text(
                                                              dropdownValue,
                                                              style: TextStyle(
                                                                  fontSize: 10),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 10),
                                                      Expanded(
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            border: Border.all(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      206,
                                                                      136,
                                                                      5),
                                                              width: 1,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        1),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical:
                                                                        8),
                                                            child: Text(
                                                              fieldValue,
                                                              style: TextStyle(
                                                                  fontSize: 10),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 10),
                                                      IconButton(
                                                        onPressed: () {
                                                          setModalState(() {
                                                            print(
                                                                "Dropdown value to delete: $dropdownValue");
                                                            textFieldsWidgets
                                                                .removeWhere(
                                                                    (widget) {
                                                              if (widget
                                                                  is Row) {
                                                                return widget
                                                                        .key ==
                                                                    ValueKey(
                                                                        dropdownValue);
                                                              }
                                                              return false;
                                                            });

                                                            selectedItems.remove(
                                                                dropdownValue);
                                                            print(
                                                                "Selected items after deletion: $selectedItems");
                                                          });
                                                        },
                                                        icon: Icon(
                                                          Icons.delete,
                                                          size: 30,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );

                                                textFieldController.clear();
                                              }
                                            });
                                          }
                                        : null,
                                    icon: Icon(
                                      Icons.add_box,
                                      size: 40,
                                      color: Color.fromARGB(255, 206, 136, 5),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color.fromARGB(255, 206, 136, 5),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: textFieldsWidgets,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            "Fermer",
                            style: TextStyle(
                              fontSize: 12,
                              letterSpacing: 2,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context)
                                .pop(true); // Fermer le modal et retourner true
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 206, 136, 5),
                            foregroundColor: Colors.white,
                          ),
                          child: Text("Modifier"),
                          onPressed: isOwnerFilled || isTextFieldWidgetAdded
                              ? () {
                                  // Votre code de modification ici
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    // Après la fermeture du modal, isModalClosed sera true si le modal a été fermé
    if (isModalClosed) {
      // Réinitialisation de l'état ou autres actions après la fermeture du modal
      setState(() {
        // Réinitialisation des variables et des listes si nécessaire
        selectedItem = null;
        isOwnerFilled = false;
        isAddButtonEnabled = false;
        textFieldValue = null;
        selectedItems.clear();
        textFieldController.clear();
        textFieldsControllers.clear();
        textFieldsWidgets.clear();
      });
    }
  }

// MOdifier le proprio
  void modifierProprio() {
    // Valeurs par défaut pour les champs
    final proprioController = TextEditingController(text: _proprio.proprio);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: Text(
              'Le proprietaire de mesure',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: proprioController,
                      keyboardType: TextInputType.name,
                      style: TextStyle(
                          fontSize:
                              10), // Taille de police pour la valeur par défaut
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.account_circle),
                        prefixIconColor: Color.fromARGB(255, 95, 95, 96),
                        hintText: "Entrez le proprio ",
                        hintStyle: TextStyle(
                          color: Color.fromARGB(255, 132, 134, 135),
                          fontSize: 12,
                        ),
                        labelText: "Proprio",
                        labelStyle: TextStyle(
                          color: Color.fromARGB(255, 132, 134, 135),
                          fontSize: 12,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Color.fromARGB(
                                255, 206, 136, 5), // Couleur de la bordure
                            width: 1.5, // Largeur de la bordure
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 206, 136, 5),
                            width: 1.5,
                          ), // Couleur de la bordure lorsqu'elle est en état de focus
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 1.5,
                          ), // Couleur de la bordure lorsqu'elle est en état de focus
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10,
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
                    fontSize: 12,
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
                  onPressed: () {
                    // your code
                  })
            ],
          );
        });
  }

//modifier un client
  void modifierClient() {
    // Valeurs par défaut pour les champs
    final nomController = TextEditingController(text: _client.nom);
    final prenomController = TextEditingController(text: _client.prenom);
    final emailController = TextEditingController(text: _client.email);
    final telephoneController = TextEditingController(text: _client.numero);
    final adresseController = TextEditingController(text: _client.adresse);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            bool isModified() {
              return nomController.text != _client.nom ||
                  prenomController.text != _client.prenom ||
                  emailController.text != _client.email ||
                  telephoneController.text != _client.numero ||
                  adresseController.text != _client.adresse;
            }

            return AlertDialog(
              scrollable: true,
              title: Text(
                'Modifier le client',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: 950, // Ajustez la largeur ici
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: nomController,
                          keyboardType: TextInputType.name,
                          style: TextStyle(
                              fontSize:
                                  10), // Taille de police pour la valeur par défaut
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.account_circle),
                            prefixIconColor: Color.fromARGB(255, 95, 95, 96),
                            hintText: "Entrez le nom ",
                            hintStyle: TextStyle(
                              color: Color.fromARGB(255, 132, 134, 135),
                              fontSize: 12,
                            ),
                            labelText: "Nom",
                            labelStyle: TextStyle(
                              color: Color.fromARGB(255, 132, 134, 135),
                              fontSize: 12,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Color.fromARGB(
                                    255, 206, 136, 5), // Couleur de la bordure
                                width: 1.5, // Largeur de la bordure
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 206, 136, 5),
                                width: 1.5,
                              ), // Couleur de la bordure lorsqu'elle est en état de focus
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10,
                            ), // Ajustez la valeur de la marge verticale selon vos besoins
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le nom';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: prenomController,
                          keyboardType: TextInputType.name,
                          style: TextStyle(
                              fontSize:
                                  10), // Taille de police pour la valeur par défaut
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.account_circle),
                            prefixIconColor: Color.fromARGB(255, 95, 95, 96),
                            hintText: "Entrez le prénom ",
                            hintStyle: TextStyle(
                              color: Color.fromARGB(255, 132, 134, 135),
                              fontSize: 12,
                            ),
                            labelText: "Prénom",
                            labelStyle: TextStyle(
                              color: Color.fromARGB(255, 132, 134, 135),
                              fontSize: 12,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Color.fromARGB(
                                    255, 206, 136, 5), // Couleur de la bordure
                                width: 1.5, // Largeur de la bordure
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 206, 136, 5),
                                width: 1.5,
                              ), // Couleur de la bordure lorsqu'elle est en état de focus
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 1.5,
                              ), // Couleur de la bordure lorsqu'elle est en état de focus
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10,
                            ), // Ajustez la valeur de la marge verticale selon vos besoins
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le prénom';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                              fontSize:
                                  10), // Taille de police pour la valeur par défaut
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            prefixIconColor: Color.fromARGB(255, 95, 95, 96),
                            hintText: "exemple@gmail.com",
                            hintStyle: TextStyle(
                              color: Color.fromARGB(255, 132, 134, 135),
                              fontSize: 12,
                            ),
                            labelText: "Email",
                            labelStyle: TextStyle(
                              color: Color.fromARGB(255, 132, 134, 135),
                              fontSize: 12,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Color.fromARGB(
                                    255, 206, 136, 5), // Couleur de la bordure
                                width: 1.5, // Largeur de la bordure
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 206, 136, 5),
                                width: 1.5,
                              ), // Couleur de la bordure lorsqu'elle est en état de focus
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10,
                            ), // Ajustez la valeur de la marge verticale selon vos besoins
                          ),
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: telephoneController,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(
                              fontSize:
                                  10), // Taille de police pour la valeur par défaut
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.phone),
                            prefixIconColor: Color.fromARGB(255, 95, 95, 96),
                            hintText: "+XXXXXXXXXXX",
                            hintStyle: TextStyle(
                              color: Color.fromARGB(255, 132, 134, 135),
                              fontSize: 12,
                            ),
                            labelText: "Téléphone",
                            labelStyle: TextStyle(
                              color: Color.fromARGB(255, 132, 134, 135),
                              fontSize: 12,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 206, 136, 5),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 206, 136, 5),
                                width: 1.5,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 1.5,
                              ), // Couleur de la bordure lorsqu'elle est en état de focus
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le numéro de téléphone';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: adresseController,
                          keyboardType: TextInputType.text,
                          style: TextStyle(
                              fontSize:
                                  10), // Taille de police pour la valeur par défaut
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.location_on),
                            prefixIconColor: Color.fromARGB(255, 95, 95, 96),
                            hintText: "Entrer l'adresse",
                            hintStyle: TextStyle(
                              color: Color.fromARGB(255, 132, 134, 135),
                              fontSize: 12,
                            ),
                            labelText: "Adresse",
                            labelStyle: TextStyle(
                              color: Color.fromARGB(255, 132, 134, 135),
                              fontSize: 12,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 206, 136, 5),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 206, 136, 5),
                                width: 1.5,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ],
                    ),
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
                      fontSize: 12,
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
                  child: Text(
                    "Modifier",
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                  onPressed: isModified()
                      ? () {
                          // votre code
                        }
                      : null, // Désactive le bouton si aucun champ n'est modifié
                ),
              ],
            );
          },
        );
      },
    );
  }
}
