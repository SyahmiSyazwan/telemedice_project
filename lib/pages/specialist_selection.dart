import 'package:flutter/material.dart';
import 'package:telemedice_project/pages/doctor_selection.dart';
import 'package:telemedice_project/models/appointment_type.dart';

class SpecialistSelection extends StatefulWidget {
  final AppointmentType appointmentType;

  const SpecialistSelection({super.key, required this.appointmentType});

  @override
  State<SpecialistSelection> createState() => _SpecialistSelectionState();
}

class _SpecialistSelectionState extends State<SpecialistSelection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select a Specialist",
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 15),
            //   decoration: BoxDecoration(
            //     border: Border.all(color: Colors.teal.shade100),
            //     borderRadius: BorderRadius.circular(10),
            //   ),
            //   child: const TextField(
            //     decoration: InputDecoration(
            //       hintText: 'Search',
            //       border: InputBorder.none,
            //       icon: Icon(Icons.search),
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Specialist",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "See more",
                  style: TextStyle(color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // can use firebase store the specialist and doctor, but need to admin prototype for insert the specialist and doctor first
            _buildSpecialistItem(
              context,
              icon: Icons.child_care,
              title: "Pediatrician",
              subtitle: "Child Specialist • 75 available doctors",
              specialistLabel: "pediatrician",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DoctorSelection(
                            specialistLabel: "pediatrician",
                          )),
                );
              },
            ),
            _buildSpecialistItem(
              context,
              icon: Icons.favorite,
              title: "Cardiologist",
              subtitle: "Heart Specialist • 75 available doctors",
              specialistLabel: "cardiologist",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DoctorSelection(
                            specialistLabel: "cardiologist",
                          )),
                );
              },
            ),
            _buildSpecialistItem(
              context,
              icon: Icons.psychology_outlined,
              title: "Neurologist",
              subtitle: "Brain Specialist • 33 available doctors",
              specialistLabel: "neurologist",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DoctorSelection(
                            specialistLabel: "neurologist",
                          )),
                );
              },
            ),
            _buildSpecialistItem(
              context,
              icon: Icons.medical_information_outlined,
              title: "Dentist",
              subtitle: "Dental Surgeon • 119 available doctors",
              specialistLabel: "dentist",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DoctorSelection(
                            specialistLabel: "dentist",
                          )),
                );
              },
            ),
            _buildSpecialistItem(
              context,
              icon: Icons.remove_red_eye_outlined,
              title: "Ophthalmologist",
              subtitle: "Eye Specialist • 102 available doctors",
              specialistLabel: "ophthalmologist",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DoctorSelection(
                            specialistLabel: "dentist",
                          )),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialistItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String specialistLabel,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        child: Icon(icon, color: Colors.blue),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
