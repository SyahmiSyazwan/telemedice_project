import 'package:flutter/material.dart';
import 'package:telemedice_project/pages/appointment_booking.dart';

class DoctorSelection extends StatefulWidget {
  final String specialistLabel;

  const DoctorSelection({super.key, required this.specialistLabel});

  @override
  State<DoctorSelection> createState() => _DoctorSelectionState();
}

class _DoctorSelectionState extends State<DoctorSelection> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> doctors = [
      {
        'id': 'doc1',
        'name': 'Dr. Chukwunomnso Iwegbu',
        'image': 'images/boy.jpeg',
        'hospital': 'Columbia Asia Hospital Tebrau',
        'rating': 4.5,
        'reviews': 1031,
        'specialistLabel': 'pediatrician',
      },
      {
        'id': 'doc2',
        'name': 'Dr. Uchendu Ebuka',
        'image': 'images/boy.jpeg',
        'hospital': 'Columbia Asia Hospital Tebrau',
        'rating': 4.0,
        'reviews': 1031,
        'specialistLabel': 'cardiologist',
      },
      {
        'id': 'doc3',
        'name': 'Dr. Chindinma Nwokoro',
        'image': 'images/boy.jpeg',
        'hospital': 'Columbia Asia Hospital Tebrau',
        'rating': 4.8,
        'reviews': 1031,
        'specialistLabel': 'neurologist',
      },
      {
        'id': 'doc4',
        'name': 'Dr. Adekunle Philips',
        'image': 'images/boy.jpeg',
        'hospital': 'Randle General Hospitals',
        'rating': 4.7,
        'reviews': 1031,
        'specialistLabel': 'dentist',
      },
      {
        'id': 'doc5',
        'name': 'Dr. Ayobami Ayodele',
        'image': 'images/boy.jpeg',
        'hospital': 'Marigold Hospital',
        'rating': 4.9,
        'reviews': 1031,
        'specialistLabel': 'ophthalmologist',
      },
    ];

    // match specialist doctor list
    List<Map<String, dynamic>> filteredDoctors = doctors
        .where((doc) => doc['specialistLabel'] == widget.specialistLabel)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.specialistLabel} Doctors",
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Doctor List
            ...filteredDoctors
                .map((doc) => _buildDoctorCard(context, doc))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, Map<String, dynamic> doctor) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundImage: AssetImage(doctor['image']),
            radius: 25,
          ),
          title: Text(
            doctor['name'],
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
                      index < doctor['rating'] ? Icons.star : Icons.star_border,
                      size: 16,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text('${doctor['reviews']} Ratings',
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                doctor['hospital'],
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AppointmentBooking(
                  doctorName: doctor['name'],
                  doctorImage: doctor['image'],
                  specialistLabel: doctor['specialistLabel'],
                  hospitalName: doctor['hospital'],
                  doctorId: doctor['id'],
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
