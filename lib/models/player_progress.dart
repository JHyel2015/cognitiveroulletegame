import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerProgress {
  int? id;
  int userId;
  int gameId;
  int levelId;
  int score;
  int successes;
  int failures;
  int attempts;
  DateTime playedTime;
  String status;
  int synced;
  DateTime timestamp;

  PlayerProgress({
    this.id,
    required this.userId,
    required this.gameId,
    required this.levelId,
    required this.score,
    required this.successes,
    required this.failures,
    required this.attempts,
    required this.playedTime,
    required this.status,
    this.synced = 0,
    required this.timestamp,
  });

  factory PlayerProgress.fromJson(Map<String, dynamic> json) {
    return PlayerProgress(
      id: json['id'] as int,
      userId: json['userId'] as int,
      gameId: json['gameId'] as int,
      levelId: json['levelId'] as int,
      score: json['score'] as int,
      successes: json['successes'] as int,
      failures: json['failures'] as int,
      attempts: json['attempts'] as int,
      playedTime: DateTime.parse(json['playedTime']),
      status: json['status'] as String,
      synced: json['synced'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'gameId': gameId,
      'levelId': levelId,
      'score': score,
      'successes': successes,
      'failures': failures,
      'attempts': attempts,
      'playedTime': playedTime.toString(),
      'status': status,
      'synced': synced,
      "timestamp": timestamp.toString(),
    };
  }

  factory PlayerProgress.fromQuery(QueryDocumentSnapshot<Object?> doc) {
    return PlayerProgress(
      id: doc['id'] as int,
      userId: doc['userId'] as int,
      gameId: doc['gameId'] as int,
      levelId: doc['levelId'] as int,
      score: doc['score'] as int,
      successes: doc['successes'] as int,
      failures: doc['failures'] as int,
      attempts: doc['attempts'] as int,
      playedTime: DateTime.parse(doc['playedTime']),
      status: doc['status'] as String,
      synced: doc['synced'],
      timestamp: DateTime.parse(doc['timestamp']),
    );
  }
}
