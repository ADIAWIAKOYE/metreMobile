import 'package:Metre/models/mesure_model.dart';
import 'package:Metre/models/modelesAlbum%20.dart';
import 'package:Metre/pages/2commande/create_commande_pages.dart';
import 'package:Metre/pages/commandes/CreateCommandePage.dart';
import 'package:Metre/models/proprioMesures_model.dart';
import 'package:Metre/models/utilisateur_model.dart'; // Import UtilisateurModel
import 'package:Metre/services/ApiService.dart';
import 'package:Metre/widgets/CustomSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class SelectClientPage extends StatefulWidget {
  final List<ModelesAlbum> selectedAlbums; // Accepter selectedAlbums

  const SelectClientPage({Key? key, required this.selectedAlbums})
      : super(key: key);

  @override
  State<SelectClientPage> createState() => _SelectClientPageState();
}

class _SelectClientPageState extends State<SelectClientPage> {
  List<UtilisateurModel> clients = [];
  List<UtilisateurModel> displayedClients = [];
  List<ProprietaireMesure> proprietaires = [];
  ProprietaireMesure? selectedProprietaire;
  UtilisateurModel? selectedClient; // Keep track of the selected client
  bool _isLoadingClients = true;
  bool _isLoadingProprietaires = false;
  final ApiService apiService = ApiService();
  String? _id;

  @override
  void initState() {
    super.initState();
    _loadUserData().then((_) {
      _loadClients();
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _id = prefs.getString('id');
    });
  }

  Future<void> _loadClients() async {
    setState(() {
      _isLoadingClients = true;
    });
    try {
      clients = await apiService.getAllClientsByUtilisateurId(_id!);
      displayedClients = List.from(clients);
    } catch (e) {
      CustomSnackBar.show(context,
          message: 'Error loading clients: $e', isError: true);
    } finally {
      setState(() {
        _isLoadingClients = false;
      });
    }
  }

  Future<void> _loadProprietaires(String clientId) async {
    setState(() {
      _isLoadingProprietaires = true;
      selectedProprietaire = null; // Reset selected owner when client changes
    });
    try {
      proprietaires = await apiService.getProprietairesByClientId(clientId);
      // After loading owners, if there are any select the first owner
      if (proprietaires.isNotEmpty) {
        setState(() {
          selectedProprietaire = proprietaires.first;
        });
      }
    } catch (e) {
      CustomSnackBar.show(context,
          message: 'Error loading proprietaires: $e', isError: true);
    } finally {
      setState(() {
        _isLoadingProprietaires = false;
      });
    }
  }

  void updateClientList(String value) {
    setState(() {
      displayedClients = clients.where((client) {
        final fullName = "${client.nom}";
        final searchTerms = value.toLowerCase().split(' ');
        bool containsAllSearchTerms = true;
        for (final term in searchTerms) {
          containsAllSearchTerms = containsAllSearchTerms &&
              (client.nom!.toLowerCase().contains(term)
              // ||
              //     element.prenom!.toLowerCase().contains(term)
              );
        }
        return containsAllSearchTerms ||
            fullName.toLowerCase().contains(value.toLowerCase()) ||
            client.username!.toLowerCase().contains(value.toLowerCase());
      }).toList();
      // displayedClients = clients.where((client) {
      //   final fullName = client.nom?.toLowerCase() ?? '';
      //   final searchTerm = value.toLowerCase();
      //   return fullName.contains(searchTerm);
      // }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Selectionner un Client',
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: updateClientList,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.tertiary,
                  decoration: TextDecoration.none,
                  fontSize: 10.sp),
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).colorScheme.primary,
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15), // même rayon que ClipRRect
                  borderSide: BorderSide(
                    color: Color.fromARGB(
                        255, 206, 136, 5), // Couleur de la bordure
                    width: 0.4.w, // Largeur de la bordure
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 206, 136, 5),
                    width: 0.4.w,
                  ), // Couleur de la bordure lorsqu'elle est en état de focus
                ),
                hintText: "Rechercher un client...",
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 10.sp,
                ),
                prefixIcon: Icon(Icons.search),
                prefixIconColor: Theme.of(context).colorScheme.secondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 1.h),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _isLoadingClients
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: displayedClients.length,
                      itemBuilder: (context, index) {
                        final client = displayedClients[index];
                        return Card(
                          elevation: 3,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Color.fromARGB(255, 206, 136, 5),
                              child: Text(
                                client.nom?[0].toUpperCase() ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                            title: Text(
                              client.nom ?? 'Unknown Client',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10.sp,
                              ),
                            ),
                            subtitle: Text(
                              client.username ?? 'No Phone',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 10.sp,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                selectedClient = client; // Select a client
                              });
                              _loadProprietaires(client.id ??
                                  'null'); // Load Proprietaires for the selected client
                            },
                            selected: selectedClient == client,
                            selectedTileColor: Colors.grey[200],
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(height: 20),
            // Owner Selection Area
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Sélectionner le propriétaire :",
                      style: TextStyle(
                          fontSize: 12.sp, fontWeight: FontWeight.w500)),
                  SizedBox(height: 10),
                  _isLoadingProprietaires
                      ? Center(child: CircularProgressIndicator())
                      : (proprietaires.isNotEmpty
                          ? SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: proprietaires.map((owner) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedProprietaire = owner;
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 8),
                                      margin: EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        color: selectedProprietaire == owner
                                            ? Color.fromARGB(255, 237, 183, 82)
                                            : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: selectedProprietaire == owner
                                              ? Color.fromARGB(255, 206, 136, 5)
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: Text(owner.proprio ?? "Unknown",
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                          )),
                                    ),
                                  );
                                }).toList(),
                              ),
                            )
                          : Text(
                              "Aucun propriétaire trouvé pour ce client.",
                              style: TextStyle(
                                fontSize: 10.sp,
                              ),
                            )),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectedProprietaire == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateCommandePages(
                            proprioId: selectedProprietaire!.id!,
                            selectedAlbums: widget
                                .selectedAlbums, // Transmettre les modèles sélectionnés
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                textStyle: TextStyle(fontSize: 10.sp),
                backgroundColor: Color.fromARGB(255, 206, 136, 5),
                foregroundColor: Colors.white,
              ),
              child: Text('Continuer la commander'),
            ),
          ],
        ),
      ),
    );
  }
}
