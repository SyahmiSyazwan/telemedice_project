import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DoctorApprovalPage extends StatefulWidget {
  const DoctorApprovalPage({Key? key}) : super(key: key);

  @override
  State<DoctorApprovalPage> createState() => _DoctorApprovalPageState();
}

class _DoctorApprovalPageState extends State<DoctorApprovalPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doctorId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade100,
        title: const Text(
          'Appointment Requests',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          indicatorColor: Colors.teal,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Reschedule'),
            Tab(text: 'Approved'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pending New Appointments Tab
          _buildAppointmentList(
            doctorId: doctorId,
            query: (doctorId) => FirebaseFirestore.instance
                .collection('appointments')
                .where('doctorId', isEqualTo: doctorId)
                .where('status', isEqualTo: 'pending')
                .orderBy('date', descending: false)
                .orderBy('timeSlot', descending: false),
            emptyMessage: 'No pending appointment requests.',
            itemBuilder: _buildNewAppointmentCard,
          ),

          // Reschedule Requests Tab
          _buildAppointmentList(
            doctorId: doctorId,
            query: (doctorId) => FirebaseFirestore.instance
                .collection('appointments')
                .where('doctorId', isEqualTo: doctorId)
                .where('rescheduleStatus', isEqualTo: 'pending')
                .orderBy('date', descending: false),
            emptyMessage: 'No pending reschedule requests.',
            itemBuilder: _buildRescheduleCard,
          ),

          // Approved Appointments Tab
          _buildAppointmentList(
            doctorId: doctorId,
            query: (doctorId) => FirebaseFirestore.instance
                .collection('appointments')
                .where('doctorId', isEqualTo: doctorId)
                .where('status', isEqualTo: 'booked')
                .orderBy('date', descending: false)
                .orderBy('timeSlot', descending: false),
            emptyMessage: 'No approved appointments.',
            itemBuilder: _buildApprovedAppointmentCard,
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentList({
    required String? doctorId,
    required Query Function(String) query,
    required String emptyMessage,
    required Widget Function(DocumentSnapshot) itemBuilder,
  }) {
    if (doctorId == null) {
      return const Center(child: Text('Not signed in as a doctor'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query(doctorId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  emptyMessage,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return itemBuilder(snapshot.data!.docs[index]);
          },
        );
      },
    );
  }

  Widget _buildNewAppointmentCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final appointmentId = doc.id;
    final patientId = data['patientId'] as String;
    final date = data['date'] as String? ?? '';
    final timeSlot = data['timeSlot'] as String;

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(patientId).get(),
      builder: (context, snapshot) {
        String patientName = 'Loading patient info...';
        String patientImageUrl = 'images/boy.jpeg'; // Default image

        if (snapshot.hasData && snapshot.data != null) {
          final patientData = snapshot.data!.data() as Map<String, dynamic>?;
          patientName = patientData?['name'] ?? 'Unknown Patient';
          patientImageUrl = patientData?['image'] ?? 'images/boy.jpeg';
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(patientImageUrl),
                      radius: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patientName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.event,
                                  size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                '$date, $timeSlot',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  data['reason'] ?? 'No reason provided',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => _rejectAppointment(appointmentId),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red.shade200),
                      ),
                      child: const Text('Reject'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => _approveAppointment(appointmentId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade100,
                      ),
                      child: const Text('Approve'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRescheduleCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final appointmentId = doc.id;
    final patientId = data['patientId'] as String;
    final currentDate = data['date'] as String;
    final currentTimeSlot = data['timeSlot'] as String;
    final proposedDate = data['proposedDate']?.toString() ?? '';
    final proposedTimeSlot = data['proposedTimeSlot'] as String;
    final reason = data['rescheduleReason'] as String? ?? 'No reason provided';

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(patientId).get(),
      builder: (context, snapshot) {
        String patientName = 'Loading patient info...';
        String patientImageUrl = 'images/boy.jpeg'; // Default image

        if (snapshot.hasData && snapshot.data != null) {
          final patientData = snapshot.data!.data() as Map<String, dynamic>?;
          patientName = patientData?['name'] ?? 'Unknown Patient';
          patientImageUrl = patientData?['image'] ?? 'images/boy.jpeg';
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(patientImageUrl),
                      radius: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patientName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Reschedule Request',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.event,
                                      size: 16,
                                      color: Colors.red[400],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$currentDate, $currentTimeSlot',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.grey,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Proposed',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.event,
                                      size: 16,
                                      color: Colors.green[400],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$proposedDate, $proposedTimeSlot',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Reason: $reason',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => _rejectReschedule(appointmentId),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red.shade200),
                      ),
                      child: const Text('Reject'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => _approveReschedule(appointmentId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade100,
                      ),
                      child: const Text('Approve'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildApprovedAppointmentCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final patientId = data['patientId'] as String;
    String date;
    if (data['date'] != null) {
      date = data['date'] as String;
    } else {
      date = ''; // or any default value you prefer
    }

    final timeSlot = data['timeSlot'] as String;

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(patientId).get(),
      builder: (context, snapshot) {
        String patientName = 'Loading patient info...';
        String patientImageUrl = 'images/boy.jpeg'; // Default image

        if (snapshot.hasData && snapshot.data != null) {
          final patientData = snapshot.data!.data() as Map<String, dynamic>?;
          patientName = patientData?['name'] ?? 'Unknown Patient';
          patientImageUrl = patientData?['image'] ?? 'images/boy.jpeg';
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(patientImageUrl),
                  radius: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.event, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '$date, $timeSlot',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          size: 14, color: Colors.green[700]),
                      const SizedBox(width: 4),
                      Text(
                        'Approved',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _approveAppointment(String appointmentId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .update({
        'status': 'booked',
        'approvedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment approved')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _rejectAppointment(String appointmentId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .update({
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment rejected')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _approveReschedule(String appointmentId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get the appointment data
      final doc = await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .get();

      if (!doc.exists) {
        throw Exception('Appointment not found');
      }

      final data = doc.data()!;

      // Update with proposed date and time
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .update({
        'date': data['proposedDate'],
        'timeSlot': data['proposedTimeSlot'],
        'rescheduleStatus': 'approved',
        'rescheduledAt': FieldValue.serverTimestamp(),
        // Keep the booking status as 'booked'
        'status': 'booked',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reschedule request approved')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _rejectReschedule(String appointmentId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .update({
        'rescheduleStatus': 'rejected',
        'rescheduledAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reschedule request rejected')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
