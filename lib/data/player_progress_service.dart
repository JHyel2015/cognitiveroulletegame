import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognitiveroulletegame/models/player_progress.dart';

class PlayerProgressService {
  static const _table = 'player_progress';
  final CollectionReference _collectionReference =
      FirebaseFirestore.instance.collection(_table);

  // FireStore
  Future<void> addData(PlayerProgress playerProgress) async {
    await _collectionReference
        .doc(playerProgress.id.toString())
        .set(playerProgress.toJson());
  }

  Future<void> updateData(PlayerProgress playerProgress) async {
    await _collectionReference
        .doc(playerProgress.id.toString())
        .update(playerProgress.toJson());
  }

  Future<void> deleteData(PlayerProgress playerProgress) async {
    await _collectionReference.doc(playerProgress.id.toString()).delete();
  }

  Stream<List<PlayerProgress>> getFirestoreData() {
    return _collectionReference.snapshots().map((snapshot) =>
        snapshot.docs.map((docs) => PlayerProgress.fromQuery(docs)).toList());
  }

  Future<QuerySnapshot> getAllItemsFromFirestore() async {
    try {
      return await _collectionReference.get();
    } catch (e) {
      rethrow;
    }
  }

  // Obtener un documento específico de Firestore por su ID
  Future<PlayerProgress?> getItemFromFirestore(String playerProgressId) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _collectionReference.doc(playerProgressId).get();

      if (documentSnapshot.exists) {
        // El documento existe, devuelve un objeto Item creado a partir de los datos de Firestore
        return PlayerProgress.fromJson(
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

  Future<void> clearData() async {
    var snapshots = await _collectionReference.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }
}
