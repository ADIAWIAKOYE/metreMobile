//here we will write the movie data model classe

import 'dart:ffi';

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
