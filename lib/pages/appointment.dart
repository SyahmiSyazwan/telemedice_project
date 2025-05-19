import 'package:flutter/material.dart';
import 'package:telemedice_project/pages/specialist_selection.dart';
import 'package:telemedice_project/models/appointment_type.dart';


class Appointment extends StatefulWidget {
  const Appointment({super.key});

  @override
  State<Appointment> createState() => _AppointmentState();
}

class _AppointmentState extends State<Appointment> {
  AppointmentType? _selectedType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Appointments", style: TextStyle(color: Colors.black)),
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
            const Text(
              "What is the patient's current location?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "This would help us connect you with the best available licensed Doctor for that location on our platform.",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 15),
            Row(
              children: const [
                Icon(Icons.location_on, color: Colors.red),
                SizedBox(width: 5),
                Text("UTM, Skudai, Johor",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                Text("Change", style: TextStyle(color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              "What's the type of appointment you\nwould like to make?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                SizedBox(
                  width: 150,
                  height: 140,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedType = AppointmentType.inPerson;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: _selectedType == AppointmentType.inPerson
                            ? Colors.blue.shade300
                            : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _selectedType == AppointmentType.inPerson
                              ? Colors.blue
                              : Colors.blue.shade100,
                          width: 2,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_hospital,
                              color: Colors.white, size: 30),
                          SizedBox(height: 10),
                          Text(
                            "In-Person\nMedical Consultation",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                SizedBox(
                  width: 150,
                  height: 140,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedType = AppointmentType.virtual;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: _selectedType == AppointmentType.virtual
                            ? Colors.green.shade400
                            : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _selectedType == AppointmentType.virtual
                              ? Colors.green.shade700
                              : Colors.green.shade200,
                          width: 2,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.directions_car,
                              color: Colors.white, size: 30),
                          SizedBox(height: 10),
                          Text(
                            "Virtual Medical\nConsultation",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedType == null
                    ? null
                    : () {
                        if (_selectedType == AppointmentType.inPerson) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                     SpecialistSelection(appointmentType: _selectedType!,)),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                     SpecialistSelection(appointmentType: _selectedType!,)),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedType == null
                      ? Colors.grey
                      : const Color(0XFFB2F2E9),
                  foregroundColor:
                      _selectedType == null ? Colors.black45 : Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text("Next — Select a Specialist  →"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
