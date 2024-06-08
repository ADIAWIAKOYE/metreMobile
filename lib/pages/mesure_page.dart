import 'package:flutter/material.dart';
import 'package:Metre/models/client_model.dart';
import 'package:Metre/pages/detail_mesure_page.dart';
import 'package:Metre/pages/login_page.dart';
import 'package:Metre/widgets/logo.dart';
import 'package:Metre/widgets/search_input.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MesurePage extends StatefulWidget {
  const MesurePage({super.key});

  @override
  State<MesurePage> createState() => _MesurePageState();
}

class _MesurePageState extends State<MesurePage> {
  static List<ClientsModel> liste_des_clients = [
    ClientsModel("idclient1", "SY", "Ibrahime", "+22393963145", "sy@gmail.com",
        "yirimadio", true, false, "i32443DEFTHGVDT"),
    ClientsModel("idclient2", "SYLLA", "Bada", "+22383963145",
        "babasylla@gmail.com", "Sirakoro", true, false, "i32443DEFTHG4DT"),
    ClientsModel("idclient3", "CISSE", "Fouseyni", "+22373963145",
        "fous6se@gmail.com", "Djikoroni", true, false, "i32443DEFTDG4DT"),
    ClientsModel("idclient4", "SY", "Ibrahime", "+22393963145", "sy@gmail.com",
        "yirimadio", true, false, "i32443DEFTHGVDT"),
    ClientsModel("idclient5", "SYLLA", "Bada", "+22383963145",
        "babasylla@gmail.com", "Sirakoro", true, false, "i32443DEFTHG4DT"),
    ClientsModel("idclient6", "CISSE", "Fouseyni", "+22373963145",
        "fous6se@gmail.com", "Djikoroni", true, false, "i32443DEFTDG4DT"),
  ];

  List<ClientsModel> displaye_liste = List.from(liste_des_clients);

  void updateliste(String value) {
    // this is a function that will filter our list
    // we will be back to this list after a wile
    // Now let's write our search function

    // setState(() {
    //   displaye_liste = liste_des_clients
    //       .where((element) =>
    //           element.nom!.toLowerCase().contains(value.toLowerCase()) &&
    //               element.prenom!.toLowerCase().contains(value.toLowerCase()) ||
    //           element.numero!.toLowerCase().contains(value.toLowerCase()))
    //       .toList();
    // });

    setState(() {
      displaye_liste = liste_des_clients.where((element) {
        final fullName = "${element.nom} ${element.prenom}";
        final nomPrenom = fullName.toLowerCase();
        final nom = element.nom!.toLowerCase();
        final prenom = element.prenom!.toLowerCase();
        final numero = element.numero!.toLowerCase();

        // Vérifie si le nom ou le prénom contient la valeur recherchée
        // ou si le nom complet contient la valeur recherchée
        // ou si le numéro contient la valeur recherchée
        final searchTerms = value.toLowerCase().split(' ');
        bool containsAllSearchTerms = true;
        for (final term in searchTerms) {
          containsAllSearchTerms = containsAllSearchTerms &&
              (nom.contains(term) || prenom.contains(term));
        }
        return containsAllSearchTerms ||
            nomPrenom.contains(value.toLowerCase()) ||
            numero.contains(value.toLowerCase());
      }).toList();
    });
  }

// FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  String? _username;
  String? _token;
  String? _refreshToken;
  String? _id;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Appel de la méthode lors de l'initialisation de l'état
  }

  // Déclaration de la méthode _loadUserData
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _id = prefs.getString('id');
      _username = prefs.getString('username');
      _token = prefs.getString('token');
      _refreshToken = prefs.getString('refreshToken');
    });
  }
// GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        LogoWidget(),
        // SizedBox(
        //   height: 5,
        // ),

        //inpute rechercher
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (value) => updateliste(value),
            style: TextStyle(
                color: Theme.of(context).colorScheme.tertiary,
                decoration: TextDecoration.none),
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).colorScheme.primary,
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(15), // même rayon que ClipRRect
                // borderSide: BorderSide(color: Colors.grey, width: 1.0),
                borderSide: const BorderSide(
                  color:
                      Color.fromARGB(255, 206, 136, 5), // Couleur de la bordure
                  width: 1.5, // Largeur de la bordure
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: Color.fromARGB(255, 206, 136, 5),
                  width: 1.5,
                ), // Couleur de la bordure lorsqu'elle est en état de focus
              ),
              hintText: "Rechercher",
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 12,
              ),
              prefixIcon: Icon(Icons.search),
              prefixIconColor: Theme.of(context).colorScheme.secondary,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        // SizedBox(
        //   height: 5,
        // ),
        Expanded(
          child: displaye_liste.length == 0
              ? Center(
                  child: Text(
                    "Aucun résultat trouvé ! ",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        fontWeight: FontWeight.w700),
                  ),
                )
              : ListView.builder(
                  itemCount: displaye_liste.length,
                  itemBuilder: (context, index) => Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      border: Border.all(
                        color: Color.fromARGB(
                            255, 206, 136, 5), // Couleur de la bordure
                        width: 1, // Largeur de la bordure
                      ),
                      borderRadius: BorderRadius.circular(5), // Bord arrondi
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 1,
                          offset: Offset(1, 2), // Shadow position
                        ),
                      ],
                    ),
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(5.0),
                      title: Text(
                        displaye_liste[index].prenom! +
                            " " +
                            displaye_liste[index].nom!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            displaye_liste[index].numero!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.tertiary,
                              fontSize: 11,
                            ),
                          ),
                          Spacer(), // Ajouter un espace flexible entre les deux éléments

                          InkWell(
                            onTap: () {
                              // Action à effectuer lors du tapotement
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailMesurePage(
                                      client: displaye_liste[index]),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Color.fromARGB(255, 206, 136,
                                      5), // Couleur de la bordure
                                  width: 1, // Largeur de la bordure
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Voir plus ',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 206, 136, 5),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Color.fromARGB(255, 206, 136, 5),
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      leading: Image.asset('assets/image/customer1.png'),
                    ),
                  ),
                  // ),
                ),
        ),
        // LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('id: $_id'),
              SizedBox(height: 10),
              Text('Username: $_username'),
              SizedBox(height: 10),
              Text('Token: $_token'),
              SizedBox(height: 10),
              Text('Refresh Token: $_refreshToken'),
            ],
          ),
        ),
        // LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
      ]),
    );
  }
}
