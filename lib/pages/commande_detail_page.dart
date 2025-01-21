import 'dart:convert';

import 'package:Metre/models/commande_model.dart';
import 'package:Metre/pages/detail_mesure_page.dart';
import 'package:Metre/services/CustomIntercepter.dart';
import 'package:Metre/widgets/CustomSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart'; // Ajout de l'import pour dotenv

class CommandeDetailsPage extends StatefulWidget {
  final Commande commande;

  CommandeDetailsPage({required this.commande});

  @override
  State<CommandeDetailsPage> createState() => _CommandeDetailsPageState();
}

class _CommandeDetailsPageState extends State<CommandeDetailsPage> {
  late String? commandeId;
  late Commande _commande; // Variable locale pour la commande

  @override
  void initState() {
    super.initState();
    commandeId = widget.commande.id;
    _commande = widget.commande; // Initialise la variable locale
  }

  // Fonction pour obtenir la couleur du statut
  Color _getStatutColor(String statut) {
    switch (statut) {
      case 'CREER':
        return const Color.fromARGB(255, 142, 127, 1);
      case 'ENCOUR':
        return Colors.orange;
      case 'TERMINER':
        return Colors.blue;
      case 'LIVRER':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

// Création d'une instance de CustomIntercepter (en dehors de la classe)
  final http.Client client = CustomIntercepter(http.Client());

  Future<void> _updateCommandeStatus(String newStatus) async {
    final url =
        'http://192.168.56.1:8010/api/commandes/changestatus/$commandeId';
    print('URL de la requete: $url');

    // final token = await getToken(); // Récupère le token stocké

    try {
      final response = await client.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $token', // Ajoute le token
        },
        body: jsonEncode({'status': newStatus}),
      );
      if (response.statusCode == 202) {
        // Mise à jour réussie
        final responseData = jsonDecode(response.body);
        // print('Réponse du backend : $responseData');
        CustomSnackBar.show(context,
            message: '${responseData['message']}', isError: false);

        setState(() {
          widget.commande.status =
              newStatus; //mettre à jour l'état de widget.commande
        });
      } else {
        // Erreur lors de la mise à jour
        // print(
        //     'Erreur lors de la mise à jour du statut: ${response.statusCode}, ${response.body}');
        final responseData = jsonDecode(response.body);
        CustomSnackBar.show(context,
            message: '${responseData['message']}', isError: true);
      }
    } catch (e) {
      // print('Erreur lors de la requête : $e');

      CustomSnackBar.show(context,
          message: 'Une erreur s\'est produite lors de la requête: $e',
          isError: true);
    }
  }

  // Future<void> _ajouterPayementCommande(String montant) async {
  //   final url = 'http://localhost:8010/api/payementcommande/create/$commandeId';
  //   print('URL de la requete: $url');

  //   // final token = await getToken(); // Récupère le token stocké

  //   try {
  //     final response = await client.post(
  //       Uri.parse(url),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         // 'Authorization': 'Bearer $token', // Ajoute le token
  //       },
  //       body: jsonEncode({'montant': montant}),
  //     );
  //     if (response.statusCode == 202) {
  //       // Mise à jour réussie
  //       final responseData = jsonDecode(response.body);
  //       // print('Réponse du backend : $responseData');
  //       CustomSnackBar.show(context,
  //           message: '${responseData['message']}', isError: false);

  //       // Mise à jour de la commande (par exemple, recupération des infos de la commande à nouveau)
  //       _refreshCommande();
  //     } else {
  //       // Erreur lors de la mise à jour
  //       // print(
  //       //     'Erreur lors de la mise à jour du statut: ${response.statusCode}, ${response.body}');
  //       final responseData = jsonDecode(response.body);
  //       CustomSnackBar.show(context,
  //           message: '${responseData['message']}', isError: true);
  //     }
  //   } catch (e) {
  //     // print('Erreur lors de la requête : $e');

  //     CustomSnackBar.show(context,
  //         message: 'Une erreur s\'est produite lors de la requête: $e',
  //         isError: true);
  //   }
  // }

  Future<void> _ajouterPayementCommande(String? montantString) async {
    if (montantString == null || montantString.isEmpty) {
      CustomSnackBar.show(context,
          message: 'Veuillez saisir un montant valide.', isError: true);
      return;
    }
    int? montant;
    try {
      montant = int.tryParse(montantString);
      if (montant == null) {
        CustomSnackBar.show(context,
            message: 'Veuillez saisir un montant numérique valide.',
            isError: true);
        return;
      }
    } catch (e) {
      CustomSnackBar.show(context,
          message: 'Veuillez saisir un montant numérique valide.',
          isError: true);
      return;
    }

    final url =
        'http://192.168.56.1:8010/api/payementcommande/create/$commandeId';
    print('URL de la requete: $url');

    try {
      final response = await client.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'montant': montant}),
      );
      if (response.statusCode == 202) {
        // Paiement ajouté avec succès (code 201)
        final responseData = jsonDecode(response.body);
        CustomSnackBar.show(context,
            message: '${responseData['message']}', isError: false);

        // Mise à jour de la commande (par exemple, recupération des infos de la commande à nouveau)
        _refreshCommande();
      } else {
        // Erreur lors de l'ajout du paiement
        final responseData = jsonDecode(response.body);
        CustomSnackBar.show(context,
            message: '${responseData['message']}', isError: true);
      }
    } catch (e) {
      CustomSnackBar.show(context,
          message: 'Une erreur s\'est produite lors de la requête: $e',
          isError: true);
    }
  }

  Future<void> _refreshCommande() async {
    final url = 'http://192.168.56.1:8010/api/commandes/loadbyid/$commandeId';
    try {
      final response = await client.get(Uri.parse(url));
      if (response.statusCode == 202) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _commande = Commande.fromJson(
              responseData['data']); // Mise à jour de _commande locale
        });
      } else {
        print(
            'Erreur lors de la mise à jour de la commande : ${response.statusCode}');
        CustomSnackBar.show(context,
            message: 'Erreur lors de la récupération des données',
            isError: true);
      }
    } catch (e) {
      print('Erreur lors de la requête : $e');
      CustomSnackBar.show(context,
          message: 'Une erreur s\'est produite lors de la requête: $e',
          isError: true);
    }
  }

  // Boîte de dialogue pour modifier le statut
  void _changeStatut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String? selectedStatut = _commande.status;
        return AlertDialog(
          title: Text(
            'Modifier le statut',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButtonFormField<String>(
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  value: selectedStatut,
                  items: ['CREER', 'ENCOUR', 'TERMINER', 'LIVRER']
                      .map((statut) => DropdownMenuItem(
                            value: statut,
                            child: Text(
                              statut,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStatut = value;
                    });
                  },
                  decoration: InputDecoration(
                    // border: OutlineInputBorder(),
                    hintText: 'Sélectionnez un statut',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 206, 136, 5),
                        width: 0.4.w,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 206, 136, 5),
                        width: 0.4.w,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.red,
                        width: 0.4.w,
                      ),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  ));
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Annuler', style: TextStyle(fontSize: 12.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Couleur du bouton
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Bords arrondis
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Modifier ici
                if (selectedStatut != null) {
                  await _updateCommandeStatus(selectedStatut!);
                  Navigator.pop(context);
                }
              },
              child: Text('Enregistrer', style: TextStyle(fontSize: 12.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Color.fromARGB(255, 206, 136, 5), // Couleur du bouton
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Bords arrondis
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Boîte de dialogue pour effectuer un paiement
  void _makePayment(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController paymentController = TextEditingController();
        return AlertDialog(
          title: Text(
            'Enregistrer un paiement',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          content: TextField(
            keyboardType: TextInputType.number,
            // autofocus: true, // Ajoute cette ligne
            controller: paymentController,
            style: TextStyle(
              fontSize: 10.sp,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            decoration: InputDecoration(
              labelText: 'Montant à payer',
              labelStyle: TextStyle(
                fontSize: 10.sp,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              // prefixIcon: Icon(Icons.money),
              // border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Color.fromARGB(255, 206, 136, 5),
                  width: 0.4.w,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Color.fromARGB(255, 206, 136, 5),
                  width: 0.4.w,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.red,
                  width: 0.4.w,
                ),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Annuler', style: TextStyle(fontSize: 12.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Couleur du bouton
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Bords arrondis
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Logique pour enregistrer le paiement
                // Ici, tu vas faire l'appel API pour faire la mise à jour du paiement
                await _ajouterPayementCommande(paymentController.text);
                Navigator.pop(context);
              },
              child: Text('Valider', style: TextStyle(fontSize: 12.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Color.fromARGB(255, 206, 136, 5), // Couleur du bouton
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Bords arrondis
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Dialogue pour la confirmation de suppression
  void _deleteCommande(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Supprimer la commande',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer cette commande ?',
            style: TextStyle(fontSize: 12.sp),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Annuler', style: TextStyle(fontSize: 12.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Logique pour supprimer la commande
                // Ici, tu vas faire l'appel API pour faire la suppression de la commande
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Commande supprimée avec succès.')),
                );
              },
              child: Text(
                'Supprimer',
                style: TextStyle(fontSize: 12.sp),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 206, 136, 5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.keyboard_backspace,
            size: 30,
          ),
        ),
        title: Text(
          ' ${_commande.reference}',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Informations Principales', onEdit: () {
              // Logique pour editer la section  Informations Principales
              print('Editer Informations Principales');
            }, onDelete: () {
              // Logique pour supprimer la section Informations Principales
              print('Supprimer Informations Principales');
            }),
            _buildInfoRow(
              'Client',
              _commande.proprietaire?.client?.nom ?? "Inconnu",
              color: Theme.of(context).colorScheme.tertiary,
            ),
            _buildInfoRow(
              'Pour',
              _commande.proprietaire?.proprio ?? "Inconnu",
              color: Theme.of(context).colorScheme.tertiary,
            ),
            _buildInfoRow(
                'Créée le', dateFormat.format(_commande.datecreation!)),
            _buildInfoRow(
              'Date RDV',
              _commande.daterdv ?? "Inconnu",
              color: Theme.of(context).colorScheme.tertiary,
            ),
            _buildInfoRow('Statut', _commande.status ?? "Inconnu",
                color: _getStatutColor(_commande.status ?? '')),
            _buildInfoRow(
              'Prix de la commande',
              '${_commande.prix} CFA',
              color: Theme.of(context).colorScheme.tertiary,
            ),
            _buildInfoRow(
              'Rest a payé',
              '${_commande.rest} CFA',
              color: Theme.of(context).colorScheme.tertiary,
            ),
            SizedBox(height: 1.h),

            // Bouton Afficher le client et Modifier statut
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 1.h, bottom: 1.h),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailMesurePage(
                              clientId: _commande.proprietaire?.client?.id ??
                                  "Inconnu"),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.person,
                      size: 12.sp,
                    ),
                    label: Text(
                      "Afficher le client",
                      style: TextStyle(fontSize: 10.sp),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Color.fromARGB(255, 206, 136, 5), // Couleur du bouton
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8), // Bords arrondis
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 1.h, bottom: 1.h),
                  child: ElevatedButton.icon(
                    onPressed: () => _changeStatut(context),
                    icon: Icon(
                      Icons.edit_note,
                      size: 12.sp,
                    ),
                    label: Text(
                      "Modifier le statut",
                      style: TextStyle(fontSize: 10.sp),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Color.fromARGB(255, 206, 136, 5), // Couleur du bouton
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8), // Bords arrondis
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Tissus
            _buildSectionTitle(
              'Tissus',
              //  onEdit: () {
              //   // Logique pour editer la section  Tissus
              //   print('Editer Tissus');
              // }, onDelete: () {
              //   // Logique pour supprimer la section Tissus
              //   print('Supprimer Tissus');
              // }
            ),
            if (_commande.tissus != null && _commande.tissus!.isNotEmpty)
              ..._commande.tissus!.map((tissu) {
                return _buildTissuItem(
                  context,
                  tissu,
                  onEdit: () {
                    // Logique pour modifier un tissu
                    print('Modifier le tissu : ${tissu.nom}');
                  },
                  onDelete: () {
                    // Logique pour supprimer un tissu
                    print('Supprimer le tissu : ${tissu.nom}');
                  },
                );
              }).toList()
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "Aucun Tissus pour cette commande",
                  style: TextStyle(fontSize: 12.sp),
                ),
              ),
            const Divider(),

            // Modèles
            _buildSectionTitle(
              'Modèles',
              // onEdit: () {
              //     // Logique pour editer la section Modèles
              //     print('Editer Modèles');
              //   }, onDelete: () {
              //     // Logique pour supprimer la section Modèles
              //     print('Supprimer Modèles');
              // }
            ),
            if (_commande.tissus != null && _commande.tissus!.isNotEmpty)
              ..._commande.tissus!
                  .expand((tissu) => tissu.modeles ?? [])
                  .map((modele) {
                return _buildModeleItem(context, modele, onEdit: () {
                  // Logique pour modifier un modèle
                  print('Modifier le modèle : ${modele.nom}');
                }, onDelete: () {
                  // Logique pour supprimer un modèle
                  print('Supprimer le modèle : ${modele.nom}');
                });
              }).toList()
            else
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "Aucun Modèles pour cette commande",
                  style: TextStyle(fontSize: 10.sp),
                ),
              ),
            const Divider(),

            SizedBox(height: 1.h),

            _buildSectionTitle(
              'Paiements',
              //  onEdit: () {
              //   // Logique pour editer la section Modèles
              //   print('Editer Modèles');
              // }, onDelete: () {
              //   // Logique pour supprimer la section Modèles
              //   print('Supprimer Modèles');
              // }
            ),
            if (_commande.payementCommandes != null &&
                _commande.payementCommandes!.isNotEmpty)
              ..._commande.payementCommandes!.map((payement) {
                return _buildPayementItem(
                  context,
                  payement,
                  onEdit: () {
                    // Logique pour modifier un paiement
                    print('Modifier le paiement : ${payement.reference}');
                  },
                  onDelete: () {
                    // Logique pour supprimer un paiement
                    print('Supprimer le paiement : ${payement.reference}');
                  },
                );
              }).toList()
            else
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "Aucun Paiements pour cette commande",
                  style: TextStyle(fontSize: 12.sp),
                ),
              ),
            const Divider(),

            SizedBox(height: 2.h),
            // Actions
            _buildActionsButtons(context),
          ],
        ),
      ),
    );
  }

  // Widget de titre de section
  Widget _buildSectionTitle(String title,
      {VoidCallback? onEdit, VoidCallback? onDelete}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          Row(
            children: [
              if (onEdit != null)
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    size: 14.sp,
                    color: Colors.blue,
                  ),
                  onPressed: onEdit,
                ),
              if (onDelete != null)
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    size: 14.sp,
                    color: Colors.red,
                  ),
                  onPressed: onDelete,
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget pour afficher une ligne d'information
  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label :',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                  fontSize: 10.sp, fontWeight: FontWeight.w600, color: color),
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour afficher un élément de la liste des tissus
  Widget _buildTissuItem(BuildContext context, Tissu tissu,
      {VoidCallback? onEdit, VoidCallback? onDelete}) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (tissu.fichiersTissus != null &&
                    tissu.fichiersTissus!.isNotEmpty)
                  Image.network(
                    tissu.fichiersTissus![0].urlfichier!,
                    fit: BoxFit.contain,
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    tissu.nom ?? "Inconnu",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            if (tissu.fichiersTissus != null &&
                tissu.fichiersTissus!.isNotEmpty)
              Image.network(
                tissu.fichiersTissus![0].urlfichier!,
                width: 25.w,
                height: 15.h,
                fit: BoxFit.cover,
              ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nom:  ${tissu.nom ?? "Inconnu"}',
                    style: TextStyle(fontSize: 10.sp),
                  ),
                  SizedBox(
                    height: 0.5.h,
                  ),
                  Text(
                    'Quantité:  ${tissu.quantite ?? "Inconnu"}',
                    style: TextStyle(fontSize: 10.sp),
                  ),
                  SizedBox(
                    height: 0.5.h,
                  ),
                  Text(
                    'Couleur:  ${tissu.couleur ?? "Inconnu"}',
                    style: TextStyle(fontSize: 10.sp),
                  ),
                  SizedBox(
                    height: 0.5.h,
                  ),
                  Text(
                    'Fourni par:  ${tissu.fournipar ?? "Inconnu"}',
                    style: TextStyle(fontSize: 10.sp),
                  ),
                ],
              ),
            ),
            if (onEdit != null || onDelete != null)
              Column(
                children: [
                  if (onEdit != null)
                    IconButton(
                        onPressed: onEdit,
                        icon: Icon(
                          Icons.edit,
                          size: 14.sp,
                          color: Colors.blue,
                        )),
                  if (onDelete != null)
                    IconButton(
                        onPressed: onDelete,
                        icon: Icon(
                          Icons.delete,
                          size: 14.sp,
                          color: Colors.red,
                        ))
                ],
              )
          ],
        ),
      ),
    );
  }

  // Widget pour afficher un élément de la liste des modèles
  Widget _buildModeleItem(BuildContext context, Modele modele,
      {VoidCallback? onEdit, VoidCallback? onDelete}) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (modele.fichiersModeles != null &&
                    modele.fichiersModeles!.isNotEmpty)
                  Image.network(
                    modele.fichiersModeles![0].urlfichier!,
                    fit: BoxFit.contain,
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    modele.nom ?? "Inconnu",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: Text(modele.description ?? "Inconnu"),
                // ),
              ],
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            if (modele.fichiersModeles != null &&
                modele.fichiersModeles!.isNotEmpty)
              Image.network(
                modele.fichiersModeles![0].urlfichier!,
                width: 25.w,
                height: 15.h,
                fit: BoxFit.cover,
              ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nom : ${modele.nom ?? "Inconnu"}',
                      style: TextStyle(fontSize: 10.sp)),
                  SizedBox(height: 0.5.h),
                  Text('Description : ${modele.description ?? "Inconnu"}',
                      style: TextStyle(fontSize: 10.sp)),
                ],
              ),
            ),
            if (onEdit != null || onDelete != null)
              Column(
                children: [
                  if (onEdit != null)
                    IconButton(
                        onPressed: onEdit,
                        icon: Icon(
                          Icons.edit,
                          size: 14.sp,
                          color: Colors.blue,
                        )),
                  if (onDelete != null)
                    IconButton(
                        onPressed: onDelete,
                        icon: Icon(
                          Icons.delete,
                          size: 14.sp,
                          color: Colors.red,
                        ))
                ],
              )
          ],
        ),
      ),
    );
  }

//   Ajoute également la méthode pour afficher un item de payement
//  ```dart
  Widget _buildPayementItem(BuildContext context, PayementCommande payement,
      {VoidCallback? onEdit, VoidCallback? onDelete}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Référence :', style: TextStyle(fontSize: 10.sp)),
                    Text(
                      ' ${payement.reference ?? "Inconnu"}',
                      style: TextStyle(
                          fontSize: 10.sp, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Text('Montant :', style: TextStyle(fontSize: 10.sp)),
                    Text(
                      ' ${payement.montant?.toString() ?? "Inconnu"} CFA',
                      style: TextStyle(
                          fontSize: 10.sp, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Text('Date :', style: TextStyle(fontSize: 10.sp)),
                    Text(
                      ' ${payement.date != null ? dateFormat.format(payement.date!) : "Inconnu"}',
                      style: TextStyle(
                          fontSize: 10.sp, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                // Text(
                //     'Date: ${payement.date != null ? dateFormat.format(payement.date!) : "Inconnu"}',
                //     style: TextStyle(fontSize: 10.sp)),
              ],
            ),
          ),
          if (onEdit != null || onDelete != null)
            Column(
              children: [
                if (onEdit != null)
                  IconButton(
                      onPressed: onEdit,
                      icon: Icon(
                        Icons.edit,
                        size: 14.sp,
                        color: Colors.blue,
                      )),
                if (onDelete != null)
                  IconButton(
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete,
                        size: 14.sp,
                        color: Colors.red,
                      ))
              ],
            )
        ],
      ),
    );
  }

  // Widget pour les boutons d'action
  Widget _buildActionsButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          margin: EdgeInsets.only(top: 1.h, bottom: 1.h),
          child: ElevatedButton.icon(
            onPressed: () => _makePayment(context),
            icon: Icon(
              Icons.payment,
              size: 12.sp,
            ),
            label: Text(
              "Ajouter un Paiement",
              style: TextStyle(fontSize: 10.sp),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Bords arrondis
              ),
            ),
          ),
        ),
      ],
    );
  }
}
