// model/commande_model.dart
class Commande {
  String? id;
  String? reference;
  DateTime? datecreation;
  String? daterdv;
  int? nbtissu;
  int? nbmodele;
  DateTime? datelivraison;
  int? prix;
  int? rest;
  String? status;
  bool? isPaye;
  bool? isDeleted;
  Proprietaire? proprietaire;
  Utilisateur? utilisateur;
  List<Tissu>? tissus;
  List<PayementCommande>? payementCommandes; // Ajout de la propriété

  Commande(
      {this.id,
      this.reference,
      this.datecreation,
      this.daterdv,
      this.nbtissu,
      this.nbmodele,
      this.datelivraison,
      this.prix,
      this.rest,
      this.status,
      this.isPaye,
      this.isDeleted,
      this.proprietaire,
      this.utilisateur,
      this.tissus,
      this.payementCommandes // Ajout au constructeur
      });

  factory Commande.fromJson(Map<String, dynamic> json) {
    return Commande(
      id: json['id'],
      reference: json['reference'],
      datecreation: json['datecreation'] != null
          ? DateTime.parse(json['datecreation'])
          : null,
      daterdv: json['daterdv'],
      nbtissu: json['nbtissu'],
      nbmodele: json['nbmodele'],
      datelivraison: json['datelivraison'] != null
          ? DateTime.parse(json['datelivraison'])
          : null,
      prix: json['prix'],
      rest: json['rest'],
      status: json['status'],
      isPaye: json['isPaye'],
      isDeleted: json['isDeleted'],
      proprietaire: json['proprietaire'] != null
          ? Proprietaire.fromJson(json['proprietaire'])
          : null,
      utilisateur: json['utilisateur'] != null
          ? Utilisateur.fromJson(json['utilisateur'])
          : null,
      tissus: json['tissus'] != null
          ? (json['tissus'] as List)
              .map((tissu) => Tissu.fromJson(tissu))
              .toList()
          : null,
      payementCommandes: json['payementCommandes'] != null
          ? (json['payementCommandes'] as List)
              .map((payement) => PayementCommande.fromJson(payement))
              .toList()
          : null, // Ajout de la conversion
    );
  }
}

class Proprietaire {
  String? id;
  String? proprio;
  bool? isActive;
  bool? isDeleted;
  Client? client;

  Proprietaire({
    this.id,
    this.proprio,
    this.isActive,
    this.isDeleted,
    this.client,
  });

  factory Proprietaire.fromJson(Map<String, dynamic> json) {
    return Proprietaire(
      id: json['id'],
      proprio: json['proprio'],
      isActive: json['isActive'],
      isDeleted: json['isDeleted'],
      client: json['client'] != null ? Client.fromJson(json['client']) : null,
    );
  }
}

class Client {
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
  List<Role>? roles;

  Client({
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

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
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
      roles: json['roles'] != null
          ? (json['roles'] as List).map((role) => Role.fromJson(role)).toList()
          : null,
    );
  }
}

class Utilisateur {
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
  List<Role>? roles;

  Utilisateur({
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

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
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
      roles: json['roles'] != null
          ? (json['roles'] as List).map((role) => Role.fromJson(role)).toList()
          : null,
    );
  }
}

class Tissu {
  String? id;
  String? nom;
  String? couleur;
  String? quantite;
  String? fournipar;
  bool? isDeleted;
  List<Modele>? modeles;
  List<FichierTissu>? fichiersTissus;

  Tissu({
    this.id,
    this.nom,
    this.couleur,
    this.quantite,
    this.fournipar,
    this.isDeleted,
    this.modeles,
    this.fichiersTissus,
  });

  factory Tissu.fromJson(Map<String, dynamic> json) {
    return Tissu(
      id: json['id'],
      nom: json['nom'],
      couleur: json['couleur'],
      quantite: json['quantite'],
      fournipar: json['fournipar'],
      isDeleted: json['isDeleted'],
      modeles: json['modeles'] != null
          ? (json['modeles'] as List)
              .map((modele) => Modele.fromJson(modele))
              .toList()
          : null,
      fichiersTissus: json['fichiersTissus'] != null
          ? (json['fichiersTissus'] as List)
              .map((fichierTissu) => FichierTissu.fromJson(fichierTissu))
              .toList()
          : null,
    );
  }
}

class Modele {
  String? id;
  String? nom;
  String? description;
  bool? isDeleted;
  List<FichierModele>? fichiersModeles;

  Modele({
    this.id,
    this.nom,
    this.description,
    this.isDeleted,
    this.fichiersModeles,
  });

  factory Modele.fromJson(Map<String, dynamic> json) {
    return Modele(
      id: json['id'],
      nom: json['nom'],
      description: json['description'],
      isDeleted: json['isDeleted'],
      fichiersModeles: json['fichiersModeles'] != null
          ? (json['fichiersModeles'] as List)
              .map((fichierModele) => FichierModele.fromJson(fichierModele))
              .toList()
          : null,
    );
  }
}

class FichierModele {
  String? id;
  String? urlfichier;

  FichierModele({this.id, this.urlfichier});

  factory FichierModele.fromJson(Map<String, dynamic> json) {
    return FichierModele(
      id: json['id'],
      urlfichier: json['urlfichier'],
    );
  }
}

class FichierTissu {
  String? id;
  String? urlfichier;

  FichierTissu({this.id, this.urlfichier});

  factory FichierTissu.fromJson(Map<String, dynamic> json) {
    return FichierTissu(
      id: json['id'],
      urlfichier: json['urlfichier'],
    );
  }
}

class Role {
  String? id;
  String? libelle;

  Role({this.id, this.libelle});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      libelle: json['libelle'],
    );
  }
}

class PayementCommande {
  String? id;
  int? montant;
  DateTime? date;
  String? reference;
  bool? isDeleted;

  PayementCommande(
      {this.id, this.montant, this.date, this.reference, this.isDeleted});

  factory PayementCommande.fromJson(Map<String, dynamic> json) {
    return PayementCommande(
      id: json['id'],
      montant: json['montant'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      reference: json['reference'],
      isDeleted: json['isDeleted'],
    );
  }
}
