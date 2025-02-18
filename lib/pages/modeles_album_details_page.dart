import 'dart:convert';

import 'package:Metre/bottom_navigationbar/navigation_page.dart';
import 'package:Metre/models/modelesAlbum%20.dart';
import 'package:Metre/pages/edit_modeles_album_page.dart';
import 'package:Metre/services/ApiService.dart';
import 'package:Metre/services/CustomIntercepter.dart';
import 'package:Metre/widgets/CustomSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;

class ModelesAlbumDetailsPage extends StatefulWidget {
  final String albumId;

  const ModelesAlbumDetailsPage({Key? key, required this.albumId})
      : super(key: key);

  @override
  State<ModelesAlbumDetailsPage> createState() =>
      _ModelesAlbumDetailsPageState();
}

class _ModelesAlbumDetailsPageState extends State<ModelesAlbumDetailsPage> {
  final http.Client client =
      CustomIntercepter(http.Client()); // Initialiser le client ici
  final ApiService apiService = ApiService();
  ModelesAlbum? album;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlbumDetails();
  }

  Future<void> _loadAlbumDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      album = await apiService.getModelesAlbumById(widget.albumId);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading album details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // delete
  Future<void> _FunctiondeleteModele(String id) async {
    final url = 'http://192.168.56.1:8010/api/modeles-albums/delete/$id';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          icon: Icon(
            Icons.keyboard_backspace,
            size: 22.sp,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : album == null
              ? Center(child: Text('Album non trouvé.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: album!.images.isNotEmpty
                            ? Image.network(
                                album!.images[0],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                      child: Text('Erreur de chargement'));
                                },
                              )
                            : Center(
                                child: Text(
                                  "Aucune image disponible",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          "Nom : ${album!.nom}",
                          style: TextStyle(
                              fontSize: 11.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "Description : ${album!.description}",
                          style: TextStyle(fontSize: 10.sp),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "Catégorie : ${album!.categorie}",
                          style: TextStyle(fontSize: 10.sp),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          "Images:",
                          style: TextStyle(
                              fontSize: 12.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: album!.images.length,
                          itemBuilder: (context, index) {
                            final imageUrl = album!.images[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Center(
                                              child:
                                                  Text('Erreur de chargement'),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    imageUrl,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 100,
                                        height: 100,
                                        color: Colors.grey[300],
                                        child: Center(
                                          child: Text('Erreur',
                                              textAlign: TextAlign.center),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                      'Confirmer la suppression',
                                      style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    content: Text(
                                      'Êtes-vous sûr de vouloir supprimer ce modèle ?',
                                      style: TextStyle(fontSize: 10.sp),
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('Annuler',
                                            style: TextStyle(fontSize: 10.sp)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Color.fromARGB(255, 206, 136, 5),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: () async {
                                          _FunctiondeleteModele(widget.albumId);
                                          Navigator.of(context).pop();
                                          messageSuppression();
                                        },
                                        child: Text('Supprimer'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text('Supprimer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 206, 136, 5),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditModelesAlbumPage(album: album!),
                                ),
                              );

                              if (result == true) {
                                _loadAlbumDetails();
                              }
                            },
                            child: Text('Modifier'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  void messageSuppression() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Suppression réussie',
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Modèle supprimer avec succès ?',
            style: TextStyle(fontSize: 10.sp),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => NavigationBarPage(
                      initialIndex: 3, // Rediriger vers la page des clients
                    ),
                  ),
                );
              },
              child: Text('ok', style: TextStyle(fontSize: 10.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 206, 136, 5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
