import 'dart:convert';
import 'dart:io';
import 'package:Metre/bottom_navigationbar/navigation_page.dart';
import 'package:Metre/services/CustomIntercepter.dart';
import 'package:Metre/services/TokenManager.dart';
import 'package:Metre/widgets/CustomSnackBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_file_picker/form_builder_file_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart'; // Importez le package intl

class CreateCommandePage extends StatefulWidget {
  final String proprioId;
  const CreateCommandePage({Key? key, required this.proprioId})
      : super(key: key);

  @override
  State<CreateCommandePage> createState() => _CreateCommandePageState();
}

class _CreateCommandePageState extends State<CreateCommandePage> {
  int photoIndex = 0; // Déclarez la variable ici.
  bool isLoading = false; // Variable d'état pour le chargement

  final _formKey = GlobalKey<FormBuilderState>();
  final ImagePicker _picker = ImagePicker();

  // Listes dynamiques pour tissus et modèles
  List<Map<String, dynamic>> tissus = [];

  String? _id;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadUserData().then((_) {});
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _id = prefs.getString('id');
      _token = prefs.getString('token');
    });
  }

  // Fonction pour ajouter une photo
  Future<File?> pickPhoto() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      return image != null ? File(image.path) : null;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection de l\'image')),
      );
      return null;
    }
  }

  // Fonction pour ajouter un tissu
  void addTissu() {
    setState(() {
      tissus.add({
        "nom": "",
        "couleur": "",
        // "nombre": "",
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
  }

  // Fonction pour ajouter un modèle
  void addModele(int tissuIndex) {
    setState(() {
      tissus[tissuIndex]["modeles"].add({
        "nom": "",
        // "nombre": "",
        "description": "", "photos": []
      });
    });
  }

  void removeModele(int tissuIndex, int modelIndex) {
    setState(() {
      tissus[tissuIndex]["modeles"].removeAt(modelIndex);
    });
  }

  // Fonction pour choisir plusieurs images
  Future<List<File>> pickMultipleImages() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage();
      return images != null
          ? images.map((image) => File(image.path)).toList()
          : [];
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection des images')),
      );
      return [];
    }
  }

  Future<http.MultipartRequest> _createMultipartRequest() async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.56.1:8010/api/commandes'),
    );
    return request;
  }

  Future<void> submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        isLoading = true; // Activer le chargement
      });

      final formData = _formKey.currentState!.value;
      final client = CustomIntercepter(http.Client());

      try {
        // Utiliser "TokenManager" avant avant de lancer la requête
        // var token = await TokenManager.getValidToken();
        // if (token == null) {
        //   throw Exception("Impossible d'obtenir un token valide.");
        // }
        // var request = http.MultipartRequest(
        //   'POST',
        //   Uri.parse('http://192.168.56.1:8010/api/commandes'),
        // );
        var request = await _createMultipartRequest();

        // Ajouter l'en-tête d'authentification
        // if (_token != null && _id != null) {
        //   request.headers['Authorization'] = 'Bearer $_token';
        // } else {
        //   throw Exception("Token non défini ou vide.");
        // }

        // Ajouter les champs principaux
        request.fields['prix'] = formData['prix'] ?? '';
        // request.fields['dateRdv'] = formData['dateRdv'].toString();
        // Formater la date
        if (formData['dateRdv'] != null) {
          final formattedDate =
              DateFormat('yyyy-MM-dd').format(formData['dateRdv']);
          request.fields['dateRdv'] = formattedDate;
        }
        request.fields['clientId'] = widget.proprioId.toString();
        request.fields['utilisateurId'] = _id.toString();
        request.fields['nbtissu'] = formData['nbtissu'].toString();
        request.fields['nbmodele'] = formData['nbmodele'].toString();

        // Traiter les tissus et leurs images
        for (int i = 0; i < tissus.length; i++) {
          final tissu = tissus[i];

          if (tissu != null) {
            request.fields['tissus[$i].nom'] = tissu["nom"] ?? '';
            request.fields['tissus[$i].couleur'] = tissu["couleur"] ?? '';
            // request.fields['tissus[$i].quantite'] =
            //     tissu["quantite" + " mètre"]?.toString() ?? '';
            request.fields['tissus[$i].quantite'] =
                '${tissu["quantite"]?.toString() ?? ''} metres';
            request.fields['tissus[$i].fournipar'] = tissu["fournipar"] ?? '';

            // Ajouter les photos des tissus
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
            // Ajouter les modèles associés
            if (tissu["modeles"] != null) {
              for (int k = 0; k < tissu["modeles"].length; k++) {
                final modele = tissu["modeles"][k];
                if (modele != null) {
                  request.fields['tissus[$i].modeles[$k].nom'] =
                      modele["nom"] ?? '';
                  request.fields['tissus[$i].modeles[$k].description'] =
                      modele["description"] ?? '';

                  // Ajouter les photos des modèles
                  if (modele["photos"] != null) {
                    for (int l = 0; l < modele["photos"].length; l++) {
                      File photo = modele["photos"][l];
                      if (photo.existsSync()) {
                        var mimeTypeData =
                            lookupMimeType(photo.path)?.split('/');
                        var photoFile = await http.MultipartFile.fromPath(
                          'tissus[$i].modeles[$k].photos[$l]',
                          photo.path,
                          contentType:
                              MediaType(mimeTypeData![0], mimeTypeData[1]),
                        );
                        request.files.add(photoFile);
                      }
                    }
                  }
                }
              }
            }
          }
        }

        // Envoyer la requête
        // Envoyer la requête avec l'intercepteur
        var response = await client.send(request);
        // var response = await request.send();
        if (response.statusCode == 202) {
          final responseData = await response.stream.bytesToString();
          var decodedJson = json.decode(responseData);
          CustomSnackBar.show(context,
              message: '${decodedJson['message']}', isError: false);
          // _resetForm();
          messageCreation();
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //       content: Text('Commande créée avec succès : $responseData')),
          // );
        } else {
          final errorData = await response.stream.bytesToString();
          var decodedJson = json.decode(errorData);
          CustomSnackBar.show(context,
              message: '${decodedJson['message']}', isError: true);
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //       content: Text('Erreur : ${response.reasonPhrase}\n$errorData')),
          // );
          print('Erreur : ${response.reasonPhrase}\n$errorData');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Une erreur s\'est produite : $e')),
        );
      } finally {
        setState(() {
          isLoading = false; // Désactiver le chargement
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Veuillez corriger les erreurs dans le formulaire.')),
      );
    }
  }

  // Fonction pour réinitialiser le formulaire
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
        backgroundColor: Theme.of(context)
            .colorScheme
            .background, // Changez cette couleur selon vos besoins
      ),
      body: Stack(
        children: [
          Padding(
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
                    // ::::::::::::::::::::::::::::::::::::::::::::::::::::
                    // FormBuilderTextField(
                    //   name: 'dateRdv',
                    //   keyboardType: TextInputType.text,
                    //   style: TextStyle(
                    //       fontSize: 10.sp,
                    //       color: Theme.of(context).colorScheme.tertiary),
                    //   decoration: InputDecoration(
                    //     prefixIcon: Icon(
                    //       Icons.date_range,
                    //       color: Color.fromARGB(255, 132, 134, 135),
                    //       size: 18.sp,
                    //     ),
                    //     hintText: "Exp: aaaa/mm/jj",
                    //     hintStyle: TextStyle(
                    //       color: Color.fromARGB(255, 132, 134, 135),
                    //       fontSize: 10.sp,
                    //     ),
                    //     labelText: 'Date RDV',
                    //     labelStyle: TextStyle(
                    //         color: Color.fromARGB(255, 132, 134, 135),
                    //         fontSize: 10.sp),
                    //     enabledBorder: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(10),
                    //       borderSide: BorderSide(
                    //         color: Color.fromARGB(
                    //             255, 206, 136, 5), // Couleur de la bordure
                    //         width: 0.4.w, // Largeur de la bordure
                    //       ),
                    //     ),
                    //     focusedBorder: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(10),
                    //       borderSide: BorderSide(
                    //         color: Color.fromARGB(255, 206, 136, 5),
                    //         width: 0.4.w,
                    //       ), // Couleur de la bordure lorsqu'elle est en état de focus
                    //     ),
                    //     errorBorder: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(10),
                    //       borderSide: BorderSide(
                    //         color: Colors.red,
                    //         width: 0.4.w,
                    //       ), // Couleur de la bordure lorsqu'elle est en état de focus
                    //     ),
                    //     contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                    //     border: OutlineInputBorder(),
                    //   ),
                    //   validator: FormBuilderValidators.compose([
                    //     FormBuilderValidators.required(),
                    //   ]),
                    // ),
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
                                color: Theme.of(context).colorScheme.tertiary),
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
                                color: Theme.of(context).colorScheme.tertiary),
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
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => removeTissu(index),
                                  ),
                                ],
                              ),
                              FormBuilderTextField(
                                name: 'tissuNom$index',
                                keyboardType: TextInputType.text,
                                style: TextStyle(
                                    fontSize: 10.sp,
                                    color:
                                        Theme.of(context).colorScheme.tertiary),
                                decoration: _textFieldDecoration(
                                  hintText: "Exp: Super sans",
                                  labelText: 'Nom',
                                  prefixIcon: Icon(
                                    Icons.text_fields_rounded,
                                    color: Color.fromARGB(255, 132, 134, 135),
                                    size: 18.sp,
                                  ),
                                ),
                                onChanged: (value) => tissu["nom"] = value,
                              ),
                              SizedBox(height: 1.h),
                              FormBuilderTextField(
                                name: 'tissuCouleur$index',
                                keyboardType: TextInputType.text,
                                style: TextStyle(
                                    fontSize: 10.sp,
                                    color:
                                        Theme.of(context).colorScheme.tertiary),
                                decoration: _textFieldDecoration(
                                  hintText: "Exp: Rouge",
                                  labelText: 'Couleur',
                                  prefixIcon: Icon(
                                    Icons.color_lens_rounded,
                                    color: Color.fromARGB(255, 132, 134, 135),
                                    size: 18.sp,
                                  ),
                                ),
                                onChanged: (value) => tissu["couleur"] = value,
                              ),
                              SizedBox(height: 1.h),
                              FormBuilderTextField(
                                name: 'tissuQuantite$index',
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                    fontSize: 10.sp,
                                    color:
                                        Theme.of(context).colorScheme.tertiary),
                                decoration: _textFieldDecoration(
                                  hintText: "Exp: 3",
                                  labelText: 'Quantité',
                                  prefixIcon: Icon(
                                    Icons.inbox,
                                    color: Color.fromARGB(255, 132, 134, 135),
                                    size: 18.sp,
                                  ),
                                ),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(),
                                  FormBuilderValidators.numeric()
                                ]),
                                onChanged: (value) => tissu["quantite"] = value,
                              ),
                              SizedBox(height: 1.h),
                              FormBuilderDropdown<String>(
                                name: 'fournipar$index',
                                style: TextStyle(
                                    fontSize: 10.sp,
                                    color:
                                        Theme.of(context).colorScheme.tertiary),
                                decoration: _textFieldDecoration(
                                    labelText: "Fourni par",
                                    prefixIcon: Icon(
                                      Icons.assignment_ind,
                                      color: Color.fromARGB(255, 132, 134, 135),
                                      size: 18.sp,
                                    ),
                                    hintText: 'choisissez...'),
                                items: [
                                  'PARENTREPRISE',
                                  'PARCLIENT',
                                ]
                                    .map((fournisseur) => DropdownMenuItem(
                                          value: fournisseur,
                                          child: Text(
                                            fournisseur,
                                            style: TextStyle(fontSize: 10.sp),
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (value) =>
                                    tissu["fournipar"] = value,
                                validator: FormBuilderValidators.required(),
                              ),
                              SizedBox(height: 2.h),
                              Container(
                                // color: Colors.red,
                                margin:
                                    EdgeInsets.only(left: 0.5.h, right: 2.h),
                                child: InkWell(
                                  onTap: () async {
                                    List<File> images =
                                        await pickMultipleImages();
                                    setState(() {
                                      tissu["photos"].addAll(images);
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Cliquer pour ajouter un photo ",
                                        style: TextStyle(
                                          fontSize: 9.sp,
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
                                  children: tissu["photos"].map<Widget>((file) {
                                    return Stack(
                                      children: [
                                        Image.file(file,
                                            height: 15.h, width: 25.w),
                                        Positioned(
                                          top: 0.h,
                                          right: 0.w,
                                          child: IconButton(
                                            icon: Icon(Icons.delete_forever,
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
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(255, 206, 136, 5),
                                  ),
                                  onPressed: () => addModele(index),
                                  child: Text(
                                    'Ajouter un modèle',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 8.sp),
                                  ),
                                ),
                              ),
                              ...tissu["modeles"]
                                  .asMap()
                                  .entries
                                  .map((modelEntry) {
                                int modelIndex = modelEntry.key;
                                Map<String, dynamic> modele = modelEntry.value;

                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Modèle ${modelIndex + 1}',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            IconButton(
                                              icon: Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () => removeModele(
                                                  index, modelIndex),
                                            ),
                                          ],
                                        ),
                                        TextField(
                                          style: TextStyle(
                                              fontSize: 10.sp,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .tertiary),
                                          decoration: _textFieldDecoration(
                                              hintText: 'Exp: Chemise complet',
                                              alignLabelWithHint: false,
                                              labelText: 'Nom du modèle'),
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
                                              modele["description"] = value,

                                          // minLines: 2,
                                          maxLines: 3,
                                          // expands: true,
                                        ),
                                        SizedBox(
                                          height: 2.h,
                                        ),
                                        Container(
                                          // color: Colors.red,
                                          margin: EdgeInsets.only(
                                              left: 0.5.h, right: 2.h),
                                          child: InkWell(
                                            onTap: () async {
                                              List<File> images =
                                                  await pickMultipleImages();
                                              setState(() {
                                                modele["photos"].addAll(images);
                                              });
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  "Cliquer pour ajouter un photo ",
                                                  style: TextStyle(
                                                    fontSize: 8.sp,
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
                                            children: modele["photos"]
                                                .map<Widget>((file) {
                                              return Stack(
                                                children: [
                                                  Image.file(file,
                                                      height: 15.h,
                                                      width: 25.w),
                                                  Positioned(
                                                    top: 0.h,
                                                    right: 0.w,
                                                    child: IconButton(
                                                      icon: Icon(
                                                          Icons.delete_forever,
                                                          color: Colors.red),
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
                              }).toList(),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 206, 136, 5),
                        ),
                        onPressed: addTissu,
                        child: Text(
                          'Ajouter un tissu',
                          style: TextStyle(color: Colors.white, fontSize: 8.sp),
                        ),
                      ),
                    ),
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
                            style:
                                TextStyle(color: Colors.white, fontSize: 8.sp),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 206, 136, 5),
                          ),
                          onPressed: submitForm,
                          child: Text(
                            'Créer la commande',
                            style: TextStyle(
                                // color: Theme.of(context).colorScheme.tertiary,
                                color: Colors.white,
                                fontSize: 8.sp),
                          ),
                        ),
                      ],
                    ),
                  ],
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
    );
  }

  // Widget _buildTextField(
  //     {required String name,
  //     required String hintText,
  //     required String labelText,
  //     TextInputType? keyboardType,
  //     FormFieldValidator? validator,
  //     ValueChanged<String?>? onChanged}) {
  //   return FormBuilderTextField(
  //     name: name,
  //     keyboardType: keyboardType,
  //     style: TextStyle(
  //         fontSize: 10.sp, color: Theme.of(context).colorScheme.tertiary),
  //     decoration:
  //         _textFieldDecoration(hintText: hintText, labelText: labelText),
  //     validator: validator,
  //     onChanged: onChanged,
  //   );
  // }

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
