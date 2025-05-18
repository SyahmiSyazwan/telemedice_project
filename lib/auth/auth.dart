import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:telemedice_project/auth/shared.pref.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentUser() async {
    return await auth.currentUser;
  }

  Future SignOut() async {
    await FirebaseAuth.instance.signOut();
    // Clear all saved data on logout
    await SharedPreferenceHelper().clearAllData();
  }

  Future deleteuser() async {
    User? user = await FirebaseAuth.instance.currentUser;
    user?.delete();
  }
}
