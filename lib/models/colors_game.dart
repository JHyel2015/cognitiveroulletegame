import 'package:cloud_firestore/cloud_firestore.dart';

class ColorsGame {
  String? id;
  String playerProgressId;
  int gameId;
  String userId;
  String selectedColor;
  String correctColor;
  bool success;
  int synced;
  DateTime timestamp;

  ColorsGame({
    this.id,
    required this.playerProgressId,
    required this.gameId,
    required this.userId,
    required this.selectedColor,
    required this.correctColor,
    required this.success,
    this.synced = 0,
    required this.timestamp,
  });

  factory ColorsGame.fromJson(Map<String, dynamic> json) {
    return ColorsGame(
      id: json['id'] as String,
      playerProgressId: json['playerProgressId'] as String,
      gameId: json['gameId'] as int,
      userId: json['userId'] as String,
      selectedColor: json['selectedColor'] as String,
      correctColor: json['correctColor'] as String,
      success: ((int.tryParse(json['success'].toString()) ?? 1)).isOdd,
      synced: json['synced'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson({bool isSqlLite = false}) {
    return <String, dynamic>{
      'id': id,
      'playerProgressId': playerProgressId,
      'gameId': gameId,
      'userId': userId,
      'selectedColor': selectedColor,
      'correctColor': correctColor,
      'success': isSqlLite ? (success ? 1 : 0) : success,
      'synced': synced,
      "timestamp": timestamp.toString(),
    };
  }

  factory ColorsGame.fromQuery(QueryDocumentSnapshot<Object?> doc) {
    return ColorsGame(
      id: doc['id'] as String,
      playerProgressId: doc['playerProgressId'] as String,
      gameId: doc['gameId'] as int,
      userId: doc['userId'] as String,
      selectedColor: doc['selectedColor'] as String,
      correctColor: doc['correctColor'] as String,
      success: doc['success'],
      synced: doc['synced'],
      timestamp: DateTime.parse(doc['timestamp']),
    );
  }
}
