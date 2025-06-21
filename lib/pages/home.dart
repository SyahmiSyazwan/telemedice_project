import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:telemedice_project/pages/appointment.dart';
import 'package:telemedice_project/pages/booking_details.dart';
import 'package:telemedice_project/pages/medical_record_upload_page.dart';
import 'package:telemedice_project/pages/patient_medical_record_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? userName;
  String? userRole;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    final userId = _auth.currentUser?.uid;
    print("Logged-in User ID: $userId"); // Log the user ID
    if (userId == null) return;

    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists) {
      final userData = userDoc.data();
      print(
          "Firestore Document Data: $userData"); // Log the entire document data

      setState(() {
        userName = userData?['name'] ?? 'User'; // Extract Name
        userRole = userData?['role'] ?? 'Patient'; // Extract Role
        userEmail = userData?['email']; // Extract Email
        print("User Role: $userRole"); // Log the user role
        print("User Name: $userName"); // Log the user name
        print("User Email: $userEmail"); // Log the user name
      });
    } else {
      print("User document not found in Firestore.");
    }
  }

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
        .collection('users')
        .where('id', isEqualTo: doctorId)
        .limit(1)
        .get();

    String doctorName = 'Unknown Doctor';
    String doctorImage = 'images/boy.jpeg';
    if (doctorSnapshot.docs.isNotEmpty) {
      final doctorData = doctorSnapshot.docs.first.data();
      doctorName = doctorData['name'] ?? 'Unknown Doctor';
      doctorImage = doctorData['image'] ?? 'images/boy.jpeg';
    }

    return {
      'bookingId': doc.id,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorImage': doctorImage,
      'timeSlot': data['timeSlot'],
      'specialist': data['specialist'],
      'location': data['location'],
      'date': data['date'],
      'appointmentType': data['appointmentType'],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade100,
        toolbarHeight: 70,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("HI, ${userName ?? 'User'}",
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const Text("What do you want to do today?",
                style: TextStyle(color: Colors.black, fontSize: 16)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("UPCOMING APPOINTMENT",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
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
                      side: BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                    child: ListTile(
                      leading:
                          const Icon(Icons.calendar_today, color: Colors.green),
                      title: const Text(
                        "You Currently Don't Have An Appointment Scheduled",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        "Book An Appointment Today!",
                        style: TextStyle(color: Colors.black),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 20,
                      ),
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
                    side: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                  child: ListTile(
                    leading:
                        const Icon(Icons.calendar_today, color: Colors.green),
                    title: Text(
                      "Appointment With ${appointment['doctorName']} At \n${appointment['date']} ${appointment['timeSlot']}",
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.justify,
                    ),
                    subtitle: Text(
                      "${appointment['specialist']} • ${appointment['location']}",
                      style: TextStyle(color: Colors.black),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 20),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingDetails(
                            bookingId: appointment['bookingId'],
                            doctorId: appointment['doctorId'],
                            doctorName: appointment['doctorName'],
                            doctorImage: appointment['doctorImage'],
                            timeSlot: appointment['timeSlot'],
                            specialist: appointment['specialist'],
                            location: appointment['location'],
                            date: appointment['date'],
                            appointmentType: appointment['appointmentType'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            const Text("GENERAL NEEDS",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const SizedBox(height: 5),
            const Text(
              "Access Quality Care Whether By Video Or At A clinic For Your General Health Needs.",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 10),

            // Cards
            _buildActionCard(
              icon: Icons.video_call,
              iconColor: Colors.purple,
              title: "Book An Appointment",
              subtitle:
                  "Connect With A Doctor For A Virtual Or In-Person Visit At Your Convenience",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Appointment()),
                );
              },
            ),
            const SizedBox(height: 10),
            if (userRole == 'Patient') ...[
              _buildActionCard(
                icon: Icons.favorite_border,
                iconColor: Colors.red,
                title: "Medical Records",
                subtitle: "Your Complete Health Records In One Place.",
                onTap: () {
                  if (userEmail != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PatientMedicalRecordsPage(patientEmail: userEmail!),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Your email is missing. Cannot view medical records.')),
                    );
                  }
                },
              ),
            ],
            const SizedBox(height: 10),
            // Conditionally render the "Upload Medical Records" card
            if (userRole == 'Doctor') ...[
              _buildActionCard(
                icon: Icons.medical_services_outlined,
                iconColor: Colors.blue,
                title: "Upload Medical Records",
                subtitle: "Diagnose and treat your medical conditions.",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MedicalRecordUploadPage()),
                  );
                },
              ),
            ],
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
          side: BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(10)),
      elevation: 0,
      child: ListTile(
        leading: CircleAvatar(
          // ignore: deprecated_member_use
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.black),
          textAlign: TextAlign.justify,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 20),
        onTap: onTap,
      ),
    );
  }
}
