import 'package:cloud_firestore/cloud_firestore.dart';

class ColorsGame {
  int gameId;
  String selectedColor;
  String correctColor;
  bool success;
  int synced;
  DateTime timestamp;

  ColorsGame({
    required this.gameId,
    required this.selectedColor,
    required this.correctColor,
    required this.success,
    this.synced = 0,
    required this.timestamp,
  });

  factory ColorsGame.fromJson(Map<String, dynamic> json) {
    return ColorsGame(
      gameId: json['gameId'] as int,
      selectedColor: json['selectedColor'] as String,
      correctColor: json['correctColor'] as String,
      success: ((int.tryParse(json['success'].toString()) ?? 1)).isOdd,
      synced: json['synced'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'gameId': gameId,
      'selectedColor': selectedColor,
      'correctColor': correctColor,
      'success': success,
      'synced': synced,
      "timestamp": timestamp.toString(),
    };
  }

  factory ColorsGame.fromQuery(QueryDocumentSnapshot<Object?> doc) {
    return ColorsGame(
      gameId: doc['gameId'] as int,
      selectedColor: doc['selectedColor'] as String,
      correctColor: doc['correctColor'] as String,
      success: ((int.tryParse(doc['success'].toString()) ?? 1)).isOdd,
      synced: doc['synced'],
      timestamp: DateTime.parse(doc['timestamp']),
    );
  }
}
