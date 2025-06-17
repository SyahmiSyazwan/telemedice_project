import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class MedicalRecordUploadPage extends StatefulWidget {
  const MedicalRecordUploadPage({Key? key}) : super(key: key);

  @override
  State<MedicalRecordUploadPage> createState() => _MedicalRecordUploadPageState();
}

class _MedicalRecordUploadPageState extends State<MedicalRecordUploadPage> {
  final _formKey = GlobalKey<FormState>();
  File? _selectedFile;
  String _selectedFileName = '';
  
  // Form fields
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _patientICController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _medicationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  // Toggle between upload and form
  bool _showUploadForm = true;

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

  void _uploadFile() {
    // Implement your file upload logic here
    if (_selectedFile != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File upload started')),
      );
      
      // Mock successful upload after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medical record uploaded successfully')),
        );
        
        // Clear selected file after upload
        setState(() {
          _selectedFile = null;
          _selectedFileName = '';
        });
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submitting medical record...')),
      );
      
      // Mock successful submission after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medical record created successfully')),
        );
        
        // Clear form fields
        _patientNameController.clear();
        _patientICController.clear();
        _diagnosisController.clear();
        _medicationController.clear();
        _notesController.clear();
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
            // Background design elements (similar to prescription page)
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
                          backgroundColor: MaterialStateProperty.resolveWith<Color>(
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
                    _showUploadForm ? _buildFileUploadWidget() : _buildMedicalRecordForm(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
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
          onPressed: _selectedFile != null ? _uploadFile : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8FE1D7),
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
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
            validator: null, // Optional field
          ),
          
          SizedBox(height: 40),
          
          // Submit form button
          ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8FE1D7),
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
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
  
  Widget _buildNavItem(String label, bool isActive, Color iconColor, Color textColor) {
    return Expanded(
      child: Container(
        width: 86,
        height: 49,
        decoration: ShapeDecoration(
          color: const Color(0xFF8FE1D7),
          shape: RoundedRectangleBorder(side: BorderSide(width: 1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 3),
            Icon(
              _getIconForLabel(label),
              size: 24,
              color: iconColor,
            ),
            SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontFamily: 'GT Walsheim Pro',
                fontWeight: FontWeight.w500,
                height: 1.50,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getIconForLabel(String label) {
    switch (label) {
      case 'Home':
        return Icons.home;
      case 'Search':
        return Icons.search;
      case 'Calendar':
        return Icons.calendar_today;
      case 'Message':
        return Icons.message;
      case 'Profile':
        return Icons.person;
      default:
        return Icons.circle;
    }
  }
}