import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/Components/my_list_tile.dart';
import 'package:practice_login/Components/my_post_button.dart';
import 'package:practice_login/database/firestore.dart';
import 'package:practice_login/pages/chat_page.dart';
import 'package:practice_login/pages/profile.dart';
import 'package:practice_login/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:practice_login/services/auth_service.dart';
import 'package:practice_login/Components/my_textfield.dart';

class HomePage2 extends StatefulWidget {
  //testing http json placeholder from here =>
  const HomePage2({super.key});

  @override
  State<HomePage2> createState() => _HomePage2();
}

// github token Juario
//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
class _HomePage2 extends State<HomePage2> {

  final FirestoreDatabase database = FirestoreDatabase();
  final TextEditingController newPostController = TextEditingController();

  void postMessage(){
    if(newPostController.text.isNotEmpty){
      String message = newPostController.text;
      database.addPost(message);
    }

    newPostController.clear();
  }
/*
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
// => to here*/

  void signUserOut() {
    FirebaseAuth.instance.signOut();
    /* final authService = Provider.of<AuthService>(context, listen: false); */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          flexibleSpace: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
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
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 25,right: 25),
              child: Row(
                children: [
                  Expanded(
                    child: MyTextField(
                        controller: newPostController,
                        hintText: "Say Something",
                        obscuretext: false,
                    ),
                  ),
                  PostButton(
                      onTap: postMessage
                  )
                ],
              ),
            ),
            StreamBuilder(
                stream: database.getPostsStream(),
                builder: (context,snapshot){
                  if (snapshot.connectionState == ConnectionState.waiting){
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final posts = snapshot.data!.docs;

                  if (snapshot.data == null || posts.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(25),
                        child: Text("No posts... Post Something"),
                      ),
                    );
                  }
                  return Expanded(
                      child: ListView.builder(
                          itemCount: posts.length,
                          itemBuilder: (context,index){
                            final post = posts[index];

                            String message = post['PostMessage'];
                            String userEmail = post['UserEmail'];
                            Timestamp timestamp = post['TimeStamp'];

                            return MyListTile(
                                title: message,
                                subTitle: const Column(

                                ),
                            );
                            /*
                            return Padding(
                              padding: const EdgeInsets.all(10),
                              child: ListTile(
                                tileColor: Colors.white,
                                isThreeLine: true,
                                leading:Image.asset('images/Avatar1.png'),
                                trailing: Text("try"),
                                title: Text(userEmail),
                                subtitle: Column(
                                  children: [
                                    Text(message),
                                    const Divider(
                                        thickness: 1
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5,bottom: 5),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: (){
                                                print("Tapped Like");
                                              },
                                              child: const Text("Like"),
                                            ),
                                          ),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: (){
                                                print("Tapped Comment");
                                              },
                                              child: const Text("Comment"),
                                            ),
                                          ),
                                          GestureDetector(
                                              onTap: (){
                                                print("Tapped Share");
                                              },
                                              child: const Text("Share"),
                                            ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                  shape: RoundedRectangleBorder(
                                  side: const BorderSide(color: Colors.white,width: 1,),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );*/
                          }

                      ),
                  );
                }
            )
          ],
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
                title: const Text('Chats'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ChatPage()));
                },
                contentPadding: const EdgeInsets.only(left: 70),
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
