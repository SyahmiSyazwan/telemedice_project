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
    }
  }

  uploadItem() async {
    if (selectedImage != null) {
      String addId = randomAlphaNumeric(10);
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child("profileImages").child(addId);
      final UploadTask task = firebaseStorageRef.putFile(selectedImage!);
      var downloadUrl = await (await task).ref.getDownloadURL();
      await SharedPreferenceHelper().saveUserProfile(downloadUrl);
      profile = downloadUrl;
      setState(() {});
    }
  }

  getSharedPrefs() async {
    final user = FirebaseAuth.instance.currentUser;

    // Fallback if SharedPreferences is empty
    if (user != null) {
      name = await SharedPreferenceHelper().getUserName() ?? user.displayName;
      email = await SharedPreferenceHelper().getUserEmail() ?? user.email;
    }

    profile = await SharedPreferenceHelper().getUserProfile();

    name ??= user?.displayName ?? "User Name";
    email ??= user?.email ?? "user@email.com";

    if ((await SharedPreferenceHelper().getUserName()) == null) {
      await SharedPreferenceHelper().saveUserName(name!);
    }
    if ((await SharedPreferenceHelper().getUserEmail()) == null) {
      await SharedPreferenceHelper().saveUserEmail(email!);
    }

    nameController.text = name!;
    emailController.text = email!;
    setState(() {
      _isLoading = false;
    });
  }

  Widget profileInfoTile(IconData icon, String title,
      TextEditingController controller, VoidCallback onUpdate) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        elevation: 2.0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.black),
              const SizedBox(width: 20.0),
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: title,
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: onUpdate,
                child: const Text("Update"),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                ),
              ),
            ],
          ),
        ),
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
                                  child: Material(
                                    elevation: 10.0,
                                    borderRadius: BorderRadius.circular(80),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(80),
                                      child: GestureDetector(
                                        onTap: getImage,
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
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        profileInfoTile(Icons.person, "Name", nameController,
                            () async {
                          await SharedPreferenceHelper()
                              .saveUserName(nameController.text);
                          setState(() {
                            name = nameController.text;
                          });
                        }),
                        const SizedBox(height: 30.0),
                        profileInfoTile(Icons.email, "Email", emailController,
                            () async {
                          await SharedPreferenceHelper()
                              .saveUserEmail(emailController.text);
                          setState(() {
                            email = emailController.text;
                          });
                        }),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 20.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.exit_to_app,
                        color: Colors.white, size: 25),
                    label: const Text(
                      "Log Out",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
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
                            "Are you sure log out from this account?",
                            style: TextStyle(fontSize: 18),
                          ),
                          actionsPadding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
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
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        side: const BorderSide(
                                            color: Colors.black),
                                      ),
                                      child: const Text(
                                        "Cancel",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 12),
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        side:
                                            const BorderSide(color: Colors.red),
                                      ),
                                      child: const Text(
                                        "Yes",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
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
