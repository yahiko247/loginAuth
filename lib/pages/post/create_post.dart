import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:practice_login/components/chat/warning_dialog.dart';
import 'package:practice_login/components/create_post/confirm_dialog.dart';
import 'package:practice_login/components/create_post/video_preview.dart';
import 'package:practice_login/pages/botto_nav_bar.dart';
import 'package:practice_login/pages/homepage.dart';
import 'package:practice_login/services/posts/posts_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

class CreateNewPost extends StatefulWidget {
  final int? returnIndex;
  final List<PlatformFile>? imagesPicked;
  final VoidCallback? refresh;
  const CreateNewPost({super.key, this.imagesPicked, this.refresh, this.returnIndex});

  @override
  State<CreateNewPost> createState() => _CreateNewPostState();
}

class _CreateNewPostState extends State<CreateNewPost> {
  final PostService _postService = PostService();
  final TextEditingController _newPostController = TextEditingController();
  List<PlatformFile> _filesPicked = [];
  bool _textIsNotEmpty = false;
  bool _postInProgress = false;

  @override
  void initState() {
    super.initState();
    if (widget.imagesPicked != null) {
      _filesPicked = widget.imagesPicked!;
    }
    _newPostController.addListener(allowPost);
  }

  @override
  void dispose() {
    super.dispose();
    _newPostController.removeListener(allowPost);
    _newPostController.dispose();
  }

  void _removeFile(int index) {
    setState(() {
      _filesPicked.removeAt(index);
    });
  }

  void _addFiles(List<PlatformFile> newImages) async {
    setState(() {
      _filesPicked.addAll(newImages);
    });
  }

  void confirmPost() {
    if (_newPostController.text.isEmpty) {
      showDialog(
          context: context,
          builder: (context) {
            return ConfirmDialog(
                title: 'Upload Files?',
                message: 'Saying something interesting about your post will make it more engaging for your audiences.',
                confirmButtonText: 'Post',
                confirmAction: post
            );
          });
    } else if (_filesPicked.isEmpty) {
      showDialog(
          context: context,
          builder: (context) {
            return ConfirmDialog(
                title: 'Confirm Post?',
                message: 'Adding images and videos to your post will make it more visually appealing.',
                confirmButtonText: 'Post',
                confirmAction: post
            );
          });
    } else {
      post();
    }
  }

  void post() async {
    if (_newPostController.text.isEmpty || _filesPicked.isEmpty) {
      Navigator.pop(context);
    }
    setState(() {
      _postInProgress = true;
    });
    try {
      if (_newPostController.text.isNotEmpty || _filesPicked.isNotEmpty) {
        showDialog(barrierDismissible: false, context: context, builder: (context) => const Center(child: CircularProgressIndicator()));
        await _postService.addPost(_newPostController.text, _filesPicked);
      }
    } finally {
      widget.refresh;
      Navigator.pop(context);
      toHomePage();
    }
  }

  void toHomePage() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyButtomNavBar(pageIndex: widget.returnIndex ?? 0))
    );
  }

  void allowPost() {
    if (_newPostController.text.isNotEmpty) {
      setState(() {
        _textIsNotEmpty = true;
      });
    } else {
      setState(() {
        _textIsNotEmpty = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 124, 210, 231),
          title: const Text('Create Post', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: false,
          titleSpacing: 20,
          automaticallyImplyLeading: false,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 15),
              child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    foregroundColor: Colors.black,
                    side: const BorderSide(
                        color: Colors.transparent
                    ),
                  ),
                  onPressed: () {
                    if (_newPostController.text.isNotEmpty || _filesPicked.isNotEmpty) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return WarningDialog(
                                title: 'Discard Post?',
                                message: 'Discard your post.',
                                confirmButtonText: 'Discard',
                                confirmAction: () {
                                  toHomePage();
                                }
                            );
                          }
                      );
                    } else {
                      toHomePage();
                    }
                  },
                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold))
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Container(
            padding: const EdgeInsets.only(bottom: 15),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 23, left: 20, right: 20),
                  child: TextFormField(
                    minLines: 3,
                    maxLines: 10,
                    controller: _newPostController,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(13),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Colors.green
                            )
                        ),
                        hintText: 'Say something about your post...'
                    ),
                  ),
                ),
                _filesPicked.isNotEmpty ? Container(
                    padding: const EdgeInsets.only(top: 10, bottom: 5, right: 0, left: 0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                            _filesPicked.length,
                                (index) {
                              if (_filesPicked[index].extension == 'jpg') {
                                return CroppedImage(
                                  padding: index == 0 ? const EdgeInsets.fromLTRB(20, 5, 5, 5)
                                      : index == _filesPicked.length -1 ? const EdgeInsets.fromLTRB(5, 5, 20, 5)
                                      : const EdgeInsets.all(5),
                                  imagePath: _filesPicked[index].path!,
                                  onRemove: () => _removeFile(index),
                                );
                              }
                              if (_filesPicked[index].extension == 'mp4') {
                                return CroppedVideo(
                                  padding: index == 0 ? const EdgeInsets.fromLTRB(20, 5, 5, 5)
                                      : index == _filesPicked.length -1 ? const EdgeInsets.fromLTRB(5, 5, 20, 5)
                                      : const EdgeInsets.all(5),
                                  videoPath: _filesPicked[index].path!,
                                  onRemove: () => _removeFile(index),
                                );
                              }
                              throw Exception('No valid file types(?)');
                            }
                        ),
                      ),
                    )
                ) : const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.only(right: 20, left: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor: Colors.green,
                                side: const BorderSide(
                                    color: Colors.green
                                ),
                              ),
                              onPressed: () async {
                                FilePickerResult? result = await FilePicker.platform.pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: ['jpg', 'png'],
                                  allowMultiple: true,
                                );
                                if (result != null && result.files.isNotEmpty) {
                                  result.files.removeWhere((file) => _filesPicked.contains(file));
                                  _addFiles(result.files);
                                }
                              },
                              child: const Icon(Icons.image, size: 25, color: Colors.white)
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor: Colors.blue,
                                side: const BorderSide(
                                    color: Colors.blue
                                ),
                              ),
                              onPressed: () async {
                                final returnedImage = await ImagePicker().pickImage(source: ImageSource.camera);
                                if (returnedImage == null) return;
                                final file = File(returnedImage.path);
                                setState(() {
                                  _filesPicked.add(PlatformFile(
                                    name: returnedImage.name,
                                    path: returnedImage.path,
                                    size: file.lengthSync(),
                                  ));
                                });
                              },
                              child: const Icon(Icons.camera_alt, size: 25, color: Colors.white,)
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor: Colors.red,
                                side: const BorderSide(
                                    color: Colors.red
                                ),
                              ),
                              onPressed: () async {
                                FilePickerResult? result = await FilePicker.platform.pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: ['mp4'],
                                  allowMultiple: true,
                                );
                                if (result != null && result.files.isNotEmpty) {
                                  result.files.removeWhere((file) => _filesPicked.contains(file));
                                  _addFiles(result.files);
                                }
                              },
                              child: const Icon(Icons.video_collection, size: 25, color: Colors.white,)
                          ),
                        ],
                      ),
                      OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              disabledForegroundColor: Colors.grey,
                              side: BorderSide(
                                  color: _postInProgress ? Colors.grey : _textIsNotEmpty || _filesPicked.isNotEmpty ? Colors.green : Colors.grey
                              ),
                              foregroundColor: _postInProgress ? Colors.grey : _textIsNotEmpty && _filesPicked.isNotEmpty ? Colors.white : Colors.green,
                              backgroundColor: _postInProgress ? Colors.white : _textIsNotEmpty && _filesPicked.isNotEmpty ? Colors.green : Colors.white
                          ),
                          onPressed: _postInProgress ? null : _textIsNotEmpty || _filesPicked.isNotEmpty ? confirmPost : null,
                          child: const Text('Post', style: TextStyle(fontWeight: FontWeight.bold))
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }

}

class CroppedVideo extends StatefulWidget {
  final String videoPath;
  final VoidCallback? onRemove;
  final EdgeInsets padding;
  const CroppedVideo({super.key, required this.videoPath, required this.onRemove, required this.padding});

  @override
  State<CroppedVideo> createState() => _CroppedVideoState();
}

class _CroppedVideoState extends State<CroppedVideo> {
  String? _thumbnailPath;
  late VideoPlayerController _vidController;

  @override
  void initState() {
    _vidController = VideoPlayerController.file(File(widget.videoPath))
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
    showDialog(
        context: context,
        builder: (context) {
          return VideoPreview(vidController: _vidController);
        }
    );
    _vidController.seekTo(const Duration(seconds: 0));
    setState(() {
      autoPlay ? _vidController.play() : _vidController.pause();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      child: GestureDetector(
          onTap: () {
            playVideo(context, false);
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                      height: 300,
                      width: 250,
                      decoration: _thumbnailPath != null ? BoxDecoration(
                          image: DecorationImage(
                              image: FileImage(
                                File(_thumbnailPath!),
                              ),
                              fit: BoxFit.cover
                          )
                      ) : const BoxDecoration(color: Color.fromARGB(100, 150, 150, 150)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: IconButton(
                                  icon: const Icon(Icons.clear, size: 25, color: Colors.white,),
                                  onPressed: () {
                                    widget.onRemove!();
                                  }
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                                icon: const Icon(Icons.zoom_out_map, size: 25, color: Colors.white,),
                                onPressed: () {
                                  playVideo(context, false);
                                }
                            ),
                          ),
                        ],
                      )
                  )
              ),
              IconButton(
                  icon: const Icon(Icons.play_arrow, size: 40, color: Colors.white,),
                  onPressed: () {
                    playVideo(context, true);
                  }
              ),
            ],
          )
      ),
    );
  }
}

class CroppedImage extends StatelessWidget {
  final String imagePath;
  final VoidCallback? onRemove;
  final EdgeInsets padding;

  const CroppedImage({super.key, required this.imagePath, required this.padding, this.onRemove});

  void expandImage(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                      icon: const Icon(Icons.clear, size: 25, color: Colors.white,),
                      onPressed: () {
                        Navigator.pop(context);
                      }
                  ),
                ),
                Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                          File(imagePath)
                      ),
                    )
                ),
                const SizedBox(height: 13),
                if (onRemove != null)
                  Align(
                    alignment: Alignment.center,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(
                            color: Colors.white
                        ),
                      ),
                      onPressed: () {
                        onRemove!();
                        Navigator.pop(context);
                      },
                      child: const Text('Remove', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: GestureDetector(
        onTap: () {
          expandImage(context);
        },
        child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
                height: 300,
                width: 250,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: FileImage(
                          File(imagePath),
                        ),
                        fit: BoxFit.cover
                    )
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                            icon: const Icon(Icons.clear, size: 25, color: Colors.white,),
                            onPressed: () {
                              onRemove!();
                            }
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: IconButton(
                          icon: const Icon(Icons.zoom_out_map, size: 25, color: Colors.white,),
                          onPressed: () {
                            expandImage(context);
                          }
                      ),
                    ),
                  ],
                )
            )
        ),
      ),
    );
  }
}