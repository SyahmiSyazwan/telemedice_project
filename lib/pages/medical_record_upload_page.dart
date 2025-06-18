import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MedicalRecordUploadPage extends StatefulWidget {
  const MedicalRecordUploadPage({Key? key}) : super(key: key);

  @override
  State<MedicalRecordUploadPage> createState() =>
      _MedicalRecordUploadPageState();
}

class _MedicalRecordUploadPageState extends State<MedicalRecordUploadPage> {
  final _formKey = GlobalKey<FormState>();
  File? _selectedFile;
  String _selectedFileName = '';
  bool _isUploading = false;

  // Form fields
  final TextEditingController _patientEmailController = TextEditingController();
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _patientICController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _medicationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _showUploadForm = true;

  // For autocomplete
  List<Map<String, String>> userList = []; // [{'email': ..., 'name': ...}]
  List<String> emailList = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').get();
      final users = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'email': data['Email']?.toString() ?? '',
          'name': data['Name']?.toString() ?? '',
        };
      }).where((user) => user['email']!.isNotEmpty).toList();

      setState(() {
        userList = users;
        emailList = users.map((u) => u['email']!).toList();
      });
    } catch (e) {
      print('Error fetching users from Firestore: $e');
    }
  }

  void _onEmailSelected(String? selectedEmail) {
    final user = userList.firstWhere((u) => u['email'] == selectedEmail,
        orElse: () => {'name': ''});
    _patientNameController.text = user['name'] ?? '';
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _selectedFileName = result.files.single.name;
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null || _patientEmailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a file and enter patient email')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload file to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('medical_records')
          .child('${DateTime.now().millisecondsSinceEpoch}_$_selectedFileName');

      final uploadTask = await storageRef.putFile(_selectedFile!);

      // Only get the download URL if the upload succeeded
      if (uploadTask.state == TaskState.success) {
        final downloadUrl = await storageRef.getDownloadURL();

        // Save metadata to Firestore
        await FirebaseFirestore.instance.collection('medical_records').add({
          'patientEmail': _patientEmailController.text.trim(),
          'patientName': _patientNameController.text.trim(),
          'fileUrl': downloadUrl,
          'fileName': _selectedFileName,
          'uploadedAt': FieldValue.serverTimestamp(),
          'type': 'file',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medical record uploaded successfully')),
        );
        setState(() {
          _selectedFile = null;
          _selectedFileName = '';
          _patientEmailController.clear();
          _patientNameController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload failed: File could not be uploaded')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isUploading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('medical_records').add({
        'patientEmail': _patientEmailController.text.trim(),
        'patientName': _patientNameController.text.trim(),
        'patientIC': _patientICController.text.trim(),
        'diagnosis': _diagnosisController.text.trim(),
        'medication': _medicationController.text.trim(),
        'notes': _notesController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'type': 'form',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medical record created successfully')),
      );
      _patientEmailController.clear();
      _patientNameController.clear();
      _patientICController.clear();
      _diagnosisController.clear();
      _medicationController.clear();
      _notesController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Stack(
          children: [
            // Background design elements
            Positioned(
              left: -79,
              top: -66,
              child: Container(
                width: 200,
                height: 200,
                decoration: ShapeDecoration(
                  color: const Color(0x728FE1D7),
                  shape: OvalBorder(),
                ),
              ),
            ),
            Positioned(
              left: -10,
              top: -111,
              child: Container(
                width: 200,
                height: 200,
                decoration: ShapeDecoration(
                  color: const Color(0x728FE1D7),
                  shape: OvalBorder(),
                ),
              ),
            ),

            // Page Content
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with back button
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Upload Medical Record',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 30),

                    // Title
                    Center(
                      child: Text(
                        'Medical Record Upload',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 25,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Toggle between upload and form
                    Center(
                      child: SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment<bool>(
                            value: true,
                            label: Text('Upload File'),
                            icon: Icon(Icons.upload_file),
                          ),
                          ButtonSegment<bool>(
                            value: false,
                            label: Text('Fill Form'),
                            icon: Icon(Icons.edit_document),
                          ),
                        ],
                        selected: {_showUploadForm},
                        onSelectionChanged: (Set<bool> newSelection) {
                          setState(() {
                            _showUploadForm = newSelection.first;
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.selected)) {
                                return const Color(0xFF8FE1D7);
                              }
                              return Colors.white;
                            },
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 40),

                    // File Upload Widget or Form
                    _showUploadForm
                        ? _buildFileUploadWidget()
                        : _buildMedicalRecordForm(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileUploadWidget() {
    // Add autocomplete email
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildEmailAutocompleteField(),
        SizedBox(height: 16),
        _buildFormField(
          label: 'Patient Name',
          controller: _patientNameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter patient name';
            }
            return null;
          },
        ),
        SizedBox(height: 20),
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: const Color(0xFFE9F9F7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF8FE1D7), width: 1),
          ),
          child: _selectedFile == null
              ? InkWell(
                  onTap: _pickFile,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload,
                        size: 60,
                        color: const Color(0xFF8FE1D7),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Tap to upload medical record',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'PDF, DOC, JPG, PNG (max 10MB)',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.description,
                      size: 50,
                      color: const Color(0xFF0040DD),
                    ),
                    SizedBox(height: 16),
                    Text(
                      _selectedFileName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(height: 8),
                    TextButton(
                      onPressed: _pickFile,
                      child: Text(
                        'Choose different file',
                        style: TextStyle(
                          color: const Color(0xFF0040DD),
                        ),
                      ),
                    ),
                  ],
                ),
        ),

        SizedBox(height: 40),

        // Upload button
        ElevatedButton(
          onPressed: _isUploading ? null : _uploadFile,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8FE1D7),
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isUploading
              ? CircularProgressIndicator()
              : Text(
                  'Upload Medical Record',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildMedicalRecordForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEmailAutocompleteField(),
          SizedBox(height: 16),
          _buildFormField(
            label: 'Patient Name',
            controller: _patientNameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter patient name';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          _buildFormField(
            label: 'Patient IC / Passport Number',
            controller: _patientICController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter IC number';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          _buildFormField(
            label: 'Diagnosis',
            controller: _diagnosisController,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter diagnosis';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          _buildFormField(
            label: 'Medication Required',
            controller: _medicationController,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter required medication';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          _buildFormField(
            label: 'Additional Notes',
            controller: _notesController,
            maxLines: 4,
            validator: null,
          ),
          SizedBox(height: 40),
          ElevatedButton(
            onPressed: _isUploading ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8FE1D7),
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isUploading
                ? CircularProgressIndicator()
                : Text(
                    'Create Medical Record',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailAutocompleteField() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return emailList.where((String option) {
          return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        _patientEmailController.text = selection;
        _onEmailSelected(selection); // This autofills the name
      },
      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
        // Ensure controller stays in sync with the main one
        controller.text = _patientEmailController.text;
        controller.selection = TextSelection.collapsed(offset: controller.text.length);

        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Patient Email',
            filled: true,
            fillColor: const Color(0xFFE9F9F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter patient email';
            }
            if (!RegExp(r'.+@.+\..+').hasMatch(value)) {
              return 'Enter a valid email';
            }
            return null;
          },
          onEditingComplete: onEditingComplete,
          onChanged: (val) {
            _patientEmailController.text = val;
            // Check if the entered email exactly matches one in the list
            final user = userList.firstWhere(
              (u) => u['email'] == val,
              orElse: () => {'name': ''},
            );
            _patientNameController.text = user['name'] ?? '';
          },
        );
      },
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFE9F9F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: const Color(0xFF8FE1D7), width: 2),
            ),
            contentPadding: EdgeInsets.all(16),
          ),
          validator: validator,
        ),
      ],
    );
  }
}