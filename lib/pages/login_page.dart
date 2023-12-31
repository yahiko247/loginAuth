import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/Components/my_button.dart';
import 'package:practice_login/Components/my_textfield.dart';
import 'package:practice_login/Components/square_tile.dart';
import 'package:practice_login/register_page/register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text editing  controllers
  final emailcontroller = TextEditingController();

  final passwordcontroller = TextEditingController();

  //sign user in method
  void signUserIn() async {
    //loading circle
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });

    //try sign in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailcontroller.text, password: passwordcontroller.text);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found that email/password');
      } else if (e.code == 'wrong-password') {
        print('wrong password');
      }
    }

    //pop the circle
    Navigator.pop(context);
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
                      const SizedBox(height: 130),

                      Text(
                        'Welcome to GigGabay',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16,
                        ),
                      ),

                      //logo

                      Image.asset(
                        'images/av2.png',
                        height: 200,
                      ),

                      //usename textfield
                      MyTextField(
                        controller: emailcontroller,
                        hintText: 'Email',
                        obscuretext: false,
                      ),

                      const SizedBox(height: 10),

                      //password textfield
                      MyTextField(
                        controller: passwordcontroller,
                        hintText: 'Password',
                        obscuretext: true,
                      ),

                      const SizedBox(height: 10),
                      //forgot password
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('Forgot Password?',
                                style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      //sign button
                      MyButton(
                        onTap: signUserIn,
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
                                  builder: (context) => const RegisterForm(),
                                ),
                              );
                            },
                            child: SizedBox(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'Register Now',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ]),
              ),
            ),
          ],
        ));
  }
}
