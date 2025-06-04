import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:telemedice_project/pages/booking_details.dart';
import 'package:telemedice_project/auth/database.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final DatabaseMethods _database = DatabaseMethods();

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final selectedDateStr =
        _selectedDay != null ? _formatDate(_selectedDay!) : '';

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.teal.shade100,
          title: const Text(
            'CALENDER',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay; // update focusedDay as well
                });
              },
              calendarFormat: CalendarFormat.month,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false, // hides the format toggle button
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Colors.teal,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.teal.shade100,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(color: Colors.white),
                todayTextStyle: const TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1, color: Colors.teal),
            Text(
              'Appointment List',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Divider(thickness: 0.8, color: Colors.teal),
            const SizedBox(height: 10),

            // The appointment list is displayed only when the selected date is not empty
            _selectedDay == null
                ? const Text('Please select a date.')
                : Expanded(
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream:
                          _database.getBookingsStreamByDate(selectedDateStr),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text("No bookings for Selected Date.",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 18)));
                        }

                        final bookings = snapshot.data!;
                        return ListView.builder(
                          itemCount: bookings.length,
                          itemBuilder: (context, index) {
                            final booking = bookings[index];
                            return ListTile(
                              leading: const Icon(
                                Icons.medical_services,
                                color: Colors.teal,
                              ),
                              title: Text(
                                "Time: ${booking['timeSlot']}",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(
                                "Location: ${booking['location']}\nSpecialist: ${booking['specialist']}",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                              isThreeLine: true,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BookingDetails(
                                      bookingId: booking['bookingId'],
                                      doctorId: booking['doctorId'],
                                      doctorName: booking['doctorName'],
                                      doctorImage: booking['doctorImage'],
                                      timeSlot: booking['timeSlot'],
                                      specialist: booking['specialist'],
                                      location: booking['location'],
                                      date: booking['date'] ?? '',
                                      appointmentType:
                                          booking['appointmentType'] ?? '',
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
