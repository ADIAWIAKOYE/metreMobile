import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:Metre/bottom_navigationbar/navigation_page.dart';

class MonComptePage extends StatefulWidget {
  const MonComptePage({super.key});

  @override
  State<MonComptePage> createState() => _MonComptePageState();
}

class _MonComptePageState extends State<MonComptePage> {
  bool isObscurePassword = true;

  String? selectedSpeciality;
// String selectedSpeciality;
  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context)
            .colorScheme
            .background, // Changez cette couleur selon vos besoins
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.keyboard_backspace,
            size: 30,
          ),
        ),
        title: Align(
          alignment: Alignment.center,
          child: Text(
            'Mon Compte',
            // style: Theme.of(context).textTheme.headline4,
            // textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              //  Theme.of(context).toggleTheme();
            },
            icon: Icon(isDark ? Icons.sunny : Icons.brightness_3),
            color: Colors.transparent,
          )
        ],
      ),
      // body: SingleChildScrollView(
      body: Container(
        padding: EdgeInsets.only(left: 15, top: 20, right: 15),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                          border: Border.all(
                            width: 4,
                            color: Colors.white,
                          ),
                          boxShadow: [
                            BoxShadow(
                              spreadRadius: 2,
                              blurRadius: 10,
                              color: Color.fromARGB(255, 206, 136, 5)
                                  .withOpacity(0.1),
                            ),
                          ],
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: AssetImage('assets/image/avatar.png'))),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(width: 4, color: Colors.white),
                          color: Color.fromARGB(255, 206, 136, 5),
                        ),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                        //   child: IconButton(
                        //   onPressed: () {},
                        //   icon: Icon(
                        //     Icons.edit,
                        //     color: Colors.white,
                        //   ),
                        // ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              buildTextField('Nom :', 'MonStyle Couture', false),
              buildTextField('Téléphone :', '+22375468913', false),
              buildTextField('Adresse :', 'Bamako, yirimadio', false),
              buildTextField(
                  'Specialité :', 'Couture Homme, Femme & Enfant', false),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      print('vous avez cliqués sur Annuler');
                    },
                    child: Text(
                      'Annuler',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 2,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20))),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      print('vous avez cliqués sur modifier');
                    },
                    child: Text(
                      'Modifier',
                      style: TextStyle(
                          fontSize: 12, letterSpacing: 2, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 206, 136, 5),
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20))),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      String labelText, String placeholder, bool isPassWordTextField) {
    if (labelText == 'Specialité :') {
      return Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Row(
          // Utilisation d'une rangée
          children: [
            Expanded(
              flex: 1,
              // Pour le label à gauche
              child: Text(
                labelText,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              flex: 3,
              // Pour le champ de saisie à droite avec le placeholder
              child: Container(
                margin: EdgeInsets.only(right: 10),
                child: DropdownButtonFormField<String>(
                  value:
                      selectedSpeciality, // Remplacez selectedSpeciality par votre variable pour suivre la valeur sélectionnée
                  onChanged: (newValue) {
                    setState(() {
                      selectedSpeciality = newValue;
                    });
                  },
                  items: <String>[
                    'Couture Homme & Enfant',
                    'Couture Femme & Enfant',
                    'Couture Homme, Femme & Enfant',
                    // Ajoutez d'autres spécialités ici
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(fontSize: 10),
                      ),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(bottom: 5),
                    hintText: placeholder,
                    hintStyle: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Row(
          // Utilisation d'une rangée
          children: [
            Expanded(
              flex: 1,
              // Pour le label à gauche
              child: Text(
                labelText,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              flex: 3,
              // Pour le champ de saisie à droite avec le placeholder
              child: Container(
                margin: EdgeInsets.only(right: 10),
                child: TextField(
                  obscureText: isPassWordTextField ? isObscurePassword : false,
                  decoration: InputDecoration(
                    suffixIcon: isPassWordTextField
                        ? IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.remove_red_eye,
                              color: Colors.grey,
                              size: 10,
                            ),
                          )
                        : null,
                    contentPadding: EdgeInsets.only(bottom: 5),
                    hintText: placeholder,
                    hintStyle: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
