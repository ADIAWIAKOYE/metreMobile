class ModelesAlbum {
  String id;
  String nom;
  String description;
  String categorie; // Utiliser un enum ou une String selon votre choix
  List<String> images;
  String utilisateurId; // Ou un objet Utilisateur si vous voulez plus d'infos

  ModelesAlbum({
    required this.id,
    required this.nom,
    required this.description,
    required this.categorie,
    required this.images,
    required this.utilisateurId,
  });

  // Méthode pour créer un objet ModelesAlbum à partir d'un JSON
  factory ModelesAlbum.fromJson(Map<String, dynamic> json) {
    return ModelesAlbum(
      id: json['id'],
      nom: json['nom'],
      description: json['description'],
      categorie: json['categorie'],
      images: List<String>.from(json['images']),
      utilisateurId:
          json['utilisateur']['id'] ?? '', // ou json['utilisateur']['id']
    );
  }
}
