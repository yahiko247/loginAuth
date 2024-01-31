import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:practice_login/components/post/image.dart';
import 'package:practice_login/components/post/video.dart';
import 'package:practice_login/database/firestore.dart';
import 'package:practice_login/pages/freelancerstalkingpage.dart';
import 'package:practice_login/pages/post/post.dart';
import 'package:practice_login/pages/profile.dart';
import 'package:practice_login/pages/userstalkingpage.dart';
import 'package:practice_login/services/user_data_services.dart';

class Post extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> postData;
  const Post({super.key, required this.postData});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  final FirestoreDatabase _firestoreDatabase = FirestoreDatabase();
  late QueryDocumentSnapshot<Object?> _postData;
  late PageController _mediaController;
  int _currentMedia = 0;

  @override
  void initState() {
    super.initState();
    _postData = widget.postData;
    _mediaController = PageController(initialPage: _currentMedia);
  }

  @override
  void dispose() {
    super.dispose();
    _mediaController.dispose();
  }

  String formatPreviewMessage(String message) {
    String formattedMessage = '';
    if (message.length > 125) {
      formattedMessage = '${message.substring(0, 125).trim()}...';
    } else {
      formattedMessage = message;
    }
    return formattedMessage.trim();
  }

  void userNavigator(String userEmail,) {
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => UserStalkPage(userEmail: userEmail)
        )
    );
  }

  void freelancerNavigator(String userEmail,) {
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => FreelancerStalkPage(userEmail: userEmail)
        )
    );
  }

  void userProfileNavigator() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ProfilePage()
        )
    );
  }

  Future<void> freelancerIdentifier2(String email, BuildContext context) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_postData['user_id'])
        .get();
    Map <String, dynamic>? userData = snapshot.data() as Map<String, dynamic>?;

    if(_postData['user_id']==FirebaseAuth.instance.currentUser!.uid) {
      userProfileNavigator();
    }else if (userData!.containsKey('freelancer')) {
        bool? isFreelancer = snapshot['freelancer'];
        if (isFreelancer == true) {
          freelancerNavigator(_postData['user_email']);
        } else {
          userNavigator(_postData['user_email']);
        }
      } else {
        userNavigator(_postData['user_email']);
      }
  }

  void openFullPost() {
    Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return FullPost(
                postId: _postData.id,
                postTitle: (_postData.data() as Map<String, dynamic>).containsKey('post_title')
                    ? _postData['post_title']
                    : '${_postData['first_name']} ${_postData['last_name']}\' Post'
            );
          },
          transitionDuration: Duration(milliseconds: 350),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.linearToEaseOut;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(position: offsetAnimation, child: child);
          },
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      isThreeLine: true,
      title: Container(
          padding: EdgeInsets.symmetric(horizontal: width - (width * (96 / 100))),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(7), topRight: Radius.circular(7)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
              trailing: IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {
                if (_postData['user_id'] == FirebaseAuth.instance.currentUser!.uid) {
                  showModalBottomSheet(
                      showDragHandle: true,
                      context: context,
                      builder: (context) {
                        return SizedBox(
                          height: 240,
                          child: ListView(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                                onTap: () {},
                                leading: const Icon(Icons.delete),
                                title: const Text('Delete post'),
                              ),
                              ListTile(
                                contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                                onTap: () {},
                                leading: const Icon(Icons.archive),
                                title: const Text('Archive Post'),
                              ),
                              ListTile(
                                contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                                onTap: () {},
                                leading: const Icon(Icons.notifications_off),
                                title: const Text('Mute notifications for this post'),
                              ),
                              ListTile(
                                contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                                onTap: () {},
                                leading: const Icon(Icons.comments_disabled),
                                title: const Text('Disable comments'),
                              )
                            ],
                          ),
                        );
                      }
                  );
                } else {
                  /*showModalBottomSheet(
                      showDragHandle: true,
                      context: context,
                      builder: (context) {
                        return Container(
                          color: Colors.red,
                          height: 300,
                        );
                      }
                  );*/
                }
                return;
              },),
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
                      freelancerIdentifier2(_postData['user_email'],context);
                    },
                    child: Text('${_postData['first_name']} ${_postData['last_name']}'),
                  ),
                  Text(
                    _firestoreDatabase.formatPostTimeStamp(_postData['timestamp']),
                    style: const TextStyle(fontSize: 11),
                  )
                ],
              ),
            ),
          )
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((_postData.data() as Map<String, dynamic>).containsKey('post_title'))
            Container(
              padding: EdgeInsets.symmetric(horizontal: width - (width * (96 / 100))),
              width: width,
              child: Container(
                padding: EdgeInsets.only(left: 15, right: 15, bottom: _postData['post_message'].isNotEmpty ? 7 : _postData['media'].isNotEmpty ? 8: 0),
                color: Colors.white,
                child: Text(_postData['post_title'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
              ),
            ),
          if (_postData['post_message'].isNotEmpty)
            Container(
                padding: EdgeInsets.symmetric(horizontal: width - (width * (96 / 100))),
                width: width,
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.only(left: 15, right: 15, bottom: _postData['media'].isNotEmpty ? 10 : 0),
                  child: GestureDetector(
                    onTap: _postData['post_message'].length < 100 ? null : openFullPost,
                    child: RichText(
                        text: TextSpan(
                          text: formatPreviewMessage(_postData['post_message']),
                          style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black
                          ),
                          children: [
                            if (_postData['post_message'].length > 100)
                              TextSpan(
                              text: '\nSee full post to read more',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                                  children: [
                                    TextSpan(
                                        text: String.fromCharCode(0x2192),
                                        style: const TextStyle(
                                            fontSize: 30,
                                            color: Colors.grey
                                        )
                                    )
                                  ]
                              )
                          ]
                        )
                    ),
                  ),
                )
            ),
          if (_postData['media'].isNotEmpty)
            Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      color: Colors.white,
                      constraints: const BoxConstraints(
                          maxHeight: 450,
                          minHeight: 300
                      ),
                      width: width * (92 / 100),
                    ),
                  ],
                ),
                Container(
                  constraints: const BoxConstraints(
                      maxHeight: 450,
                      minHeight: 300
                  ),
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      PageView.builder(
                          physics: AlwaysScrollableScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          controller: _mediaController,
                          itemCount: _postData['media'].length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentMedia = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return GestureDetector(
                                /*onDoubleTap: _postData['media'][index]['media_type'] == 'mp4' ? null : () {
                                  setState(() {
                                    _zoomedCurrentMedia = _currentMedia;
                                    _zoomedMediaController = PageController(initialPage: _currentMedia);
                                  });
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return ZoomMedia(
                                            zoomedCurrentMedia: _zoomedCurrentMedia,
                                            zoomedMediaController: _zoomedMediaController,
                                            media: _postData
                                        );
                                      }
                                  );
                                },*/
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: width - (width * (98 / 100))),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(7),
                                    child: Media(media: _postData['media'][index]),
                                  ),
                                )
                            );
                          }
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10, top: 5),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                              onPressed: openFullPost,
                              icon: const Icon(Icons.open_in_new, color: Colors.white)
                          ),
                        ),
                      ),
                      if (_postData['media'].length > 1)
                        AnimatedOpacity(
                          opacity: _currentMedia == _postData['media'].length - 1 ? 0 : 1,
                          duration: const Duration(milliseconds: 200),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 13, bottom: 5),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: IconButton(
                                  onPressed: _currentMedia == _postData['media'].length - 1 ? null : () {
                                    _mediaController.animateToPage(
                                        _postData['media'].length - 1,
                                        duration: const Duration(milliseconds: 650),
                                        curve: Curves.linearToEaseOut
                                    );
                                  },
                                  icon: const Icon(Icons.arrow_right_alt_sharp, color: Colors.white, size: 30)
                              ),
                            ),
                          ),
                        )
                    ],
                  )
                )
              ],
            ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: width - (width * (96 / 100))),
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.only(top: 10, left: width - (width * (96 / 100)), right: width - (width * (98 / 100))),
                  child: const Divider(height:1),
                ),
                Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(7), bottomLeft: Radius.circular(7))
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      GestureDetector(
                        onTap: () {
                          print("Tapped Like");
                        },
                        child: const Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text("Like"),),
                      ),
                      GestureDetector(
                        onTap: () {
                          print("Tapped Comment");
                        },
                        child: const Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text("Comment"),),
                      ),
                      GestureDetector(
                        onTap: () {
                          print("Tapped Share");
                        },
                        child: const Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text("Share"),),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ZoomMedia extends StatefulWidget {
  final PageController zoomedMediaController;
  final int zoomedCurrentMedia;
  final QueryDocumentSnapshot<Object?> media;
  const ZoomMedia({super.key, required this.zoomedCurrentMedia, required this.zoomedMediaController, required this.media});

  @override
  State<ZoomMedia> createState() => _ZoomMediaState();
}

class _ZoomMediaState extends State<ZoomMedia> {
  late PageController _zoomedMediaController;
  late QueryDocumentSnapshot<Object?> _postData;
  int _zoomedCurrentMedia = 0;

  @override
  void initState() {
    super.initState();
    _zoomedCurrentMedia = widget.zoomedCurrentMedia;
    _zoomedMediaController = widget.zoomedMediaController;
    _postData = widget.media;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width,
      child: PageView.builder(
          scrollDirection: Axis.horizontal,
          controller: _zoomedMediaController,
          itemCount: _postData['media'].length,
          onPageChanged: (index) {
            setState(() {
              _zoomedCurrentMedia = index;
            });
          },
          itemBuilder: (context, index) {
            return GestureDetector(
              child: Media(media: _postData['media'][index], zoomed: true),
            );
          }
      ),
    );
  }
}

class Media extends StatefulWidget {
  final Map<String, dynamic> media;
  final bool? zoomed;
  const Media({super.key, required this.media, this.zoomed});

  @override
  State<Media> createState() => _MediaState();
}

class _MediaState extends State<Media> {
  late Map<String, dynamic> _media;

  @override
  void initState() {
    super.initState();
    _media = widget.media;
  }

  @override
  Widget build(BuildContext context) {
    if (_media['media_type'] == 'jpg' || _media['media_type'] == 'png') {
      return ImagePost(imgUrl: _media['media_reference'], zoomed: widget.zoomed ?? false);
    } else {
      return Video(videoPath: _media['media_reference'], zoomed: true);
    }
  }
}