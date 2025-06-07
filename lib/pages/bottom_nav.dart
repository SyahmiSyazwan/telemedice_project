import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:telemedice_project/pages/calendar.dart';
import 'package:telemedice_project/pages/home.dart';
import 'package:telemedice_project/pages/message.dart';
import 'package:telemedice_project/pages/profile.dart';

Future<String?> getUserRole() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return null;

  final doc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
  return doc.data()?['Role'];
}

class BottomNavBar extends StatefulWidget {
  final int initialIndex;
  const BottomNavBar({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentTabIndex = 0;

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
            index: currentTabIndex,
            onTap: (index) {
              setState(() {
                currentTabIndex = index;
              });
            },
            items: items,
          ),
          body: pages[currentTabIndex],
        );
      },
    );
  }
}
