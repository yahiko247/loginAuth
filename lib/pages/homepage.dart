import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/pages/profile.dart';
import 'package:practice_login/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:practice_login/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage2 extends StatefulWidget{
  //testing http json placeholder from here =>
  const HomePage2 ({super.key});

  @override
  State<HomePage2> createState() => _HomePage2();
}

// github token Juario
//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
class _HomePage2 extends State<HomePage2> {

  List<dynamic> posts = [];

  @override
  void initState(){
    getPosts();
    super.initState();
  }

  Future<void> getPosts() async {
    var url = Uri.parse("https://jsonplaceholder.typicode.com/posts");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        posts = json.decode(response.body);
      });
    } else {
      throw Exception("Failed to load posts");
    }
  }
// => to here

  void signUserOut() {
    FirebaseAuth.instance.signOut();
    /* final authService = Provider.of<AuthService>(context, listen: false); */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              child: Container(
                  padding: const EdgeInsets.only(top: 10, left: 15),
                  child: Image.asset('images/Avatar1.png', height: 40)),
            ),
          ],
        ),
        actions: const [],
        backgroundColor: const Color.fromARGB(255, 124, 210, 231),
      ),
      body:posts.isEmpty
      ? const Center(child: CircularProgressIndicator() ,)
      : Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context,index){
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                          leading:Image.asset('images/Avatar1.png'),
                          title: Text(posts[index]["title"]),
                          subtitle: Column(
                            children: [
                              Text(posts[index]["body"]),
                                ButtonBar(
                                 alignment: MainAxisAlignment.center,
                                 mainAxisSize: MainAxisSize.max,
                                 children: [
                                  GestureDetector(
                                    onTap: (){
                                      print("Tapped Like");
                                    },
                                    child: const Text("Like"),
                                  ),
                                   GestureDetector(
                                       onTap: (){
                                         print("Tapped Comment");
                                       },
                                       child: const Text("Comment"),
                                   ),
                                   GestureDetector(
                                       onTap: (){
                                         print("Tapped Share");
                                       },
                                       child: const Text("Share"),
                                   ),
                                ],

                              )
                            ],
                          ),
                            shape: RoundedRectangleBorder(
                            side: const BorderSide(color: Colors.lightBlueAccent, width: 1),
                            borderRadius: BorderRadius.circular(5)
                          ),
                      ),
                    );
                  }
                ),
          )
      ),

      endDrawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text('About'),
              onTap: () {},
              contentPadding: const EdgeInsets.only(top: 50, left: 70),
            ),
            const ListTile(
              title: Text('Help'),
              contentPadding: EdgeInsets.only(left: 70),
            ),
            const ListTile(
              title: Text('Dark Mode'),
              contentPadding: EdgeInsets.only(left: 70),
            ),
            const ListTile(
              title: Text('Freelancer Mode'),
              contentPadding: EdgeInsets.only(left: 70),
            ),
            const ListTile(
              title: Text('Account Settings'),
              contentPadding: EdgeInsets.only(left: 70),
            ),
            ListTile(
              title: const Text('Log out'),
              onTap: () {
                // Add your logic for logging out
                signUserOut();
              },
              leading: const Icon(Icons.logout),
            ),
          ],
        ),
      ),
    );
  }
}
