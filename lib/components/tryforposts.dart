import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:practice_login/components/post/post.dart';
import 'package:practice_login/database/firestore.dart';
import 'package:practice_login/pages/post/create_post.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:practice_login/services/posts/posts_service.dart';

import '../pages/userstalkingpage.dart';


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
            builder: (context) => UserStalkPage(userEmail: userEmail))
    );
  }

  @override
  Widget build(BuildContext context){
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            color: const Color.fromARGB(15, 0, 0, 0),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child:  Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(7), bottomLeft: Radius.circular(7)),
                color: Colors.white
              ),
              padding: const EdgeInsets.only(top: 15, bottom: 20),
              child: Row(
                children: [
                  Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 25),
                        child: TextField(
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
                          readOnly: true,
                          controller: newPostController,
                          decoration: InputDecoration(
                            hintText: 'Create a post',
                            focusColor: Colors.black,
                            contentPadding: const EdgeInsets.all(13),
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(8.0)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: const BorderSide(color: Colors.grey)),
                          ),
                        ),
                      )
                  ),
                  Container(
                      padding: const EdgeInsets.only(right: 25, left: 15),
                      child: GestureDetector(
                        onTap: addFiles,
                        child: const Icon(Icons.image_outlined, size: 30,),
                      ))
                ],
              ),
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
                    padding: const EdgeInsets.only(top: 5),
                    color: const Color.fromARGB(15, 0, 0, 0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        return Post(postData: posts[index]);
                      })
                );
              })
        ],
      ),
    );
  }
}

