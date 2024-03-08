import 'package:cloud_firestore/cloud_firestore.dart';

class Game {
  int? id;
  int userId;
  int levelId;
  int score;
  DateTime playedTime;
  DateTime playDate;
  int synced;
  DateTime timestamp;

  Game({
    this.id,
    required this.userId,
    required this.levelId,
    required this.score,
    required this.playedTime,
    required this.playDate,
    this.synced = 0,
    required this.timestamp,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as int,
      userId: json['userId'] as int,
      levelId: json['levelId'] as int,
      score: json['score'] as int,
      playedTime: DateTime.parse(json['playedTime']),
      playDate: DateTime.parse(json['playDate']),
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
      'playedTime': playedTime,
      'playDate': playDate,
      'synced': synced,
      "timestamp": timestamp.toString(),
    };
  }

  factory Game.fromQuery(QueryDocumentSnapshot<Object?> doc) {
    return Game(
      id: doc['id'] as int,
      userId: doc['userId'] as int,
      levelId: doc['levelId'] as int,
      score: doc['score'] as int,
      playedTime: DateTime.parse(doc['playedTime']),
      playDate: DateTime.parse(doc['playDate']),
      synced: doc['synced'],
      timestamp: DateTime.parse(doc['timestamp']),
    );
  }
}
