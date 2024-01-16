import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/components/my_post_button.dart';
import 'package:practice_login/database/firestore.dart';
import 'package:practice_login/pages/chat/chat_page.dart';
import 'package:practice_login/pages/post/create_post.dart';
import 'package:practice_login/pages/profile.dart';
import 'package:practice_login/components/my_textfield.dart';
import 'package:practice_login/pages/stalking_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

class HomePage2 extends StatefulWidget {
  const HomePage2({super.key});

  @override
  State<HomePage2> createState() => _HomePage2();
}

// github token Juario
//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
class _HomePage2 extends State<HomePage2> {
  final FirestoreDatabase database = FirestoreDatabase();
  final TextEditingController newPostController = TextEditingController();
  final FirestoreDatabase _firestoreDatabase = FirestoreDatabase();
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  late Stream<QuerySnapshot> postsStream;
  List<PlatformFile>? _pickedFiles;

  @override
  void initState() {
    super.initState();
    postsStream = _firestoreDatabase.getPostsStream();
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
    /* final authService = Provider.of<AuthService>(context, listen: false); */
  }

  Future<void> addImages() async {
    try {
      final files = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png']
      );
      if (files != null && files.files.isNotEmpty) {
        setState(() {
          _pickedFiles = files.files;
        });
      }
      else {
        _pickedFiles = [];
      }
    } catch (e) {
      throw Exception(e);
    }
    goToCreate();
  }

  void goToCreate() {
    List<PlatformFile> imagesPicked = _pickedFiles!;
    setState(() {
      _pickedFiles = [];
    });
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return CreateNewPost(imagesPicked: imagesPicked);
        })
    );
  }

  void NavigatorDetails(
    String userEmail,
  ) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => StalkPage(userEmail: userEmail))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
                  padding: const EdgeInsets.only(left: 15),
                  alignment: Alignment.center,
                  child: Image.asset('images/Avatar1.png', height: 40)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatPage()),
              );
            },
          )
        ],
        backgroundColor: const Color.fromARGB(255, 124, 210, 231),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      child: MyTextField(
                        controller: newPostController,
                        hintText: "Create a post",
                        obscuretext: false,
                        disableInput: true
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) {
                                  return const CreateNewPost();
                                }
                            )
                        );
                      },
                    )
                  ),
                  Container(padding: const EdgeInsets.only(right: 20), child: IconButton(onPressed: addImages, icon: const Icon(Icons.photo, size: 30,)))
                ],
              ),
            ),
            StreamBuilder(
                stream: database.getPostsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
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

                  return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        List<dynamic> mediaReferences = post['MediaReferences'];
                        String message = post['PostMessage'];
                        Timestamp timestamp = post['TimeStamp'];
                        Timestamp postTimeStamp = posts[index]['TimeStamp'];
                        String formattedTimestamp = _firestoreDatabase
                            .formatPostTimeStamp(postTimeStamp);

                        return Padding(
                          padding: const EdgeInsets.all(10),
                          child: ListTile(
                            tileColor: Colors.white,
                            isThreeLine: true,
                            title: Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                trailing: const Text("try"),
                                leading: const CircleAvatar(
                                    radius: 20,
                                    backgroundImage:
                                        AssetImage('images/Avatar1.png')),
                                title: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        NavigatorDetails(post['UserEmail']);
                                      },
                                      child: Text('${post['UserFirstName']} ${post['UserLastName']}'),
                                    ),
                                    Text(
                                      formattedTimestamp,
                                      style: const TextStyle(fontSize: 10),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (message.isNotEmpty)
                                  Text(message, style: const TextStyle(fontSize: 16)),
                                if (mediaReferences.isNotEmpty)
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        for(String url in mediaReferences)
                                          Container(
                                            height: 300,
                                            width: 300,
                                            child: Image.network(url),
                                          )
                                      ],
                                    ),
                                  ),
                                const Divider(thickness: 1),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 5, bottom: 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          print("Tapped Like");
                                        },
                                        child: const Text("Like"),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          print("Tapped Comment");
                                        },
                                        child: const Text("Comment"),
                                      ),
                                      GestureDetector(
                                        onTap: () {
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
                              side: const BorderSide(
                                color: Colors.white,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      });
                })
          ],
        ),
      ),
    );
  }
}
