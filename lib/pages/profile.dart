import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:telemedice_project/auth/auth.dart';
import 'package:telemedice_project/auth/shared.pref.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? profile, name, email;
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  bool _isLoading = true;

  late TextEditingController nameController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    getSharedPrefs();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage = File(image.path);
      setState(() {});
      await uploadItem();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile picture updated!")),
      );
    }
  }

  uploadItem() async {
    if (selectedImage != null) {
      String addId = randomAlphaNumeric(10);
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child("profileImages").child(addId);
      UploadTask task = firebaseStorageRef.putFile(selectedImage!);
      TaskSnapshot snapshot = await task;

      var downloadUrl = await snapshot.ref.getDownloadURL();
      await SharedPreferenceHelper().saveUserProfile(downloadUrl);

      setState(() {
        profile = downloadUrl;
      });
    }
  }

  getSharedPrefs() async {
    final user = FirebaseAuth.instance.currentUser;

    // Try loading from SharedPreferences first
    name = await SharedPreferenceHelper().getUserName();
    email = await SharedPreferenceHelper().getUserEmail();
    profile = await SharedPreferenceHelper().getUserProfile();

    // Fallback to Firebase if missing
    if (user != null) {
      await user.reload();
      name ??= user.displayName ?? "UserName";
      email ??= user.email ?? "user@email.com";

      // Save fallback values if SharedPrefs are empty
      if (await SharedPreferenceHelper().getUserName() == null) {
        await SharedPreferenceHelper().saveUserName(name!);
      }
      if (await SharedPreferenceHelper().getUserEmail() == null) {
        await SharedPreferenceHelper().saveUserEmail(email!);
      }
    }

    nameController.text = name!;
    emailController.text = email!;
    setState(() {
      _isLoading = false;
    });
  }

  Widget profileInfoTile(
    IconData icon,
    String title,
    TextEditingController controller,
    VoidCallback? onSave, {
    bool showUpdateButton = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 30.0,
            color: Colors.teal,
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                labelText: title,
                labelStyle: const TextStyle(fontSize: 18.0),
                border: const OutlineInputBorder(),
                suffixIcon: showUpdateButton
                    ? IconButton(
                        icon:
                            const Icon(Icons.check_circle, color: Colors.teal),
                        onPressed: onSave,
                        tooltip: 'Update',
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.only(
                                  top: 45.0, left: 20.0, right: 20.0),
                              height: MediaQuery.of(context).size.height / 3.8,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Colors.teal.shade100,
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.elliptical(
                                      MediaQuery.of(context).size.width, 105.0),
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                const SizedBox(height: 50),
                                Center(
                                  child: Text(
                                    name ?? "User Name",
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Center(
                                  child: Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      Material(
                                        elevation: 10.0,
                                        borderRadius: BorderRadius.circular(80),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(80),
                                          child: selectedImage != null
                                              ? Image.file(
                                                  selectedImage!,
                                                  height: 160,
                                                  width: 160,
                                                  fit: BoxFit.cover,
                                                )
                                              : profile != null
                                                  ? Image.network(
                                                      profile!,
                                                      height: 160,
                                                      width: 160,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Image.asset(
                                                      "images/boy.jpeg",
                                                      height: 160,
                                                      width: 160,
                                                      fit: BoxFit.cover,
                                                    ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: getImage,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: Colors.grey.shade300),
                                            ),
                                            child: const Icon(
                                              Icons.camera_alt,
                                              size: 22,
                                              color: Colors.teal,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        profileInfoTile(
                          Icons.person,
                          "Name",
                          nameController,
                          () async {
                            await SharedPreferenceHelper()
                                .saveUserName(nameController.text);
                            setState(() {
                              name = nameController.text;
                            });
                          },
                          showUpdateButton: true,
                        ),
                        const SizedBox(height: 20.0),
                        profileInfoTile(
                          Icons.email,
                          "Email",
                          emailController,
                          null,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 22.0, vertical: 20.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.exit_to_app,
                        color: Colors.black, size: 23),
                    label: const Text(
                      "Log Out",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () async {
                      bool? confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text(
                            "LOGOUT",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 25,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          content: const Text(
                            textAlign: TextAlign.center,
                            "Are you sure want to log out from this account?",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          actionsPadding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 18),
                          actions: [
                            SizedBox(
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 12),
                                        backgroundColor: Colors.teal.shade100,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        "Cancel",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 12),
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        "Yes",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await AuthMethods().signOut();
                        await SharedPreferenceHelper().clear();
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
