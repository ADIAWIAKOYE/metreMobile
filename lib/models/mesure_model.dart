class ProprietaireMesure {
  String? id;
  String? proprio;
  bool? isActive;
  bool? isDeleted;
  bool isExpanded;
  List<Mesure> mesures; // Champ pour stocker les mesures

  ProprietaireMesure({
    this.id,
    this.proprio,
    this.isActive,
    this.isDeleted,
    this.mesures = const [], // Initialisez-le avec une liste vide par défaut
    this.isExpanded = false,
  });
  // Ajoutez un setter pour le champ mesures
  set setMesures(List<Mesure> value) {
    mesures = value;
  }

  factory ProprietaireMesure.fromJson(Map<String, dynamic> json) {
    return ProprietaireMesure(
      id: json['id'],
      proprio: json['proprio'],
      isActive: json['isActive'],
      isDeleted: json['isDeleted'],
      mesures: [], // Initialisez-le avec une liste vide par défaut
      isExpanded: false,
    );
  }

  @override
  String toString() {
    return 'ProprietaireMesure{id: $id, proprio: $proprio, isActive: $isActive, isDeleted: $isDeleted, mesures: $mesures, isExpanded: $isExpanded}';
  }
}

class Mesure {
  String? id;
  String? libelle;
  String? valeur;
  bool? isActive;
  bool? isDeleted;
  Mesure(this.id, this.libelle, this.valeur, this.isActive, this.isDeleted);

  factory Mesure.fromJson(Map<String, dynamic> json) {
    return Mesure(
      json['id'],
      json['libelle'],
      json['valeur'],
      json['isActive'],
      json['isDeleted'],
    );
  }

  @override
  String toString() {
    return 'ProprietaireMesure{id: $id, libelle: $libelle, valeur: $valeur, isActive: $isActive, isDeleted: $isDeleted}';
  }
}
