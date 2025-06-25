import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:telemedice_project/pages/bottom_nav.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingDetails extends StatefulWidget {
  final String bookingId;
  final String doctorId;
  final String doctorName;
  final String doctorImage;
  final String timeSlot;
  final String specialist;
  final String location;
  final String date;
  final String appointmentType;
  final String patientId;
  final String patientName;

  const BookingDetails({
    super.key,
    required this.bookingId,
    required this.doctorId,
    required this.doctorName,
    required this.doctorImage,
    required this.timeSlot,
    required this.specialist,
    required this.location,
    required this.date,
    required this.appointmentType,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  @override
  void initState() {
    super.initState();
    fetchUserRole(); // <-- IMPORTANT!
  }

  bool _isCancelling = false;
  String? userRole;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> fetchUserRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (doc.exists) {
      setState(() {
        userRole = doc.data()?['role'];
      });
    }
  }

  // Cancel appointment
  Future<void> _cancelBooking() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Cancel Appointment",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "Are you sure you want to cancel this appointment?",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        actions: [
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      backgroundColor: Colors.teal.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Yes",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isCancelling = true;
    });

    try {
      await FirebaseFirestore.instance
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
    // Get the reserved time slots from Firestore
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

    final selectedSlot = await showDialog<String>(
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
          title: const Text("Select New Time Slot",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              textAlign: TextAlign.center),
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

    if (selectedSlot == null || selectedSlot == widget.timeSlot) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Confirm Reschedule",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Change appointment time to $selectedSlot?",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        actions: [
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      backgroundColor: Colors.teal.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      backgroundColor: Colors.teal.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Yes",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );

    if (confirm != true) return;
    try {
      // Update appointment time
      await _firestore
          .collection('appointments')
          .doc(widget.bookingId)
          .update({'timeSlot': selectedSlot});

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment rescheduled successfully.")),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => BottomNavBar(initialIndex: 1),
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

  Future<void> joinMeeting(String appointmentId) async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    String displayName = "Guest";
    String? email = user?.email;

    if (uid != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        displayName = doc.data()?['name'] ?? "Guest";
        email = doc.data()?['email'] ?? email;
      }
    }

    final options = JitsiMeetConferenceOptions(
      room: appointmentId,
      userInfo: JitsiMeetUserInfo(
        displayName: displayName,
        email: email,
      ),
    );

    await JitsiMeet().join(options);
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle,
      {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal.shade300, size: 32),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 16, color: Colors.black)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      onTap: onTap,
    );
  }

  void _openMap(String location) async {
    final encodedLocation = Uri.encodeComponent(location);
    final googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=$encodedLocation";

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open the map.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Received location: ${widget.location}");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Detail",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24)),
        backgroundColor: Colors.teal.shade100,
        elevation: 1,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(widget.doctorImage),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    FirebaseAuth.instance.currentUser?.uid == widget.doctorId
                        ? widget.patientName
                        : widget.doctorName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade400),
              ),
              child: Column(children: [
                if (userRole != 'Doctor') ...[
                  _buildInfoTile(
                      Icons.category, "Specialist", widget.specialist),
                  Divider(
                    height: 15,
                    color: Colors.grey.shade500,
                  ),
                ],
                if (widget.appointmentType == 'inPerson') ...[
                  _buildInfoTile(
                    Icons.location_on,
                    "Navigate Location",
                    widget.location,
                    onTap: () => _openMap(widget.location),
                  ),
                  Divider(
                    height: 15,
                    color: Colors.grey.shade400,
                  ),
                ],
                if (widget.appointmentType == 'virtual') ...[
                  _buildInfoTile(
                    Icons.video_call,
                    "Join Virtual Meeting",
                    "Click to join",
                    onTap: () => joinMeeting(widget.bookingId),
                  ),
                  Divider(
                    height: 15,
                    color: Colors.grey.shade400,
                  ),
                ],
                _buildInfoTile(Icons.access_time, "Time", widget.timeSlot),
              ]),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _reschedule,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade100,
                      side: BorderSide(color: Colors.teal.shade100),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Reschedule",
                        style: TextStyle(fontSize: 18, color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isCancelling ? null : _cancelBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
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
                            style:
                                TextStyle(fontSize: 18, color: Colors.black)),
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
