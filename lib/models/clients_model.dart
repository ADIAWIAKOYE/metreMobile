class ClientsModels {
  String? id;
  String? nom;
  String? prenom;
  String? numero;
  String? email;
  String? adresse;
  bool? isActive;
  bool? isDeleted;
  String? utilisateurId;

  ClientsModels(this.id, this.nom, this.prenom, this.numero, this.email,
      this.adresse, this.isActive, this.isDeleted, this.utilisateurId);

  factory ClientsModels.fromJson(Map<String, dynamic> json) {
    return ClientsModels(
      json['id'],
      json['nom'],
      json['prenom'],
      json['numero'],
      json['email'],
      json['adresse'],
      json['isActive'],
      json['isDeleted'],
      json['utilisateur']['id'],
    );
  }
}

class Client {
  final String id;
  final String nom;
  final String prenom;
  final String numero;
  final String adresse;
  final String email;

  Client({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.numero,
    required this.adresse,
    required this.email,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      numero: json['numero'],
      adresse: json['adresse'],
      email: json['email'],
    );
  }
}
