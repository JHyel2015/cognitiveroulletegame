import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  int? id;
  String? name;
  String displayName;
  final String email;
  String? phoneNumber;
  String? photoURL;
  int synced;
  DateTime timestamp;

  UserData({
    this.id,
    this.name,
    required this.displayName,
    required this.email,
    this.phoneNumber,
    this.photoURL,
    this.synced = 0,
    required this.timestamp,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
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

  factory UserData.fromQuery(QueryDocumentSnapshot<Object?> doc) {
    return UserData(
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
