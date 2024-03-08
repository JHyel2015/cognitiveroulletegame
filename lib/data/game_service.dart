import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognitiveroulletegame/models/game.dart';

class GameService {
  static const _table = 'games';
  final CollectionReference _collectionReference =
      FirebaseFirestore.instance.collection(_table);

  // FireStore
  Future<void> addData(Game game) async {
    await _collectionReference.doc(game.id.toString()).set(game.toJson());
  }

  Future<void> updateData(Game game) async {
    await _collectionReference.doc(game.id.toString()).update(game.toJson());
  }

  Future<void> deleteData(Game game) async {
    await _collectionReference.doc(game.id.toString()).delete();
  }

  Stream<List<Game>> getFirestoreData() {
    return _collectionReference.snapshots().map((snapshot) =>
        snapshot.docs.map((docs) => Game.fromQuery(docs)).toList());
  }

  Future<QuerySnapshot> getAllItemsFromFirestore() async {
    try {
      return await _collectionReference.get();
    } catch (e) {
      rethrow;
    }
  }

  // Obtener un documento específico de Firestore por su ID
  Future<Game?> getItemFromFirestore(String gameId) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _collectionReference.doc(gameId).get();

      if (documentSnapshot.exists) {
        // El documento existe, devuelve un objeto Item creado a partir de los datos de Firestore
        return Game.fromJson(
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
