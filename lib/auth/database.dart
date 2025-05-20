import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add or update user information
  Future<void> addUserDetail(
      Map<String, dynamic> userInfoMap, String id) async {
    return await _firestore.collection('users').doc(id).set(userInfoMap);
  }

  // Query the list of time periods that a doctor has been booked for on a certain day
  Future<List<String>> getBookedTimeSlots(String doctorId, String date) async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .where('date', isEqualTo: date)
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
}
