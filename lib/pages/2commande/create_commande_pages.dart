import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:Metre/bottom_navigationbar/navigation_page.dart';
import 'package:Metre/models/modelesAlbum%20.dart';
import 'package:Metre/services/CustomIntercepter.dart';
import 'package:Metre/widgets/CustomSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';

class CreateCommandePages extends StatefulWidget {
  final String proprioId;
  final List<ModelesAlbum> selectedAlbums; // Accepter selectedAlbums

  const CreateCommandePages(
      {Key? key, required this.proprioId, required this.selectedAlbums})
      : super(key: key);

  @override
  State<CreateCommandePages> createState() => _CreateCommandePagesState();
}

class _CreateCommandePagesState extends State<CreateCommandePages> {
  int photoIndex = 0;
  bool isLoading = false;

  final _formKey = GlobalKey<FormBuilderState>();
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> tissus = [];

  String? _id;

  // Dans CreateCommandePages.dart
  @override
  void initState() {
    super.initState();
    _loadUserData().then((_) {
      // Initialiser les tissus avec les modèles sélectionnés
      if (widget.selectedAlbums.isNotEmpty) {
        tissus = widget.selectedAlbums.map((album) {
          return {
            "nom":
                "", // Vous pouvez initialiser avec des valeurs par défaut ou laisser l'utilisateur les remplir
            "couleur": "",
            "quantite": "",
            "fournipar": "",
            "photos": [],
            "modeles": [
              {
                "nom": album.nom,
                "description": album.description,
                "photos": album.images, // Garder les images sous forme d'URLs
              }
            ],
          };
        }).toList();
      }
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _id = prefs.getString('id');
    });
  }

  Future<File?> pickPhoto() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      return image != null ? File(image.path) : null;
    } catch (e) {
      CustomSnackBar.show(context,
          message: 'Erreur lors de la sélection de l\'image', isError: true);
      return null;
    }
  }

  void addTissu() {
    setState(() {
      tissus.add({
        "nom": "",
        "couleur": "",
        "quantite": "",
        "fournipar": "",
        "photos": [],
        "modeles": []
      });
    });
  }

  void removeTissu(int index) {
    setState(() {
      tissus.removeAt(index);
    });

    // Mettre à jour nbtissu et nbmodele
    _formKey.currentState?.fields['nbtissu']
        ?.didChange(tissus.length.toString());
    _formKey.currentState?.fields['nbmodele']
        ?.didChange(tissus.length.toString());
  }

  void addModele(int tissuIndex) {
    setState(() {
      tissus[tissuIndex]["modeles"]
          .add({"nom": "", "description": "", "photos": []});
    });
  }

  void removeModele(int tissuIndex, int modelIndex) {
    setState(() {
      tissus[tissuIndex]["modeles"].removeAt(modelIndex);
    });
  }

  Future<List<File>> pickMultipleImages() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage();
      return images != null
          ? images.map((image) => File(image.path)).toList()
          : [];
    } catch (e) {
      CustomSnackBar.show(context,
          message: 'Erreur lors de la sélection des images', isError: true);
      return [];
    }
  }

  Future<void> submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        isLoading = true;
      });

      final formData = _formKey.currentState!.value;
      final client = CustomIntercepter(http.Client());

      try {
        var request = http.MultipartRequest(
            'POST',
            Uri.parse(
                'http://192.168.56.1:8010/api/commandes/createCommande')); // Assure-toi que l'URL est correcte

        // Ajouter les champs de base
        request.fields['prix'] = formData['prix'] ?? '';
        if (formData['dateRdv'] != null) {
          final formattedDate = DateFormat('yyyy-MM-dd')
              .format(formData['dateRdv'] as DateTime); //Cast as DateTime
          request.fields['dateRdv'] = formattedDate;
        }
        request.fields['clientId'] = widget.proprioId.toString();
        request.fields['utilisateurId'] = _id.toString();
        request.fields['nbtissu'] =
            formData['nbtissu']?.toString() ?? '0'; //Default value
        request.fields['nbmodele'] =
            formData['nbmodele']?.toString() ?? '0'; //Default value

        // Préparer les données des tissus
        for (int i = 0; i < tissus.length; i++) {
          final tissu = tissus[i];

          if (tissu != null) {
            request.fields['tissus[$i].nom'] = tissu["nom"] ?? '';
            request.fields['tissus[$i].couleur'] = tissu["couleur"] ?? '';
            request.fields['tissus[$i].quantite'] =
                '${tissu["quantite"]?.toString() ?? ''} metres';
            request.fields['tissus[$i].fournipar'] = tissu["fournipar"] ?? '';

            // Gérer les photos des tissus
            if (tissu["photos"] != null) {
              for (int j = 0; j < tissu["photos"].length; j++) {
                File photo = tissu["photos"][j];
                if (photo.existsSync()) {
                  var mimeTypeData = lookupMimeType(photo.path)?.split('/');
                  var photoFile = await http.MultipartFile.fromPath(
                    'tissus[$i].photos[$j]',
                    photo.path,
                    contentType: MediaType(mimeTypeData![0], mimeTypeData[1]),
                  );
                  request.files.add(photoFile);
                }
              }
            }

            // Gérer les modèles
            if (tissu["modeles"] != null) {
              for (int k = 0; k < tissu["modeles"].length; k++) {
                final modele = tissu["modeles"][k];

                if (modele != null) {
                  request.fields['tissus[$i].modeles[$k].nom'] =
                      modele["nom"] ?? '';
                  request.fields['tissus[$i].modeles[$k].description'] =
                      modele["description"] ?? '';

                  // Gérer les photos des modèles (String ou File)
                  if (modele["photos"] != null) {
                    for (int l = 0; l < modele["photos"].length; l++) {
                      var photo = modele["photos"][l];

                      if (photo is File) {
                        // C'est un fichier
                        if (photo.existsSync()) {
                          var mimeTypeData =
                              lookupMimeType(photo.path)?.split('/');
                          var photoFile = await http.MultipartFile.fromPath(
                            'tissus[$i].modeles[$k].photos[$l]', // Nom du champ pour les fichiers
                            photo.path,
                            contentType:
                                MediaType(mimeTypeData![0], mimeTypeData[1]),
                          );
                          request.files.add(photoFile);
                        }
                      } else if (photo is String) {
                        // C'est une URL
                        request.fields['tissus[$i].modeles[$k].photos[$l]'] =
                            photo; // Envoyer l'URL directement
                      }
                    }
                  }
                }
              }
            }
          }
        }

        // Log des champs envoyés
        print('Champs envoyés : ${request.fields}');

        var response = await client.send(request);

        if (response.statusCode == 200 || response.statusCode == 202) {
          // Le serveur répond avec un code 200 OK ou 202 Accepted
          final responseData = await response.stream.bytesToString();
          var decodedJson = json.decode(responseData);
          CustomSnackBar.show(context,
              message: '${decodedJson['message']}', isError: false);
          // _resetForm();
          messageCreation(); // Call messageCreation here
        } else {
          // Le serveur répond avec un code d'erreur
          final errorData = await response.stream.bytesToString();
          print('Erreur : ${response.statusCode}\n$errorData');
          CustomSnackBar.show(context,
              message:
                  'Erreur lors de la création de la commande: ${response.statusCode}',
              isError: true);
        }
      } catch (e) {
        CustomSnackBar.show(context,
            message: 'Une erreur s\'est produite : $e', isError: true);

        print("Une erreur s\'est produite : $e");
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      CustomSnackBar.show(context,
          message: 'Veuillez corriger les erreurs dans le formulaire.',
          isError: true);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      tissus.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Enregistrer une Commande',
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
          ),
          backgroundColor: Theme.of(context).colorScheme.background,
        ),
        body: Stack(children: [
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FormBuilder(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informations générales',
                            style: TextStyle(
                                fontSize: 12.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 2.h),
                          FormBuilderTextField(
                            name: 'prix',
                            keyboardType: TextInputType.text,
                            style: TextStyle(
                                fontSize: 10.sp,
                                color: Theme.of(context).colorScheme.tertiary),
                            decoration: _textFieldDecoration(
                              hintText: "Exp: 1000",
                              labelText: " Prix",
                              prefixIcon: Icon(
                                Icons.local_offer,
                                color: Color.fromARGB(255, 132, 134, 135),
                                size: 18.sp,
                              ),
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.numeric(),
                            ]),
                          ),
                          SizedBox(height: 1.5.h),
                          FormBuilderDateTimePicker(
                            name: 'dateRdv',
                            style: TextStyle(
                                fontSize: 10.sp,
                                color: Theme.of(context).colorScheme.tertiary),
                            decoration: _textFieldDecoration(
                              hintText: "Exp: aaaa/mm/jj",
                              labelText: 'Date RDV',
                              prefixIcon: Icon(
                                Icons.date_range,
                                color: Color.fromARGB(255, 132, 134, 135),
                                size: 18.sp,
                              ),
                            ),
                            inputType: InputType.date,
                            locale: const Locale('fr', 'FR'),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                            ]),
                          ),
                          SizedBox(height: 1.5.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: FormBuilderTextField(
                                  name: 'nbtissu',
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                      fontSize: 10.sp,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary),
                                  decoration: _textFieldDecoration(
                                    hintText: "Exp: 1",
                                    labelText: 'Nombre de tissu',
                                    prefixIcon: Icon(
                                      Icons.layers_outlined,
                                      color: Color.fromARGB(255, 132, 134, 135),
                                      size: 18.sp,
                                    ),
                                  ),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(),
                                    FormBuilderValidators.numeric()
                                  ]),
                                ),
                              ),
                              SizedBox(width: 1.5.w),
                              Expanded(
                                child: FormBuilderTextField(
                                  name: 'nbmodele',
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                      fontSize: 10.sp,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary),
                                  decoration: _textFieldDecoration(
                                    hintText: "Exp: 1",
                                    labelText: 'Nombre de modele',
                                    prefixIcon: Icon(
                                      Icons.auto_awesome,
                                      color: Color.fromARGB(255, 132, 134, 135),
                                      size: 18.sp,
                                    ),
                                  ),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(),
                                    FormBuilderValidators.numeric()
                                  ]),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          ...tissus.asMap().entries.map((entry) {
                            int index = entry.key;
                            Map<String, dynamic> tissu = entry.value;
                            return Card(
                              elevation: 2,
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Tissu ${index + 1}',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () => removeTissu(index),
                                        ),
                                      ],
                                    ),
                                    FormBuilderTextField(
                                      name: 'tissuNom$index',
                                      keyboardType: TextInputType.text,
                                      style: TextStyle(
                                          fontSize: 10.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary),
                                      decoration: _textFieldDecoration(
                                        hintText: "Exp: Super sans",
                                        labelText: 'Nom',
                                        prefixIcon: Icon(
                                          Icons.text_fields_rounded,
                                          color: Color.fromARGB(
                                              255, 132, 134, 135),
                                          size: 18.sp,
                                        ),
                                      ),
                                      onChanged: (value) =>
                                          tissu["nom"] = value,
                                    ),
                                    SizedBox(height: 1.h),
                                    FormBuilderTextField(
                                      name: 'tissuCouleur$index',
                                      keyboardType: TextInputType.text,
                                      style: TextStyle(
                                          fontSize: 10.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary),
                                      decoration: _textFieldDecoration(
                                        hintText: "Exp: Rouge",
                                        labelText: 'Couleur',
                                        prefixIcon: Icon(
                                          Icons.color_lens_rounded,
                                          color: Color.fromARGB(
                                              255, 132, 134, 135),
                                          size: 18.sp,
                                        ),
                                      ),
                                      onChanged: (value) =>
                                          tissu["couleur"] = value,
                                    ),
                                    SizedBox(height: 1.h),
                                    FormBuilderTextField(
                                      name: 'tissuQuantite$index',
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          fontSize: 10.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary),
                                      decoration: _textFieldDecoration(
                                        hintText: "Exp: 3",
                                        labelText: 'Quantité',
                                        prefixIcon: Icon(
                                          Icons.inbox,
                                          color: Color.fromARGB(
                                              255, 132, 134, 135),
                                          size: 18.sp,
                                        ),
                                      ),
                                      validator: FormBuilderValidators.compose([
                                        FormBuilderValidators.required(),
                                        FormBuilderValidators.numeric()
                                      ]),
                                      onChanged: (value) =>
                                          tissu["quantite"] = value,
                                    ),
                                    SizedBox(height: 1.h),
                                    FormBuilderDropdown<String>(
                                      name: 'fournipar$index',
                                      style: TextStyle(
                                          fontSize: 10.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary),
                                      decoration: _textFieldDecoration(
                                          labelText: "Fourni par",
                                          prefixIcon: Icon(
                                            Icons.assignment_ind,
                                            color: Color.fromARGB(
                                                255, 132, 134, 135),
                                            size: 18.sp,
                                          ),
                                          hintText: 'choisissez...'),
                                      items: [
                                        'PARENTREPRISE',
                                        'PARCLIENT',
                                      ]
                                          .map(
                                              (fournisseur) => DropdownMenuItem(
                                                    value: fournisseur,
                                                    child: Text(
                                                      fournisseur,
                                                      style: TextStyle(
                                                          fontSize: 10.sp),
                                                    ),
                                                  ))
                                          .toList(),
                                      onChanged: (value) =>
                                          tissu["fournipar"] = value,
                                      validator:
                                          FormBuilderValidators.required(),
                                    ),
                                    SizedBox(height: 2.h),
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: 0.5.h, right: 2.h),
                                      child: InkWell(
                                        onTap: () async {
                                          List<File> images =
                                              await pickMultipleImages();
                                          setState(() {
                                            tissu["photos"].addAll(images);
                                          });
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              "Cliquer pour ajouter un photo ",
                                              style: TextStyle(
                                                fontSize: 9.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(
                                                    255, 206, 136, 5),
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  left: 5.0),
                                              child: Icon(
                                                Icons.add_circle,
                                                color: Color.fromARGB(
                                                    255, 206, 136, 5),
                                                size: 14.sp,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Wrap(
                                        children:
                                            tissu["photos"].map<Widget>((file) {
                                          return Stack(
                                            children: [
                                              Image.file(file,
                                                  height: 15.h, width: 25.w),
                                              Positioned(
                                                top: 0.h,
                                                right: 0.w,
                                                child: IconButton(
                                                  icon: Icon(
                                                      Icons.delete_forever,
                                                      color: Colors.red),
                                                  onPressed: () {
                                                    setState(() {
                                                      tissu["photos"]
                                                          .removeAt(photoIndex);
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    ...tissu["modeles"].asMap().entries.map(
                                      (modelEntry) {
                                        int modelIndex = modelEntry.key;
                                        Map<String, dynamic> modele =
                                            modelEntry.value;

                                        return Card(
                                          margin:
                                              EdgeInsets.symmetric(vertical: 8),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                        'Modèle ${modelIndex + 1}',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                ),
                                                TextField(
                                                  style: TextStyle(
                                                      fontSize: 10.sp,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .tertiary),
                                                  decoration: _textFieldDecoration(
                                                      hintText:
                                                          'Exp: Chemise complet',
                                                      alignLabelWithHint: false,
                                                      labelText:
                                                          'Nom du modèle'),
                                                  onChanged: (value) =>
                                                      modele["nom"] = value,
                                                ),
                                                SizedBox(
                                                  height: 1.5.h,
                                                ),
                                                TextField(
                                                  style: TextStyle(
                                                      fontSize: 10.sp,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .tertiary),
                                                  decoration: _textFieldDecoration(
                                                      hintText:
                                                          'plus d\'explication ....',
                                                      alignLabelWithHint: true,
                                                      labelText: 'Description'),
                                                  onChanged: (value) =>
                                                      modele["description"] =
                                                          value,
                                                  maxLines: 3,
                                                ),
                                                SizedBox(
                                                  height: 2.h,
                                                ),
                                                // Container(
                                                //   margin: EdgeInsets.only(
                                                //       left: 0.5.h, right: 2.h),
                                                //   child: InkWell(
                                                //     onTap: () async {
                                                //       List<File> images =
                                                //           await pickMultipleImages();
                                                //       setState(() {
                                                //         modele["photos"]
                                                //             .addAll(images);
                                                //       });
                                                //     },
                                                //     child: Row(
                                                //       mainAxisAlignment:
                                                //           MainAxisAlignment.end,
                                                //       children: [
                                                //         Text(
                                                //           "Cliquer pour ajouter un photo ",
                                                //           style: TextStyle(
                                                //             fontSize: 8.sp,
                                                //             fontWeight:
                                                //                 FontWeight.bold,
                                                //             color:
                                                //                 Color.fromARGB(
                                                //                     255,
                                                //                     206,
                                                //                     136,
                                                //                     5),
                                                //           ),
                                                //         ),
                                                //         Container(
                                                //           margin:
                                                //               const EdgeInsets
                                                //                   .only(
                                                //                   left: 5.0),
                                                //           child: Icon(
                                                //             Icons.add_circle,
                                                //             color:
                                                //                 Color.fromARGB(
                                                //                     255,
                                                //                     206,
                                                //                     136,
                                                //                     5),
                                                //             size: 14.sp,
                                                //           ),
                                                //         )
                                                //       ],
                                                //     ),
                                                //   ),
                                                // ),
                                                Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Wrap(
                                                    children: modele["photos"]
                                                        .map<Widget>((photo) {
                                                      Widget imageWidget;
                                                      if (photo is File) {
                                                        imageWidget =
                                                            Image.file(photo,
                                                                height: 15.h,
                                                                width: 25.w);
                                                      } else if (photo
                                                          is String) {
                                                        imageWidget =
                                                            Image.network(photo,
                                                                height: 15.h,
                                                                width: 25.w);
                                                      } else {
                                                        imageWidget = Text(
                                                            "Type d'image non pris en charge");
                                                      }

                                                      return Stack(
                                                        children: [
                                                          imageWidget,
                                                          Positioned(
                                                            top: 0.h,
                                                            right: 0.w,
                                                            child: IconButton(
                                                              icon: Icon(
                                                                  Icons
                                                                      .delete_forever,
                                                                  color: Colors
                                                                      .red),
                                                              onPressed: () {
                                                                setState(() {
                                                                  modele["photos"]
                                                                      .removeAt(
                                                                          photoIndex);
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ).toList(),
                                  ],
                                ),
                              ),
                            );
                          }),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () {
                                  print("creation de commande annuler");
                                },
                                child: Text(
                                  'Annuler la commande',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 8.sp),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color.fromARGB(255, 206, 136, 5),
                                ),
                                onPressed: submitForm,
                                child: Text(
                                  'Créer la commande',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 8.sp),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (isLoading)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ]));
  }

  InputDecoration _textFieldDecoration({
    required String hintText,
    required String labelText,
    bool alignLabelWithHint = false,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      prefixIcon: prefixIcon,
      hintText: hintText,
      hintStyle: TextStyle(
        color: Color.fromARGB(255, 132, 134, 135),
        fontSize: 10.sp,
      ),
      labelText: labelText,
      labelStyle:
          TextStyle(color: Color.fromARGB(255, 132, 134, 135), fontSize: 10.sp),
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

  void messageCreation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Creation réussie',
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Commande creer avec succès ?',
            style: TextStyle(fontSize: 10.sp),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => NavigationBarPage(
                      initialIndex: 2, // Rediriger vers la page des clients
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
