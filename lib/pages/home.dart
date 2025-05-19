import 'package:flutter/material.dart';
import 'package:telemedice_project/pages/appointment.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
            Text(
              "What do you want to do today?",
              style: TextStyle(color: Colors.black54, fontSize: 14),
            )
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
            Card(
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.blue.shade100),
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.green),
                title: const Text(
                    "You currently don't have an appointment scheduled."),
                subtitle: const Text("Book an appointment today!"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
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
                  MaterialPageRoute(
                      builder: (context) => const Appointment()),
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
