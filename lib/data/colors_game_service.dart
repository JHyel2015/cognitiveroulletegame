import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognitiveroulletegame/models/colors_game.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ColorsGameService {
  static const _table = 'colors_games';
  final CollectionReference _collectionReference =
      FirebaseFirestore.instance.collection(_table);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  // FireStore
  Future<String> addData(ColorsGame colorsGame) async {
    _user = _auth.currentUser;
    DocumentReference documentReference = _collectionReference.doc();
    print(
        '${ColorsGameService._table} ${_user!.isAnonymous.toString()} ${documentReference.id}');
    if (_user != null && !_user!.isAnonymous) {
      await documentReference.set(colorsGame.toJson());
    } else {
      // Usuario autenticado de forma anónima, no permitir la carga de datos
      print('Usuario invitado, no puede guardar datos');
    }
    return documentReference.id;
  }

  Future<void> updateData(ColorsGame colorsGame) async {
    _user = _auth.currentUser;
    if (_user != null && !_user!.isAnonymous) {
      await _collectionReference
          .doc(colorsGame.id.toString())
          .update(colorsGame.toJson());
    } else {
      // Usuario autenticado de forma anónima, no permitir la carga de datos
      print('Usuario invitado, no puede guardar datos');
    }
  }

  Future<void> deleteData(ColorsGame colorsGame) async {
    _user = _auth.currentUser;
    if (_user != null && !_user!.isAnonymous) {
      await _collectionReference.doc(colorsGame.id.toString()).delete();
    } else {
      // Usuario autenticado de forma anónima, no permitir la carga de datos
      print('Usuario invitado, no puede borrar datos');
    }
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
