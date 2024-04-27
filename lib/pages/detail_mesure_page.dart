import 'package:flutter/material.dart';
import 'package:metremobile/bottom_navigationbar/navigation_page.dart';
import 'package:metremobile/models/client_model.dart';
import 'package:metremobile/widgets/logo.dart';

class DetailMesurePage extends StatefulWidget {
  final ClientsModel client;

  const DetailMesurePage({Key? key, required this.client}) : super(key: key);

  @override
  State<DetailMesurePage> createState() => _DetailMesurePageState();
}

class _DetailMesurePageState extends State<DetailMesurePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LogoWidget(),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () {
                // Action à effectuer lors du tapotement
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NavigationBarPage(),
                  ),
                );
              },
              icon: Icon(
                Icons.keyboard_backspace,
                size: 35,
              ),
            ),
          ),
          // Center(
          // Centrer le texte
          SizedBox(
            // height: 50,
            width: double.infinity,
            child: Container(
              margin: const EdgeInsets.only(left: 20.0, right: 20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color:
                      Color.fromARGB(255, 206, 163, 5), // Couleur de la bordure
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
                  'Les informations personnels Client', // Ajoutez votre texte personnalisé ici
                  textAlign: TextAlign.center, // Centrer le texte
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          // ),
          SizedBox(
            height: 20,
          ),
          // Center(
          Column(
            // Détails du client
            children: [
              // Liste des détails à afficher
              for (var detail in [
                {'label': 'Nom', 'value': widget.client.nom},
                {'label': 'Prénom', 'value': widget.client.prenom},
                {'label': 'Téléphone', 'value': widget.client.numero},
                {'label': 'Adresse', 'value': widget.client.adresse},
                {'label': 'Email', 'value': widget.client.email},
              ])
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Centrer les éléments horizontalement
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label du détail
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${detail['label']}:',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      // Espacement
                      SizedBox(width: 10),
                      // Valeur du détail
                      Expanded(
                        flex: 3,
                        child: Text(
                          ' ${detail['value']}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 5.0),
                child: ElevatedButton(
                  onPressed: () {
                    print("BUTTON cliqué !");
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Bord arrondi du bouton
                      side: BorderSide(
                        color: Color.fromARGB(
                            255, 206, 163, 5), // Couleur de la bordure
                        width: 1, // Épaisseur de la bordure
                      ),
                    ),
                    backgroundColor: Colors.white, // Arrière-plan transparent
                  ),
                  child: Row(
                    children: [
                      Text(
                        "Modifier",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 206, 163, 5),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 5.0),
                        child: Icon(
                          Icons.border_color,
                          color: Color.fromARGB(255, 206, 163, 5),
                          size: 20,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 5.0, right: 10.0),
                child: ElevatedButton(
                  onPressed: () {
                    print("BUTTON cliqué !");
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Bord arrondi du bouton
                      side: BorderSide(
                        color: Colors.red, // Couleur de la bordure
                        width: 1, // Épaisseur de la bordure
                      ),
                    ),
                    backgroundColor: Colors.white, // Arrière-plan transparent
                  ),
                  child: Row(
                    children: [
                      Text(
                        "Supprimer",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 5.0),
                        child: Icon(
                          Icons.delete_forever,
                          color: Colors.red,
                          size: 20,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          // ),
          SizedBox(
            height: 10,
          ),
          SizedBox(
            // height: 50,
            width: double.infinity,
            child: Container(
              margin: const EdgeInsets.only(left: 20.0, right: 20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color:
                      Color.fromARGB(255, 206, 163, 5), // Couleur de la bordure
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
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
// ici la liste des mesures
        ],
      ),
    );
  }
}
