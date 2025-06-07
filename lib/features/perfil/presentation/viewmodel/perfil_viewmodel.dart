import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PerfilViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _firebaseUser;
  String? _username;
  String? _displayName;
  String? _email;
  DateTime? _creationDate;

  User? get firebaseUser => _firebaseUser;

  String get username => _username ?? '';
  String get displayName => _displayName ?? '';
  String get email => _email ?? '';
  DateTime? get creationDate => _creationDate;


  bool get isLoaded => _firebaseUser != null && _username != null;

  PerfilViewModel() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    _firebaseUser = _auth.currentUser;
    if (_firebaseUser != null) {
      _email = _firebaseUser!.email;
      _displayName = _firebaseUser!.displayName;
      _creationDate = _firebaseUser!.metadata.creationTime?.toLocal();

      final userDoc = await _firestore.collection('usuarios').doc(_firebaseUser!.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        _username = data?['username'] as String?;

        if (_username == null || _username!.isEmpty) {
          _username = 'Usuario';
        }
      } else {

        _username = 'Usuario';
      }
    } else {

      _username = null;
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}