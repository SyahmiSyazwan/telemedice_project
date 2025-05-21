import 'package:firebase_auth/firebase_auth.dart';
import 'package:telemedice_project/auth/shared.pref.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get the current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Log out and clear cache
  Future<void> signOut() async {
    await _auth.signOut();
    await SharedPreferenceHelper().clear();
  }

  /// Delete the current user
  Future<void> deleteUser() async {
    try {
      User? user = _auth.currentUser;
      await user?.delete();
    } on FirebaseAuthException catch (e) {
      print("Delete user failed: ${e.code} - ${e.message}");
      rethrow;
    }
  }
}
