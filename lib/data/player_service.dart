import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognitiveroulletegame/services/app_logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cognitiveroulletegame/models/player_data.dart';

class PlayerService {
  static const _table = 'players';
  static const _tableUsers = 'users';
  final CollectionReference _collectionReference =
      FirebaseFirestore.instance.collection(_tableUsers);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  final logger = AppLogger();

  // FireStore
  Future<String> addData(PlayerData player) async {
    _user = _auth.currentUser;
    DocumentReference documentReference =
        _collectionReference.doc(_user?.uid).collection(_table).doc();
    if (_user != null && !_user!.isAnonymous) {
      await documentReference.set(player.toJson());
    } else {
      // Usuario autenticado de forma anónima, no permitir la carga de datos
      logger.i('Usuario invitado, no puede guardar datos');
    }
    return documentReference.id;
  }

  Future<void> updateData(PlayerData player) async {
    _user = _auth.currentUser;
    if (_user != null && !_user!.isAnonymous) {
      await _collectionReference
          .doc(_user?.uid)
          .collection(_table)
          .doc(player.uid.toString())
          .update(player.toJson());
    } else {
      // Usuario autenticado de forma anónima, no permitir la carga de datos
      logger.i('Usuario invitado, no puede guardar datos');
    }
  }

  Future<void> deleteData(PlayerData player) async {
    _user = _auth.currentUser;
    if (_user != null && !_user!.isAnonymous) {
      await _collectionReference
          .doc(_user?.uid)
          .collection(_table)
          .doc(player.uid.toString())
          .delete();
    } else {
      // Usuario autenticado de forma anónima, no permitir la carga de datos
      logger.i('Usuario invitado, no puede guardar datos');
    }
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
  Future<PlayerData?> getItemFromFirestore(String playerId) async {
    _user = _auth.currentUser;
    try {
      DocumentSnapshot documentSnapshot = await _collectionReference
          .doc(_user?.uid)
          .collection(_table)
          .doc(playerId)
          .get();

      if (documentSnapshot.exists) {
        // El documento existe, devuelve un objeto Item creado a partir de los datos de Firestore
        return PlayerData.fromJson(
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
}
