import 'dart:convert';
import 'package:Metre/models/modelesAlbum%20.dart';
import 'package:Metre/services/CustomIntercepter.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://192.168.56.1:8010/api/modeles-albums';
  final http.Client client =
      CustomIntercepter(http.Client()); // Initialiser le client ici

  // Récupérer tous les albums (paginés)
  Future<List<ModelesAlbum>> getAllModelesAlbums(
      {int page = 0, int size = 10}) async {
    try {
      final response =
          await client.get(Uri.parse('$baseUrl/getall?page=$page&size=$size'));

      if (response.statusCode == 202) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> content =
            (data['data'] as Map<String, dynamic>)['content'];
        return content.map((json) => ModelesAlbum.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load albums: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getAllModelesAlbums: $e');
      rethrow; // Relancer l'exception pour que le widget puisse la gérer
    }
  }

  // Récupérer un album par ID
  Future<ModelesAlbum> getModelesAlbumById(String id) async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/loadById/$id'));

      if (response.statusCode == 202) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ModelesAlbum.fromJson(data['data']);
      } else {
        throw Exception('Failed to load album: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getModelesAlbumById: $e');
      rethrow;
    }
  }

  Future<ModelesAlbum> createModelesAlbum({
    required String nom,
    required String description,
    required String categorie,
    required List<http.MultipartFile> images,
    required String utilisateurId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/create'); // URL de base seulement
      var request =
          http.MultipartRequest('POST', url); // Créer la requête Multipart

      // Ajouter les champs au corps de la requête
      request.fields['nom'] = nom;
      request.fields['description'] = description;
      request.fields['categorie'] = categorie;
      request.fields['utilisateurId'] = utilisateurId;

      // Ajouter les images
      for (var image in images) {
        request.files.add(image);
      }

      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 202 || response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ModelesAlbum.fromJson(data['data']);
      } else {
        throw Exception(
            'Failed to create album: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in createModelesAlbum: $e');
      rethrow;
    }
  }

  // Mettre à jour un album
  Future<ModelesAlbum> updateModelesAlbum({
    required String id,
    required String nom,
    required String description,
    required String categorie,
    required List<http.MultipartFile> images,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/update/$id');
      var request =
          http.MultipartRequest('PUT', url); // Utiliser http.MultipartRequest

      request.fields['album'] = jsonEncode({
        'nom': nom,
        'description': description,
        'categorie': categorie,
        'images': [],
      });
      for (var image in images) {
        request.files.add(image);
      }

      // Utiliser client.send() pour envoyer la requête via l'intercepteur
      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ModelesAlbum.fromJson(data['data']);
      } else {
        throw Exception(
            'Failed to update album: ${response.statusCode} - ${response.body}'); // Utiliser response.body
      }
    } catch (e) {
      print('Error in updateModelesAlbum: $e');
      rethrow;
    }
  }

  // Mettre à jour un album san image
  Future<ModelesAlbum?> updateModelesAlbums({
    required String id,
    required String nom,
    required String description,
    required String categorie,
  }) async {
    final url = Uri.parse('$baseUrl/updates/$id');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'nom': nom,
      'description': description,
      'categorie': categorie,
    });

    final response = await client.put(url, headers: headers, body: body);

    if (response.statusCode == 202) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return ModelesAlbum.fromJson(data['data']);
    } else {
      print(
          'Failed to update album: ${response.statusCode} - ${response.body}');
      return null; // Retourner null en cas d'erreur
    }
  }

  // Supprimer un album
  Future<bool> deleteModelesAlbum(String id) async {
    try {
      final response = await client.delete(Uri.parse('$baseUrl/delete/$id'));

      if (response.statusCode == 200 || response.statusCode == 202) {
        return true; // Suppression réussie
      } else {
        print('Failed to delete album: ${response.statusCode}');
        return false; // Suppression échouée
      }
    } catch (e) {
      print('Error in deleteModelesAlbum: $e');
      return false; // Erreur lors de la suppression
    }
  }

  // Récupérer les albums par utilisateur (paginés)
  Future<List<ModelesAlbum>> getModelesAlbumsByUtilisateurId(
      String utilisateurId,
      {int page = 0,
      int size = 10}) async {
    try {
      final response = await client.get(Uri.parse(
          '$baseUrl/getAllbyUser/$utilisateurId?page=$page&size=$size'));

      if (response.statusCode == 202) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> content =
            (data['data'] as Map<String, dynamic>)['content'];
        return content.map((json) => ModelesAlbum.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load albums: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getModelesAlbumsByUtilisateurId: $e');
      rethrow;
    }
  }

  // Récupérer les albums par catégorie (paginés)
  Future<List<ModelesAlbum>> getModelesAlbumsByCategorie(String categorie,
      {int page = 0, int size = 10}) async {
    try {
      final response = await client.get(Uri.parse(
          '$baseUrl/categorie/$categorie/page?page=$page&size=$size'));

      if (response.statusCode == 202) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> content =
            (data['data'] as Map<String, dynamic>)['content'];
        return content.map((json) => ModelesAlbum.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load albums: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getModelesAlbumsByCategorie: $e');
      rethrow;
    }
  }
}
