import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPreview extends StatefulWidget {
  final VideoPlayerController vidController;
  const VideoPreview({super.key, required this.vidController});

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  bool isFullScreen = false;
  IconData playIcon = Icons.play_arrow;

  @override
  void initState() {
    super.initState();
    widget.vidController.addListener(setPlayIcon);
  }

  @override
  void dispose() {
    super.dispose();
    widget.vidController.removeListener(setPlayIcon);
  }

  void setPlayIcon() {
    if (widget.vidController.value.isPlaying) {
      setState(() {
        playIcon = Icons.pause;
      });
    } else if (widget.vidController.value.isCompleted) {
      setState(() {
        playIcon = Icons.replay;
      });
    } else {
      setState(() {
        playIcon = Icons.play_arrow;
      });
    }
  }

  void _enterFullScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenVideo(
          vidController: widget.vidController
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.only(left: 40, right: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
              child: GestureDetector(
                onDoubleTap: () {
                  _enterFullScreen();
                },
                  onTap: () {
                    setState(() {
                      widget.vidController.value.isPlaying
                          ? widget.vidController.pause()
                          : widget.vidController.play();
                    });
                  },
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: widget.vidController.value.isInitialized ? AspectRatio(
                          aspectRatio: widget.vidController.value.aspectRatio,
                          child: VideoPlayer(widget.vidController),
                        )
                            : Container(),
                      ),
                      /*Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: IconButton(
                                      icon: const Icon(Icons.clear, size: 25, color: Colors.white,),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      }
                                  ),
                                ),
                              ],
                            ),
                          ),*/
                      Container(
                        padding: EdgeInsets.only(bottom: 13),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    widget.vidController.value.isPlaying
                                        ? widget.vidController.pause()
                                        : widget.vidController.play();
                                  });
                                },
                                icon: Icon(playIcon, size: 28, color: Colors.white,)
                            ),
                            Container(
                              padding: EdgeInsets.only(bottom: 5),
                              width: width - 200,
                              child: VideoProgressIndicator(
                                  widget.vidController,
                                  allowScrubbing: false,
                                  colors: const VideoProgressColors(
                                      playedColor: Colors.white,
                                      bufferedColor: Colors.transparent,
                                      backgroundColor: Color.fromARGB(100, 255, 255, 255)
                                  )
                              ),
                            ),
                            IconButton(
                                onPressed: () {
                                  _enterFullScreen();
                                },
                                icon: Icon(Icons.fullscreen, size: 28, color: Colors.white,)
                            ),
                          ],
                        ),
                      )
                    ],
                  )
              )
          ),
        ],
      ),
    );
  }

}

class FullScreenVideo extends StatefulWidget {
  final VideoPlayerController vidController;

  const FullScreenVideo({super.key, required this.vidController});

  @override
  State<FullScreenVideo> createState() => _FullScreenVideoState();
}

class _FullScreenVideoState extends State<FullScreenVideo> {
  IconData playIcon = Icons.play_arrow;

  @override
  void initState() {
    super.initState();
    widget.vidController.addListener(setPlayIcon);
  }

  @override
  void dispose() {
    super.dispose();
    widget.vidController.removeListener(setPlayIcon);
  }

  void setPlayIcon() {
    if (widget.vidController.value.isPlaying) {
      setState(() {
        playIcon = Icons.pause;
      });
    } else if (widget.vidController.value.isCompleted) {
      setState(() {
        playIcon = Icons.replay;
      });
    } else {
      setState(() {
        playIcon = Icons.play_arrow;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                widget.vidController.value.isPlaying
                    ? widget.vidController.pause()
                    : widget.vidController.play();
              });
            },
            child: SizedBox(
                width: screenWidth,
                height: screenHeight,
                child: Center(
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: widget.vidController.value.aspectRatio,
                        child: VideoPlayer(widget.vidController),
                      ),
                    ],
                  ),
                )
            ),
          ),
          Align(
              alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(top: screenHeight - ((screenHeight * 94) / 100), left: 15),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_outlined, color: Colors.white,),
              ),
            )
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: screenHeight - (screenHeight * 98) / 100),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          widget.vidController.value.isPlaying
                              ? widget.vidController.pause()
                              : widget.vidController.play();
                        });
                      },
                      icon: Icon(playIcon, size: 28, color: Colors.white,)
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 5),
                    width: screenWidth - 125,
                    child: VideoProgressIndicator(
                        widget.vidController,
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
                          widget.vidController.value.volume == 1.0
                              ? widget.vidController.setVolume(0.0)
                              : widget.vidController.setVolume(1.0);
                        });
                      },
                      icon: Icon(widget.vidController.value.volume == 1.0 ? Icons.volume_up : Icons.volume_off, size: 28, color: Colors.white,)
                  ),
                ],
              ),
            )
          )
        ],
      ),
    );
  }
}
