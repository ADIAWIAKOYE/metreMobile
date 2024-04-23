import 'package:flutter/material.dart';
import 'package:metremobile/models/client_model.dart';
import 'package:metremobile/pages/login_page.dart';
import 'package:metremobile/widgets/logo.dart';
import 'package:metremobile/widgets/search_input.dart';

class MesurePage extends StatefulWidget {
  const MesurePage({super.key});

  @override
  State<MesurePage> createState() => _MesurePageState();
}

class _MesurePageState extends State<MesurePage> {
  static List<ClientsModel> liste_des_clients = [
    ClientsModel("SY", "Ibrahime", "+22393963145", "sy@gmail.com", "yirimadio",
        true, false, "i32443DEFTHGVDT"),
    ClientsModel("SYLLA", "Bada", "+22383963145", "babasylla@gmail.com",
        "Sirakoro", true, false, "i32443DEFTHG4DT"),
    ClientsModel("CISSE", "Fouseyni", "+22373963145", "fous6se@gmail.com",
        "Djikoroni", true, false, "i32443DEFTDG4DT"),
    ClientsModel("SY", "Ibrahime", "+22393963145", "sy@gmail.com", "yirimadio",
        true, false, "i32443DEFTHGVDT"),
    ClientsModel("SYLLA", "Bada", "+22383963145", "babasylla@gmail.com",
        "Sirakoro", true, false, "i32443DEFTHG4DT"),
    ClientsModel("CISSE", "Fouseyni", "+22373963145", "fous6se@gmail.com",
        "Djikoroni", true, false, "i32443DEFTDG4DT"),
  ];

  List<ClientsModel> displaye_liste = List.from(liste_des_clients);

  void updateliste(String value) {
    // this is a function that will filter our list
    // we will be back to this list after a wile
    // Now let's write our search function

    setState(() {
      displaye_liste = liste_des_clients
          .where((element) =>
              element.nom!.toLowerCase().contains(value.toLowerCase()) ||
              element.prenom!.toLowerCase().contains(value.toLowerCase()) ||
              element.numero!.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      LogoWidget(),
      // SizedBox(
      //   height: 5,
      // ),

      //inpute rechercher
      Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          onChanged: (value) => updateliste(value),
          style:
              TextStyle(color: Colors.black, decoration: TextDecoration.none),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(15), // même rayon que ClipRRect
              // borderSide: BorderSide(color: Colors.grey, width: 1.0),
              borderSide: const BorderSide(
                color:
                    Color.fromARGB(255, 195, 154, 5), // Couleur de la bordure
                width: 1.5, // Largeur de la bordure
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: Color.fromARGB(255, 195, 154, 5),
                width: 1.5,
              ), // Couleur de la bordure lorsqu'elle est en état de focus
            ),
            hintText: "Rechercher",
            hintStyle: TextStyle(color: Colors.black45),
            prefixIcon: Icon(Icons.search),
            prefixIconColor: Colors.black45,
            contentPadding: EdgeInsets.symmetric(vertical: 13),
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
                      fontSize: 18,
                      fontWeight: FontWeight.w700),
                ),
              )
            : ListView.builder(
                itemCount: displaye_liste.length,
                itemBuilder: (context, index) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Color.fromARGB(
                          255, 206, 163, 5), // Couleur de la bordure
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
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Text(
                          displaye_liste[index].numero!,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                        Spacer(), // Ajouter un espace flexible entre les deux éléments

                        InkWell(
                          onTap: () {
                            // Action à effectuer lors du tapotement
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
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
                                color: Color.fromARGB(
                                    255, 206, 163, 5), // Couleur de la bordure
                                width: 1, // Largeur de la bordure
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Voir plus ',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 206, 163, 5),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Color.fromARGB(255, 206, 163, 5),
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    leading: Image.asset('assets/image/customer.png'),
                  ),
                ),
                // ),
              ),
      )
    ]);
  }
}
