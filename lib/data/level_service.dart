import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognitiveroulletegame/models/level.dart';

class LevelService {
  static const _table = 'levels';
  final CollectionReference _collectionReference =
      FirebaseFirestore.instance.collection(_table);

  // FireStore
  Future<void> addData(Level level) async {
    await _collectionReference.doc(level.id.toString()).set(level.toJson());
  }

  Future<void> updateData(Level level) async {
    await _collectionReference.doc(level.id.toString()).update(level.toJson());
  }

  Future<QuerySnapshot> getAllItemsFromFirestore() async {
    try {
      return await _collectionReference.get();
    } catch (e) {
      rethrow;
    }
  }

  // Obtener un documento específico de Firestore por su ID
  Future<Level?> getItemFromFirestore(String levelId) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _collectionReference.doc(levelId).get();

      if (documentSnapshot.exists) {
        // El documento existe, devuelve un objeto Item creado a partir de los datos de Firestore
        return Level.fromJson(
          documentSnapshot.data() as Map<String, dynamic>,
        );
      } else {
        // El documento no existe
        return null;
      }
    } catch (e) {
      print('Error al obtener el elemento de Firestore: $e');
      return null;
    }
  }
}
