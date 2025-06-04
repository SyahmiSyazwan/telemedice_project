import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:telemedice_project/models/appointment_type.dart';
import 'package:telemedice_project/models/doctor.dart';
import 'package:telemedice_project/pages/appointment_booking.dart';

class DoctorSelection extends StatefulWidget {
  final String specialistLabel;
  final String location;
  final AppointmentType appointmentType;

  const DoctorSelection(
      {super.key,
      required this.specialistLabel,
      required this.location,
      required this.appointmentType});

  @override
  State<DoctorSelection> createState() => _DoctorSelectionState();
}

class _DoctorSelectionState extends State<DoctorSelection> {
  Future<List<Doctor>> _fetchDoctors() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('doctors')
        .where('specialistLabel', isEqualTo: widget.specialistLabel)
        .where('location', isEqualTo: widget.location)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Doctor(
        id: data['id'],
        name: data['name'],
        image: data['image'],
        location: data['location'],
        rating: (data['rating'] as num).toDouble(),
        reviews: data['reviews'],
        specialistLabel: data['specialistLabel'],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.specialistLabel} Doctors",
            style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar (not implemented for filtering yet)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.teal.shade100),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Available doctors for ${widget.specialistLabel}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Doctor>>(
              future: _fetchDoctors(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No doctors found."));
                }
                final doctors = snapshot.data!;
                return Column(
                  children: doctors
                      .map((doc) => _buildDoctorCard(context, doc))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, Doctor doctor) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundImage: AssetImage(doctor.image),
            radius: 25,
          ),
          title: Text(
            doctor.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ...List.generate(
                    5,
                    (index) => Icon(
                      index < doctor.rating ? Icons.star : Icons.star_border,
                      size: 16,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text('${doctor.reviews} Ratings',
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(height: 2),
              // Text(
              //   doctor.location,
              //   style: const TextStyle(fontSize: 12),
              // ),
            ],
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AppointmentBooking(
                  doctorName: doctor.name,
                  doctorImage: doctor.image,
                  specialistLabel: doctor.specialistLabel,
                  doctorId: doctor.id,
                  location: widget.location,
                  appointmentType: widget.appointmentType,
                ),
              ),
            );
          },
        ),
        const Divider(height: 25),
      ],
    );
  }
}
