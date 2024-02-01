import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/components/post/post.dart';
import 'package:practice_login/database/firestore.dart';
import 'package:practice_login/pages/post/create_post.dart';
import 'package:file_picker/file_picker.dart';
import 'package:practice_login/services/posts/posts_service.dart';


class ForUserPosts extends StatefulWidget{
  ForUserPosts({super.key});
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  State<StatefulWidget> createState() => _ForUserPosts();


}
class _ForUserPosts extends State<ForUserPosts> with TickerProviderStateMixin{

  late final TabController _tabController;
  final PostService _postService = PostService();
  final TextEditingController newPostController = TextEditingController();
  final FirestoreDatabase _firestoreDatabase = FirestoreDatabase();
  List<PlatformFile>? _pickedFiles;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: Column(
        children: [
          StreamBuilder(
              stream: _postService.getPostsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final posts = snapshot.data!.docs;
                final userPosts = posts.where((post) => post['user_id'] == FirebaseAuth.instance.currentUser!.uid).toList();

                if (posts.isEmpty) {
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
                    itemCount: userPosts.length,
                    itemBuilder: (context, index) {
                      return Post(postData: userPosts[index]);
                    });
              })
        ],
      ),
    );
  }

}