import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  int? id;
  String? name;
  String displayName;
  final String email;
  String? phoneNumber;
  String? photoURL;
  int synced;
  DateTime timestamp;

  User({
    this.id,
    this.name,
    required this.displayName,
    required this.email,
    this.phoneNumber,
    this.photoURL,
    this.synced = 0,
    required this.timestamp,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      photoURL: json['photoURL'] as String,
      synced: json['synced'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'displayName': displayName,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
      'synced': synced,
      "timestamp": timestamp.toString(),
    };
  }

  factory User.fromQuery(QueryDocumentSnapshot<Object?> doc) {
    return User(
      id: doc['id'] as int,
      name: doc['name'] as String,
      displayName: doc['displayName'] as String,
      email: doc['email'] as String,
      phoneNumber: doc['phoneNumber'] as String,
      photoURL: doc['photoURL'] as String,
      synced: doc['synced'],
      timestamp: DateTime.parse(doc['timestamp']),
    );
  }
}
