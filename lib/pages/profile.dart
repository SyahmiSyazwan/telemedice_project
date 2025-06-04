import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:telemedice_project/auth/auth.dart';
import 'package:telemedice_project/auth/database.dart';
import 'package:telemedice_project/auth/shared.pref.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

// Profile state class
class _ProfileState extends State<Profile> {
  String? name, email;
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
    _loadUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    name = await SharedPreferenceHelper().getUserName();
    email = await SharedPreferenceHelper().getUserEmail();

    if (user != null) {
      await user.reload();
      name ??= user.displayName ?? "UserName";
      email ??= user.email ?? "user@email.com";

      if (await SharedPreferenceHelper().getUserName() == null) {
        await SharedPreferenceHelper().saveUserName(name!);
      }
      if (await SharedPreferenceHelper().getUserEmail() == null) {
        await SharedPreferenceHelper().saveUserEmail(email!);
      }
    }

    nameController.text = name!;
    emailController.text = email!;
    setState(() => _isLoading = false);
  }

  // Get image from camera or gallery
  Future<void> _getImage(ImageSource source) async {
    final pickedImage = await _picker.pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        selectedImage = File(pickedImage.path);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile picture updated!")),
      );
    }
  }

  // Confirm delete account dialog
  Future<void> _confirmDeleteAccount() async {
    final passwordController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("DELETE ACCOUNT",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "To delete account, please enter your password for verification",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.black),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Cancel",
                      style: TextStyle(color: Colors.black, fontSize: 20)),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Delete",
                      style: TextStyle(color: Colors.black, fontSize: 20)),
                ),
              ),
            ],
          )
        ],
      ),
    );

    if (confirmed == true) {
      final password = passwordController.text.trim();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null && user.email != null && password.isNotEmpty) {
        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );

        try {
          // Reauthenticate
          await user.reauthenticateWithCredential(cred);

          // Delete account
          await DatabaseMethods().deleteUserDetail(user.uid);
          await user.delete();
          await SharedPreferenceHelper().clear();

          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        } on FirebaseAuthException catch (e) {
          String errorMsg = "Failed to Delete Account";
          if (e.code == 'wrong-password') {
            errorMsg = "Wrong password. Please try again";
          } else if (e.code == 'requires-recent-login') {
            errorMsg = "Please Login Again and Try Deleting Your Account";
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg)),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password Cannot be Empty")),
        );
      }
    }
  }

  // Update user name
  Future<void> _updateUserName() async {
    final newName = nameController.text.trim();
    if (newName.isEmpty) return;

    await SharedPreferenceHelper().saveUserName(newName);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.updateDisplayName(newName);
      await user.reload();

      await DatabaseMethods().addUserDetail({'Name': newName}, user.uid);
    }

    setState(() => name = newName);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Username updated successfully!")),
    );
  }

  // Profile info tile widget
  Widget _profileInfoTile({
    required IconData icon,
    required String title,
    required TextEditingController controller,
    VoidCallback? onSave,
    bool showUpdateButton = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 30.0, color: Colors.teal),
          const SizedBox(width: 16.0),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: title,
                border: const OutlineInputBorder(),
                suffixIcon: showUpdateButton
                    ? IconButton(
                        icon: const Icon(Icons.upload, color: Colors.teal),
                        onPressed: onSave,
                      )
                    : null,
              ),
              style:
                  const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // Confirm logout dialog
  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("LOGOUT",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        content: const Text(
          "Are you sure want to log out from this account?",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Cancel",
                      style: TextStyle(color: Colors.black, fontSize: 20)),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Yes",
                      style: TextStyle(color: Colors.black, fontSize: 20)),
                ),
              ),
            ],
          )
        ],
      ),
    );

    if (confirmed == true) {
      await AuthMethods().signOut();
      await SharedPreferenceHelper().clear();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  // Show image source dialog
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('SELECT IMAGE',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: Colors.black,
              ),
              title: const Text('Take A Photo',
                  style: TextStyle(fontSize: 18, color: Colors.black)),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.black),
              title: const Text(
                'Choose From Gallery',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Build method to render the profile page
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
                              height: MediaQuery.of(context).size.height / 3.8,
                              width: double.infinity,
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
                                        color: Colors.black87),
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
                                          onTap: _showImageSourceDialog,
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
                        const SizedBox(height: 20),
                        _profileInfoTile(
                          icon: Icons.person,
                          title: "Name",
                          controller: nameController,
                          onSave: _updateUserName,
                          showUpdateButton: true,
                        ),
                        const SizedBox(height: 20),
                        _profileInfoTile(
                          icon: Icons.email,
                          title: "Email",
                          controller: emailController,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: 250,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 22.0, vertical: 10.0),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.delete_forever,
                                color: Colors.black, size: 25),
                            label: const Text(
                              "Delete Account",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade100,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            onPressed: _confirmDeleteAccount,
                          ),
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
                        color: Colors.black, size: 25),
                    label: const Text(
                      "Log Out",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: _confirmLogout,
                  ),
                ),
              ],
            ),
    );
  }
}
