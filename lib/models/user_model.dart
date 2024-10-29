class Role {
  final String id;
  final String libelle;

  Role({required this.id, required this.libelle});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      libelle: json['libelle'],
    );
  }
}

class Utilisateur_model {
  final String id;
  final String nom;
  final String adresse;
  final String specialite;
  final String profile;
  final String email;
  final String username;
  final bool isActive;
  final bool isDeleted;
  final List<Role> roles;

  Utilisateur_model({
    required this.id,
    required this.nom,
    required this.adresse,
    required this.specialite,
    required this.profile,
    required this.email,
    required this.username,
    required this.isActive,
    required this.isDeleted,
    required this.roles,
  });

  factory Utilisateur_model.fromJson(Map<String, dynamic> json) {
    var list = json['roles'] as List;
    List<Role> rolesList = list.map((i) => Role.fromJson(i)).toList();

    return Utilisateur_model(
      id: json['id'],
      nom: json['nom'],
      adresse: json['adresse'],
      specialite: json['specialite'],
      profile: json['profile'] ?? '',
      email: json['email'] ?? '',
      username: json['username'],
      isActive: json['isActive'],
      isDeleted: json['isDeleted'],
      roles: rolesList,
    );
  }
}
