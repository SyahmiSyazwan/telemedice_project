import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:telemedice_project/auth/database.dart';
import 'package:telemedice_project/auth/shared.pref.dart';
import 'package:telemedice_project/pages/bottom_nav.dart';
import 'package:telemedice_project/pages/login.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  String email = "",
      password = "",
      name = "",
      selectedRole = "Patient",
      staffId = "";
  TextEditingController namecontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController mailcontroller = TextEditingController();
  TextEditingController staffIdController = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  registration() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content:
            Text("Registered Successfully", style: TextStyle(fontSize: 18)),
      ));

      String uid = userCredential.user!.uid;

      Map<String, dynamic> addUserInfo = {
        "Name": namecontroller.text,
        "Email": mailcontroller.text,
        "Id": uid,
        "Role": selectedRole,
        if (selectedRole == "Doctor") "StaffId": staffIdController.text,
      };

      if (selectedRole == "Doctor") {
        await SharedPreferenceHelper().saveStaffId(staffIdController.text);
      }

      await DatabaseMethods().addUserDetail(addUserInfo, uid);
      await SharedPreferenceHelper().saveUserName(namecontroller.text);
      await SharedPreferenceHelper().saveUserEmail(mailcontroller.text);
      await SharedPreferenceHelper().saveUserId(uid);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNavBar()),
      );
    } on FirebaseAuthException catch (e) {
      String message = "An error occurred";
      if (e.code == 'weak-password') {
        message = "Password Provided is too Weak";
      } else if (e.code == "email-already-in-use") {
        message = "Account Already Exists";
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(message, style: TextStyle(fontSize: 18)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Logo
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('images/logo.png', width: 80),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SizedBox(height: 10),
                        Text(
                          'MediTap',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D3557),
                          ),
                        ),
                        Text(
                          'Healthcare at your fingertips -\ntap and connect',
                          style: TextStyle(fontSize: 12, color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        const Text("Account Registration",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: namecontroller,
                          validator: (value) =>
                              value!.isEmpty ? 'Please Enter Name' : null,
                          decoration: const InputDecoration(
                            hintText: 'Name',
                            prefixIcon: Icon(Icons.person_outlined),
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: mailcontroller,
                          validator: (value) =>
                              value!.isEmpty ? 'Please Enter E-mail' : null,
                          decoration: const InputDecoration(
                            hintText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: passwordcontroller,
                          obscureText: true,
                          validator: (value) =>
                              value!.isEmpty ? 'Please Enter Password' : null,
                          decoration: const InputDecoration(
                            hintText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                        ),
                        const SizedBox(height: 30),
                        DropdownButtonFormField<String>(
                          value: ['Patient', 'Doctor'].contains(selectedRole)
                              ? selectedRole
                              : null,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person_pin),
                            border: OutlineInputBorder(),
                            labelText: 'Role',
                          ),
                          items: ['Patient', 'Doctor']
                              .map((role) => DropdownMenuItem<String>(
                                    value: role,
                                    child: Text(role),
                                  ))
                              .toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedRole = newValue!;
                            });
                          },
                        ),
                        if (selectedRole == "Doctor")
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: TextFormField(
                              controller: staffIdController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Staff ID';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                hintText: 'Staff ID',
                                prefixIcon: Icon(Icons.badge_outlined),
                              ),
                            ),
                          ),
                        const SizedBox(height: 30),
                        GestureDetector(
                          onTap: () {
                            if (_formkey.currentState!.validate()) {
                              setState(() {
                                email = mailcontroller.text.trim();
                                name = namecontroller.text.trim();
                                password = passwordcontroller.text.trim();
                              });
                              registration();
                            }
                          },
                          child: Material(
                            elevation: 5.0,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              width: 200,
                              decoration: BoxDecoration(
                                color: Colors.teal.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.person_add, color: Colors.black),
                                  SizedBox(width: 10),
                                  Text(
                                    "SIGN UP",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Login()));
                  },
                  child: const Text(
                    "Already Have an Account? Login",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
