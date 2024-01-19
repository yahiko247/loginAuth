import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:practice_login/components/post/post.dart';
import 'package:practice_login/database/firestore.dart';
import 'package:practice_login/pages/post/create_post.dart';
import 'package:practice_login/components/my_textfield.dart';
import 'package:practice_login/pages/stalking_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:practice_login/services/posts/posts_service.dart';


class ForPosts extends StatefulWidget{
  const ForPosts({super.key});

  @override
  State<ForPosts> createState() => _ForPosts();

}

class _ForPosts extends State<ForPosts>{
  final PostService _postService = PostService();
  final TextEditingController newPostController = TextEditingController();
  final FirestoreDatabase _firestoreDatabase = FirestoreDatabase();
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  List<PlatformFile>? _pickedFiles;
  final GlobalKey<_ForPosts> _refreshKey = GlobalKey<_ForPosts>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    newPostController.dispose();
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
    /* final authService = Provider.of<AuthService>(context, listen: false); */
  }

  Future<void> addFiles() async {
    try {
      final files = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.custom,
          allowedExtensions: ['jpg', 'png', 'mp4']
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
  Widget build(BuildContext context){
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 15),
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
                        Navigator.pushReplacement(
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
                Container(padding: const EdgeInsets.only(right: 20), child: IconButton(onPressed: addFiles, icon: const Icon(Icons.photo, size: 30,)))
              ],
            ),
          ),
          StreamBuilder(
              stream: _postService.getPostsStream(),
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

                return Container(
                  padding: EdgeInsets.only(top: 5),
                  color: Color.fromARGB(15, 0, 0, 0),
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        return Post(postData: posts[index]);
                      }),
                );
              })
        ],
      ),
    );
  }
}

