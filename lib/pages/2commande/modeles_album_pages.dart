import 'dart:math';
import 'package:Metre/models/modelesAlbum%20.dart';
import 'package:Metre/pages/2commande/select_client_page.dart';
import 'package:Metre/pages/add_modeles_album_page.dart';
import 'package:Metre/pages/modeles_album_details_page.dart';
import 'package:Metre/services/ApiService.dart';
import 'package:Metre/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ModelesAlbumPages extends StatefulWidget {
  const ModelesAlbumPages({Key? key}) : super(key: key);

  @override
  State<ModelesAlbumPages> createState() => _ModelesAlbumPagesState();
}

class _ModelesAlbumPagesState extends State<ModelesAlbumPages> {
  String? _id;
  String? _token;

  final ApiService apiService = ApiService();
  List<ModelesAlbum> albums = [];
  int _page = 0;
  int _size = 10;
  bool _isLoading = false;
  bool _hasMore = true;
  ScrollController _scrollController = ScrollController();
  List<String> categories = [
    'TOUT', // Ajouter l'option "TOUT"
    'ROBES',
    'PANTALONS',
    'JUPES',
    'CHEMISES',
    'BLOUSES',
    'TISSUS_COMPLET',
    'VESTES',
    'COLLECTIONS_SPECIALES',
    'AUTRE',
  ];
  String? selectedCategory; // La catégorie sélectionnée

  // New variables for selected models and their images
  List<ModelesAlbum> selectedAlbums = [];
  List<String> selectedImageUrls = [];

  @override
  void initState() {
    super.initState();
    selectedCategory = 'TOUT'; // Sélectionner "TOUT" par défaut
    _loadUserData().then((_) {
      _loadMoreAlbums();
      _scrollController.addListener(_onScroll);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        _hasMore &&
        !_isLoading) {
      _loadMoreAlbums();
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _id = prefs.getString('id');
      _token = prefs.getString('token');
    });
  }

  Future<void> _loadMoreAlbums() async {
    if (_isLoading || !_hasMore) return;
    setState(() {
      _isLoading = true;
    });
    try {
      List<ModelesAlbum> newAlbums;
      if (selectedCategory == null || selectedCategory == 'TOUT') {
        // Charger tous les albums
        newAlbums = await apiService.getModelesAlbumsByUtilisateurId(_id!,
            page: _page, size: _size);
      } else {
        // Charger les albums par catégorie
        newAlbums = await apiService.getModelesAlbumsByCategorie(
            selectedCategory!,
            page: _page,
            size: _size);
      }

      setState(() {
        albums.addAll(newAlbums);
        _isLoading = false;
        if (newAlbums.isEmpty || newAlbums.length < _size) {
          _hasMore = false;
        } else {
          _page++;
        }
      });
    } catch (e) {
      print('Error loading albums: $e');
      setState(() {
        _isLoading = false;
      });
      // Gérez l'erreur (afficher un message d'erreur, etc.)
    }
  }

  // Function to toggle selection of an album and its images
  void toggleAlbumSelection(ModelesAlbum album) {
    setState(() {
      if (selectedAlbums.contains(album)) {
        selectedAlbums.remove(album);
        selectedImageUrls.removeWhere((url) => album.images.contains(url));
      } else {
        selectedAlbums.add(album);
        selectedImageUrls.addAll(album.images);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double itemwidth = (w / 2) - 24; // Adjusted for padding and spacing
    double crossAxisCount = (w / itemwidth).roundToDouble();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: LogoWidget(),
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: Column(
        children: [
          // Barre de catégories
          Container(
            height: 5.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                      print('Catégorie sélectionnée: $category');
                      _page = 0; // Réinitialiser la pagination
                      albums.clear(); // Vider la liste des albums
                      _hasMore = true; // Réinitialiser le flag _hasMore
                      _loadMoreAlbums(); // Recharger les albums
                    });
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.h),
                    margin: EdgeInsets.symmetric(horizontal: 1.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          category,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Color.fromARGB(255, 206, 136, 5)
                                : Colors.black, // Modifier la couleur du texte
                          ),
                        ),
                        if (isSelected)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            width: 10.w,
                            height: 1,
                            color: Color.fromARGB(255, 206, 136,
                                5), // Modifier la couleur de l'indicateur
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Grille des albums
          Expanded(
            child: _isLoading && albums.isEmpty
                ? _buildShimmerGrid(
                    crossAxisCount: crossAxisCount.toInt(),
                    itemwidth: itemwidth) // Afficher Shimmer
                : albums.isEmpty
                    ? Center(
                        child: Text('Aucun album trouvé.',
                            style: TextStyle(fontSize: 12.sp)))
                    : MasonryGridView.count(
                        controller: _scrollController,
                        crossAxisCount: crossAxisCount.toInt(),
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        padding: EdgeInsets.all(16.0),
                        itemCount: albums.length + (_isLoading ? 1 : 0),
                        itemBuilder: (BuildContext context, int index) {
                          if (index < albums.length) {
                            final album = albums[index];
                            double itemHeight = 200; // Définir une hauteur fixe

                            return AlbumCard(
                              album: album,
                              itemWidth: itemwidth,
                              itemHeight: itemHeight,
                              isSelected: selectedAlbums
                                  .contains(album), // Pass the selection state
                              onTap: () {
                                toggleAlbumSelection(album);
                              },
                            );
                          } else {
                            return _buildLoader();
                          }
                        },
                      ),
          ),
          if (selectedAlbums.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelectClientPage(
                        selectedAlbums: selectedAlbums, // Passer selectedAlbums
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 206, 136, 5),
                  foregroundColor: Colors.white,
                ),
                child: Text('Commander'),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Ouvrir la page d'ajout de modèles
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddModelesAlbumPage()),
          );
          // Si un nouvel album a été créé, recharger les albums
          if (result == true) {
            setState(() {
              _page = 0;
              albums.clear();
              _hasMore = true;
              _loadMoreAlbums();
            });
          }
        },
        backgroundColor: Color.fromARGB(255, 206, 136, 5),
        child: Icon(Icons.add, size: 15.sp),
      ),
    );
  }

  Widget _buildShimmerGrid(
      {required int crossAxisCount, required double itemwidth}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: MasonryGridView.count(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        padding: EdgeInsets.all(16.0),
        itemCount: 6, // Nombre d'éléments Shimmer à afficher
        itemBuilder: (BuildContext context, int index) {
          double itemHeight = 200;
          return ShimmerAlbumCard(itemWidth: itemwidth, itemHeight: itemHeight);
        },
      ),
    );
  }

  Widget _buildLoader() {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : SizedBox.shrink();
  }
}

class ShimmerAlbumCard extends StatelessWidget {
  final double itemWidth;
  final double itemHeight;

  const ShimmerAlbumCard({
    Key? key,
    required this.itemWidth,
    required this.itemHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      color: Colors.grey[300], // Couleur de base du Shimmer
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: itemWidth,
            height: itemHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                color: Colors.grey[300], // Couleur de base du Shimmer
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.0),
            child: Container(
              width: itemWidth * 0.7,
              height: 10,
              color: Colors.grey[300], // Couleur de base du Shimmer
            ),
          ),
        ],
      ),
    );
  }
}

class AlbumCard extends StatelessWidget {
  final ModelesAlbum album;
  final double itemWidth;
  final double itemHeight;
  final bool isSelected; // Indicate if the album is selected
  final VoidCallback onTap; // Callback for single tap (selection)

  const AlbumCard({
    Key? key,
    required this.album,
    required this.itemWidth,
    required this.itemHeight,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Single tap for selection
      onDoubleTap: () {
        // Double tap for details
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ModelesAlbumDetailsPage(
                albumId: album.id), // Passer l'ID de l'album
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: isSelected
              ? BorderSide(color: Color.fromARGB(255, 237, 183, 82), width: 2)
              : BorderSide.none,
        ), // Highlight the selected card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: itemWidth,
              height: itemHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  color: Colors.grey[300],
                  child: album.images.isNotEmpty
                      ? Image.network(
                          album.images[0],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(child: Text('Erreur de chargement'));
                          },
                        )
                      : Center(
                          child: Text(
                            "Aucune image disponible",
                            textAlign: TextAlign.center,
                          ),
                        ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.0),
              child: Text(
                album.nom,
                style: TextStyle(fontSize: 8.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
