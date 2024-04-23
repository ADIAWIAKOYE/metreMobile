import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:metremobile/widgets/logo.dart';

class AddMesurePage extends StatefulWidget {
  const AddMesurePage({super.key});

  @override
  State<AddMesurePage> createState() => _AddMesurePageState();
}

class _AddMesurePageState extends State<AddMesurePage> {
  List<String> items = [
    'LongueurPantalon',
    'Ceinture',
    'Toure de fesse',
    'Cuisse',
    'Patte',
    'LongueurChemise',
    'LongueurBoubou',
    'Poitrine',
    'Epaule',
    'MancheLong',
    'MancheCourt',
    'TourManche',
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
  TextEditingController nomController = TextEditingController();
  TextEditingController prenomController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController telephoneController = TextEditingController();
  TextEditingController adresseController = TextEditingController();

  TextEditingController proprietaireController = TextEditingController();

  TextEditingController dropdownController = TextEditingController();
  TextEditingController textValueController = TextEditingController();

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
            'Donnes personnels',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          isActive: _currentStep >= 0,
          state: _currentStep <= 0 ? StepState.indexed : StepState.complete,
          content: Form(
            key: _formKey, // Clé pour le formulaire
            child: Column(
              children: [
                TextFormField(
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.account_circle),
                    prefixIconColor: Color.fromARGB(255, 95, 95, 96),
                    hintText: "Entrez le nom ",
                    hintStyle: TextStyle(
                      color: Color.fromARGB(255, 132, 134, 135),
                    ),

                    labelText: "Nom",
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color.fromARGB(
                            255, 195, 154, 5), // Couleur de la bordure
                        width: 1.5, // Largeur de la bordure
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 195, 154, 5),
                        width: 1.5,
                      ), // Couleur de la bordure lorsqu'elle est en état de focus
                    ),

                    contentPadding: EdgeInsets.symmetric(
                        vertical:
                            13), // Ajustez la valeur de la marge verticale selon vos besoins
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
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.account_circle),
                    prefixIconColor: Color.fromARGB(255, 95, 95, 96),
                    hintText: "Entrez le prenom ",
                    hintStyle: TextStyle(
                      color: Color.fromARGB(255, 132, 134, 135),
                    ),

                    labelText: "prenom",
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color.fromARGB(
                            255, 195, 154, 5), // Couleur de la bordure
                        width: 1.5, // Largeur de la bordure
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 195, 154, 5),
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
                            13), // Ajustez la valeur de la marge verticale selon vos besoins
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
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    prefixIconColor: Color.fromARGB(255, 95, 95, 96),
                    hintText: "exemple@gmail.com",
                    hintStyle: TextStyle(
                      color: Color.fromARGB(255, 132, 134, 135),
                    ),

                    labelText: "Email",
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color.fromARGB(
                            255, 195, 154, 5), // Couleur de la bordure
                        width: 1.5, // Largeur de la bordure
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 195, 154, 5),
                        width: 1.5,
                      ), // Couleur de la bordure lorsqu'elle est en état de focus
                    ),
                    // errorBorder: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(10),
                    //   borderSide: BorderSide(
                    //     color: Colors.red,
                    //     width: 1.5,
                    //   ), // Couleur de la bordure lorsqu'elle est en état de focus
                    // ),

                    contentPadding: EdgeInsets.symmetric(
                        vertical:
                            13), // Ajustez la valeur de la marge verticale selon vos besoins
                  ),
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Veuillez entrer l\'email';
                  //   }
                  //   return null;
                  // },
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  keyboardType: TextInputType
                      .phone, // Clavier téléphonique pour permettre la saisie de l'indicatif de pays
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.phone),
                    prefixIconColor: Color.fromARGB(255, 95, 95, 96),
                    hintText: "+XXXXXXXXXXX",
                    hintStyle: TextStyle(
                      color: Color.fromARGB(255, 132, 134, 135),
                    ),
                    labelText: "Téléphone",
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 195, 154, 5),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 195, 154, 5),
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
                      vertical: 13,
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
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.location_on),
                    prefixIconColor: Color.fromARGB(255, 95, 95, 96),
                    hintText: "Entrer l'adresse",
                    hintStyle: TextStyle(
                      color: Color.fromARGB(255, 132, 134, 135),
                    ),
                    labelText: "Adresse",
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 195, 154, 5),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 195, 154, 5),
                        width: 1.5,
                      ),
                    ),
                    // errorBorder: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(10),
                    //   borderSide: BorderSide(
                    //     color: Colors.red,
                    //     width: 1.5,
                    //   ), // Couleur de la bordure lorsqu'elle est en état de focus
                    // ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 13,
                    ),
                  ),
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Veuillez entrer l\'adresse';
                  //   }
                  //   return null;
                  // },
                ),
              ],
            ),
          ),
        ),
        Step(
          title: Text(
            'Mésures',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          isActive: _currentStep >= 1,
          state: _currentStep <= 1 ? StepState.indexed : StepState.complete,
          content: Column(
            children: [
              TextFormField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.location_on),
                  prefixIconColor: Colors.transparent,
                  hintText: "Entrer nom propriétaire",
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 132, 134, 135),
                  ),
                  labelText: "Proprietaire",
                  labelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    // borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 195, 154, 5),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 195, 154, 5),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 13,
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
                            ),
                            labelText: "Selectonner",
                            labelStyle: TextStyle(color: Colors.black),
                            enabledBorder: OutlineInputBorder(
                              // borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 195, 154, 5),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 195, 154, 5),
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
                              child: Text(value),
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
                            ),
                            labelText: "Valeur",
                            labelStyle: TextStyle(color: Colors.black),
                            enabledBorder: OutlineInputBorder(
                              // borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 195, 154, 5),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 195, 154, 5),
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
                                                255, 206, 163, 5),
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(1),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 8),
                                          child: Text(dropdownValue),
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
                                                255, 206, 163, 5),
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(1),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 8),
                                          child: Text(textValue + " cm"),
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
                          color: Color.fromARGB(255, 195, 154, 5),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color.fromARGB(
                            255, 206, 163, 5), // Couleur de la bordure
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
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LogoWidget(),
        SizedBox(height: 10), // Ajouter un espacement entre le logo et le texte
        Center(
          // Centrer le texte
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color:
                    Color.fromARGB(255, 206, 163, 5), // Couleur de la bordure
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
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              child: Text(
                'Ajouter un nouveau client', // Ajoutez votre texte personnalisé ici
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
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
                  primary: Color.fromARGB(255, 195, 154, 5),
                  secondary: Colors.black,
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
                                      fontSize: 15),
                                ),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    Color.fromARGB(255, 206, 163,
                                        5), // Couleur d'arrière-plan du bouton
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: ElevatedButton(
                                onPressed:
                                    isOwnerFilled && isTextFieldWidgetAdded
                                        ? () {
                                            print(
                                                "Envoyer l'enregistrement du client");
                                          }
                                        : null,
                                child: Text(
                                  'Envoyer',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15),
                                ),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    isOwnerFilled && isTextFieldWidgetAdded
                                        ? Color.fromARGB(255, 206, 163, 5)
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
                                  fontSize: 15),
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                Color.fromARGB(255, 206, 163,
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
    );
  }
}
