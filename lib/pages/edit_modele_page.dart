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

class EditModelePage extends StatefulWidget {
  final Commande commande;
  final int tissuIndex;
  final int modeleIndex;

  EditModelePage(
      {required this.commande,
      required this.tissuIndex,
      required this.modeleIndex});

  @override
  State<EditModelePage> createState() => _EditModelePageState();
}

// Définir la classe FichierModele pour gérer les données de fichier
class FichierModele {
  String? id;
  String? urlfichier;
  FichierModele({this.id, this.urlfichier});
}

class _EditModelePageState extends State<EditModelePage> {
  final http.Client client = CustomIntercepter(http.Client());
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _modeleData;
  List<FichierModele> _fichiersModeles = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Modele modele =
        widget.commande.tissus![widget.tissuIndex].modeles![widget.modeleIndex];
    _modeleData = {
      'id': modele.id,
      'nom': modele.nom,
      'description': modele.description,
    };
    // mise a jour des fichier
    _fetchFichiersModeles();
  }

  Future<void> _fetchFichiersModeles() async {
    setState(() {
      _isLoading = true;
    });
    Modele modele =
        widget.commande.tissus![widget.tissuIndex].modeles![widget.modeleIndex];

    if (modele.fichiersModeles != null) {
      _fichiersModeles = modele.fichiersModeles!
          .map(
              (file) => FichierModele(id: file.id, urlfichier: file.urlfichier))
          .toList();
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateModele() async {
    if (_formKey.currentState!.validate()) {
      final url =
          'http://192.168.56.1:8010/api/modeles/update/${_modeleData['id']}';

      try {
        final response = await client.put(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'nom': _modeleData['nom'],
            'description': _modeleData['description'],
          }),
        );

        if (response.statusCode == 202) {
          final responseData = jsonDecode(response.body);
          CustomSnackBar.show(context,
              message: '${responseData['message']}', isError: false);
          _fetchFichiersModeles();
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

  // Fonction pour ajouter un fichier
  Future<void> _addFichierModele() async {
    setState(() {
      _isLoading = true;
    });
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.isNotEmpty) {
      File file = File(result.files.single.path!);
      final url =
          'http://192.168.56.1:8010/fichier/addfichierModeles/${_modeleData['id']}';

      try {
        var request = http.MultipartRequest('POST', Uri.parse(url));
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
        final response = await client.send(request);
        final responseData = await http.Response.fromStream(response);

        if (responseData.statusCode == 202) {
          final jsonResponse = jsonDecode(responseData.body);
          // Mise à jour immédiate de la liste
          setState(() {
            _fichiersModeles.add(
                FichierModele(id: null, urlfichier: jsonResponse['message']));
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

  Future<void> _deleteFichierModele(String idFichier) async {
    setState(() {
      _isLoading = true;
    });
    final url = 'http://192.168.56.1:8010/fichier/fichiersmodeles/$idFichier';

    try {
      final response = await client.delete(
        Uri.parse(url),
      );

      if (response.statusCode == 202) {
        setState(() {
          _fichiersModeles.removeWhere((element) => element.id == idFichier);
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

  InputDecoration _inputDecoration(
      {String? hintText,
      String? labelText,
      Widget? prefixIcon,
      bool alignLabelWithHint = false}) {
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
          'Modifier le modèle',
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
                          'Modèle ${widget.modeleIndex + 1} du tissu ${widget.tissuIndex + 1}:',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        TextFormField(
                          initialValue: _modeleData['nom'],
                          style: TextStyle(fontSize: 10.sp),
                          decoration: _inputDecoration(
                            labelText: 'Nom',
                          ),
                          maxLength: 50,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Le nom est requis'
                              : null,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(50),
                          ],
                          onChanged: (value) =>
                              setState(() => _modeleData['nom'] = value),
                        ),
                        SizedBox(
                          height: 1.5.h,
                        ),
                        TextFormField(
                          initialValue: _modeleData['description'],
                          style: TextStyle(fontSize: 10.sp),
                          decoration: _inputDecoration(
                            labelText: 'Description',
                            alignLabelWithHint: true,
                          ),
                          maxLines: 5,
                          maxLength: 200,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(200),
                          ],
                          onChanged: (value) => setState(
                              () => _modeleData['description'] = value),
                        ),
                        SizedBox(height: 1.5.h),
                        // Partie pour afficher les images et les boutons de suppression
                        if (_fichiersModeles.isNotEmpty)
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
                                  children: _fichiersModeles
                                      .map((file) => Stack(
                                            alignment: Alignment.topRight,
                                            children: [
                                              if (file.urlfichier != null)
                                                Builder(
                                                  builder: (context) {
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
                                                    _deleteFichierModele(
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
                          onPressed: _addFichierModele,
                          icon: Icon(
                            Icons.add_a_photo,
                            size: 12.sp,
                          ),
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
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 1.h, bottom: 1.h),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      _updateModele();
                    },
                    icon: Icon(
                      Icons.edit_note,
                      size: 12.sp,
                    ),
                    label: Text(
                      "Modifier le modèle",
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
