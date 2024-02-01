import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:practice_login/components/post/image.dart';
import 'package:practice_login/components/post/video.dart';
import 'package:practice_login/database/firestore.dart';

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
  late PageController _zoomedMediaController;
  int _zoomedCurrentMedia = 0;
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

  void navigatorDetails(
      String userEmail,
      ) {
    /*Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => StalkPage(userEmail: userEmail))
    );*/
  }

  String formatPreviewMessage(String message) {
    String formattedMessage = '';
    if (message.length > 100) {
      formattedMessage = '${message.substring(0, 100)}${String.fromCharCode(Icons.arrow_right_alt.codePoint)}';
    } else {
      formattedMessage = message;
    }
    return formattedMessage;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      isThreeLine: true,
      title: Container(
          padding: EdgeInsets.symmetric(horizontal: width - (width * (98 / 100))),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              trailing: IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {
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
                      navigatorDetails(_postData['user_email']);
                    },
                    child: Text('${_postData['first_name']} ${_postData['last_name']}'),
                  ),
                  Text(
                    _firestoreDatabase.formatPostTimeStamp(_postData['timestamp']),
                    style: const TextStyle(fontSize: 10),
                  )
                ],
              ),
            ),
          )
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_postData['post_message'].isNotEmpty)
            Container(
                padding: EdgeInsets.symmetric(horizontal: width - (width * (98 / 100))),
                width: width,
                child: Container(
                  padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
                  color: Colors.white,
                  child: GestureDetector(
                    onTap: _postData['post_message'].length < 100 ? null : () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(25),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(Radius.circular(15))
                                    ),
                                    padding: const EdgeInsets.all(25),
                                    child: Text(_postData['post_message'], style: const TextStyle(fontSize: 16)),
                                  ),
                                )
                            );
                          }
                      );
                    },
                    child: Text(
                        formatPreviewMessage(_postData['post_message']).trim(),
                        style: const TextStyle(fontSize: 16)
                    ),
                  ),
                )
            ),
          /*Container(
                padding: EdgeInsets.only(left: width - (width * (96.5 / 100)), right: width - (width * (96.5 / 100))),
                child:
              ),*/
          if (_postData['media'].isNotEmpty)
            Stack(
              children: [
                Container(
                  constraints: const BoxConstraints(
                      maxHeight: 450,
                      minHeight: 300
                  ),
                  alignment: Alignment.center,
                  child: PageView.builder(
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
                            onDoubleTap: _postData['media'][index]['media_type'] == 'mp4' ? null : () {
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
                            },
                            onHorizontalDragEnd: (details) {
                              if (details.primaryVelocity! > 0) {
                                if (_currentMedia > 0) {
                                  _mediaController.previousPage(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.ease,
                                  );
                                }
                              } else if (details.primaryVelocity! < 0) {
                                if (_currentMedia < _postData['media'].length - 1) {
                                  _mediaController.nextPage(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.ease,
                                  );
                                }
                              }
                            },
                            child: Media(media: _postData['media'][index])
                        );
                      }
                  ),
                ),
              ],
            ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: width - (width * (98 / 100))),
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.only(top: 10, left: width - (width * (96 / 100)), right: width - (width * (96 / 100))),
                  child: const Divider(height: 1),
                ),
                Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(10), bottomLeft: Radius.circular(10))
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
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! > 0) {
                  // Swiped to the right
                  if (_zoomedCurrentMedia > 0) {
                    _zoomedMediaController.previousPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    );
                  }
                } else if (details.primaryVelocity! < 0) {
                  if (_zoomedCurrentMedia < _postData['media'].length - 1) {
                    _zoomedMediaController.nextPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    );
                  }
                }
              },
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
      return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: ImagePost(imgUrl: _media['media_reference'], zoomed: widget.zoomed ?? false),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Video(videoPath: _media['media_reference'], zoomed: true),
      );
    }
  }
}