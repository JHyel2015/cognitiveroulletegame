import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognitiveroulletegame/models/player_progress.dart';
import 'package:cognitiveroulletegame/services/app_logger.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlayerProgressService {
  static const _table = 'player_progress';
  static const _tableUsers = 'users';
  final CollectionReference _collectionReference =
      FirebaseFirestore.instance.collection(_tableUsers);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  final logger = AppLogger();

  // FireStore
  Future<String> addData(PlayerProgress playerProgress) async {
    _user = _auth.currentUser;
    DocumentReference documentReference =
        _collectionReference.doc(_user?.uid).collection(_table).doc();
    if (_user != null && !_user!.isAnonymous) {
      await documentReference.set(playerProgress.toJson());
    } else {
      // Usuario autenticado de forma anónima, no permitir la carga de datos
      logger.i('Usuario invitado, no puede guardar datos');
    }
    return documentReference.id;
  }

  Future<void> updateData(PlayerProgress playerProgress) async {
    _user = _auth.currentUser;
    if (_user != null && !_user!.isAnonymous) {
      await _collectionReference
          .doc(_user?.uid)
          .collection(_table)
          .doc(playerProgress.id.toString())
          .update(playerProgress.toJson());
    } else {
      // Usuario autenticado de forma anónima, no permitir la carga de datos
      logger.i('Usuario invitado, no puede guardar datos');
    }
  }

  Future<void> deleteData(PlayerProgress playerProgress) async {
    _user = _auth.currentUser;
    if (_user != null && !_user!.isAnonymous) {
      await _collectionReference
          .doc(_user?.uid)
          .collection(_table)
          .doc(playerProgress.id.toString())
          .delete();
    } else {
      // Usuario autenticado de forma anónima, no permitir la carga de datos
      logger.i('Usuario invitado, no puede guardar datos');
    }
  }

  Future<void> deleteDataByPlayerUID(String playerUID) async {
    _user = _auth.currentUser;
    if (_user != null && !_user!.isAnonymous) {
      QuerySnapshot querySnapshot = await _collectionReference
          .doc(_user?.uid)
          .collection(_table)
          .where('userId', isEqualTo: playerUID)
          .get();

      // Recorre los documentos y elimínalos uno por uno
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } else {
      // Usuario autenticado de forma anónima, no permitir la carga de datos
      logger.i('Usuario invitado, no puede guardar datos');
    }
  }

  Stream<List<PlayerProgress>> getFirestoreData() {
    return _collectionReference
        .doc(_user?.uid)
        .collection(_table)
        .where("userId", isEqualTo: _user!.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((docs) => PlayerProgress.fromQuery(docs))
            .toList());
  }

  Future<QuerySnapshot> getAllItemsFromFirestore() async {
    _user = _auth.currentUser;
    try {
      return await _collectionReference
          .doc(_user?.uid)
          .collection(_table)
          .get();
    } catch (e) {
      rethrow;
    }
  }

  // Obtener un documento específico de Firestore por su ID
  Future<PlayerProgress?> getItemFromFirestore(String playerProgressId) async {
    try {
      DocumentSnapshot documentSnapshot = await _collectionReference
          .doc(_user?.uid)
          .collection(_table)
          .doc(playerProgressId)
          .get();

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
      logger.e('Error al obtener el elemento de Firestore: $e');
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
