import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivityWrapper({required this.child});

  @override
  _ConnectivityWrapperState createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  late Connectivity _connectivity;
  late Stream<List<ConnectivityResult>> _connectivityStream;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _connectivityStream = _connectivity.onConnectivityChanged;

    _connectivityStream.listen((List<ConnectivityResult> results) {
      bool connectionStatus = !results.contains(ConnectivityResult.none);
      if (connectionStatus != _isConnected) {
        setState(() {
          _isConnected = connectionStatus;
        });

        // Afficher un message lorsque la connexion est perdue ou rétablie
        if (!_isConnected) {
          _showNoInternetSnackbar();
        } else {
          _showConnectedSnackbar();
        }
      }
    });
  }

  // Message de perte de connexion
  void _showNoInternetSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pas de connexion Internet.'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: Duration(
            days: 365), // Afficher jusqu'à ce que la connexion revienne
      ),
    );
  }

  // Message de connexion rétablie
  void _showConnectedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connexion Internet rétablie.'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration:
            Duration(seconds: 3), // Durée courte pour informer l'utilisateur
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
