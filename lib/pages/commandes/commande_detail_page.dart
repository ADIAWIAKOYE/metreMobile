import 'dart:convert';
import 'dart:io';

import 'package:Metre/bottom_navigationbar/navigation_page.dart';
import 'package:Metre/models/commande_model.dart';
import 'package:Metre/pages/detail_mesure_page.dart';
import 'package:Metre/pages/edit_modele_page.dart';
import 'package:Metre/pages/edit_tissu_page.dart';
import 'package:Metre/services/CustomIntercepter.dart';
import 'package:Metre/widgets/CustomSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

// import 'package:flutter_dotenv/flutter_dotenv.dart'; // Ajout de l'import pour dotenv

class CommandeDetailsPage extends StatefulWidget {
  final Commande commande;
  final Function(String)? onCommandeAnnulee; // Add callback function
  final Function(Commande)? onCommandeUpdated; // Nouveau callback

  CommandeDetailsPage({
    required this.commande,
    this.onCommandeAnnulee,
    this.onCommandeUpdated,
  });

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
      case 'ANNULER':
        return Colors.red;
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

        // Mise à jour de la commande (par exemple, recupération des infos de la commande à nouveau)
        // _refreshCommande();
        setState(() {
          _commande.status = newStatus;
        });

        // Appeler le callback pour informer la page parente
        if (widget.onCommandeUpdated != null) {
          widget.onCommandeUpdated!(_commande);
        }
        //  Check if the status is "ANNULER" and call the callback
        if (newStatus == 'ANNULER') {
          widget.onCommandeAnnulee?.call(commandeId!); // Call the callback
        }
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Appeler _refreshCommande ici pour charger les données à chaque fois que le widget revient en premier plan
    _refreshCommande();
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

  Future<void> _functiondeleteCommande() async {
    final url = 'http://192.168.56.1:8010/api/commandes/delete/$commandeId';
    try {
      final response = await client.delete(Uri.parse(url));
      if (response.statusCode == 202) {
        final responseData = jsonDecode(response.body);
        CustomSnackBar.show(context,
            message: '${responseData['message']}', isError: false);
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => NavigationBarPage(
                initialIndex: 2, // Rediriger vers la page des clients
              ),
            ),
          );
        }
      } else {
        // print(
        //     'Erreur lors de la suppression de la commande : ${response.statusCode}');
        final responseData = jsonDecode(response.body);
        CustomSnackBar.show(context,
            message: '${responseData['message']}', isError: true);
      }
    } catch (e) {
      print('Erreur lors de la requête : $e');
      CustomSnackBar.show(context,
          message: 'Une erreur s\'est produite lors de la requête: $e',
          isError: true);
    }
  }

  Future<void> _deletePayement(String idpayement) async {
    final url =
        'http://192.168.56.1:8010/api/payementcommande/payementcommande/$idpayement';
    try {
      final response = await client.delete(Uri.parse(url));
      if (response.statusCode == 202) {
        final responseData = jsonDecode(response.body);

        setState(() {
          _refreshCommande();
        });
        CustomSnackBar.show(context,
            message: '${responseData['message']}', isError: false);
      } else {
        print(
            'Erreur lors de la mise à jour de la commande : ${response.statusCode}');
        CustomSnackBar.show(context,
            message: 'Erreur lors de la suppression du payement',
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
    if (_commande.status == 'ANNULER') {
      CustomSnackBar.show(context,
          message: 'Impossible de modifier le statut d\'une commande annulée.',
          isError: true);
      return; // Ne pas ouvrir la boîte de dialogue
    }

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
                  items: [
                    'CREER',
                    'ENCOUR',
                    'TERMINER',
                    'LIVRER'
                  ] // Removed 'ANNULER'
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
    if (_commande.status == 'ANNULER') {
      CustomSnackBar.show(context,
          message:
              'Impossible d\'ajouter des payements sur une commande annulée.',
          isError: true);
      return; // Ne pas ouvrir la boîte de dialogue
    }
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController paymentController = TextEditingController();
        return AlertDialog(
          title: Text(
            'Enregistrer un paiement',
            style: TextStyle(
              fontSize: 10.sp,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Annuler', style: TextStyle(fontSize: 10.sp)),
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
                  child: Text('Valider', style: TextStyle(fontSize: 10.sp)),
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
            ),
          ],
        );
      },
    );
  }

  // Dialogue pour la confirmation de suppression
  void _deletepayement(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Supprimer du Payement de commande',
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer cet Payement de commande ?',
            style: TextStyle(fontSize: 10.sp),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Annuler', style: TextStyle(fontSize: 10.sp)),
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
                _deletePayement(id);
                _refreshCommande();
                Navigator.pop(context);
              },
              child: Text(
                'Supprimer',
                style: TextStyle(fontSize: 10.sp),
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

  // Dialogue pour annuler la commande
  void _annulerCommande(BuildContext context, String statut) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Annuler commande',
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Êtes-vous sur le point d\'annuler la commande .',
            style: TextStyle(fontSize: 10.sp),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Non', style: TextStyle(fontSize: 10.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Logique pour supprimer la commande
                // Ici, tu vas faire l'appel API pour
                //faire la suppression de la commande
                if (_commande.payementCommandes != null &&
                    _commande.payementCommandes!.isNotEmpty) {
                  CustomSnackBar.show(context,
                      message:
                          'Impossible d\'annuler une commande qui a des payements ',
                      isError: true);
                  Navigator.pop(context);
                } else {
                  await _updateCommandeStatus(statut);
                  // Appeler le callback pour informer la page appelante
                  Navigator.pop(context);
                }
              },
              child: Text(
                'Oui',
                style: TextStyle(fontSize: 10.sp),
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

  // Dialogue pour la confirmation de suppression
  void _deleteCommande(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Supprimer la commande',
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer cette commande ?',
            style: TextStyle(fontSize: 8.sp),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Annuler', style: TextStyle(fontSize: 10.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Logique pour supprimer la commande
                // Ici, tu vas faire l'appel API pour faire la suppression de la commande

                Navigator.pop(context);
                await _functiondeleteCommande();
              },
              child: Text(
                'Supprimer',
                style: TextStyle(fontSize: 10.sp),
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

// Fonction pour la modification des Tissus
  void _openEditTissusPage(int index) {
    // Add the index parameter
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTissuPage(
            commande: _commande, tissuIndex: index), // pass the index
      ),
    ).then((value) {
      if (value == true) {
        _refreshCommande();
      }
    });
  }

// Fonction pour la modification des modeles
  void _openEditModelePage(int tissuIndex, int modeleIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditModelePage(
            commande: _commande,
            tissuIndex: tissuIndex,
            modeleIndex: modeleIndex),
      ),
    ).then((value) {
      if (value == true) {
        _refreshCommande(); // Actualiser après modification
      }
    });
  }

  // Future<void> _generateAndSharePdf(PayementCommande payement) async {
  //   final pdf = pw.Document();

  //   // Charger la police de Google Fonts
  //   final font = GoogleFonts.roboto;

  //   final fontData =
  //       await rootBundle.load("assets/image/static/Roboto-Regular.ttf");
  //   final pdfFont = pw.Font.ttf(fontData);

  //   pdf.addPage(
  //     pw.Page(
  //       build: (pw.Context context) => pw.Column(
  //         crossAxisAlignment: pw.CrossAxisAlignment.start,
  //         children: [
  //           pw.Text('FACTURE DE PAIEMENT',
  //               style: pw.TextStyle(
  //                   font: pdfFont,
  //                   fontSize: 20,
  //                   fontWeight: pw.FontWeight.bold)),
  //           pw.SizedBox(height: 10),
  //           pw.Text('Référence: ${payement.reference ?? "Inconnu"}',
  //               style: pw.TextStyle(
  //                 font: pdfFont,
  //                 fontSize: 14,
  //               )),
  //           pw.Text('Montant: ${payement.montant?.toString() ?? "Inconnu"} CFA',
  //               style: pw.TextStyle(
  //                 font: pdfFont,
  //                 fontSize: 14,
  //               )),
  //           pw.Text(
  //               'Date: ${payement.date != null ? dateFormat.format(payement.date!) : "Inconnu"}',
  //               style: pw.TextStyle(
  //                 font: pdfFont,
  //                 fontSize: 14,
  //               )),
  //           pw.SizedBox(height: 20),
  //           pw.Text('Merci pour votre paiement !',
  //               style: pw.TextStyle(
  //                 font: pdfFont,
  //                 fontSize: 16,
  //               )),
  //         ],
  //       ),
  //     ),
  //   );

  //   try {
  //     final pdfBytes = await pdf.save();

  //     await Share.shareXFiles(
  //       [
  //         XFile.fromData(pdfBytes,
  //             mimeType: 'application/pdf',
  //             name: 'facture_paiement_${payement.reference}.pdf')
  //       ],
  //       subject: 'Facture de paiement',
  //     );
  //   } catch (e) {
  //     CustomSnackBar.show(context,
  //         message: 'Erreur lors de la génération du PDF: $e', isError: true);
  //   }
  // }

  Future<void> _generateAndSharePdf(
      BuildContext context, PayementCommande payement) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');

    // Charger les polices
    final fontData =
        await rootBundle.load("assets/image/static/Roboto-Regular.ttf");
    final pdfFont = pw.Font.ttf(fontData);

    // Charger les images
    final orangeMoneyLogo = pw.MemoryImage(
      (await rootBundle.load('assets/image/logo_coture.png'))
          .buffer
          .asUint8List(),
    );
    final recuPayeImage = pw.MemoryImage(
      (await rootBundle.load('assets/image/logo_coture.png'))
          .buffer
          .asUint8List(), // Remplacez par le bon chemin
    );
    final orangeLogo = pw.MemoryImage(
      (await rootBundle.load('assets/image/logo_coture.png'))
          .buffer
          .asUint8List(), // Remplacez par le bon chemin
    );

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Logo Orange Money
              pw.Center(
                child: pw.Image(orangeMoneyLogo, width: 150),
              ),
              pw.SizedBox(height: 20),

              // Titre
              pw.Center(
                child: pw.Text('Reçu de paiement de COMMANDE',
                    style: pw.TextStyle(
                        font: pdfFont,
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.SizedBox(
                    width: 0.5 * 595.28 - 40, // 50% de la largeur du document
                    child: pw.Table(
                      columnWidths: {
                        0: const pw.FixedColumnWidth(0.5 * 0.25 * 595.28),
                        1: const pw.FixedColumnWidth(0.5 * 0.25 * 595.28),
                      },
                      border: pw.TableBorder.all(color: PdfColors.grey),
                      children: [
                        _buildTableRow(
                            'Nom et Prénom',
                            _commande.proprietaire?.client?.nom ?? "Inconnu",
                            pdfFont),
                        _buildTableRow(
                            'Téléphone',
                            _commande.proprietaire?.client?.username ??
                                "Inconnu",
                            pdfFont),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              // Table des informations
              pw.Table(
                columnWidths: {
                  0: const pw.FixedColumnWidth(120), // Ajustez la largeur
                  1: const pw.FixedColumnWidth(150), // Ajustez la largeur
                },
                border: pw.TableBorder.all(
                    color: PdfColors.grey), // Ajoute une bordure
                //tablePadding: const pw.EdgeInsets.all(5),  //SUPPRIMER CETTE LIGNE
                children: [
                  // _buildTableRow('N° Facture', '2492223902636', pdfFont),
                  _buildTableRow('Référence de payement',
                      payement.reference ?? "Inconnu", pdfFont),
                  _buildTableRow('Date Paiement',
                      dateFormat.format(payement.date!), pdfFont),

                  _buildTableRow(
                      'Montant facture',
                      '${payement.montant?.toString() ?? "Inconnu"} FCFA',
                      pdfFont),
                ],
              ),
              pw.SizedBox(height: 20),

              pw.Table(
                columnWidths: {
                  0: const pw.FixedColumnWidth(120), // Ajustez la largeur
                  1: const pw.FixedColumnWidth(150), // Ajustez la largeur
                },
                border: pw.TableBorder.all(
                    color: PdfColors.grey), // Ajoute une bordure
                //tablePadding: const pw.EdgeInsets.all(5),  //SUPPRIMER CETTE LIGNE
                children: [
                  // _buildTableRow('N° Facture', '2492223902636', pdfFont),
                  _buildTableRow('Référence de commande',
                      _commande.reference ?? "Inconnu", pdfFont),
                  _buildTableRow(
                      'prix',
                      '${_commande.prix?.toString() ?? "Inconnu"} FCFA',
                      pdfFont),

                  _buildTableRow(
                      'Rest à payé',
                      '${_commande.rest?.toString() ?? "Inconnu"} FCFA',
                      pdfFont),
                ],
              ),
              pw.SizedBox(height: 20),

              pw.Text('Merci pour votre paiement !', // Nouveau message
                  style: pw.TextStyle(
                      font: pdfFont,
                      fontSize: 14)), // Ajuster la taille de la police
              pw.SizedBox(height: 20),

              // Image "reçu payé"
              pw.Center(
                child: pw.Image(recuPayeImage, width: 100),
              ),
              pw.SizedBox(height: 20),

              // Logo Orange en bas
              pw.Align(
                alignment: pw.Alignment.bottomRight,
                child: pw.Image(orangeLogo, width: 80),
              ),
            ],
          );
        },
      ),
    );

    // Sauvegarder et partager le PDF
    try {
      final pdfBytes = await pdf.save();
      final directory = await getTemporaryDirectory();
      final path =
          '${directory.path}/recu_payement_commande_${payement.reference}.pdf';
      final file = File(path);
      await file.writeAsBytes(pdfBytes);

      await Share.shareXFiles(
        [
          XFile(path, mimeType: 'application/pdf'),
        ],
        subject: 'Reçu de paiement COMMANDE',
      );
    } catch (e) {
      CustomSnackBar.show(context,
          message: 'Erreur lors de la génération du PDF: $e', isError: true);
    }
  }

// Helper function to create a table row
  pw.TableRow _buildTableRow(String label, String value, pw.Font pdfFont) {
    return pw.TableRow(children: [
      pw.Padding(
        // Ajout du padding ici
        padding: const pw.EdgeInsets.all(5),
        child: pw.Text(label + ':',
            style: pw.TextStyle(font: pdfFont, fontSize: 12)),
      ),
      pw.Padding(
        // Ajout du padding ici
        padding: const pw.EdgeInsets.all(5),
        child: pw.Text(value, style: pw.TextStyle(font: pdfFont, fontSize: 12)),
      ),
    ]);
  }

  bool _getBorderColor() {
    if (_commande.daterdv == null || _commande.daterdv!.isEmpty) {
      return true;
    }

    try {
      // Extraction des composants de la date
      List<String> dateParts =
          _commande.daterdv!.split('-'); // Sépare l'année, le mois et le jour

      if (dateParts.length != 3) {
        print("Format de date incorrect: ${_commande.daterdv}");
        return true; // Gérer le format incorrect
      }

      int year = int.parse(dateParts[0]);
      int month = int.parse(dateParts[1]);
      int day = int.parse(dateParts[2]);

      // Création de l'objet DateTime (à 00:00:00 par défaut)
      DateTime dateRDV = DateTime(year, month, day);
      DateTime now = DateTime.now();

      if (now.isAfter(dateRDV) && (_commande.status ?? '') != "TERMINER") {
        return false; // Date dépassée et commande non terminée
      } else {
        return true; // Couleur par défaut du statut
      }
    } catch (e) {
      print(
          "Erreur lors de la conversion de la date: $e, dateRDV = ${_commande.daterdv}");
      return true; // Retourner la couleur du statut en cas d'erreur
    }
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
            size: 20.sp,
          ),
        ),
        title: Text(
          ' ${_commande.reference}',
          style: TextStyle(
            fontSize: 11.sp,
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
            if (!_getBorderColor())
              Text(
                "Cette commande dévrais etre terminer avant le ${_commande.daterdv}",
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.red,
                ),
              ),
            _buildSectionTitle(
              'Informations Principales',
              onDelete: () {
                // Logique pour supprimer la section Informations Principales
                print('Supprimer Informations Principales');
                _deleteCommande(context);
              },
              onEdit: () {
                // Logique pour editer la section  Informations Principales
                print('Editer Informations Principales');
              },
            ),
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
              'Prix ',
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
                            clientId:
                                _commande.proprietaire?.client?.id ?? "Inconnu",
                            onClientDeleted: (String) {},
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.person,
                      size: 10.sp,
                    ),
                    label: Text(
                      "Afficher le client",
                      style: TextStyle(fontSize: 8.sp),
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
                      size: 10.sp,
                    ),
                    label: Text(
                      "Modifier le statut",
                      style: TextStyle(fontSize: 8.sp),
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
            if (_commande.tissus != null && _commande.tissus!.isNotEmpty)
              ..._commande.tissus!.indexed.map((indexedTissu) {
                final tissuIndex = indexedTissu.$1; // Extrait l'index du tissu
                final tissu = indexedTissu.$2; // Extrait le tissu
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tissu ${tissuIndex + 1}:",
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    _buildTissuItem(
                      context,
                      tissu,
                      tissuIndex, // Passe l'index du tissu
                      onEdit: () {
                        _openEditTissusPage(tissuIndex);
                      },
                    ),
                    // Modèles associés à ce tissu
                    if (tissu.modeles != null && tissu.modeles!.isNotEmpty)
                      Padding(
                        padding:
                            EdgeInsets.only(left: 16.0), // Ajoute un retrait
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Modèles associés :",
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                            ...tissu.modeles!.indexed.map((indexedModele) {
                              // Utilise indexed pour obtenir l'index du modèle
                              final modeleIndex =
                                  indexedModele.$1; //Extrait l'index du modele
                              final modele =
                                  indexedModele.$2; // Extrait le modele

                              return _buildModeleItem(
                                context,
                                modele,
                                tissuIndex,
                                modeleIndex, // Passe les index du tissu et du modele
                                onEdit: () {
                                  // Logique pour modifier un modèle
                                  _openEditModelePage(tissuIndex, modeleIndex);
                                },
                              );
                            }).toList(),
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
                        child: Text(
                          "Aucun modèle associé à ce tissu.",
                          style: TextStyle(fontSize: 10.sp),
                        ),
                      ),
                  ],
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
                  onDelete: () {
                    _deletepayement(context, payement.id ?? '');

                    print('Supprimer le paiement : ${payement.reference}');
                  },
                );
              }).toList()
            else
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "Aucun Paiements pour cette commande",
                  style: TextStyle(fontSize: 10.sp),
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
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          Row(
            children: [
              if (_commande.status == "ANNULER")
                if (onDelete != null)
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      size: 14.sp,
                      color: Colors.red,
                    ),
                    onPressed: onDelete,
                  ),
              if (onEdit != null)
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    size: 14.sp,
                    color: Colors.blue,
                  ),
                  onPressed: onEdit,
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
            flex: 4,
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
  Widget _buildTissuItem(BuildContext context, Tissu tissu, int tissuIndex,
      {VoidCallback? onEdit, VoidCallback? onDelete}) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            //  shape: null, // Supprime le borderRadius
            // backgroundColor: Colors.transparent, // Transparence pour le Dialog
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (tissu.fichiersTissus != null &&
                      tissu.fichiersTissus!.isNotEmpty)
                    SizedBox(
                      height: 50.h, // Ajustez la hauteur si nécessaire
                      child: PageView.builder(
                          itemCount: tissu.fichiersTissus!.length,
                          itemBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Image.network(
                                  tissu.fichiersTissus![index].urlfichier!,
                                  fit: BoxFit.contain,
                                ),
                              )),
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
              SizedBox(
                  width: 15.w,
                  height: 10.h,
                  child: PageView.builder(
                    itemCount: tissu.fichiersTissus!.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: Image.network(
                        tissu.fichiersTissus![index].urlfichier!,
                        width: 15.w,
                        height: 10.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nom:  ${tissu.nom ?? "Inconnu"}',
                    style: TextStyle(fontSize: 9.sp),
                  ),
                  SizedBox(
                    height: 0.5.h,
                  ),
                  Text(
                    'Quantité:  ${tissu.quantite ?? "Inconnu"}',
                    style: TextStyle(fontSize: 9.sp),
                  ),
                  SizedBox(
                    height: 0.5.h,
                  ),
                  Text(
                    'Couleur:  ${tissu.couleur ?? "Inconnu"}',
                    style: TextStyle(fontSize: 9.sp),
                  ),
                  SizedBox(
                    height: 0.5.h,
                  ),
                  Text(
                    'Fourni par:  ${tissu.fournipar ?? "Inconnu"}',
                    style: TextStyle(fontSize: 9.sp),
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
  Widget _buildModeleItem(
      BuildContext context, Modele modele, int tissuIndex, int modeleIndex,
      {VoidCallback? onEdit, VoidCallback? onDelete}) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            // backgroundColor: Colors.transparent, // Transparence pour le Dialog
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (modele.fichiersModeles != null &&
                      modele.fichiersModeles!.isNotEmpty)
                    SizedBox(
                      height: 50.h, // Ajustez la hauteur si nécessaire

                      child: PageView.builder(
                          itemCount: modele.fichiersModeles!.length,
                          itemBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Image.network(
                                  modele.fichiersModeles![index].urlfichier!,
                                  fit: BoxFit.contain,
                                ),
                              )),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      modele.nom ?? "Inconnu",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
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
              SizedBox(
                  width: 15.w,
                  height: 10.h,
                  child: PageView.builder(
                    itemCount: modele.fichiersModeles!.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: Image.network(
                        modele.fichiersModeles![index].urlfichier!,
                        width: 15.w,
                        height: 10.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nom : ${modele.nom ?? "Inconnu"}',
                      style: TextStyle(fontSize: 9.sp)),
                  SizedBox(height: 0.5.h),
                  Text('Description : ${modele.description ?? "Inconnu"}',
                      style: TextStyle(fontSize: 9.sp)),
                ],
              ),
            ),
            if (onEdit != null || onDelete != null)
              Column(
                children: [
                  if (onEdit != null)
                    IconButton(
                        onPressed: () => onEdit!(),
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
      margin: EdgeInsets.symmetric(vertical: 1.h),
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
      padding: EdgeInsets.all(2.w),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Référence :', style: TextStyle(fontSize: 9.sp)),
                    Text(
                      ' ${payement.reference ?? "Inconnu"}',
                      style: TextStyle(
                          fontSize: 9.sp, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Text('Montant :', style: TextStyle(fontSize: 9.sp)),
                    Text(
                      ' ${payement.montant?.toString() ?? "Inconnu"} CFA',
                      style: TextStyle(
                          fontSize: 9.sp, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Text('Date :', style: TextStyle(fontSize: 9.sp)),
                    Text(
                      ' ${payement.date != null ? dateFormat.format(payement.date!) : "Inconnu"}',
                      style: TextStyle(
                          fontSize: 9.sp, fontWeight: FontWeight.w600),
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
                // if (onEdit != null)
                //   IconButton(
                //       onPressed: onEdit,
                //       icon: Icon(
                //         Icons.edit,
                //         size: 14.sp,
                //         color: Colors.blue,
                //       )),
                if (onDelete != null)
                  IconButton(
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete,
                        size: 14.sp,
                        color: Colors.red,
                      )),
                IconButton(
                  icon: Icon(Icons.share, size: 14.sp),
                  onPressed: () =>
                      _generateAndSharePdf(context, payement), // Correction ici
                )
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
            onPressed: () {
              _annulerCommande(context, 'ANNULER');
            },
            icon: Icon(
              Icons.delete_forever,
              size: 10.sp,
            ),
            label: Text(
              "Annuler Commande",
              style: TextStyle(fontSize: 8.sp),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Bords arrondis
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 1.h, bottom: 1.h),
          child: ElevatedButton.icon(
            onPressed: () => _makePayment(context),
            icon: Icon(
              Icons.payment,
              size: 10.sp,
            ),
            label: Text(
              "Ajouter Paiement",
              style: TextStyle(fontSize: 8.sp),
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
