import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:telemedice_project/pages/appointment.dart';
import 'package:telemedice_project/pages/booking_details.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> _getUpcomingAppointment() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    final now = DateTime.now();
    final dateStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final snapshot = await _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: userId)
        .where('status', isEqualTo: 'booked')
        .where('date', isGreaterThanOrEqualTo: dateStr)
        .orderBy('date')
        .orderBy('timeSlot')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    final data = doc.data();
    final doctorId = data['doctorId'];

    // 用 where 查询，而非直接 doc()
    final doctorSnapshot = await _firestore
        .collection('doctors')
        .where('id', isEqualTo: doctorId)
        .limit(1)
        .get();

    String doctorName = 'Unknown Doctor';
    if (doctorSnapshot.docs.isNotEmpty) {
      final doctorData = doctorSnapshot.docs.first.data();
      doctorName = doctorData['name'] ?? 'Unknown Doctor';
    }

    return {
      'bookingId': doc.id,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'timeSlot': data['timeSlot'],
      'specialist': data['specialist'],
      'location': data['location'],
      'date': data['date'],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hi, User!",
                style: TextStyle(color: Colors.black, fontSize: 22)),
            Text("What do you want to do today?",
                style: TextStyle(color: Colors.black54, fontSize: 14)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_active_outlined),
            color: Colors.black,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Upcoming Appointments",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue)),
            const SizedBox(height: 10),

            FutureBuilder<Map<String, dynamic>?>(
              future: _getUpcomingAppointment(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.blue.shade100),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                    child: ListTile(
                      leading:
                          const Icon(Icons.calendar_today, color: Colors.green),
                      title: const Text(
                          "You currently don't have an appointment scheduled."),
                      subtitle: const Text("Book an appointment today!"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const Appointment()));
                      },
                    ),
                  );
                }

                final appointment = snapshot.data!;
                return Card(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.blue.shade100),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                  child: ListTile(
                    leading:
                        const Icon(Icons.calendar_today, color: Colors.green),
                    title: Text(
                        "Appointment with ${appointment['doctorName']} on ${appointment['date']} at ${appointment['timeSlot']}"),
                    subtitle: Text(
                        "${appointment['specialist']} • ${appointment['location']}"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingDetails(
                            bookingId: appointment['bookingId'],
                            doctorId: appointment['doctorId'],
                            doctorName: appointment['doctorName'],
                            timeSlot: appointment['timeSlot'],
                            specialist: appointment['specialist'],
                            location: appointment['location'],
                            date: appointment['date'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            const Text("For General Needs",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text(
              "Get medical advice, prescriptions, test & referrals by video appointment with our doctors.",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 10),

            // Cards
            _buildActionCard(
              icon: Icons.video_call,
              iconColor: Colors.purple,
              title: "Book an Appointment",
              subtitle:
                  "Choose a Primary Care Doctor and complete your first video appointment.",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Appointment()),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildActionCard(
              icon: Icons.medical_services_outlined,
              iconColor: Colors.blue,
              title: "Online Consultation with Doctor",
              subtitle: "Get medical advice, prescriptions, test & more.",
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _buildActionCard(
              icon: Icons.favorite_border,
              iconColor: Colors.red,
              title: "Medical Records",
              subtitle: "Chat by video with the next available doctor.",
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10)),
      elevation: 0,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
