import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Metre/theme/theme_provider.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(
          // top: MediaQuery.of(context).padding.top,
          // left: 5,
          // right: 5,
          ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // le logo
          Container(
            child: Image.asset(
              'assets/image/logo4.png',
              width: 70,
            ),
          ),
          // actions
          // actions
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              var isDark =
                  themeProvider.themeData.brightness == Brightness.dark;
              return IconButton(
                onPressed: () {
                  // themeProvider.toggleTheme();
                  Provider.of<ThemeProvider>(context, listen: false)
                      .toggleTheme();
                },
                icon: Icon(isDark ? Icons.sunny : Icons.brightness_3),
              );
            },
          ),
        ],
      ),
    );
  }
}
