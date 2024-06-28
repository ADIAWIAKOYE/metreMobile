import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:Metre/widgets/logo.dart';

class AddMesurePage extends StatefulWidget {
  const AddMesurePage({super.key});

  @override
  State<AddMesurePage> createState() => _AddMesurePageState();
}

class _AddMesurePageState extends State<AddMesurePage> {
  List<String> items = [
    'L.Pantalon',
    'Ceinture',
    'T.fesse',
    'Cuisse',
    'Patte',
    'L.Chemise',
    'L.Boubou',
    'Poitrine',
    'Epaule',
    'Manche.L',
    'Manche.C',
    'T.Manche',
    'Encolure'
  ]; // Options du DropdownButton
  String? selectedItem; // Valeur sélectionnée du DropdownButton
  TextEditingController textFieldController =
      TextEditingController(); // Contrôleur de champ de texte

  List<Widget> textFieldsWidgets =
      []; // Liste pour stocker les widgets des champs de texte dynamiques

  List<String> selectedItems = []; // Définir la liste selectedItems

  bool isAddButtonEnabled = false;
  String? textFieldValue; // Définir la variable textFieldValue

// Déclarez la clé en dehors de la méthode build
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isOwnerFilled = false;
  bool isTextFieldWidgetAdded = false;

  // Déclarez les contrôleurs pour chaque champ de texte

  TextEditingController nomController = TextEditingController(); // Pour le nom
  TextEditingController prenomController =
      TextEditingController(); // Pour le prenom
  TextEditingController emailController =
      TextEditingController(); // Pour l'email
  TextEditingController telephoneController =
      TextEditingController(); // Pour le telephone
  TextEditingController adresseController =
      TextEditingController(); // Pour l'adresse

  TextEditingController proprietaireController =
      TextEditingController(); // Pour le propriétaire

  // Déclarez textFieldsControllers pour stocker les contrôleurs de champ de texte
  Map<String, TextEditingController> textFieldsControllers = {};

  Map<String, String> textFieldsValues =
      {}; // Déclaration de la variable textFieldsValues

  @override
  void initState() {
    super.initState();
    selectedItem = items.first; // Sélectionner la première option par défaut
  }

  int _currentStep = 0;
  bool isCompleted = false;
  List<Step> stepList() => [
        Step(
          title: const Text(
            'Données personnels',
            style: TextStyle(
              // color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          isActive: _currentStep >= 0,
          state: _currentStep <= 0 ? StepState.indexed : StepState.complete,
          content: Form(
            key: _formKey, // Clé pour le formulaire
            child: Column(
              children: [
                TextFormField(
                  controller: nomController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.account_circle),
                    prefixIconColor: Color.fromARGB(255, 95, 95, 96),
                    hintText: "Entrez le nom ",
                    hintStyle: TextStyle(
                      color: Color.fromARGB(255, 132, 134, 135),
                      fontSize: 12,
                    ),

                    labelText: "Nom",
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 132, 134, 135),
                      fontSize: 12,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color.fromARGB(
                            255, 206, 136, 5), // Couleur de la bordure
                        width: 1.5, // Largeur de la bordure
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 206, 136, 5),
                        width: 1.5,
                      ), // Couleur de la bordure lorsqu'elle est en état de focus
                    ),

                    contentPadding: EdgeInsets.symmetric(
                        vertical:
                            10), // Ajustez la valeur de la marge verticale selon vos besoins
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le nom';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: prenomController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.account_circle),
                    prefixIconColor: Color.fromARGB(255, 95, 95, 96),
                    hintText: "Entrez le prenom ",
                    hintStyle: TextStyle(
                      color: Color.fromARGB(255, 132, 134, 135),
                      fontSize: 12,
                    ),

                    labelText: "prenom",
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 132, 134, 135),
                      fontSize: 12,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color.fromARGB(
                            255, 206, 136, 5), // Couleur de la bordure
                        width: 1.5, // Largeur de la bordure
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 206, 136, 5),
                        width: 1.5,
                      ), // Couleur de la bordure lorsqu'elle est en état de focus
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.red,
                        width: 1.5,
                      ), // Couleur de la bordure lorsqu'elle est en état de focus
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        vertical:
                            10), // Ajustez la valeur de la marge verticale selon vos besoins
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le prenom';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    prefixIconColor: Color.fromARGB(255, 95, 95, 96),
                    hintText: "exemple@gmail.com",
                    hintStyle: TextStyle(
                      color: Color.fromARGB(255, 132, 134, 135),
                      fontSize: 12,
                    ),

                    labelText: "Email",
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 132, 134, 135),
                      fontSize: 12,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color.fromARGB(
                            255, 206, 136, 5), // Couleur de la bordure
                        width: 1.5, // Largeur de la bordure
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 206, 136, 5),
                        width: 1.5,
                      ), // Couleur de la bordure lorsqu'elle est en état de focus
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        vertical:
                            10), // Ajustez la valeur de la marge verticale selon vos besoins
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: telephoneController,
                  keyboardType: TextInputType
                      .phone, // Clavier téléphonique pour permettre la saisie de l'indicatif de pays
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.phone),
                    prefixIconColor: Color.fromARGB(255, 95, 95, 96),
                    hintText: "+XXXXXXXXXXX",
                    hintStyle: TextStyle(
                      color: Color.fromARGB(255, 132, 134, 135),
                      fontSize: 12,
                    ),
                    labelText: "Téléphone",
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 132, 134, 135),
                      fontSize: 12,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 206, 136, 5),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 206, 136, 5),
                        width: 1.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.red,
                        width: 1.5,
                      ), // Couleur de la bordure lorsqu'elle est en état de focus
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le numero de telephone';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: adresseController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.location_on),
                    prefixIconColor: Color.fromARGB(255, 95, 95, 96),
                    hintText: "Entrer l'adresse",
                    hintStyle: TextStyle(
                      color: Color.fromARGB(255, 132, 134, 135),
                      fontSize: 12,
                    ),
                    labelText: "Adresse",
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 132, 134, 135),
                      fontSize: 12,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 206, 136, 5),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 206, 136, 5),
                        width: 1.5,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Step(
          title: Text(
            'Mésures',
            style: TextStyle(
              // color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          isActive: _currentStep >= 1,
          state: _currentStep <= 1 ? StepState.indexed : StepState.complete,
          content: Column(
            // DEBUT
            children: [
              TextFormField(
                controller: proprietaireController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.location_on),
                  prefixIconColor: Colors.transparent,
                  hintText: "Entrer nom propriétaire",
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 132, 134, 135),
                    fontSize: 12,
                  ),
                  labelText: "Proprietaire",
                  labelStyle: TextStyle(
                    color: Color.fromARGB(255, 132, 134, 135),
                    fontSize: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    // borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 206, 136, 5),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 206, 136, 5),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    isOwnerFilled = value.isNotEmpty;
                  });
                },
              ),
              SizedBox(
                height: 15,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            prefixIconColor: Colors.transparent,
                            hintText: "Selectonner",
                            hintStyle: TextStyle(
                              color: Color.fromARGB(255, 132, 134, 135),
                              fontSize: 10,
                            ),
                            labelText: "Selectonner",
                            labelStyle: TextStyle(
                              color: Color.fromARGB(255, 132, 134, 135),
                              fontSize: 10,
                            ),
                            enabledBorder: OutlineInputBorder(
                              // borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 206, 136, 5),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 206, 136, 5),
                                width: 1.5,
                              ),
                            ),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                          ),
                          // value: selectedItem,
                          onChanged: (newValue) {
                            setState(() {
                              selectedItem = newValue!;
                              isAddButtonEnabled = (selectedItem != null &&
                                  selectedItem!.isNotEmpty &&
                                  textFieldValue != null &&
                                  textFieldValue!.isNotEmpty &&
                                  !selectedItems.contains(selectedItem));
                            });
                          },
                          items: items.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(fontSize: 12),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          onChanged: (value) {
                            setState(() {
                              textFieldValue = value;
                              isAddButtonEnabled = (selectedItem != null &&
                                  selectedItem!.isNotEmpty &&
                                  textFieldValue != null &&
                                  textFieldValue!.isNotEmpty &&
                                  !selectedItems.contains(selectedItem));
                            });
                          },
                          controller: textFieldController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            prefixIconColor: Colors.transparent,
                            hintText: "Valeur",
                            hintStyle: TextStyle(
                              color: Color.fromARGB(255, 132, 134, 135),
                              fontSize: 10,
                            ),
                            labelText: "Valeur",
                            labelStyle: TextStyle(
                              color: Color.fromARGB(255, 132, 134, 135),
                              fontSize: 10,
                            ),
                            enabledBorder: OutlineInputBorder(
                              // borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 206, 136, 5),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 206, 136, 5),
                                width: 1.5,
                              ),
                            ),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                      ),
                      // SizedBox(width: 0),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            String? dropdownValue = selectedItem;
                            String textValue = textFieldController.text;

                            // Vérifier si les conditions sont remplies pour activer l'ajout
                            if (dropdownValue != null &&
                                dropdownValue.isNotEmpty &&
                                textValue.isNotEmpty &&
                                !selectedItems.contains(dropdownValue)) {
                              // Ajouter l'élément seulement si les conditions sont remplies
                              selectedItems.add(dropdownValue);

                              // Récupérer la valeur du champ de texte
                              String fieldValue = textFieldController.text;
                              fieldValue = '$fieldValue cm';
                              // Ajouter les contrôleurs et les valeurs à leurs listes respectives
                              textFieldsControllers[dropdownValue] =
                                  textFieldController;
                              textFieldsValues[dropdownValue] = fieldValue;

                              // Ajouter les éléments visuels à votre liste de widgets
                              textFieldsWidgets.add(
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        margin: EdgeInsets.only(left: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Color.fromARGB(
                                                255, 206, 136, 5),
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(1),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 8),
                                          child: Text(
                                            dropdownValue,
                                            style: TextStyle(fontSize: 10),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Color.fromARGB(
                                                255, 206, 136, 5),
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(1),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 8),
                                          child: Text(
                                            fieldValue,
                                            style: TextStyle(fontSize: 10),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          textFieldsWidgets.removeLast();
                                          if (textFieldsWidgets.isEmpty) {
                                            isTextFieldWidgetAdded =
                                                false; // Aucun widget TextField n'est présent, donc définir la variable à false
                                          }
                                        });
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        size: 30,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              isTextFieldWidgetAdded =
                                  true; // Définir la variable à true car un widget a été ajouté

                              // Effacer le champ de texte après l'ajout
                              textFieldController.clear();
                            }
                          });
                        },
                        icon: Icon(
                          Icons.add_box,
                          size: 40,
                          color: Color.fromARGB(255, 206, 136, 5),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color.fromARGB(
                            255, 206, 136, 5), // Couleur de la bordure
                        width: 1, // Largeur de la bordure
                      ),
                    ),
                    child: Column(
                      children: textFieldsWidgets,
                    ),
                  ),
                ],
              ),
            ],
            // FIN
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: LogoWidget(),
        backgroundColor: Theme.of(context)
            .colorScheme
            .background, // Changez cette couleur selon vos besoins
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LogoWidget(),
          SizedBox(
              height: 10), // Ajouter un espacement entre le logo et le texte
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
                  'Ajouter un nouveau Client', // Ajoutez votre texte personnalisé ici
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
          SizedBox(height: 10),
          // Assurez-vous que ce widget a une taille définie
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child:
                  // isCompleted
                  // ? buildCompleted()
                  // :
                  Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Color.fromARGB(255, 206, 136, 5),
                    secondary: Color.fromARGB(255, 73, 73, 73),
                  ),
                ),
                child: Stepper(
                  steps: stepList(),
                  type: StepperType.horizontal,
                  elevation: 0,
                  currentStep: _currentStep,
                  onStepContinue: () {
                    final isLastStep = _currentStep == stepList().length - 1;
                    if (isLastStep) {
                      print('StepComplet');
                    } else {
                      setState(() {
                        _currentStep += 1;
                      });
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0) {
                      setState(() {
                        _currentStep -= 1;
                      });
                    }
                  },
                  controlsBuilder:
                      (BuildContext context, ControlsDetails controlsDetails) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_currentStep != 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(9.0),
                                child: ElevatedButton(
                                  onPressed: controlsDetails.onStepCancel,
                                  child: Text(
                                    'Retour',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 2,
                                        fontSize: 13),
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                      Color.fromARGB(255, 206, 136,
                                          5), // Couleur d'arrière-plan du bouton
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(9.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Vérifier si tous les champs obligatoires sont remplis et si des mesures ont été ajoutées
                                    if (_formKey.currentState!.validate() &&
                                        isOwnerFilled &&
                                        isTextFieldWidgetAdded) {
                                      // Appeler la fonction pour envoyer les données
                                      envoyerDonnees();
                                    }
                                  },
                                  child: Text(
                                    'Envoyer',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 2,
                                        fontSize: 13),
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                      isOwnerFilled && isTextFieldWidgetAdded
                                          ? Color.fromARGB(255, 206, 136, 5)
                                          : Colors
                                              .grey, // Couleur d'arrière-plan du bouton
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (_currentStep != stepList().length - 1)
                          Padding(
                            padding: const EdgeInsets.all(9.0),
                            child: ElevatedButton(
                              onPressed: () {
                                // Vérifier la validation des champs avant de permettre à l'utilisateur de passer à l'étape suivante
                                if (_formKey.currentState!.validate()) {
                                  controlsDetails.onStepContinue!();
                                }
                              },
                              child: Text(
                                'Continuer',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2,
                                    fontSize: 13),
                              ),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                  Color.fromARGB(255, 206, 136,
                                      5), // Couleur d'arrière-plan du bouton
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void envoyerDonnees() {
    // Capturer les valeurs des champs
    String nom = nomController.text;
    String prenom = prenomController.text;
    String email = emailController.text;
    String telephone = telephoneController.text;
    String adresse = adresseController.text;
    String proprietaire = proprietaireController.text;

    // Créer une liste de mesures avec les champs sélectionnés et leurs valeurs
    List<Map<String, String>> mesures = [];
    selectedItems.forEach((champ) {
      String valeur = textFieldsValues[champ] ?? ""; // Valeur par défaut
      mesures.add({'champ': champ, 'valeur': valeur});
    });

    // Afficher les valeurs dans le popup ou effectuer d'autres actions nécessaires
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Les champs renseignés'),
          backgroundColor: Color.fromARGB(255, 254, 254,
              254), // Modification de la couleur de l'arrière-plan
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nom : $nom'),
              Text('Prénom : $prenom'),
              Text('Email : $email'),
              Text('Téléphone : $telephone'),
              Text('Adresse : $adresse'),
              Text('Mesures :',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              Text('Propriétaire : $proprietaire'),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(mesures.length, (index) {
                  String champ = mesures[index]['champ']!;
                  String valeur = mesures[index]['valeur']!;
                  return Text('$champ : $valeur');
                }),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}
