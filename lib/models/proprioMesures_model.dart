import 'package:Metre/models/clients_model.dart';

class ProprioMesures {
  String? id;
  String? proprio;
  bool? isActive;
  bool? isDeleted;
  ClientsModels? clients;
  List<Mesures>? mesures;

  ProprioMesures(this.id, this.proprio, this.isActive, this.isDeleted,
      this.clients, this.mesures);

  factory ProprioMesures.fromJson(Map<String, dynamic> json) {
    var mesuresList = json['mesures'] as List;
    List<Mesures> mesures =
        mesuresList.map((i) => Mesures.fromJson(i)).toList();

    return ProprioMesures(
      json['id'],
      json['proprio'],
      json['isActive'],
      json['isDeleted'],
      ClientsModels.fromJson(json['clients']),
      mesures,
    );
  }
}

class Mesures {
  String? id;
  String? libelle;
  String? valeur;
  bool? isActive;
  bool? isDeleted;

  Mesures(this.id, this.libelle, this.valeur, this.isActive, this.isDeleted);

  factory Mesures.fromJson(Map<String, dynamic> json) {
    return Mesures(
      json['id'],
      json['libelle'],
      json['valeur'],
      json['isActive'],
      json['isDeleted'],
    );
  }
}
