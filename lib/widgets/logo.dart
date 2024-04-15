import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top, left: 5, right: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //une ecriture
          // Text(
          //   'Salut !, Que\n Cherches-Vous',
          //   style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          // ),
          //le logo
          Container(
            child: Image.asset(
              'assets/image/logo2.png',
              width: 120,
            ),
          )
        ],
      ),
    );
  }
}
