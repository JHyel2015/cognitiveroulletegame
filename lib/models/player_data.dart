import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerData {
  String? uid;
  String name;
  int age;
  String userId;
  int synced;
  DateTime timestamp;

  PlayerData({
    this.uid,
    required this.name,
    required this.age,
    required this.userId,
    this.synced = 0,
    required this.timestamp,
  });

  factory PlayerData.fromJson(Map<String, dynamic> json) {
    return PlayerData(
      uid: json['uid'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      userId: json['userId'] as String,
      synced: json['synced'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'age': age,
      'userId': userId,
      'synced': synced,
      "timestamp": timestamp.toString(),
    };
  }

  factory PlayerData.fromQuery(QueryDocumentSnapshot<Object?> doc) {
    return PlayerData(
      uid: doc['uid'] as String,
      name: doc['name'] as String,
      age: doc['age'] as int,
      userId: doc['userId'] as String,
      synced: doc['synced'],
      timestamp: DateTime.parse(doc['timestamp']),
    );
  }
}
