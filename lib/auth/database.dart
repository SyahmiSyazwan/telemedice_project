import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 新增或更新用户信息
  Future<void> addUserDetail(
      Map<String, dynamic> userInfoMap, String id) async {
    return await _firestore.collection('users').doc(id).set(userInfoMap);
  }

  // 查询某医生某天已经被预约的时间段列表
  Future<List<String>> getBookedTimeSlots(String doctorId, String date) async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .where('date', isEqualTo: date)
        .where('status', isEqualTo: 'booked')
        .get();

    return snapshot.docs.map((doc) => doc['timeSlot'] as String).toList();
  }

  /// 预约医生时间段
  /// 返回是否成功（成功则该时间段无其他人预约）
  Future<bool> bookAppointment({
    required String doctorId,
    required String patientId,
    required String date,
    required String timeSlot,
  }) async {
    final docRef = _firestore.collection('appointments').doc();

    try {
      // 使用事务保证操作原子性，防止重复预约
      await _firestore.runTransaction((transaction) async {
        // 查询是否已有预约存在
        final query = await _firestore
            .collection('appointments')
            .where('doctorId', isEqualTo: doctorId)
            .where('date', isEqualTo: date)
            .where('timeSlot', isEqualTo: timeSlot)
            .where('status', isEqualTo: 'booked')
            .get();

        if (query.docs.isNotEmpty) {
          // 该时间段已被预约，抛异常终止事务
          throw Exception('时间段已被预约');
        }

        // 没有预约，写入新预约
        transaction.set(docRef, {
          'doctorId': doctorId,
          'patientId': patientId,
          'date': date,
          'timeSlot': timeSlot,
          'status': 'booked',
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      return true;
    } catch (e) {
      // 捕获异常（如重复预约）返回失败
      print('预约失败: $e');
      return false;
    }
  }
}
