import 'package:Metre/models/modelesAlbum%20.dart';
import 'package:Metre/services/ApiService.dart';
import 'package:Metre/widgets/CustomSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class EditModelesAlbumPage extends StatefulWidget {
  final ModelesAlbum album;

  const EditModelesAlbumPage({Key? key, required this.album}) : super(key: key);

  @override
  _EditModelesAlbumPageState createState() => _EditModelesAlbumPageState();
}

class _EditModelesAlbumPageState extends State<EditModelesAlbumPage> {
  final ValueNotifier<bool> _isFormModified =
      ValueNotifier<bool>(false); // Nouveau ValueNotifier
  final _formKey = GlobalKey<FormBuilderState>();
  final ApiService apiService = ApiService();
  String? _id;
  String? _token;
  bool isLoading = false;

  List<String> categories = [
    'ROBES',
    'PANTALONS',
    'JUPES',
    'CHEMISES',
    'BLOUSES',
    'TISSUS_COMPLET',
    'VESTES',
    'COLLECTIONS_SPECIALES',
    'AUTRE',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _id = prefs.getString('id');
      _token = prefs.getString('token');
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        isLoading = true;
      });

      try {
        final formData = _formKey.currentState!.value;

        // Récupérer les valeurs des champs
        String nom = formData['nom'] as String;
        String description = formData['description'] as String;
        String categorie = formData['categorie'] as String;

        // Appel à l'API
        final response = await apiService.updateModelesAlbums(
          id: widget.album.id,
          nom: nom,
          description: description,
          categorie: categorie,
        );

        // Vérifier si la modification a réussi
        if (response != null) {
          CustomSnackBar.show(context,
              message: 'Modèle modifié avec succès', isError: false);
          Navigator.pop(context, true);
        } else {
          CustomSnackBar.show(context,
              message: 'Erreur lors de la modification du modèle',
              isError: true);
        }
      } catch (e) {
        print('Erreur lors de la modification de l\'album: $e');
        CustomSnackBar.show(context,
            message: 'Erreur lors de la modification du modèle: $e',
            isError: true);
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.keyboard_backspace,
            size: 20.sp,
          ),
        ),
        title: Text(
          ' Modifier le Modèle',
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FormBuilder(
              key: _formKey,
              initialValue: {
                'nom': widget.album.nom,
                'description': widget.album.description,
                'categorie': widget.album.categorie,
              },
              child: ListView(
                children: [
                  _buildTextField(
                      name: 'nom',
                      labelText: 'Nom du modèle',
                      hintText: 'Entrez le nom'),
                  SizedBox(height: 1.5.h),
                  _buildTextField(
                      name: 'description',
                      labelText: 'Description',
                      hintText: 'Entrez la description',
                      maxLines: 3),
                  SizedBox(height: 1.5.h),
                  _buildDropdown(
                      name: 'categorie',
                      labelText: 'Catégorie',
                      items: categories),
                  SizedBox(height: 20),
                  ValueListenableBuilder<bool>(
                    // Envelopper le bouton
                    valueListenable: _isFormModified,
                    builder: (context, isFormModified, child) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(
                              255, 206, 136, 5), // Couleur du bouton
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8), // Bords arrondis
                          ),
                        ),
                        onPressed: isLoading || !isFormModified
                            ? null
                            : _submitForm, // Activer/désactiver le bouton
                        child: isLoading
                            ? CircularProgressIndicator()
                            : Text('Enregistrer les modifications'),
                      );
                    },
                  ),
                ],
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

  // Widget pour les champs de texte
  Widget _buildTextField({
    required String name,
    required String labelText,
    String? hintText,
    int? maxLines = 1,
  }) {
    return FormBuilderTextField(
      name: name,
      keyboardType: TextInputType.multiline,
      style: TextStyle(
          fontSize: 10.sp, color: Theme.of(context).colorScheme.tertiary),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
            color: Color.fromARGB(255, 132, 134, 135), fontSize: 10.sp),
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
      ),
      maxLines: maxLines,
      validator: FormBuilderValidators.required(),
      onChanged: (value) {
        // Ajouter onChanged
        _isFormModified.value = true;
      },
    );
  }

  // Widget pour le menu déroulant
  Widget _buildDropdown({
    required String name,
    required String labelText,
    required List<String> items,
  }) {
    return FormBuilderDropdown<String>(
      name: name,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
            color: Color.fromARGB(255, 132, 134, 135), fontSize: 10.sp),
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
      ),
      items: items
          .map((String item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(fontSize: 9.sp),
                ),
              ))
          .toList(),
      validator: FormBuilderValidators.required(),
      onChanged: (value) {
        // Ajouter onChanged
        _isFormModified.value = true;
      },
    );
  }
}
