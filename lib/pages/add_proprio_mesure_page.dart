import 'package:Metre/pages/detail_mesure_page.dart';
import 'package:flutter/material.dart';
import 'package:Metre/services/CustomIntercepter.dart';
import 'package:Metre/widgets/CustomSnackBar.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddProprioMesurePage extends StatefulWidget {
  final String clientId;
  const AddProprioMesurePage({Key? key, required this.clientId})
      : super(key: key);

  @override
  _AddMesurePageState createState() => _AddMesurePageState();
}

class _AddMesurePageState extends State<AddProprioMesurePage> {
  List<String> items = [
    'Longueur_Pantalon',
    'Toure_Ceinture',
    'Toure_Fesse',
    'Toure_Cuisse',
    'Toure_Patte',
    'Longueur_Chemise',
    'Longueur_Boubou',
    'Toure_Poitrine',
    'Epaule',
    'Manche.Long',
    'Manche.Courte',
    'Toure_Manche',
    'Encolure'
  ];
  String? selectedItem;
  bool isOwnerFilled = false;
  bool isTextFieldWidgetAdded = false;
  bool isAddButtonEnabled = false;
  String? textFieldValue;
  List<String> selectedItems = [];
  TextEditingController textFieldController = TextEditingController();
  Map<String, TextEditingController> textFieldsControllers = {};
  Map<String, String> textFieldsValues = {};
  List<Widget> textFieldsWidgets = [];
  TextEditingController proprioownerController = TextEditingController();
  final http.Client client = CustomIntercepter(http.Client());
  String? _id;
  String? _token;
  @override
  void initState() {
    super.initState();
    selectedItem = items.first; // Sélectionner la première option par défaut
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _id = prefs.getString('id');
      _token = prefs.getString('token');
    });
  }

  Future<void> sendPostRequest(Map<String, dynamic> body) async {
    final response = await client.post(
      Uri.parse('http://192.168.56.1:8010/proprio/ajouter'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 202) {
      // print('Corps de la réponse: ${response.body}');
      final responseData = jsonDecode(response.body);
      String message = responseData['message'];
      CustomSnackBar.show(context, message: '$message', isError: false);
    } else if (response.statusCode == 400) {
      final responseData = jsonDecode(response.body);
      String message = responseData['message'];
      CustomSnackBar.show(context, message: '$message', isError: true);
    } else {
      // print('Erreur lors de l\'ajout de la mesure: ${response.statusCode}');
      // print('Corps de la réponse: ${response.body}'); // Ajoute cette ligne
      CustomSnackBar.show(context,
          message: 'Erreur lors de l\'ajout de la mesure', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ajouter une Mesure',
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(1.h),
        child: Form(
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: proprioownerController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.location_on),
                  prefixIconColor: Colors.transparent,
                  hintText: "Entrer nom propriétaire",
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 132, 134, 135),
                    fontSize: 10.sp,
                  ),
                  labelText: "Propriétaire",
                  labelStyle: TextStyle(
                    color: Color.fromARGB(255, 132, 134, 135),
                    fontSize: 10.sp,
                  ),
                  enabledBorder: OutlineInputBorder(
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
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (value) {
                  setState(() {
                    isOwnerFilled = value.isNotEmpty;
                  });
                },
              ),
              SizedBox(height: 1.h),
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
                            hintText: "Sélectionner",
                            hintStyle: TextStyle(
                              color: Color.fromARGB(255, 132, 134, 135),
                              fontSize: 10.sp,
                            ),
                            labelText: "Sélectionner",
                            labelStyle: TextStyle(
                              color: Color.fromARGB(255, 132, 134, 135),
                              fontSize: 10.sp,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 206, 136, 5),
                                width: 0.4.w,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 206, 136, 5),
                                width: 0.4.w,
                              ),
                            ),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 1.h),
                          ),
                          value: selectedItem,
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
                              child: Text(value,
                                  style: TextStyle(fontSize: 10.sp)),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(width: 1.w),
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
                              fontSize: 10.sp,
                            ),
                            labelText: "Valeur",
                            labelStyle: TextStyle(
                              color: Color.fromARGB(255, 132, 134, 135),
                              fontSize: 10.sp,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 206, 136, 5),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 206, 136, 5),
                                width: 0.4.w,
                              ),
                            ),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 1.h),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: isAddButtonEnabled
                            ? () {
                                setState(() {
                                  String? dropdownValue = selectedItem;
                                  String textValue = textFieldController.text;

                                  if (dropdownValue != null &&
                                      dropdownValue.isNotEmpty &&
                                      textValue.isNotEmpty &&
                                      !selectedItems.contains(dropdownValue)) {
                                    selectedItems.add(dropdownValue);

                                    String fieldValue = '$textValue cm';
                                    textFieldsControllers[dropdownValue] =
                                        TextEditingController(text: textValue);
                                    textFieldsValues[dropdownValue] =
                                        fieldValue;

                                    textFieldsWidgets.add(
                                      Row(
                                        key: ValueKey(
                                            dropdownValue), // Ajouter une clé unique
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              margin:
                                                  EdgeInsets.only(left: 1.h),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                  color: Color.fromARGB(
                                                      255, 206, 136, 5),
                                                  width: 0.4.w,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(1),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 1.w,
                                                    vertical: 0.8.h),
                                                child: Text(
                                                  dropdownValue,
                                                  style: TextStyle(
                                                      fontSize: 10.sp),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 1.w),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                  color: Color.fromARGB(
                                                      255, 206, 136, 5),
                                                  width: 0.4.w,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(1),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 1.w,
                                                    vertical: 0.8.h),
                                                child: Text(
                                                  fieldValue,
                                                  style:
                                                      TextStyle(fontSize: 8.sp),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 1.w),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                print(
                                                    "Dropdown value to delete: $dropdownValue");
                                                textFieldsWidgets
                                                    .removeWhere((widget) {
                                                  if (widget is Row) {
                                                    return widget.key ==
                                                        ValueKey(dropdownValue);
                                                  }
                                                  return false;
                                                });

                                                selectedItems
                                                    .remove(dropdownValue);
                                                print(
                                                    "Selected items after deletion: $selectedItems");
                                              });
                                            },
                                            icon: Icon(
                                              Icons.delete,
                                              size: 20.sp,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );

                                    textFieldController.clear();
                                  }
                                });
                              }
                            : null,
                        icon: Icon(
                          Icons.add_box,
                          size: 30.sp,
                          color: Color.fromARGB(255, 206, 136, 5),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color.fromARGB(255, 206, 136, 5),
                        width: 0.4.w,
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
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 206, 136, 5),
            foregroundColor: Colors.white,
          ),
          child: Text("Ajouter"),
          onPressed: isOwnerFilled || isTextFieldWidgetAdded
              ? () async {
                  Map<String, dynamic> body = {
                    "proprietaireMesures": {
                      "proprio": proprioownerController.text,
                      "client": {
                        "id": widget.clientId // Remplacez par l'ID approprié
                      }
                    },
                    "mesuresList": selectedItems.map((item) {
                      return {
                        "libelle": item,
                        "valeur": textFieldsValues[item]
                      };
                    }).toList()
                  };

                  await sendPostRequest(
                      body); // Utilisez la fonction de requête ici
                  // Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetailMesurePage(clientId: widget.clientId),
                    ),
                  );
                }
              : null,
        ),
      ),
    );
  }
}
