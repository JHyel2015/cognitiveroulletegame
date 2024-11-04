import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SavedImage {
  String name;
  String imagePath;

  SavedImage({
    required this.name,
    required this.imagePath,
  });

  factory SavedImage.fromJson(Map<String, dynamic> json) {
    return SavedImage(
      name: json['name'] as String,
      imagePath: json['imagePath'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'imagePath': imagePath,
    };
  }

  factory SavedImage.fromQuery(QueryDocumentSnapshot<Object?> doc) {
    return SavedImage(
      name: doc['name'] as String,
      imagePath: doc['imagePath'] as String,
    );
  }
}
