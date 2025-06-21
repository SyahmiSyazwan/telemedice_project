import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:telemedice_project/pages/doctor_selection.dart';
import 'package:telemedice_project/models/appointment_type.dart';

class SpecialistSelection extends StatefulWidget {
  final AppointmentType appointmentType;
  final String location;

  const SpecialistSelection(
      {super.key, required this.appointmentType, required this.location});

  @override
  State<SpecialistSelection> createState() => _SpecialistSelectionState();
}

class _SpecialistSelectionState extends State<SpecialistSelection> {
  Future<int> _countDoctorsForSpecialistAndLocation(
      String specialist, String location) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Doctor')
        .where('specialistLabel', isEqualTo: specialist)
        .where('location', isEqualTo: location)
        .get();

    return snapshot.docs.length;
  }

  Widget _buildSpecialistItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String specialistLabel,
    required VoidCallback onTap,
  }) {
    return FutureBuilder<int>(
      future: _countDoctorsForSpecialistAndLocation(
          specialistLabel, widget.location),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Icon(icon, color: Colors.blue),
          ),
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
              "$subtitle • $count available doctor${count == 1 ? '' : 's'}"),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        );
      },
    );
  }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Specialist",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // can use firebase store the specialist and doctor, but need to admin prototype for insert the specialist and doctor first
            _buildSpecialistItem(
              icon: Icons.child_care,
              title: "Pediatrician",
              subtitle: "Child Specialist",
              specialistLabel: "pediatrician",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DoctorSelection(
                            appointmentType: widget.appointmentType,
                            specialistLabel: "pediatrician",
                            location: widget.location,
                          )),
                );
              },
            ),
            _buildSpecialistItem(
              icon: Icons.favorite,
              title: "Cardiologist",
              subtitle: "Heart Specialist",
              specialistLabel: "cardiologist",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DoctorSelection(
                            appointmentType: widget.appointmentType,
                            specialistLabel: "cardiologist",
                            location: widget.location,
                          )),
                );
              },
            ),
            _buildSpecialistItem(
              icon: Icons.psychology_outlined,
              title: "Neurologist",
              subtitle: "Brain Specialist",
              specialistLabel: "neurologist",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DoctorSelection(
                            appointmentType: widget.appointmentType,
                            specialistLabel: "neurologist",
                            location: widget.location,
                          )),
                );
              },
            ),
            _buildSpecialistItem(
              icon: Icons.medical_information_outlined,
              title: "Dentist",
              subtitle: "Dental Surgeon",
              specialistLabel: "dentist",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DoctorSelection(
                            appointmentType: widget.appointmentType,
                            specialistLabel: "dentist",
                            location: widget.location,
                          )),
                );
              },
            ),
            _buildSpecialistItem(
              icon: Icons.remove_red_eye_outlined,
              title: "Ophthalmologist",
              subtitle: "Eye Specialist",
              specialistLabel: "ophthalmologist",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DoctorSelection(
                            appointmentType: widget.appointmentType,
                            specialistLabel: "ophthalmologist",
                            location: widget.location,
                          )),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
