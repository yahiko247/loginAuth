import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/pages/profile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage2 extends StatefulWidget{
  //testing http json placeholder from here =>
  const HomePage2 ({super.key});

  @override
  State<HomePage2> createState() => _HomePage2();
}

// github token
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
        actions: const [
        ],
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
                        title: Text(posts[index]["title"]),
                        subtitle: Text(posts[index]["body"]),
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
            ListTile(
              title: const Text('Help'),
              contentPadding: const EdgeInsets.only(left: 70),
            ),
            ListTile(
              title: const Text('Dark Mode'),
              contentPadding: const EdgeInsets.only(left: 70),
            ),
            ListTile(
              title: const Text('Freelancer Mode'),
              contentPadding: const EdgeInsets.only(left: 70),
            ),
            ListTile(
              title: const Text('Account Settings'),
              contentPadding: const EdgeInsets.only(left: 70),
            ),
            ListTile(
              title: const Text('Log out'),
              onTap: () {
                // Add your logic for logging out
                signUserOut();
              },
              leading: Icon(Icons.logout),
            ),
          ],
        ),
      ),
    );
  }
}
