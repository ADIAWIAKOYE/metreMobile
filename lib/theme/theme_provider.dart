import 'package:Metre/theme/theme.dart';
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _lightTheme = lightMode;
  ThemeData _darkTheme = darkMode;

  ThemeData get lightTheme => _lightTheme;
  ThemeData get darkTheme => _darkTheme;

  ThemeData _themeData = lightMode;

  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == _lightTheme) {
      themeData = _darkTheme;
    } else {
      themeData = _lightTheme;
    }
  }
  // bool get isDark =>
  //     _themeData ==
  //     darkMode; // Définissez le getter isDark pour vérifier si le thème est sombre
  // void toggleTheme() {
  //   _themeData = (_themeData == lightMode) ? darkMode : lightMode;
  //   notifyListeners(); // N'oubliez pas d'appeler notifyListeners() pour informer les écouteurs du changement de thème
  // }
}
