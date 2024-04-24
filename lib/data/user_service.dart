import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cognitiveroulletegame/models/user_data.dart';

class UserService {
  static const _table = 'users';
  final CollectionReference _collectionReference =
      FirebaseFirestore.instance.collection(_table);
  User? userAuth = FirebaseAuth.instance.currentUser;

  // FireStore
  Future<void> addData(UserData user) async {
    if (userAuth != null && !userAuth!.isAnonymous) {
      await _collectionReference.doc(user.id.toString()).set(user.toJson());
    } else {
      // Usuario autenticado de forma anónima, no permitir la carga de datos
      print('Usuario invitado, no puede guardar datos');
    }
  }

  Future<void> updateData(UserData user) async {
    if (userAuth != null && !userAuth!.isAnonymous) {
      await _collectionReference.doc(user.id.toString()).update(user.toJson());
    } else {
      // Usuario autenticado de forma anónima, no permitir la carga de datos
      print('Usuario invitado, no puede guardar datos');
    }
  }

  // Obtener un documento específico de Firestore por su ID
  Future<UserData?> getItemFromFirestore(String userId) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _collectionReference.doc(userId).get();

      if (documentSnapshot.exists) {
        // El documento existe, devuelve un objeto Item creado a partir de los datos de Firestore
        return UserData.fromJson(
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
