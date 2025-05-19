import 'package:firebase_auth/firebase_auth.dart';
import 'package:telemedice_project/auth/shared.pref.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 获取当前用户
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// 登出并清除缓存
  Future<void> signOut() async {
    await _auth.signOut();
    await SharedPreferenceHelper().clear(); // 确保你定义了这个方法
  }

  /// 删除当前用户
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
