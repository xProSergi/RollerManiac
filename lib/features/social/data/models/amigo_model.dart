
import '../../domain/entities/amigo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AmigoModel extends Amigo {
  AmigoModel({
    required String id,
    required String email,
    required String displayName,
    required String username,
    int cantidadParques = 0,
  }) : super(
    id: id,
    email: email,
    displayName: displayName,
    username: username,
    cantidadParques: cantidadParques,
  );

  factory AmigoModel.fromMap(Map<String, dynamic> map, String id) {
    return AmigoModel(
      id: id,
      email: map['email'] ?? '',
      displayName: map['displayName'] ,
      username: map['username'] ?? '',
      cantidadParques: map['cantidadParques'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'cantidadParques': cantidadParques,
      'username': username,
    };
  }
}