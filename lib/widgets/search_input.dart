import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SearchInputWidget extends StatelessWidget {
  const SearchInputWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: TextField(
          decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: 'Rechercher',
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(10), // même rayon que ClipRRect
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(14.0),
                child: SvgPicture.asset(
                  'assets/image/icone/search.svg',
                  width: 10,
                ),
              )),
        ),
      ),
    );
  }
}
