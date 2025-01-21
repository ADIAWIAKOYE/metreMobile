import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:sizer/sizer.dart';

class StyledDatePicker extends StatelessWidget {
  final TextStyle? style;
  final InputDecoration? decoration;
  final String name;
  const StyledDatePicker(
      {Key? key, this.style, this.decoration, required this.name})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light().copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Color.fromARGB(255, 206, 136, 5), // Couleur principale
            ),
        dialogTheme: DialogTheme(
          backgroundColor: Colors.white, // Couleur de fond de la boîte
          shape: RoundedRectangleBorder(
            // Bordure de la boîte
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButtonTheme.of(context).style!.copyWith(
                foregroundColor: MaterialStateProperty.all<Color>(
                    Color.fromARGB(255, 206, 136,
                        5)), // Couleur des boutons "OK" et "Annuler"
              ),
        ),
      ),
      child: FormBuilderDateTimePicker(
        name: name,
        style: style,
        decoration: decoration ??
            InputDecoration(), // Utiliser une InputDecoration par défaut si decoration est null
        inputType: InputType.date,
        locale: const Locale('fr', 'FR'),
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
        ]),
      ),
    );
  }
}
