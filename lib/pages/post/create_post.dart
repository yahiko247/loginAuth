import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:practice_login/components/chat/warning_dialog.dart';
import 'package:practice_login/components/post/confirm_dialog.dart';
import 'package:practice_login/services/posts/posts_service.dart';
import 'package:reorderables/reorderables.dart';
import 'package:image_picker/image_picker.dart';

class CreateNewPost extends StatefulWidget {
  final List<PlatformFile>? imagesPicked;
  const CreateNewPost({Key? key, this.imagesPicked}) : super(key: key);

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

  void _removeImage(int index) {
    setState(() {
      _filesPicked.removeAt(index);
    });
  }

  void _addImages(List<PlatformFile> newImages) async {
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
                message: 'Adding images to your post will make it more visually appealing.',
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
    try {
      if (_newPostController.text.isNotEmpty || _filesPicked.isNotEmpty) {
        showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator()));
        await _postService.addPost(_newPostController.text, _filesPicked);
      }
    } finally {
      Navigator.pop(context);
      Navigator.pop(context);
    }
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
                                Navigator.pop(context);
                                Navigator.pop(context);
                              }
                          );
                        }
                    );
                  } else {
                    Navigator.pop(context);
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
                  minLines: 2,
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
                padding: const EdgeInsets.only(top: 10, bottom: 5, right: 15, left: 15),
                child: ReorderableRow(
                  draggingWidgetOpacity: 0.5,
                  mainAxisAlignment: MainAxisAlignment.start,
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      PlatformFile col = _filesPicked.removeAt(oldIndex);
                      _filesPicked.insert(newIndex, col);
                    });
                  },
                  children: List.generate(
                      _filesPicked.length,
                          (index){
                            return CroppedImage(
                              key: UniqueKey(),
                              imagePath: _filesPicked[index].path!,
                              onRemove: () => _removeImage(index),
                            );
                      }
                  )
                ),
              ) : const SizedBox(height: 15),
              /*Container(
                padding: EdgeInsets.only(top: 20, bottom: 15),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                      children: List.generate(
                        _filesPicked.length,
                            (index) => CroppedImage(
                          imagePath: _filesPicked[index].path!,
                          onRemove: () => _removeImage(index),
                        ),
                      )
                  ),
                ),
              ),*/
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
                                _addImages(result.files);
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
                            onPressed: () {
                            },
                            child: const Icon(Icons.video_collection, size: 25, color: Colors.white,)
                        ),
                      ],
                    ),
                    OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            disabledForegroundColor: Colors.grey,
                            side: BorderSide(
                              color: _textIsNotEmpty || _filesPicked.isNotEmpty ? Colors.green : Colors.grey
                            ),
                            foregroundColor: _textIsNotEmpty && _filesPicked.isNotEmpty ? Colors.white : Colors.green,
                            backgroundColor: _textIsNotEmpty && _filesPicked.isNotEmpty ? Colors.green : Colors.white
                        ),
                        onPressed: _textIsNotEmpty || _filesPicked.isNotEmpty ? confirmPost : null,
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

class CroppedImage extends StatelessWidget {
  final String imagePath;
  final VoidCallback? onRemove;

  const CroppedImage({Key? key, required this.imagePath, this.onRemove}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: GestureDetector(
        onTap: () {
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
            child: Align(
              alignment: Alignment.topLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                      icon: const Icon(Icons.clear, size: 25, color: Colors.white,),
                      onPressed: () {
                        onRemove!();
                      }
                  ),
                ],
              ),
            ),
          )
        ),
      ),
    );
  }
}