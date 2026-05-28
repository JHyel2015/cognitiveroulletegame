import 'package:cloud_firestore/cloud_firestore.dart';

class Level {
  int? id;
  String name;
  String description;
  int difficulty;
  int previousLevelRequirement;
  int synced;
  DateTime timestamp;

  Level({
    this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.previousLevelRequirement,
    this.synced = 0,
    required this.timestamp,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      difficulty: json['difficulty'] as int,
      previousLevelRequirement: json['previousLevelRequirement'] as int,
      synced: json['synced'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'difficulty': difficulty,
      'previousLevelRequirement': previousLevelRequirement,
      'synced': synced,
      "timestamp": timestamp.toString(),
    };
  }

  factory Level.fromQuery(QueryDocumentSnapshot<Object?> doc) {
    return Level(
      id: doc['id'] as int,
      name: doc['name'] as String,
      description: doc['description'] as String,
      difficulty: doc['difficulty'] as int,
      previousLevelRequirement: doc['previousLevelRequirement'] as int,
      synced: doc['synced'],
      timestamp: DateTime.parse(doc['timestamp']),
    );
  }
}
