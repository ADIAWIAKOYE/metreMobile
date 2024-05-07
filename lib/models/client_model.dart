//here we will write the movie data model classe
import 'dart:ffi';

import 'package:flutter/material.dart';

class ClientsModel {
  String? id;
  String? nom;
  String? prenom;
  String? numero;
  String? email;
  String? adresse;
  bool? isActive;
  bool? isDeleted;
  String? utilisateur;

  ClientsModel(this.id, this.nom, this.prenom, this.numero, this.email,
      this.adresse, this.isActive, this.isDeleted, this.utilisateur);
}

List dataList = [
  {
    "name": "Sales",
    "icon": Icons.payment,
    "subMenu": [
      {"name": "Orders"},
      {"name": "Invoices"}
    ]
  },
  {
    "name": "Marketing",
    "icon": Icons.volume_up,
    "subMenu": [
      {
        "name": "Promotions",
        "subMenu": [
          {"name": "Catalog Price Rule"},
          {"name": "Cart Price Rules"}
        ]
      },
      {
        "name": "Communications",
        "subMenu": [
          {"name": "Newsletter Subscribers"}
        ]
      },
      {
        "name": "SEO & Search",
        "subMenu": [
          {"name": "Search Terms"},
          {"name": "Search Synonyms"}
        ]
      },
      {
        "name": "User Content",
        "subMenu": [
          {"name": "All Reviews"},
          {"name": "Pending Reviews"}
        ]
      }
    ]
  }
];

class Menu {
  String? name;
  IconData? icon;
  List<Menu>? subMenu = [];

  Menu({this.name, this.subMenu, this.icon});

  Menu.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    icon = json['icon'];
    if (json['subMenu'] != null) {
      subMenu?.clear();
      json['subMenu'].forEach((v) {
        subMenu?.add(new Menu.fromJson(v));
      });
    }
  }
}
