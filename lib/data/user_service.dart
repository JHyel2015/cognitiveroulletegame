import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cognitiveroulletegame/models/user.dart';

class UserService {
  static const _table = 'users';
  final CollectionReference _collectionReference =
      FirebaseFirestore.instance.collection(_table);

  // FireStore
  Future<void> addData(User user) async {
    await _collectionReference.doc(user.id.toString()).set(user.toJson());
  }

  Future<void> updateData(User user) async {
    await _collectionReference.doc(user.id.toString()).update(user.toJson());
  }

  // Obtener un documento específico de Firestore por su ID
  Future<User?> getItemFromFirestore(String userId) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _collectionReference.doc(userId).get();

      if (documentSnapshot.exists) {
        // El documento existe, devuelve un objeto Item creado a partir de los datos de Firestore
        return User.fromJson(
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
