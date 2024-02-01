import 'package:flutter/material.dart';
import 'package:practice_login/components/create_post/video_preview.dart';
import 'package:practice_login/database/firestore.dart';
import 'package:practice_login/services/posts/posts_service.dart';
import 'package:video_player/video_player.dart';

class FullPost extends StatefulWidget {
  final String postId;
  final String postTitle;
  const FullPost({super.key, required this.postId, required this.postTitle});

  @override
  State<FullPost> createState() => _FullPostState();
}

class _FullPostState extends State<FullPost> {
  final PostService _postService = PostService();
  final FirestoreDatabase _firestoreDatabase = FirestoreDatabase();
  late final List<VideoPlayerController> _videoControllers = [];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      /*appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.clear)
          )
        ],
      ),*/
      body: FutureBuilder(
          future: _postService.getPost(widget.postId),
          builder: (context, postSnapshot) {
            if (postSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (postSnapshot.hasError) {
              return ErrorWidget('error');
            }
            if (postSnapshot.hasData) {
              Map<String, dynamic> postData = postSnapshot.data!.data()!;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    /// Post Details
                    Container(
                      padding: const EdgeInsets.only(top: 30, bottom: 5),
                      width: width,
                      child: ListTile(
                        contentPadding: const EdgeInsets.only(left: 20, right: 10),
                        trailing: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            Navigator.pop(context);
                          }
                        ),
                        leading: const CircleAvatar(
                            radius: 20,
                            backgroundImage:
                            AssetImage('images/Avatar1.png')),
                        title: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {},
                              child: Text('${postData['first_name']} ${postData['last_name']}'),
                            ),
                            Text(
                              _firestoreDatabase.formatPostTimeStamp(postData['timestamp']),
                              style: const TextStyle(fontSize: 11),
                            )
                          ],
                        ),
                      ),
                    ),
                    /// Post Title
                    if (postData.containsKey('post_title'))
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: width - (width * (98.5 / 100))),
                        width: width,
                        child: Container(
                          padding: EdgeInsets.only(left: 15, right: 15, bottom: postData['post_message'].isNotEmpty ? 7 : postData['media'].isNotEmpty ? 8: 0),
                          color: Colors.white,
                          child: Text(postData['post_title'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                        ),
                      ),
                    /// Post Message
                    if (postData['post_message'].isNotEmpty)
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: width - (width * (98.5 / 100))),
                          width: width,
                          child: Container(
                            color: Colors.white,
                            padding: EdgeInsets.only(left: 15, right: 15, bottom: postData['media'].isNotEmpty ? 15 : 0),
                            child: Text(
                              postData['post_message'],
                              style: const TextStyle(
                                fontSize: 16
                              ),
                            )
                          )
                      ),
                    /// Post Media
                    if (postData['media'].isNotEmpty)
                      Column(
                        children: List.generate(
                            postData['media'].length,
                                (index) {
                              if (postData['media'][index]['media_type'] == 'jpg' || postData['media'][index]['media_type'] == 'png') {
                                return Container(
                                  padding: const EdgeInsets.symmetric(vertical: 3.5),
                                  child: Image.network(
                                      postData['media'][index]['media_reference'],
                                      width: width,
                                      errorBuilder: (context, url, error) => const SizedBox(
                                        height: 400,
                                        child: Center(child: CircularProgressIndicator(color: Color.fromARGB(100, 0, 0, 0)),),
                                      )
                                  ),
                                );
                              }
                              if (postData['media'][index]['media_type'] == 'mp4') {
                                return Container(
                                  padding: const EdgeInsets.symmetric(vertical: 3.5),
                                  child: FullPostVideo(videoUrl: postData['media'][index]['media_reference'])
                                );
                              }
                              return ErrorWidget('Not a valid media type');
                            }
                        ),
                      ),
                  ],
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }
      ),
    );
  }

}

class FullPostVideo extends StatefulWidget {
  final String videoUrl;
  const FullPostVideo({super.key, required this.videoUrl});

  @override
  State<FullPostVideo> createState() => _FullPostVideoState();
}

class _FullPostVideoState extends State<FullPostVideo> {
  late VideoPlayerController _videoPlayerController;
  IconData playIcon = Icons.play_arrow;
  double playOpacity = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {});
      });
    _videoPlayerController.addListener(setPlayIcon);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _videoPlayerController.dispose();
    _videoPlayerController.removeListener(setPlayIcon);
  }

  void setPlayIcon() {
    if (_videoPlayerController.value.isPlaying) {
      setState(() {
        playIcon = Icons.pause;
        playOpacity = 0.0;
      });
    } else if (_videoPlayerController.value.isCompleted) {
      setState(() {
        playIcon = Icons.replay;
        playOpacity = 1.0;
      });
    } else {
      setState(() {
        playIcon = Icons.play_arrow;
        playOpacity = 1.0;
      });
    }
  }

  @override
  Widget build(BuildContext context){
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SizedBox(
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _videoPlayerController.value.isPlaying
                    ? _videoPlayerController.pause()
                    : _videoPlayerController.play();
              });
            },
            child: SizedBox(
                child: Center(
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: _videoPlayerController.value.aspectRatio,
                        child: VideoPlayer(_videoPlayerController),
                      ),
                    ],
                  ),
                )
            ),
          ),
          SizedBox(
            height: width / _videoPlayerController.value.aspectRatio,
            child: Align(
              alignment: Alignment.center,
              child: AnimatedOpacity(
                opacity: playOpacity,
                duration: const Duration(milliseconds: 450),
                child: Container(
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(75, 0, 0, 0),
                      border: Border.all(width: 2, color: Colors.white),
                      borderRadius: BorderRadius.circular(100)
                  ),
                  child: IconButton(
                      icon: Icon(playIcon, size: 40, color: Colors.white,),
                      onPressed: () {
                      }
                  ),
                ),
              )
            ),
          ),
          AnimatedOpacity(
            opacity: playOpacity,
            duration: const Duration(milliseconds: 450),
            child: Container(
              padding: const EdgeInsets.only(bottom: 5),
              height: width / _videoPlayerController.value.aspectRatio,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenVideo(
                                  vidController: _videoPlayerController
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.fullscreen, size: 28, color: Colors.white,)
                    ),
                    Container(
                      padding: const EdgeInsets.only(bottom: 5),
                      width: width - 110,
                      child: VideoProgressIndicator(
                          _videoPlayerController,
                          allowScrubbing: true,
                          colors: const VideoProgressColors(
                              playedColor: Colors.white,
                              bufferedColor: Colors.transparent,
                              backgroundColor: Color.fromARGB(100, 255, 255, 255)
                          )
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            _videoPlayerController.value.volume == 1.0
                                ? _videoPlayerController.setVolume(0.0)
                                : _videoPlayerController.setVolume(1.0);
                          });
                        },
                        icon: Icon(_videoPlayerController.value.volume == 1.0 ? Icons.volume_up : Icons.volume_off, size: 28, color: Colors.white,)
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}