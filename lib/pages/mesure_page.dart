import 'dart:convert';
import 'package:Metre/models/clients_model.dart';
import 'package:flutter/material.dart';
import 'package:Metre/pages/detail_mesure_page.dart';
import 'package:Metre/widgets/logo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MesurePage extends StatefulWidget {
  const MesurePage({Key? key});

  @override
  State<MesurePage> createState() => _MesurePageState();
}

class _MesurePageState extends State<MesurePage> {
  List<ClientsModels> listeDesClients = [];
  List<ClientsModels> displayedListe = [];

  String? _id;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadUserData().then((_) {
      _fetchClients();
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
    if (_id != null && _token != null) {
      final url = 'http://192.168.56.1:8010/clients/getByUser/$_id';

      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {'Authorization': 'Bearer $_token'},
        );

        if (response.statusCode == 202) {
          final data = jsonDecode(response.body);
          final clientsData = data['data']['content'] as List;

          setState(() {
            listeDesClients = clientsData
                .map((clientJson) => ClientsModels.fromJson(clientJson))
                .toList();
            displayedListe = List.from(listeDesClients);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erreur lors du chargement des clients.'),
          ));
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Une erreur s\'est produite. Veuillez réessayer.'),
        ));
      }
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
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (value) => updateListe(value),
            style: TextStyle(
                color: Theme.of(context).colorScheme.tertiary,
                decoration: TextDecoration.none),
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).colorScheme.primary,
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(15), // même rayon que ClipRRect
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
        Expanded(
          child: displayedListe.isEmpty
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
                  itemCount: displayedListe.length,
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
                        displayedListe[index].prenom! +
                            " " +
                            displayedListe[index].nom!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            displayedListe[index].numero!,
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
                                    // client: displayedListe[index],
                                    clientId: displayedListe[index].id!,
                                  ),
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
                ),
        ),
      ]),
    );
  }
}
