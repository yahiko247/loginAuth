import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/Components/button_register.dart';
import 'package:practice_login/Components/my_textfield.dart';
import 'package:practice_login/Components/square_tile.dart';
import 'package:practice_login/onBoardPage/onboard.dart';
import 'package:practice_login/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
class RegisterForm extends StatefulWidget {
  final void Function()? onTap;
  const RegisterForm({super.key, required this.onTap});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}
class Item {
  String id;
  String name;

  Item(this.id, this.name);
}

class _RegisterFormState extends State<RegisterForm> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();


  String response = "Null";
  List<Item> data = [];

  createItem() async {
    var dataStr = jsonEncode({
      "command": "add_clients",
      "user_id": FirebaseAuth.instance.currentUser!.uid,
      "firstname": firstNameController.text,
      "lastname" : lastNameController.text,
      "email": emailController.text,

    });
    var url = 'http://192.168.1.17:80/userreg.php?data=$dataStr';
    var result = await http.get(Uri.parse(url));
    setState(() {
      response = result.body;
      lastNameController.clear();
      firstNameController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
    });
  }

 void RegisterUser() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("password do not match")),
      );
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);

    String? myLastName = lastNameController.text;

    try {
      await authService.signUp(emailController.text, passwordController.text, firstNameController.text, myLastName, false);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OnBoard()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
    createItem();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: ListView(
        children: [
          SafeArea(
            child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),

                    //logo
                    const Icon(
                      Icons.lock,
                      size: 100,
                    ),

                    const SizedBox(height: 50),

                    //wellcomeback
                    Text(
                      'Sign up for your account now.',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 25),

                    //usename textfield
                    MyTextField(
                      controller: emailController,
                      hintText: 'Email',
                      obscuretext: false,
                    ),

                    const SizedBox(height: 10),

                    //password textfield
                    MyTextField(
                      controller: passwordController,
                      hintText: 'Password',
                      obscuretext: true,
                    ),

                    const SizedBox(height: 10),

                    //confirm password
                    MyTextField(
                      controller: confirmPasswordController,
                      hintText: 'Confirm Password',
                      obscuretext: true,
                    ),

                    const SizedBox(height: 10),

                    MyTextField(
                      controller: firstNameController,
                      hintText: 'First Name',
                      obscuretext: false,
                    ),

                    const SizedBox(height: 10),

                    MyTextField(
                      controller: lastNameController,
                      hintText: 'Last Name',
                      obscuretext: false,
                    ),

                    const SizedBox(height: 25),

                    //sign button
                    MyButtonTwo(
                      onTap: RegisterUser,
                    ),

                    const SizedBox(height: 50),

                    //or continue with
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: Colors.grey[400],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              'Or continue with',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: Colors.grey[400],
                            ),
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),

                    //Google + apple  sign buttons
                    Container(
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //google button
                          SquareTile(imagPath: 'images/google.png'),

                          SizedBox(width: 25),

                          //apple
                          SquareTile(imagPath: 'images/apple.png'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),
                    //not a member? register now
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Not a member?',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: SizedBox(
                            child: Container(
                                padding: const EdgeInsets.all(16),
                                child: const Text('Sign Up',
                                    style: TextStyle(color: Colors.blue))),
                          ),
                        ),
                      ],
                    )
                  ]),
            ),
          ),
        ],
      ),
    );
  }
}
