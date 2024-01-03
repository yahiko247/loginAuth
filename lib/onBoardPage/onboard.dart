import 'package:flutter/material.dart';
import 'package:practice_login/pages/auth_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoard extends StatefulWidget {
  const OnBoard({super.key});

  @override
  State<OnBoard> createState() => _OnBoard();
}

class _OnBoard extends State<OnBoard> {
  final controller = PageController();

  void GetStarted() {}

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller,
        children: [
          Container(
            color: Colors.grey[300],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Get things done with GiGabay',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent ultricies sem at iaculis venenatis.',
                    style: TextStyle(fontSize: 15),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          ),
          ListView(
            children: [
            Container(
              color: Colors.grey[300],
              child: Center(
                  child: Column(children: [
                    const SizedBox(
                  height: 100,
                ),
                    Image.asset(
                  'images/Avatar1.png',
                  height: 250,
                ),
                    const SizedBox(
                  height: 80,
                ),
                    const Text('Get things done with GiGabay',
                    style: TextStyle(fontSize: 20)),
                    const SizedBox(
                  height: 10,
                ),
                    const Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                      child: Text(
                    'GiGabay is a central platform that provides freelancers equal opportunites to showcase their portfolios and reach their target audiences.',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                  ),
                ),
                    const SizedBox(
                    height: 200,
                ),
                    Container(
                      height: 40,
                      width: 300,
                      color: const Color.fromARGB(255, 124, 210, 231),
                      child: const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                        'Get Started!!',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                    ),
                  ),
                )
              ])),
            ),
          ]
          ),
          Container(
            color: Colors.grey[300],
            child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AuthPage()));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 300),
                        child: Container(
                          height: 40,
                          width: 300,
                          color: const Color.fromARGB(2255, 124, 210, 231),
                          child: const Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              'Lets Go',
                              style: TextStyle(color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 300),
                      child: Text('Already have Account ? Sign In'),
                    )
                  ]),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        color: Colors.grey[300],
        padding: const EdgeInsets.symmetric(
          horizontal: 10.0,
        ),
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              child: const Text('Skip'),
              onPressed: () => controller.jumpToPage(2),
            ),
            Center(
              child: SmoothPageIndicator(controller: controller, count: 3),
            ),
            TextButton(
              child: const Text('Next'),
              onPressed: () {
                controller.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut);
              },
            )
          ],
        ),
      ),
    );
  }
}
