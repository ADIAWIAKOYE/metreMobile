class UtilisateurModel {
  String? id;
  String? nom;
  String? adresse;
  String? specialite;
  String? profile;
  String? email;
  String? username;
  String? password;
  bool? isActive;
  bool? isDeleted;
  List<RoleModel>? roles;

  UtilisateurModel({
    this.id,
    this.nom,
    this.adresse,
    this.specialite,
    this.profile,
    this.email,
    this.username,
    this.password,
    this.isActive,
    this.isDeleted,
    this.roles,
  });

  // Méthode pour convertir un JSON en instance de UtilisateurModel
  factory UtilisateurModel.fromJson(Map<String, dynamic> json) {
    return UtilisateurModel(
      id: json['id'],
      nom: json['nom'],
      adresse: json['adresse'],
      specialite: json['specialite'],
      profile: json['profile'],
      email: json['email'],
      username: json['username'],
      password: json['password'],
      isActive: json['isActive'],
      isDeleted: json['isDeleted'],
      roles: (json['roles'] as List)
          .map((roleJson) => RoleModel.fromJson(roleJson))
          .toList(),
    );
  }

  // Méthode pour convertir une instance de UtilisateurModel en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'adresse': adresse,
      'specialite': specialite,
      'profile': profile,
      'email': email,
      'username': username,
      'password': password,
      'isActive': isActive,
      'isDeleted': isDeleted,
      'roles': roles?.map((role) => role.toJson()).toList(),
    };
  }
}

class RoleModel {
  String? id;
  String? libelle;

  RoleModel({this.id, this.libelle});

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'],
      libelle: json['libelle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'libelle': libelle,
    };
  }
}
