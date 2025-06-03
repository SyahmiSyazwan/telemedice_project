import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add or update user information
  Future<void> addUserDetail(
      Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance.collection("users").doc(id).set(
        userInfoMap,
        SetOptions(merge: true)); // use SetOptions() to update existing fields
  }

  // Delete user information
  Future<void> deleteUserDetail(String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .delete();
  }

  // Query the list of time periods that a doctor has been booked for on a certain day
  Future<List<String>> getBookedTimeSlots(
      String doctorId, String date, String location, String specialist) async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .where('date', isEqualTo: date)
        .where('location', isEqualTo: location)
        .where('specialist', isEqualTo: specialist)
        .where('status', isEqualTo: 'booked')
        .get();

    return snapshot.docs.map((doc) => doc['timeSlot'] as String).toList();
  }

  /// Doctor appointment time
  /// Returns whether it is successful (if successful, no one else has made a reservation for that time period)
  Future<bool> bookAppointment({
    required String doctorId,
    required String patientId,
    required String date,
    required String timeSlot,
    required String location,
    required String specialist,
  }) async {
    final docRef = _firestore.collection('appointments').doc();

    try {
      // Use transactions to ensure atomicity of operations and prevent duplicate reservations
      await _firestore.runTransaction((transaction) async {
        // Check if there is an existing reservation
        final query = await _firestore
            .collection('appointments')
            .where('doctorId', isEqualTo: doctorId)
            .where('date', isEqualTo: date)
            .where('timeSlot', isEqualTo: timeSlot)
            .where('status', isEqualTo: 'booked')
            .get();

        if (query.docs.isNotEmpty) {
          // The time period has been reserved, and the transaction is terminated with an exception.
          throw Exception('The time slot has been reserved');
        }

        // No appointment, write a new appointment
        transaction.set(docRef, {
          'doctorId': doctorId,
          'patientId': patientId,
          'date': date,
          'timeSlot': timeSlot,
          'status': 'booked',
          'location': location,
          'specialist': specialist,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      return true;
    } catch (e) {
      // Catch exceptions (such as duplicate reservations) and return failure
      print('Appointment failed: $e');
      return false;
    }
  }

  /// 返回指定日期的预约流（包含status='booked'）
  Stream<List<Map<String, dynamic>>> getBookingsStreamByDate(String date) {
    return _firestore
        .collection('appointments')
        .where('date', isEqualTo: date)
        .where('status', isEqualTo: 'booked')
        .snapshots()
        .asyncMap((snapshot) async {
      final bookings = snapshot.docs;

      final doctorIds = bookings.map((b) => b['doctorId'] as String).toSet();

      final doctorsSnapshot = await _firestore
          .collection('doctors')
          .where('id', whereIn: doctorIds.toList())
          .get();

      final doctorMap = {
        for (var doc in doctorsSnapshot.docs)
          doc.data()['id']: {
            'name': doc.data()['name'] ?? 'Unknown Doctor',
            'image': doc.data()['image'] ?? 'assets/images/boy.jpeg',
          }
      };

      return bookings.map((doc) {
        final data = doc.data();
        final docId = doc.id;
        final doctorId = data['doctorId'] as String;
        // final doctorName = doctorMap[doctorId] ?? 'Unknown Doctor';
        // final doctorImage = doctorMap['image'] ?? 'assets/images/boy.jpeg';
        final doctorInfo = doctorMap[doctorId] ?? {};
        final bookingDate = data['date'] ?? 'No date';

        return {
          'bookingId': docId,
          'doctorId': doctorId,
          'patientId': data['patientId'],
          'timeSlot': data['timeSlot'],
          'specialist': data['specialist'],
          'location': data['location'],
          'doctorName': doctorInfo['name'] ?? 'Unknown Doctor',
          'doctorImage': doctorInfo['image'] ?? 'assets/images/boy.jpeg',
          'date': bookingDate,
        };
      }).toList();
    });
  }
}
