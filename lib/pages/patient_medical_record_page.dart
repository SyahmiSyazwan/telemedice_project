import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart'; 

class PatientMedicalRecordsPage extends StatelessWidget {
  final String patientEmail;

  const PatientMedicalRecordsPage({Key? key, required this.patientEmail})
      : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchMedicalRecords() async {
    final query = await FirebaseFirestore.instance
        .collection('medical_records')
        .where('patientEmail', isEqualTo: patientEmail)
        .orderBy('createdAt', descending: true)
        .get();

    // If you also want file uploads to show up, fetch by uploadedAt as well
    final fileQuery = await FirebaseFirestore.instance
        .collection('medical_records')
        .where('patientEmail', isEqualTo: patientEmail)
        .orderBy('uploadedAt', descending: true)
        .get();

    // Merge and sort by latest timestamp (createdAt or uploadedAt)
    List<Map<String, dynamic>> records = [
      ...query.docs.map((doc) => doc.data()),
      ...fileQuery.docs.map((doc) => doc.data()),
    ];

    // Remove duplicates (if any)
    final seen = <String>{};
    records = records.where((r) {
      final id = (r['fileUrl'] ?? '') +
          (r['createdAt']?.toString() ?? '') +
          (r['uploadedAt']?.toString() ?? '');
      if (seen.contains(id)) return false;
      seen.add(id);
      return true;
    }).toList();

    // Sort by timestamp
    records.sort((a, b) {
      final aTimestamp = a['createdAt'] ?? a['uploadedAt'];
      final bTimestamp = b['createdAt'] ?? b['uploadedAt'];
      if (aTimestamp == null && bTimestamp == null) return 0;
      if (aTimestamp == null) return 1;
      if (bTimestamp == null) return -1;
      return (bTimestamp as Timestamp).compareTo(aTimestamp as Timestamp);
    });

    return records;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Medical Records'),
        backgroundColor: const Color(0xFF8FE1D7),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchMedicalRecords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No medical records found."));
          }

          final records = snapshot.data!;

          return ListView.separated(
            itemCount: records.length,
            separatorBuilder: (context, idx) => Divider(),
            itemBuilder: (context, index) {
              final record = records[index];
              final isFile = record['type'] == 'file';
              final timestamp = record['createdAt'] ?? record['uploadedAt'];
              final date =
                  timestamp != null ? (timestamp as Timestamp).toDate() : null;

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Color(0xFFE9F9F7),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: isFile
                      ? _buildFileRecord(context, record, date)
                      : _buildFormRecord(record, date),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFileRecord(
      BuildContext context, Map<String, dynamic> record, DateTime? date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Medical Record File",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(height: 8),
        Text("Name: ${record['patientName'] ?? '-'}"),
        SizedBox(height: 4),
        Text("File: ${record['fileName'] ?? 'Unknown'}"),
        SizedBox(height: 4),
        if (date != null)
          Text('Uploaded: ${date.toLocal().toString().substring(0, 16)}'),
        SizedBox(height: 8),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF8FE1D7),
            foregroundColor: Colors.black,
          ),
          icon: Icon(Icons.open_in_new),
          label: Text("Open File"),
          onPressed: () async {
            final url = record['fileUrl'];
            // Debug print and show the URL
            // print('DEBUG: Trying to open file URL: $url');
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(
            //     content: Text('DEBUG: Trying to open URL:\n$url'),
            //     duration: Duration(seconds: 3),
            //   ),
            // );
            if (url != null) {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                // Copy link to clipboard as fallback
                await Clipboard.setData(ClipboardData(text: url));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Could not open the file. Link copied to clipboard.')),
                );
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildFormRecord(Map<String, dynamic> record, DateTime? date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Medical Record Form",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(height: 8),
        Text("Name: ${record['patientName'] ?? '-'}"),
        Text("IC/Passport: ${record['patientIC'] ?? '-'}"),
        SizedBox(height: 8),
        Text("Diagnosis:", style: TextStyle(fontWeight: FontWeight.w600)),
        Text(record['diagnosis'] ?? '-'),
        SizedBox(height: 8),
        Text("Medication Required:",
            style: TextStyle(fontWeight: FontWeight.w600)),
        Text(record['medication'] ?? '-'),
        SizedBox(height: 8),
        Text("Additional Notes:",
            style: TextStyle(fontWeight: FontWeight.w600)),
        Text(record['notes'] ?? '-'),
        if (date != null) ...[
          SizedBox(height: 8),
          Text('Created: ${date.toLocal().toString().substring(0, 16)}'),
        ],
      ],
    );
  }
}