import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:Metre/bottom_navigationbar/navigation_page.dart';
import 'package:Metre/models/client_model.dart';
import 'package:Metre/models/product.dart';
import 'package:Metre/widgets/logo.dart';

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
  final ClientsModel client;

  const DetailMesurePage({Key? key, required this.client}) : super(key: key);

  @override
  State<DetailMesurePage> createState() => _DetailMesurePageState();
}

class _DetailMesurePageState extends State<DetailMesurePage> {
  final List<Product> _products = Product.generateItems(2);
  bool _showDetailClient = true;
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
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => NavigationBarPage(),
                //   ),
                // );
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.keyboard_backspace,
                size: 30,
              ),
            ),
          ),
          // Center(
          // Centrer le texte
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
            // Center(
            Column(
              children: [
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
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Centrer les éléments horizontalement
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Label du détail
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${detail['label']}:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                              ),
                            ),
                            // Espacement
                            // SizedBox(width: 10),
                            // Valeur du détail
                            Expanded(
                              flex: 3,
                              child: Text(
                                '${detail['value']}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
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
                          padding:
                              EdgeInsets.symmetric(vertical: 6, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Color.fromARGB(
                                  255, 206, 163, 5), // Couleur de la bordure
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
                      margin: const EdgeInsets.only(left: 5.0, right: 10.0),
                      child: InkWell(
                        onTap: () {
                          print("BUTTON cliqué !");
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          padding:
                              EdgeInsets.symmetric(vertical: 6, horizontal: 10),
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
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ExpansionPanelList.radio(
                expansionCallback: (int index, bool isExpanded) {
                  setState(() => _products[index].isExpanded = !isExpanded);
                },
                children: _products.map<ExpansionPanel>((Product product) {
                  return ExpansionPanelRadio(
                    // isExpanded: product.isExpanded,

                    value: product.id,
                    canTapOnHeader: true,
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Image.asset(
                            'assets/image/logo4.png',
                            // width: 20,
                          ),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              product.title,
                              textAlign: TextAlign.center, // Centrer le texte
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Color.fromARGB(255, 206, 136, 5),
                                size: 17,
                              ),
                              // color: Colors.white,
                              onPressed: () {
                                print('vous avez cliquer sur le buttom');
                              },
                            ),
                          ],
                        ),
                      );
                    },

                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Text(
                                  'LongueurPantalon',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                '100 cm',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              // color: Colors.white,
                              onPressed: () {
                                print('vous avez cliquer sur le buttom');
                              },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Text(
                                  'Ceinture',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                '82 cm',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              color: Theme.of(context).colorScheme.tertiary,
                              onPressed: () {
                                print('vous avez cliquer sur le buttom');
                              },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Text(
                                  'Toure de fesse',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                '110 cm',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              // color: Colors.white,
                              onPressed: () {
                                print('vous avez cliquer sur le buttom');
                              },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Text(
                                  'Cuisse',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                '66 cm',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              // color: Colors.white,
                              onPressed: () {
                                print('vous avez cliquer sur le buttom');
                              },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Text(
                                  'Patte',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                '16 cm',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              // color: Colors.white,
                              onPressed: () {
                                print('vous avez cliquer sur le buttom');
                              },
                            ),
                          ],
                        ),
// les buttoms
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
                                      color: Color.fromARGB(255, 206, 136,
                                          5), // Couleur de la bordure
                                      width: 1, // Largeur de la bordure
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Ajouter",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Color.fromARGB(255, 206, 136, 5),
                                        ),
                                      ),
                                      Container(
                                        margin:
                                            const EdgeInsets.only(left: 5.0),
                                        child: Icon(
                                          Icons.add_circle,
                                          color:
                                              Color.fromARGB(255, 206, 136, 5),
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
                                      color:
                                          Colors.red, // Couleur de la bordure
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
                                        margin:
                                            const EdgeInsets.only(left: 5.0),
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
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
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
