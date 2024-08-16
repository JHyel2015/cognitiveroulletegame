import 'package:cloud_firestore/cloud_firestore.dart';

class Game {
  int? id;
  String userId;
  int levelId;
  int score;
  DateTime playedTime;
  DateTime playDate;
  String name;
  String description;
  String instructions;
  String imageUri;
  int synced;
  DateTime timestamp;

  Game({
    this.id,
    required this.userId,
    required this.levelId,
    required this.score,
    required this.playedTime,
    required this.playDate,
    required this.name,
    required this.description,
    required this.instructions,
    required this.imageUri,
    this.synced = 0,
    required this.timestamp,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as int,
      userId: json['userId'] as String,
      levelId: json['levelId'] as int,
      score: json['score'] as int,
      playedTime: DateTime.parse(json['playedTime']),
      playDate: DateTime.parse(json['playDate']),
      name: json['name'],
      description: json['description'],
      instructions: json['instructions'],
      imageUri: json['imageUri'],
      synced: json['synced'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'levelId': levelId,
      'score': score,
      'playedTime': playedTime.toString(),
      'playDate': playDate.toString(),
      'name': name,
      'description': description,
      'instructions': instructions,
      'imageUri': imageUri,
      'synced': synced,
      "timestamp": timestamp.toString(),
    };
  }

  factory Game.fromQuery(QueryDocumentSnapshot<Object?> doc) {
    return Game(
      id: doc['id'] as int,
      userId: doc['userId'] as String,
      levelId: doc['levelId'] as int,
      score: doc['score'] as int,
      playedTime: DateTime.parse(doc['playedTime']),
      playDate: DateTime.parse(doc['playDate']),
      name: doc['name'],
      description: doc['description'],
      instructions: doc['instructions'],
      imageUri: doc['imageUri'],
      synced: doc['synced'],
      timestamp: DateTime.parse(doc['timestamp']),
    );
  }
}
