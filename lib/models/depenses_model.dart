class Depenses {
  String? id;
  String? libelle;
  double? montant;
  String? description;
  DateTime? date;
  String? reference;
  Utilisateur? utilisateur; // Ajout du champ utilisateur

  Depenses({
    this.id,
    this.libelle,
    this.montant,
    this.description,
    this.date,
    this.reference,
    this.utilisateur,
  });

  factory Depenses.fromJson(Map<String, dynamic> json) {
    return Depenses(
      id: json['id'],
      libelle: json['libelle'],
      montant: (json['montant'] as num?)?.toDouble(),
      description: json['description'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      reference: json['reference'],
      utilisateur: json['utilisateur'] != null
          ? Utilisateur.fromJson(json['utilisateur'])
          : null, // Conversion de l'utilisateur
    );
  }
}

class Utilisateur {
  String? nom;
  String? profile;
  // Autres champs de l'utilisateur

  Utilisateur({this.nom, this.profile});

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      nom: json['nom'],
      profile: json['profile'],
      // Initialiser les autres champs
    );
  }
}
