import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerProgress {
  int? id;
  int userId;
  int levelId;
  int score;
  String status;
  int synced;
  DateTime timestamp;

  PlayerProgress({
    this.id,
    required this.userId,
    required this.levelId,
    required this.score,
    required this.status,
    this.synced = 0,
    required this.timestamp,
  });

  factory PlayerProgress.fromJson(Map<String, dynamic> json) {
    return PlayerProgress(
      id: json['id'] as int,
      userId: json['userId'] as int,
      levelId: json['levelId'] as int,
      score: json['score'] as int,
      status: json['status'] as String,
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
      'status': status,
      'synced': synced,
      "timestamp": timestamp.toString(),
    };
  }

  factory PlayerProgress.fromQuery(QueryDocumentSnapshot<Object?> doc) {
    return PlayerProgress(
      id: doc['id'] as int,
      userId: doc['userId'] as int,
      levelId: doc['levelId'] as int,
      score: doc['score'] as int,
      status: doc['status'] as String,
      synced: doc['synced'],
      timestamp: DateTime.parse(doc['timestamp']),
    );
  }
}
