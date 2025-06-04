import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:telemedice_project/auth/database.dart';
import 'package:telemedice_project/pages/bottom_nav.dart';

class AppointmentBooking extends StatefulWidget {
  final String doctorName;
  final String doctorImage;
  final String specialistLabel;
  // final String hospitalName;
  final String doctorId;
  final String location;

  const AppointmentBooking({
    super.key,
    required this.doctorName,
    required this.doctorImage,
    required this.specialistLabel,
    // required this.hospitalName,
    required this.doctorId,
    required this.location,
  });

  @override
  State<AppointmentBooking> createState() => _AppointmentBookingState();
}

class _AppointmentBookingState extends State<AppointmentBooking> {
  DateTime? selectedDate;
  String? selectedTimeSlot;
  List<String> bookedSlots = [];
  bool isLoading = false;

  final dateFormatter = DateFormat('MMM d, yyyy');
  final timeFormatter = DateFormat('hh:mm a');

  List<String> generateTimeSlots() {
    List<String> slots = [];
    final startHour = 8;
    final endHour = 17;
    for (int hour = startHour; hour <= endHour; hour++) {
      slots.add('${hour.toString().padLeft(2, '0')}:00');
      if (hour != endHour) {
        slots.add('${hour.toString().padLeft(2, '0')}:30');
      }
    }
    return slots;
  }

  Future<void> _onDatePicked(DateTime pickedDate) async {
    setState(() {
      selectedDate = pickedDate;
      selectedTimeSlot = null;
      bookedSlots = [];
      isLoading = true;
    });

    String dateStr = DateFormat('yyyy-MM-dd').format(pickedDate);
    List<String> booked = await DatabaseMethods().getBookedTimeSlots(
        widget.doctorId, dateStr, widget.location, widget.specialistLabel);

    setState(() {
      bookedSlots = booked;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final timeSlots = generateTimeSlots();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Book An Appointment",
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
            const Text(
              "Confirm a date and time for your appointment with a general practitioner. Include a note as well",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),

            const Text("DOCTOR", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage(widget.doctorImage),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.doctorName,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(widget.specialistLabel,
                        style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(),

            const Text("LOCATION",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(widget.location,
                style: TextStyle(fontWeight: FontWeight.w600)),
            // Text(widget.hospitalName, style: TextStyle(color: Colors.black54)),

            const SizedBox(height: 20),
            const Divider(),

            const Text("DATE & TIME",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // Date & Time Selector (static for now)
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () async {
                      final now = DateTime.now();
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? now,
                        firstDate: now,
                        lastDate: DateTime(now.year + 1),
                      );
                      if (pickedDate != null) {
                        await _onDatePicked(pickedDate);
                      }
                    },
                    child: Text(
                      selectedDate == null
                          ? 'Choose Date'
                          : dateFormatter.format(selectedDate!),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  flex: 1,
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : DropdownButton<String>(
                          isExpanded: true,
                          hint: const Text('Select Time Slot'),
                          value: selectedTimeSlot,
                          items: timeSlots.map((slot) {
                            // Time format conversion
                            final parts = slot.split(':');
                            final time = DateTime(0, 0, 0, int.parse(parts[0]),
                                int.parse(parts[1]));
                            final formattedTime = timeFormatter.format(time);

                            // Disable reserved time slots
                            final isBooked = bookedSlots.contains(slot);

                            return DropdownMenuItem<String>(
                              value: slot,
                              enabled: !isBooked,
                              child: Text(
                                formattedTime +
                                    (isBooked ? " (Already booked)" : ""),
                                style: TextStyle(
                                    color:
                                        isBooked ? Colors.grey : Colors.black),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedTimeSlot = val;
                            });
                          },
                        ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedDate != null && selectedTimeSlot != null
                    ? () async {
                        final userId = FirebaseAuth.instance.currentUser?.uid;
                        if (userId == null) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Please log in first!"),
                          ));
                          return;
                        }

                        setState(() => isLoading = true);

                        final dateStr =
                            DateFormat('yyyy-MM-dd').format(selectedDate!);

                        final success = await DatabaseMethods().bookAppointment(
                            doctorId: widget.doctorId,
                            patientId: userId,
                            date: dateStr,
                            timeSlot: selectedTimeSlot!,
                            location: widget.location,
                            specialist: widget.specialistLabel);

                        setState(() => isLoading = false);

                        if (success) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Reservation successful!"),
                          ));
                          Future.delayed(const Duration(seconds: 1), () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) =>
                                    BottomNavBar(initialIndex: 2),
                              ),
                              (route) => false,
                            );
                          });
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                                "This time slot has been booked. Please select another time."),
                          ));
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      selectedDate != null && selectedTimeSlot != null
                          ? const Color(0xFFB2F2E9)
                          : Colors.grey,
                  foregroundColor:
                      selectedDate != null && selectedTimeSlot != null
                          ? Colors.black
                          : Colors.black45,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Book an Appointment"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
