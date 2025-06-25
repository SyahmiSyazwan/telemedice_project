import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:telemedice_project/pages/calendar.dart';
import 'package:telemedice_project/pages/home.dart';
import 'package:telemedice_project/pages/message.dart';
import 'package:telemedice_project/pages/profile.dart';
import 'package:telemedice_project/pages/doctor_approval_page.dart';
import 'package:intl/intl.dart'; // Add this for date formatting
import 'package:rxdart/rxdart.dart'; // Add this for Rx operations

Future<String?> getUserRole() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return null;

  final doc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
  return doc.data()?['role'];
}

class BottomNavBar extends StatefulWidget {
  final int initialIndex;
  const BottomNavBar({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentTabIndex = 0;
  String? userRole;

  late Home homepage;
  late Calendar calendar;
  late Messages messages;
  late Profile profile;

  @override
  void initState() {
    super.initState();
    homepage = Home();
    calendar = Calendar();
    messages = Messages();
    profile = Profile();
    currentTabIndex = widget.initialIndex;
    _checkUserRole();
  }
  
  Future<void> _checkUserRole() async {
    final role = await getUserRole();
    setState(() {
      userRole = role;
    });
  }

  void _navigateToDoctorApproval() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DoctorApprovalPage()),
    );
  }
  
  // Add this method to count both new appointments and reschedule requests
  Stream<int> _getPendingRequestsCount() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Stream.value(0);
    }

    // Stream for new appointment requests
    final newAppointmentsStream = FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);

    // Stream for reschedule requests
    final rescheduleRequestsStream = FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: uid)
        .where('rescheduleStatus', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);

    // Combine the two streams using RxDart's CombineLatestStream
    return CombineLatestStream.combine2(
      newAppointmentsStream,
      rescheduleRequestsStream,
      (int newCount, int rescheduleCount) => newCount + rescheduleCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getUserRole(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        String role = snapshot.data!;
        List<Widget> pages;
        List<Widget> items;

        if (role == 'Patient') {
          pages = [homepage, calendar, messages, profile];
          items = const [
            Icon(Icons.home_outlined, color: Colors.white),
            Icon(Icons.calendar_today_outlined, color: Colors.white),
            Icon(Icons.message_outlined, color: Colors.white),
            Icon(Icons.person_outline, color: Colors.white),
          ];
        } else if (role == 'Doctor') {
          pages = [homepage, calendar, profile];
          items = const [
            Icon(Icons.home_outlined, color: Colors.white),
            Icon(Icons.calendar_today_outlined, color: Colors.white),
            Icon(Icons.person_outline, color: Colors.white),
          ];
        } else {
          return const Scaffold(body: Center(child: Text("Unknown role.")));
        }

        return Scaffold(
          bottomNavigationBar: CurvedNavigationBar(
            height: 65,
            backgroundColor: Colors.white,
            color: Colors.black,
            animationDuration: const Duration(milliseconds: 500),
            index: currentTabIndex < pages.length ? currentTabIndex : 0,
            onTap: (index) {
              setState(() {
                currentTabIndex = index;
              });
            },
            items: items,
          ),
          body: Stack(
            children: [
              // Main content
              pages[currentTabIndex < pages.length ? currentTabIndex : 0],
              
              // Add floating action button for doctor role
              if (role == 'Doctor')
                Positioned(
                  bottom: 80, // Position above bottom nav bar
                  right: 16,
                  child: StreamBuilder<int>(
                    stream: _getPendingRequestsCount(),
                    builder: (context, snapshot) {
                      int pendingCount = snapshot.data ?? 0;
                      
                      return FloatingActionButton.extended(
                        onPressed: _navigateToDoctorApproval,
                        backgroundColor: const Color(0xFFB2F2E9),
                        foregroundColor: Colors.black,
                        elevation: 4,
                        label: Row(
                          children: [
                            const Icon(Icons.approval),
                            const SizedBox(width: 8),
                            Text(pendingCount > 0 
                              ? 'Requests ($pendingCount)' 
                              : 'Requests'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}