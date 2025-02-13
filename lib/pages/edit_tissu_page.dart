import 'dart:convert';
import 'dart:io';
import 'package:Metre/models/commande_model.dart';
import 'package:Metre/services/CustomIntercepter.dart';
import 'package:Metre/widgets/CustomSnackBar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';

class EditTissuPage extends StatefulWidget {
  final Commande commande;
  final int tissuIndex;

  EditTissuPage({required this.commande, required this.tissuIndex});

  @override
  State<EditTissuPage> createState() => _EditTissuPageState();
}

class _EditTissuPageState extends State<EditTissuPage> {
  final http.Client client = CustomIntercepter(http.Client());
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _tissuData;
  List<String> _fournisseurs = ['PARCLIENT', 'PARENTREPRISE'];
  // Liste pour stocker les données des fichiers
  List<FichierTissu> _fichiersTissus = [];

  bool _isLoading = false; // Indique si une requête est en cours

  @override
  void initState() {
    super.initState();
    Tissu tissu = widget.commande.tissus![widget.tissuIndex];
    String? fournipar = tissu.fournipar;
    if (fournipar == null || !_fournisseurs.contains(fournipar)) {
      fournipar = _fournisseurs.first;
    }
    _tissuData = {
      'id': tissu.id,
      'nom': tissu.nom,
      'quantite': tissu.quantite.toString(),
      'couleur': tissu.couleur,
      'fournipar': fournipar,
    };
    // // Récupérer les données des fichiers du tissu
    // if (tissu.fichiersTissus != null) {
    //   _fichiersTissus = tissu.fichiersTissus!
    //       .map((file) => FichierTissu(id: file.id, urlfichier: file.urlfichier))
    //       .toList();
    // }
    // mise a jour des fichier
    _fetchFichiersTissus();
  }

  Future<void> _fetchFichiersTissus() async {
    setState(() {
      _isLoading = true;
    });
    Tissu tissu = widget.commande.tissus![widget.tissuIndex];

    if (tissu.fichiersTissus != null) {
      _fichiersTissus = tissu.fichiersTissus!
          .map((file) => FichierTissu(id: file.id, urlfichier: file.urlfichier))
          .toList();
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateTissu() async {
    if (_formKey.currentState!.validate()) {
      final url =
          'http://192.168.56.1:8010/api/tissus/update/${_tissuData['id']}';
      // print('Données envoyées: ${jsonEncode({
      //       'nom': _tissuData['nom'],
      //       'quantite': _tissuData['quantite'],
      //       'couleur': _tissuData['couleur'],
      //       'fournipar': _tissuData['fournipar'],
      //     })}');
      try {
        final response = await client.put(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'nom': _tissuData['nom'],
            'quantite': _tissuData['quantite'],
            'couleur': _tissuData['couleur'],
            'fournipar': _tissuData['fournipar'],
          }),
        );
        // print('Response status code: ${response.statusCode}');
        // print('Response body: ${response.body}');

        if (response.statusCode == 202) {
          final responseData = jsonDecode(response.body);
          CustomSnackBar.show(context,
              message: '${responseData['message']}', isError: false);
          _fetchFichiersTissus();
          Navigator.pop(context, true);
        } else {
          final responseData = jsonDecode(response.body);
          CustomSnackBar.show(context,
              message: '${responseData['message']}', isError: true);
        }
      } catch (e) {
        CustomSnackBar.show(context,
            message: 'Une erreur s\'est produite lors de la requête: $e',
            isError: true);
      }
    }
  }

  // Ajouter un fichier au tissu
  Future<void> _addFichierTissus() async {
    setState(() {
      _isLoading = true;
    });
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.isNotEmpty) {
      File file = File(result.files.single.path!);
      final url =
          'http://192.168.56.1:8010/fichier/addfichierTissus/${_tissuData['id']}';

      try {
        var request = http.MultipartRequest('POST', Uri.parse(url));
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
        final response = await client.send(request);
        final responseData = await http.Response.fromStream(response);

        if (responseData.statusCode == 202) {
          final jsonResponse = jsonDecode(responseData.body);
          // Mise à jour immédiate de la liste
          setState(() {
            _fichiersTissus.add(
                FichierTissu(id: null, urlfichier: jsonResponse['message']));
          });

          CustomSnackBar.show(context,
              message: '${jsonResponse['message']}', isError: false);
        } else {
          final jsonResponse = jsonDecode(responseData.body);
          CustomSnackBar.show(context,
              message: '${jsonResponse['message']}', isError: true);
        }
      } catch (e) {
        CustomSnackBar.show(context,
            message:
                'Une erreur s\'est produite lors de l\'ajout du fichier: $e',
            isError: true);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteFichierTissus(String idFichier) async {
    setState(() {
      _isLoading = true;
    });
    final url = 'http://192.168.56.1:8010/fichier/fichierstissus/$idFichier';

    try {
      final response = await client.delete(
        Uri.parse(url),
      );

      if (response.statusCode == 202) {
        setState(() {
          _fichiersTissus.removeWhere((element) => element.id == idFichier);
        });
        // mise a jour des fichiers
        // _fetchFichiersTissus();
        final jsonResponse = jsonDecode(response.body);
        CustomSnackBar.show(context,
            message: '${jsonResponse['message']}', isError: false);
      } else {
        final jsonResponse = jsonDecode(response.body);
        CustomSnackBar.show(context,
            message: '${jsonResponse['message']}', isError: true);
      }
    } catch (e) {
      CustomSnackBar.show(context,
          message:
              'Une erreur s\'est produite lors de la suppression du fichier: $e',
          isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  InputDecoration _inputDecoration({
    String? hintText,
    String? labelText,
    Widget? prefixIcon,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      prefixIcon: prefixIcon,
      hintText: hintText,
      hintStyle: TextStyle(
        color: Color.fromARGB(255, 132, 134, 135),
        fontSize: 10.sp,
      ),
      labelText: labelText,
      labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.tertiary, fontSize: 10.sp),
      alignLabelWithHint: alignLabelWithHint,
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
      contentPadding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
    );
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
        title: Text(
          'Modifier le tissu',
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.delete_forever,
                color: Colors.red,
              ))
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              children: [
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tissu ${widget.tissuIndex + 1}:',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        TextFormField(
                          initialValue: _tissuData['nom'],
                          style: TextStyle(fontSize: 10.sp),
                          decoration: _inputDecoration(
                            labelText: 'Nom',
                          ),
                          maxLength: 20,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Le nom est requis'
                              : null,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(20)
                          ],
                          onChanged: (value) => _tissuData['nom'] = value,
                        ),
                        SizedBox(height: 1.5.h),
                        TextFormField(
                          initialValue: _tissuData['quantite'],
                          // keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 10.sp),
                          decoration: _inputDecoration(
                            labelText: 'Quantité',
                          ),
                          maxLength: 20,
                          validator: (value) => value == null || value.isEmpty
                              ? 'La quantité est requise'
                              : null,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(20)
                          ],
                          onChanged: (value) => _tissuData['quantite'] = value,
                        ),
                        SizedBox(height: 1.5.h),
                        TextFormField(
                          initialValue: _tissuData['couleur'],
                          style: TextStyle(fontSize: 10.sp),
                          decoration: _inputDecoration(
                            labelText: 'Couleur',
                          ),
                          maxLength: 20,
                          validator: (value) => value == null || value.isEmpty
                              ? 'La couleur est requise'
                              : null,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(20)
                          ],
                          onChanged: (value) => _tissuData['couleur'] = value,
                        ),
                        SizedBox(height: 1.5.h),
                        DropdownButtonFormField<String>(
                          value: _tissuData['fournipar'],
                          style: TextStyle(fontSize: 10.sp),
                          items: _fournisseurs
                              .map((fournisseur) => DropdownMenuItem(
                                    value: fournisseur,
                                    child: Text(
                                      fournisseur,
                                      style: TextStyle(
                                          fontSize: 10.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary),
                                    ),
                                  ))
                              .toList(),
                          decoration: _inputDecoration(
                            labelText: 'Fourni par',
                          ),
                          onChanged: (value) => _tissuData['fournipar'] = value,
                        ),
                        SizedBox(height: 1.5.h),
                        // Partie pour afficher les images et les boutons de suppression
                        if (_fichiersTissus.isNotEmpty)
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Images:',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children: _fichiersTissus
                                      .map((file) => Stack(
                                            alignment: Alignment.topRight,
                                            children: [
                                              if (file.urlfichier != null)
                                                Builder(
                                                  builder: (context) {
                                                    // print(
                                                    //     'Image URL: ${file.urlfichier}');
                                                    return Image.network(
                                                      file.urlfichier!,
                                                      width: 80,
                                                      height: 80,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (BuildContext context,
                                                              Object error,
                                                              StackTrace?
                                                                  stackTrace) {
                                                        return Container(
                                                          color: Colors.grey,
                                                          width: 80,
                                                          height: 80,
                                                          child: Center(
                                                              child: Text(
                                                            'Erreur',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red),
                                                          )),
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () =>
                                                    _deleteFichierTissus(
                                                        file.id!),
                                              ),
                                            ],
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(
                          height: 1.5.h,
                        ),
                        ElevatedButton.icon(
                          onPressed: _addFichierTissus,
                          icon: Icon(Icons.add_a_photo, size: 12.sp),
                          label: Text(
                            "Ajouter un fichier",
                            style: TextStyle(fontSize: 10.sp),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 206, 136, 5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 1.h, bottom: 1.h),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      _updateTissu();
                    },
                    icon: Icon(
                      Icons.edit_note,
                      size: 12.sp,
                    ),
                    label: Text(
                      "Modifier le tissu",
                      style: TextStyle(fontSize: 10.sp),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 206, 136, 5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                if (_isLoading)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
