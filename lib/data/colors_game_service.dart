import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognitiveroulletegame/models/colors_game.dart';

class ColorsGameService {
  static const _table = 'colors_games';
  final CollectionReference _collectionReference =
      FirebaseFirestore.instance.collection(_table);

  // FireStore
  Future<void> addData(ColorsGame colorsGame) async {
    await _collectionReference
        .doc(colorsGame.gameId.toString())
        .set(colorsGame.toJson());
  }

  Future<void> updateData(ColorsGame colorsGame) async {
    await _collectionReference
        .doc(colorsGame.gameId.toString())
        .update(colorsGame.toJson());
  }

  Future<void> deleteData(ColorsGame colorsGame) async {
    await _collectionReference.doc(colorsGame.gameId.toString()).delete();
  }

  Stream<List<ColorsGame>> getFirestoreData() {
    return _collectionReference.snapshots().map((snapshot) =>
        snapshot.docs.map((docs) => ColorsGame.fromQuery(docs)).toList());
  }

  Future<QuerySnapshot> getAllItemsFromFirestore() async {
    try {
      return await _collectionReference.get();
    } catch (e) {
      rethrow;
    }
  }

  // Obtener un documento específico de Firestore por su ID
  Future<ColorsGame?> getItemFromFirestore(String colorsGameId) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _collectionReference.doc(colorsGameId).get();

      if (documentSnapshot.exists) {
        // El documento existe, devuelve un objeto Item creado a partir de los datos de Firestore
        return ColorsGame.fromJson(
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
