import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:telemedice_project/pages/calendar.dart';
import 'package:telemedice_project/pages/home.dart';
import 'package:telemedice_project/pages/message.dart';
import 'package:telemedice_project/pages/profile.dart';
import 'package:telemedice_project/pages/search.dart';

class BottomNavBar extends StatefulWidget {
  final int initialIndex;
  const BottomNavBar({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int currentTabIndex = 0;

  late List<Widget> pages;
  late Home homepage;
  late Search search;
  late Calendar calendar;
  late Messages messages;
  late Profile profile;

  @override
  void initState() {
    super.initState();
    currentTabIndex = widget.initialIndex;
    homepage = Home();
    search = Search();
    calendar = Calendar();
    messages = Messages();
    profile = Profile();
    pages = [homepage, search, calendar, messages, profile];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
          height: 65,
          backgroundColor: Colors.white,
          color: Colors.black,
          animationDuration: Duration(milliseconds: 500),
          onTap: (int index) {
            setState(() {
              currentTabIndex = index;
            });
          },
          index: currentTabIndex,
          items: [
            Icon(
              Icons.home_outlined,
              color: Colors.white,
            ),
            Icon(
              Icons.search_outlined,
              color: Colors.white,
            ),
            Icon(
              Icons.calendar_today_outlined,
              color: Colors.white,
            ),
            Icon(
              Icons.message_outlined,
              color: Colors.white,
            ),
            Icon(
              Icons.person_outline,
              color: Colors.white,
            ),
          ]),
      body: pages[currentTabIndex],
    );
  }
}
