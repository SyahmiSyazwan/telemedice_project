import 'package:flutter/material.dart';

class Doctor {
  final String name;
  final String specialty;
  final double rating;
  final String photoUrl;

  Doctor({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.photoUrl,
  });
}

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final List<Doctor> doctors = [
    Doctor(
      name: 'Dr. Helena Fox',
      specialty: 'Pulmonologist',
      rating: 4.8,
      photoUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
    ),
    Doctor(
      name: 'Dr. Andrew Miller',
      specialty: 'Pulmonologist',
      rating: 5.0,
      photoUrl: 'https://randomuser.me/api/portraits/men/46.jpg',
    ),
    // Repeat or add more doctors as needed
  ];

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredDoctors = doctors.where((doc) {
      final lowerQuery = searchQuery.toLowerCase();
      return doc.name.toLowerCase().contains(lowerQuery) ||
          doc.specialty.toLowerCase().contains(lowerQuery);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFEFF7F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Doctors',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
              onChanged: (val) {
                setState(() {
                  searchQuery = val;
                });
              },
            ),

            const SizedBox(height: 12),

            // Grid of doctor cards
            Expanded(
              child: GridView.builder(
                itemCount: filteredDoctors.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 5,
                  childAspectRatio: 2 / 3,
                ),
                itemBuilder: (context, index) {
                  final doctor = filteredDoctors[index];
                  return DoctorCard(doctor: doctor);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final Doctor doctor;

  const DoctorCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Column(
          children: [
            CircleAvatar(
              radius: 42,
              backgroundImage: NetworkImage(doctor.photoUrl),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  doctor.rating.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.star, color: Colors.amber, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              doctor.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              doctor.specialty,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF59D7C1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.all(8),
                minimumSize: const Size(36, 36),
              ),
              onPressed: () {
                // Action when button pressed
              },
              child: const Icon(Icons.arrow_forward),
            ),
          ],
        ),
      ),
    );
  }
}
