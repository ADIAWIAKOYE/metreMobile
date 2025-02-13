import 'dart:convert';

import 'package:Metre/models/user_model.dart';
import 'package:Metre/models/utilisateur_model.dart';
import 'package:Metre/services/CustomIntercepter.dart';
import 'package:Metre/widgets/CustomSnackBar.dart';
import 'package:Metre/widgets/Textfield_Widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;

class CollaborateurPage extends StatefulWidget {
  const CollaborateurPage({super.key});

  @override
  State<CollaborateurPage> createState() => _CollaborateurPageState();
}

class _CollaborateurPageState extends State<CollaborateurPage> {
  bool _isLoadingc = true;
  List<UtilisateurModel> listeDesCollagorateurs = [];
  List<UtilisateurModel> listeCollagorateurs = [];
  String? _id;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadUserData().then((_) {
      _fetchCollaborateirs();
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _id = prefs.getString('id');
      _token = prefs.getString('token');
    });
  }

  final http.Client client = CustomIntercepter(http.Client());
  // pour afficher les Collaborateurs
  Future<void> _fetchCollaborateirs() async {
    final url = 'http://192.168.56.1:8010/user/loadCollaboratorsByUserId/$_id';
    try {
      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $_token'
        },
      );

      if (response.statusCode == 202) {
        final data = jsonDecode(response.body);

        final collaborateurData = data['data'] as List;

        setState(() {
          listeDesCollagorateurs = collaborateurData
              .map((collaboJson) => UtilisateurModel.fromJson(collaboJson))
              .toList();
          listeCollagorateurs = List.from(listeDesCollagorateurs);
          _isLoadingc = false;
          // _isLoadingproprio = false;
        });
      } else {
        CustomSnackBar.show(context,
            message: 'Erreur lors du chargement !', isError: true);
      }
    } catch (e) {
      CustomSnackBar.show(context,
          message:
              'Une erreur s\'est produite. Veuillez vérifier votre connexion.',
          isError: true);
      setState(() {
        _isLoadingc = false;
        // _isLoadingproprio = false;
      });
    }
  }

  Future<void> _changeCollaborateurState(
      String idcollaborateur, String libelleurl) async {
    final url =
        'http://192.168.56.1:8010/user/$_id/${libelleurl}/${idcollaborateur}';
    //  showLoadingDialog(context);
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 202) {
        setState(() {
          _fetchCollaborateirs();
        });
        final message = json.decode(response.body)['message'];
        CustomSnackBar.show(context, message: '$message', isError: false);
      } else {
        final message = json.decode(response.body)['message'];
        CustomSnackBar.show(context, message: '$message', isError: true);
      }
    } catch (e) {
      CustomSnackBar.show(context,
          message:
              'Une erreur s\'est produite. Veuillez vérifier votre connexion.',
          isError: true);
    }
  }

  Future<void> _deleteCollaborateur(String idcollaborateur) async {
    final url =
        'http://192.168.56.1:8010/user/$_id/deletecollaborateur/${idcollaborateur}';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );
      if (response.statusCode == 202) {
        setState(() {
          _fetchCollaborateirs();
        });
        final message = json.decode(response.body)['message'];
        CustomSnackBar.show(context, message: '$message', isError: false);
      } else {
        final message = json.decode(response.body)['message'];
        CustomSnackBar.show(context, message: '$message', isError: true);
      }
    } catch (e) {
      CustomSnackBar.show(context,
          message:
              'Une erreur s\'est produite. Veuillez vérifier votre connexion.',
          isError: true);
    }
  }

  Future<void> _retrouverCollaborateur(String idcollaborateur) async {
    final url = 'http://192.168.56.1:8010/user/retrouver/${idcollaborateur}';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );
      if (response.statusCode == 202) {
        setState(() {
          _fetchCollaborateirs();
        });
        final message = json.decode(response.body)['message'];
        CustomSnackBar.show(context, message: '$message', isError: false);
      } else {
        final message = json.decode(response.body)['message'];
        CustomSnackBar.show(context, message: '$message', isError: true);
      }
    } catch (e) {
      CustomSnackBar.show(context,
          message:
              'Une erreur s\'est produite. Veuillez vérifier votre connexion.',
          isError: true);
    }
  }

  // supprimer un  client
  void deleteUser(String idcollaborateur) {
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
            "Vous allez supprimer ce collaborateur si vous cliquez sur 'supprimer' ",
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 2.h),
                    backgroundColor: Color.fromARGB(255, 206, 136, 5),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    "Annuler",
                    style: TextStyle(
                      fontSize: 8.sp,
                      letterSpacing: 2,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Fermer la boîte de dialogue
                  },
                ),
                // ),
                SizedBox(
                  width: 3.w,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 2.h),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    "Supprimer",
                    style: TextStyle(
                      fontSize: 8.sp,
                      letterSpacing: 2,
                    ),
                  ),
                  onPressed: () async {
                    // ::::::::::::::::::::::::::::::::::::::::
                    _deleteCollaborateur(idcollaborateur);
                    //:::::::::::::::::::::::::::::::::::::::::::
                    Navigator.of(context).pop(); // Fermer la boîte de dialogue
                    //:::::::::::::::::::::::::::::::::::::::::::
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
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
          'Les Collaborateurs',
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context)
            .colorScheme
            .background, // Changez cette couleur selon vos besoins
      ),
      body: Padding(
        padding: EdgeInsets.all(3.w), // Padding général
        child: _isLoadingc
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
                    margin:
                        EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
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
            : listeDesCollagorateurs.isEmpty
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
                    itemCount: listeCollagorateurs.length,
                    itemBuilder: (context, index) {
                      final collaborator = listeCollagorateurs[index];
                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 1.5.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(4.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        Color.fromARGB(255, 206, 136, 5),
                                    radius: 5.w,
                                    child: Text(
                                      collaborator.nom != null &&
                                              collaborator.nom!.isNotEmpty
                                          ? collaborator.nom!
                                              .substring(0, 1)
                                              .toUpperCase()
                                          : "N", // Met une lettre par défaut si le nom est nul ou vide
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    collaborator.nom ?? "nom",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    collaborator.isActive == true
                                        ? "Activé"
                                        : "Déactivé",
                                    style: TextStyle(
                                        fontSize: 10.sp, color: Colors.grey),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    collaborator.isDeleted == true
                                        ? "Supprimer"
                                        : "",
                                    style: TextStyle(
                                        fontSize: 10.sp, color: Colors.red),
                                  )
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      children: [
                                        Text(
                                          'Numéro : ${collaborator.username}',
                                          style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 10.sp),
                                        ),
                                        SizedBox(height: 1.h),
                                        Row(
                                          children: [
                                            Icon(Icons.mark_email_read,
                                                color: Color.fromARGB(
                                                    255, 206, 136, 5),
                                                size: 14.sp),
                                            SizedBox(width: 2.w),
                                            Text(
                                              'Email : ${collaborator.email}',
                                              style: TextStyle(
                                                color: Colors.grey[800],
                                                fontSize: 10.sp,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: [
                                        Container(
                                          // margin: EdgeInsets.only(right: 2.h),
                                          child: InkWell(
                                            onTap: () {
                                              if (collaborator.isActive ==
                                                  true) {
                                                // Ajouter ici la logique pour désactiver l'utilisateur
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text(
                                                        "Attention",
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .tertiary,
                                                        ),
                                                      ),
                                                      content: Text(
                                                        "Vous allez désactivé ce collaborateur si vous cliquez sur 'Désactivé' ",
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .tertiary,
                                                        ),
                                                      ),
                                                      actions: [
                                                        SizedBox(height: 2.h),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            // Padding(
                                                            //   padding: const EdgeInsets.all(8.0),
                                                            //   child:
                                                            ElevatedButton(
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            2.h),
                                                                backgroundColor:
                                                                    Color
                                                                        .fromARGB(
                                                                            255,
                                                                            206,
                                                                            136,
                                                                            5),
                                                                foregroundColor:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                              child: Text(
                                                                "Annuler",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      8.sp,
                                                                  letterSpacing:
                                                                      2,
                                                                ),
                                                              ),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(); // Fermer la boîte de dialogue
                                                              },
                                                            ),
                                                            // ),
                                                            SizedBox(
                                                              width: 3.w,
                                                            ),
                                                            ElevatedButton(
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            2.h),
                                                                backgroundColor:
                                                                    Colors.red,
                                                                foregroundColor:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                              child: Text(
                                                                "Désactivé",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      8.sp,
                                                                  letterSpacing:
                                                                      2,
                                                                ),
                                                              ),
                                                              onPressed:
                                                                  () async {
                                                                // ::::::::::::::::::::::::::::::::::::::::
                                                                _changeCollaborateurState(
                                                                    collaborator
                                                                            .id ??
                                                                        "id",
                                                                    "desactiver-collaborateur");
                                                                //:::::::::::::::::::::::::::::::::::::::::::
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(); // Fermer la boîte de dialogue
                                                                //:::::::::::::::::::::::::::::::::::::::::::
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              } else {
                                                // Ajouter ici la logique pour réactiver l'utilisateur
                                                _changeCollaborateurState(
                                                    collaborator.id ?? "id",
                                                    "reactiver-collaborateur");
                                              }
                                            },
                                            child: Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 1.w),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 0.5.h),
                                              decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: Color.fromARGB(
                                                      255,
                                                      206,
                                                      136,
                                                      5), // Couleur de la bordure
                                                  width: 0.4
                                                      .w, // Largeur de la bordure
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  collaborator.isActive == true
                                                      ? "Déactivé"
                                                      : "Réactivé",
                                                  style: TextStyle(
                                                    fontSize: 8.sp,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 2,
                                                    color: Color.fromARGB(
                                                        255, 206, 136, 5),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (collaborator.isActive == false)
                                Container(
                                  margin: EdgeInsets.only(top: 2.h),
                                  child: InkWell(
                                    onTap: () {
                                      print("BUTTON cliqué !");
                                      deleteUser(collaborator.id ?? "id");
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 20.w),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 0.5.h),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Supprimer",
                                          style: TextStyle(
                                            fontSize: 8.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (collaborator.isDeleted == true)
                                Container(
                                  margin: EdgeInsets.only(top: 2.h),
                                  child: InkWell(
                                    onTap: () {
                                      _retrouverCollaborateur(
                                          collaborator.id ?? "id");
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 20.w),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 0.5.h),
                                      decoration: BoxDecoration(
                                        color: Color.fromARGB(255, 206, 136, 5),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Rétrouver",
                                          style: TextStyle(
                                            fontSize: 8.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openAddCollaborator(context);
          // Action à effectuer lors de l'appui sur le bouton
          // Par exemple, ajouter un nouveau collaborateur
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text('Ajouter un nouveau collaborateur')),
          // );
        },
        backgroundColor: Color.fromARGB(255, 206, 136, 5),
        child: Icon(Icons.add, size: 24.sp),
      ),
    );
  }

  final TextEditingController _controllerNom = TextEditingController();
  final TextEditingController _controllerTelephone = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerAdresse = TextEditingController();
  final TextEditingController _controllerSpecialite = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _ValidPhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez remplir ce champ.';
    }
    RegExp regExp = RegExp(r'^\+\d{11}$');
    if (!regExp.hasMatch(value)) {
      return 'Veuillez entrer un numero valide.';
    }

    return null;
  }

// Fonction pour valider le format de l'email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez remplir ce champ.';
    }

    // Vérifier le format de l'email avec une expression régulière
    final RegExp emailRegExp =
        RegExp(r'^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+');

    if (!emailRegExp.hasMatch(value)) {
      return 'Veuillez entrer un email valide.';
    }

    return null;
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  void _submitForm() async {
    String _nomEntre = _controllerNom.text;
    String _adresse = _controllerAdresse.text;
    String _phone = _controllerTelephone.text;
    String _email = _controllerEmail.text;
    String _specialite = _controllerSpecialite.text;

    // if (_formKey.currentState!.validate()) {
    //   _formKey.currentState!.save();

    showLoadingDialog(context);

    final url = 'http://192.168.56.1:8010/user/$_id/addCollaborator';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $_token', // Assurez-vous que $_token est défini et valide
        },
        body: jsonEncode({
          'nom': _nomEntre,
          'adresse': _adresse,
          'specialite': _specialite,
          'email': _email,
          'username': _phone,
        }),
      );

      if (response.statusCode == 202) {
        final responseData = jsonDecode(response.body);
        String message = responseData['message'];
        Navigator.pop(context);
        setState(() {
          _fetchCollaborateirs();
        });
        CustomSnackBar.show(context, message: '$message', isError: false);
      } else {
        final message = json.decode(response.body)['data'];
        CustomSnackBar.show(context, message: '$message', isError: true);
      }
    } catch (e) {
      Navigator.of(context).pop();
      CustomSnackBar.show(context,
          message:
              'Une erreur s\'est produite. Veuillez vérifier votre connexion.',
          isError: true);
    }
    // }
  }

  void _openAddCollaborator(context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).colorScheme.background,
        builder: (BuildContext bc) {
          return Container(
            margin: EdgeInsets.only(top: 6.h),
            child: Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.keyboard_backspace,
                          // color: Colors.red,
                          size: 22.sp,
                        ),
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Text(
                        'Ajouter un Collaborateur',
                        style: TextStyle(
                            fontSize: 12.sp, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TexfieldWidget(
                          controller: _controllerNom,
                          keyboardType: TextInputType.name,
                          hintText: "Exp: Baba Touré",
                          labelText: "Nom et Prénom",
                          prefixIcon: Icon(
                            Icons.person,
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Veuillez remplir ce champ.";
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 2.5.h,
                        ),
                        TexfieldWidget(
                          controller: _controllerTelephone,
                          keyboardType: TextInputType.phone,
                          hintText: "Exp: +22375468913",
                          labelText: "Téléphone",
                          prefixIcon: Icon(
                            Icons.phone,
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                          ),
                          validator: (String? value) =>
                              _ValidPhoneNumber(value),
                        ),
                        SizedBox(
                          height: 2.5.h,
                        ),
                        TexfieldWidget(
                          controller: _controllerEmail,
                          keyboardType: TextInputType.emailAddress,
                          hintText: "Exp: example@gmail.com",
                          labelText: "Email",
                          prefixIcon: Icon(
                            Icons.email_rounded,
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                          ),
                          validator: (String? value) => _validateEmail(value),
                        ),
                        SizedBox(
                          height: 2.5.h,
                        ),
                        TexfieldWidget(
                          controller: _controllerAdresse,
                          keyboardType: TextInputType.name,
                          hintText: "Exp: Bamako, yiromadio, 1008lgts",
                          labelText: "Adresse",
                          prefixIcon: Icon(
                            Icons.location_on_outlined,
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Veuillez remplir ce champ.";
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 2.5.h,
                        ),
                        TexfieldWidget(
                          controller: _controllerSpecialite,
                          keyboardType: TextInputType.name,
                          hintText: "Exp: Sécretaire",
                          labelText: "Fonction",
                          prefixIcon: Icon(
                            Icons.badge_outlined,
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Veuillez remplir ce champ.";
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 4.h,
                        ),
                        SizedBox(
                          height: 5.h,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              print("Collaborateur inscrit");
                              if (_formKey.currentState!.validate()) {
                                _submitForm();
                                Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(
                                  255, 206, 136, 5), // Couleur or du bouton
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    100), // Bord arrondi du bouton
                              ),
                            ),
                            child: Text(
                              "Ajouter",
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
