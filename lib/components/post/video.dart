import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:practice_login/components/create_post/video_preview.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';


class Video extends StatefulWidget {
  final String videoPath;
  final bool zoomed;
  const Video({super.key, required this.videoPath, required this.zoomed});

  @override
  State<Video> createState() => _VideoState();
}

class _VideoState extends State<Video> {
  String? _thumbnailPath;
  late VideoPlayerController _vidController;

  @override
  void initState() {
    _vidController = VideoPlayerController.networkUrl(Uri.parse(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
      });
    generateThumbnail();
    super.initState();
  }

  @override
  void dispose() {
    _vidController.dispose();
    super.dispose();
  }

  void _enterFullScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenVideo(
            vidController: _vidController
        ),
      ),
    );
  }

  Future<void> generateThumbnail() async {
    final thumbnail = await VideoThumbnail.thumbnailFile(
      video: widget.videoPath,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.WEBP,
      maxHeight: 300,
      quality: 100,
    );
    setState(() {
      _thumbnailPath = thumbnail;
    });
  }

  void playVideo(BuildContext context, bool autoPlay) {
    setState(() {
      autoPlay ? _vidController.play() : _vidController.pause();
    });
    showDialog(
        context: context,
        builder: (context) {
          return VideoPreview(vidController: _vidController);
        }
    );
  }

  @override
  Widget build(BuildContext) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      padding: EdgeInsets.zero,
      child: GestureDetector(
          onTap: () {
            widget.zoomed ? _enterFullScreen() : playVideo(context, true);
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: 300,
                        maxHeight: 450
                    ),
                    decoration: _thumbnailPath != null ? BoxDecoration(
                        image: DecorationImage(
                            image: FileImage(
                              File(_thumbnailPath!),
                            ),
                            fit: BoxFit.cover
                        )
                    ) : const BoxDecoration(color: Color.fromARGB(100, 150, 150, 150)),
                    child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Color.fromARGB(150, 0, 0, 0),
                              border: Border.all(width: 2, color: Colors.white),
                              borderRadius: BorderRadius.circular(100)
                          ),
                          child: IconButton(
                              icon: const Icon(Icons.play_arrow, size: 40, color: Colors.white,),
                              onPressed: () {
                                widget.zoomed ? _enterFullScreen() : playVideo(context, true);
                              }
                          ),
                        )
                    ),
                  )
              ),
              /*if (widget.showMoreIcon)
                Container(
                  padding: EdgeInsets.only(bottom: height - ((height * 76) / 100), right: 10),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () {
                      },
                      icon: const Icon(Icons.open_in_new, size: 25, color: Colors.white),
                    ),
                  ),
                )*/
            ],
          )
      ),
    );
  }
}