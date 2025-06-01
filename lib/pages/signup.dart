import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:telemedice_project/auth/database.dart';
import 'package:telemedice_project/auth/shared.pref.dart';
import 'package:random_string/random_string.dart';
import 'package:telemedice_project/pages/bottomNav.dart';
import 'package:telemedice_project/pages/login.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  String email = "", password = "", name = "";
  TextEditingController namecontroller = new TextEditingController();
  TextEditingController passwordcontroller = new TextEditingController();
  TextEditingController mailcontroller = new TextEditingController();

  final _formkey = GlobalKey<FormState>();

  registration() async {
    if (password != null) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        ScaffoldMessenger.of(context).showSnackBar((SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              "Registered Successfully",
              style: TextStyle(fontSize: 20.0),
            ))));
        String uid = FirebaseAuth.instance.currentUser!.uid;
        Map<String, dynamic> addUserInfo = {
          "Name": namecontroller.text,
          "Email": mailcontroller.text,
          "Id": uid,
        };
        await DatabaseMethods().addUserDetail(addUserInfo, uid);
        await SharedPreferenceHelper().saveUserName(namecontroller.text);
        await SharedPreferenceHelper().saveUserEmail(mailcontroller.text);
        await SharedPreferenceHelper().saveUserId(uid);

        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BottomNavBar()));
      } on FirebaseException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Password Provided is too Weak",
                style: TextStyle(fontSize: 18.0),
              )));
        } else if (e.code == "email-already-in-use") {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Account Already exists",
                style: TextStyle(fontSize: 18.0),
              )));
        }
      }
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
              Container(
                child: Column(
                  children: [
                    Center(
                      child: Row(
                        children: [
                          Image.asset('images/logo.png', width: 80),
                          const SizedBox(width: 10),
                          Column(
                            children: [
                              const SizedBox(height: 10),
                              const Text(
                                'MediTap',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1D3557),
                                ),
                              ),
                              const Text(
                                'Healthcare at your fingertips -\ntap and connect',
                                textAlign: TextAlign.left,
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 1.8,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20)),
                        child: Form(
                          key: _formkey,
                          child: Column(
                            children: [
                              SizedBox(height: 30),
                              Text(
                                "Sign up",
                              ),
                              SizedBox(height: 30),
                              TextFormField(
                                controller: namecontroller,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter Name';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                    hintText: 'Name',
                                    prefixIcon: Icon(Icons.person_outlined)),
                              ),
                              SizedBox(height: 30),
                              TextFormField(
                                controller: mailcontroller,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter E-mail';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                    hintText: 'Email',
                                    prefixIcon: Icon(Icons.email_outlined)),
                              ),
                              SizedBox(height: 30),
                              TextFormField(
                                controller: passwordcontroller,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter Password';
                                  }
                                  return null;
                                },
                                obscureText: true,
                                decoration: InputDecoration(
                                    hintText: 'Password',
                                    prefixIcon: Icon(Icons.password_outlined)),
                              ),
                              SizedBox(height: 60),
                              GestureDetector(
                                onTap: () async {
                                  if (_formkey.currentState!.validate()) {
                                    setState(() {
                                      email = mailcontroller.text;
                                      name = namecontroller.text;
                                      password = passwordcontroller.text;
                                    });
                                  }
                                  registration();
                                },
                                child: Material(
                                  elevation: 5.0,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    width: 200,
                                    decoration: BoxDecoration(
                                        color: Color(0Xffff5722),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Center(
                                      child: Text(
                                        "SIGN UP",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 70),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Login()));
                      },
                      child: Text(
                        "Already have an account? Login",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
