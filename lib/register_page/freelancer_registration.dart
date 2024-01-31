import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:practice_login/Components/button_register.dart';
import 'package:practice_login/Components/my_textfield.dart';
import 'package:practice_login/Components/square_tile.dart';
import 'package:practice_login/onBoardPage/onboard.dart';
import 'package:practice_login/services/auth_service.dart';
import 'package:provider/provider.dart';

class FreelancerRegisterForm extends StatefulWidget {
  //final void Function()? onTap;
  const FreelancerRegisterForm({super.key/*, required this.onTap*/});

  @override
  State<FreelancerRegisterForm> createState() => _FreelancerRegisterFormState();
}

class Item {
  String id;
  String name;

  Item(this.id, this.name);
}

class _FreelancerRegisterFormState extends State<FreelancerRegisterForm> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var priceController = TextEditingController();
  String selectedRateType = 'HR';

  String response = "Null";
  List<Item> data = [];

  createItem() async {
    var dataStr = jsonEncode({
      "command": "add_freelancer",
      "user_id": FirebaseAuth.instance.currentUser!.uid,
      "firstname": firstNameController.text,
      "lastname" : lastNameController.text,
      "email": emailController.text,

    });
    var url = 'http://192.168.1.17:80/freelancerreg.php?data=$dataStr';
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
  addPrice() async {
    var dataStr = jsonEncode({
      "command": "add_price",
      "user_id": FirebaseAuth.instance.currentUser!.uid,
      "priceRate_type" : selectedRateType,
      "price" : double.tryParse(priceController.text) ?? 0.0,
    });
    var url = 'http://192.168.1.17:80/price.php?data=$dataStr';
    var result = await http.get(Uri.parse(url));
    setState(() {
      response = result.body;
      priceController.clear();
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
      await authService.signUp(emailController.text, passwordController.text, firstNameController.text, myLastName,true);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OnBoard()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
    createItem();
    addPrice();
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
                      'Sign up as a freelancer now.',
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

                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        children: [
                          Flexible(
                            flex:2,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: TextField(
                                keyboardType: TextInputType.number,
                                enabled: true,
                                controller: priceController,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                obscureText: false,
                                maxLength: 4,
                                decoration: InputDecoration(
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey.shade400),
                                    ),
                                    fillColor: Colors.grey.shade200,
                                    filled: true,
                                    hintText: ("Enter Price"),
                                    hintStyle: TextStyle(color: Colors.grey[500])),
                              ),
                            ),
                          ),
                          DropdownButton<String>(
                            value: selectedRateType,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedRateType = newValue!;
                              });
                            },
                            items: <String>['HR', 'DAILY']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
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
                          onTap:(){
                            //widget.onTap;
                          },


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
