import 'package:flutter/material.dart';
import 'package:practice_login/Components/button_register.dart';
import 'package:practice_login/Components/my_button.dart';
import 'package:practice_login/Components/my_textfield.dart';
import 'package:practice_login/Components/square_tile.dart';
import 'package:practice_login/pages/login_page.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  var fnameController = TextEditingController();
  var lnameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  void RegisterUser() {}

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

                    //First Name

                    MyTextField(
                      controller: fnameController,
                      hintText: 'First Name',
                      obscuretext: false,
                    ),

                    const SizedBox(height: 10),

                    MyTextField(
                      controller: lnameController,
                      hintText: 'Last Name',
                      obscuretext: false,
                    ),
                    const SizedBox(height: 10),

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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
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
                          onTap: () async {
                            var result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          child: SizedBox(
                            child: Container(
                                padding: EdgeInsets.all(16),
                                child: Text('Sign Up',
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
