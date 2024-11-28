import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerProgress {
  String? id;
  String userId;
  int gameId;
  int levelId;
  int score;
  int successes;
  int failures;
  int attempts;
  String playedTime;
  String comment;
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
    required this.comment,
    required this.status,
    this.synced = 0,
    required this.timestamp,
  });

  factory PlayerProgress.fromJson(Map<String, dynamic> json) {
    return PlayerProgress(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      gameId: json['gameId'] as int,
      levelId: json['levelId'] as int,
      score: json['score'] as int,
      successes: json['successes'] as int,
      failures: json['failures'] as int,
      attempts: json['attempts'] as int,
      playedTime: json['playedTime'] as String,
      comment: json['comment'] as String,
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
      'playedTime': playedTime,
      'comment': comment,
      'status': status,
      'synced': synced,
      "timestamp": timestamp.toString(),
    };
  }

  factory PlayerProgress.fromQuery(QueryDocumentSnapshot<Object?> doc) {
    return PlayerProgress(
      id: doc['id'] as String,
      userId: doc['userId'] as String,
      gameId: doc['gameId'] as int,
      levelId: doc['levelId'] as int,
      score: doc['score'] as int,
      successes: doc['successes'] as int,
      failures: doc['failures'] as int,
      attempts: doc['attempts'] as int,
      playedTime: doc['playedTime'] as String,
      comment: doc['comment'] as String,
      status: doc['status'] as String,
      synced: doc['synced'],
      timestamp: DateTime.parse(doc['timestamp']),
    );
  }
}
