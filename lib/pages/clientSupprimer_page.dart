import 'dart:convert';

import 'package:Metre/bottom_navigationbar/navigation_page.dart';
import 'package:Metre/models/clients_model.dart';
import 'package:Metre/widgets/CustomSnackBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class ClientSupprimerPage extends StatefulWidget {
  const ClientSupprimerPage({super.key});

  @override
  State<ClientSupprimerPage> createState() => _ClientSupprimerPageState();
}

class _ClientSupprimerPageState extends State<ClientSupprimerPage> {
  List<ClientsModels> listeDesClients = [];
  List<ClientsModels> displayedListe = [];
  bool isLoading = true; // Indicateur de chargement

  String? _id;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadUserData().then((_) {
      _fetchClients();
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
    });
  }

  Future<void> _fetchClients() async {
    if (_id != null && _token != null) {
      final url = 'http://192.168.56.1:8010/clients/getdeletedByUser/$_id';

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
            isLoading = false; // Fin du chargement
          });
        } else {
          CustomSnackBar.show(context,
              message: 'Erreur lors du chargement des clients.', isError: true);

          setState(() {
            isLoading = false; // Fin du chargement même en cas d'erreur
          });
        }
      } catch (e) {
        CustomSnackBar.show(context,
            message: 'Une erreur s\'est produite. Veuillez réessayer.',
            isError: true);
        // print('Error: $e');
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //   content: Text('Une erreur s\'est produite. Veuillez réessayer.'),
        // ));
        setState(() {
          isLoading = false; // Fin du chargement même en cas d'erreur
        });
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
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.keyboard_backspace,
            size: 22.sp,
          ),
        ),
        title: Text(
          'Les clients supprimés',
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context)
            .colorScheme
            .background, // Changez cette couleur selon vos besoins
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    color: Color.fromARGB(
                        255, 206, 136, 5), // Couleur de la bordure
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
                            itemBuilder: (context, index) {
                              final client = displayedListe[index];

                              final String title =
                                  "${client.nom}  ${client.prenom} \n ${client.numero}";

                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 1.h, horizontal: 4.w),
                                child: Container(
                                  // margin: EdgeInsets.symmetric(vertical: 0.5.h),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Color.fromARGB(255, 206, 136,
                                          5), // Couleur de la bordure
                                      width: 0.4.w, // Largeur de la bordure
                                    ),
                                  ),
                                  child: ExpansionTile(
                                    trailing: Icon(
                                      Icons.visibility_outlined,
                                      size: 20.sp,
                                      color: Color.fromARGB(255, 206, 136, 5),
                                    ), // Icône à droite
                                    title: Row(
                                      children: [
                                        Image.asset(
                                            'assets/image/customer1.png'),
                                        SizedBox(width: 5.w),
                                        Text(
                                          title,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .tertiary,
                                            fontSize: 10.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildAlertInfoRow(
                                              'Adresse:',
                                              client.adresse ?? "neant",
                                              context,
                                            ),
                                            _buildAlertInfoRow(
                                              'Email:',
                                              client.email ?? "neant",
                                              context,
                                            ),
                                            SizedBox(height: 2.h),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 3.h),
                                                      backgroundColor:
                                                          Colors.red,
                                                      foregroundColor:
                                                          Colors.white,
                                                    ),
                                                    onPressed: () {
                                                      deleteClient();
                                                    },
                                                    child: Text(
                                                      "Supprimer",
                                                      style: TextStyle(
                                                        fontSize: 8.sp,
                                                        letterSpacing: 2,
                                                      ),
                                                    ),
                                                    // onPressed: () {
                                                    //   Navigator.of(context)
                                                    //       .pop(true); // Fermer le modal et retourner true
                                                    // },
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 3.w,
                                                ),
                                                Padding(
                                                  padding:
                                                      EdgeInsets.all(0.8.h),
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 3.h),
                                                      backgroundColor:
                                                          Color.fromARGB(
                                                              255, 206, 136, 5),
                                                      foregroundColor:
                                                          Colors.white,
                                                    ),
                                                    child: Text(
                                                      "Recuperer",
                                                      style: TextStyle(
                                                        fontSize: 8.sp,
                                                        letterSpacing: 2,
                                                      ),
                                                    ),
                                                    onPressed: () async {
                                                      // // ::::::::::::::::::::::::::::::::::::::::
                                                      _FunctiondeleteClient(
                                                          client.id ?? "null");
                                                      // //:::::::::::::::::::::::::::::::::::::::::::
                                                      // Attendre 5 secondes
                                                      // await Future.delayed(
                                                      //     Duration(seconds: 2));
                                                      Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                NavigationBarPage()),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
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
          ),
        ],
      ),
    );
  }

  Future<void> _FunctiondeleteClient(String id) async {
    final url = 'http://192.168.56.1:8010/clients/retrouverClients/$id';
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 202) {
      // setState(() {
      //   _fetchProprietaireMesure();
      // });
      final message = json.decode(response.body)['message'];

      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text('$message'),
      // ));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: EdgeInsets.all(8),
            height: 8.h,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 43, 158, 47),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20.sp,
                ),
                SizedBox(
                  width: 3.w,
                ),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Success :",
                      style: TextStyle(fontSize: 14.sp, color: Colors.white),
                    ),
                    Spacer(),
                    Text(
                      '$message',
                      style: TextStyle(fontSize: 12.sp, color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ))
              ],
            ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur: Une erreur est produite.'),
      ));
    }
  }

  Widget _buildAlertInfoRow(String label, String value, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 10.w),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: TextStyle(
                // fontWeight: FontWeight.bold,
                fontSize: 10.sp,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ),
          // SizedBox(width: 1.w),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(fontSize: 10.sp),
            ),
          ),
        ],
      ),
    );
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
            "Je vous conseil de ne pas totalement supprimer un client",
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
                // ElevatedButton(
                //   style: ElevatedButton.styleFrom(
                //     padding: EdgeInsets.symmetric(horizontal: 2.h),
                //     backgroundColor: Color.fromARGB(255, 206, 136, 5),
                //     foregroundColor: Colors.white,
                //   ),
                //   child: Text(
                //     "Annuler",
                //     style: TextStyle(
                //       fontSize: 8.sp,
                //       letterSpacing: 2,
                //     ),
                //   ),
                //   onPressed: () {
                //     Navigator.of(context).pop(); // Fermer la boîte de dialogue
                //   },
                // ),
                // ),
                // SizedBox(
                //   width: 3.w,
                // ),
                // Padding(
                //   padding: EdgeInsets.all(0.8.h),
                // child:
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 2.h),
                    backgroundColor: Color.fromARGB(255, 206, 136, 5),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    "Ok",
                    style: TextStyle(
                      fontSize: 8.sp,
                      letterSpacing: 2,
                    ),
                  ),
                  onPressed: () {
                    // ::::::::::::::::::::::::::::::::::::::::
                    // _FunctiondeleteClient();
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
}
