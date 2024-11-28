import 'package:firebase_auth/firebase_auth.dart';
import 'storage_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final storageService = StorageService();

  Future<void> validateConexion() async {
    try {
      if (!storageService.isOnline) {
        throw FirebaseAuthException(
            code: 'no-internet', message: 'No hay conexión a internet.');
      }
    } catch (e) {
      throw FirebaseAuthException(code: (e as FirebaseAuthException).code);
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw FirebaseAuthException(code: (e as FirebaseAuthException).code);
    }
  }

  Future<void> logout() async {
    try {
      //await validateConexion();
      await _auth.signOut();
    } catch (e) {
      throw FirebaseAuthException(code: (e as FirebaseAuthException).code);
    }
  }

  String mapFirebaseError(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Usuario no encontrado.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'invalid-email':
        return 'Correo electrónico inválido.';
      default:
        return 'Error en el inicio de sesión. Intente nuevamente.';
    }
  }
}
