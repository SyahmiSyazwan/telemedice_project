import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:telemedice_project/pages/bottomNav.dart';

class BookingDetails extends StatefulWidget {
  final String bookingId;
  final String doctorId;
  final String doctorName;
  final String timeSlot;
  final String specialist;
  final String location;
  final String date;

  const BookingDetails({
    super.key,
    required this.bookingId,
    required this.doctorId,
    required this.doctorName,
    required this.timeSlot,
    required this.specialist,
    required this.location,
    required this.date,
  });

  @override
  State<BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  bool _isCancelling = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // cancel appointment
  Future<void> _cancelBooking() async {
    setState(() {
      _isCancelling = true;
    });

    try {
      await _firestore
          .collection('appointments')
          .doc(widget.bookingId)
          .update({'status': 'cancelled'});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment cancelled successfully.")),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to cancel appointment: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
      }
    }
  }

  // Rescheduling with time conflict detection
  Future<void> _reschedule() async {
    // get the reserved time slots from Firestore
    final bookedSlotsQuery = await _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: widget.doctorId)
        .where('date', isEqualTo: widget.date)
        .where('status', isEqualTo: 'booked')
        .get();

    // Extract all scheduled times, excluding the current scheduled time
    final bookedSlots = bookedSlotsQuery.docs
        .map((doc) => doc['timeSlot'] as String)
        .where((slot) => slot != widget.timeSlot)
        .toSet();

    final newTimeSlot = await showDialog<String>(
      context: context,
      builder: (context) {
        List<String> timeOptions = [
          '08:00',
          '08:30',
          '09:00',
          '09:30',
          '10:00',
          '10:30',
          '11:00',
          '11:30',
          '12:00',
          '12:30',
          '13:00',
          '13:30',
          '14:00',
          '14:30',
          '15:00',
          '15:30',
          '16:00',
          '16:30',
          '17:00',
        ];

        return AlertDialog(
          title: const Text("Select new time"),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: timeOptions.length,
              itemBuilder: (context, index) {
                final time = timeOptions[index];
                final isBooked = bookedSlots.contains(time);
                final isCurrent = time == widget.timeSlot;

                return ListTile(
                  title: Text(
                    time +
                        (isBooked ? " (Already booked)" : "") +
                        (isCurrent ? " (Current)" : ""),
                    style: TextStyle(
                      color: isBooked ? Colors.grey : Colors.black,
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  enabled: !isBooked, // The appointment time is not available
                  onTap: !isBooked ? () => Navigator.pop(context, time) : null,
                );
              },
            ),
          ),
        );
      },
    );

    if (newTimeSlot == null || newTimeSlot == widget.timeSlot) return;

    try {
      // Update appointment time
      await _firestore
          .collection('appointments')
          .doc(widget.bookingId)
          .update({'timeSlot': newTimeSlot});

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment rescheduled successfully.")),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => BottomNavBar(initialIndex: 2),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to reschedule: $e")),
      );
    }
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade700, size: 32),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 16)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("BookingDetails date: ${widget.date}");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoTile(
                Icons.medical_services, "Doctor Name", widget.doctorName),
            const Divider(height: 30, thickness: 1),
            _buildInfoTile(Icons.category, "Specialist", widget.specialist),
            const Divider(height: 30, thickness: 1),
            _buildInfoTile(Icons.location_on, "Location", widget.location),
            const Divider(height: 30, thickness: 1),
            _buildInfoTile(Icons.access_time, "Time", widget.timeSlot),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isCancelling ? null : _cancelBooking,
                    style: ElevatedButton.styleFrom(
                      side: BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isCancelling
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child:
                                CircularProgressIndicator(color: Colors.black),
                          )
                        : const Text("Cancel Booking",
                            style: TextStyle(fontSize: 16, color: Colors.red)),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _reschedule,
                    style: ElevatedButton.styleFrom(
                      side: BorderSide(color: Colors.blue),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Reschedule",
                        style: TextStyle(fontSize: 16, color: Colors.blue)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
