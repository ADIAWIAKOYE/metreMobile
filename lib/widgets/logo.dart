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
          //le logo
          Container(
            child: Image.asset(
              'assets/image/logo4.png',
              width: 70,
            ),
          ),
          //une ecriture
          // Expanded(
          //   child: Center(
          //     child: Text(
          //       'La liste de vos clients enregistrés ! ',
          //       style: TextStyle(fontWeight: FontWeight.w700,),
          //       textAlign: TextAlign.center,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
