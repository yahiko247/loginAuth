import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:practice_login/pages/post/create_post.dart';

class Ratings extends StatefulWidget{
   const Ratings({super.key});

  @override
  State<Ratings> createState() => _Ratings();
}

class _Ratings extends State<Ratings>{
  TextEditingController feedbackController = TextEditingController();
  double ratingValue = 0;
  List<PlatformFile> _filesPicked = [];
  Text? ratingText(){
    if (ratingValue == 1 || ratingValue == 1.5){
      return const Text("Bad");
    }else if(ratingValue == 2 || ratingValue == 2.5){
      return const Text("Not Bad");
    }else if(ratingValue == 3 || ratingValue == 3.5){
      return  const Text("Satisfactory");
    }else if(ratingValue == 4 || ratingValue == 4.5){
      return const Text("Excellent");
    }else if(ratingValue == 5){
      return const Text("Amazing");
    }
    return const Text("Add Rating");
  }
  void _addFiles(List<PlatformFile> newImages) async {
    setState(() {
      _filesPicked.addAll(newImages);
    });
  }
  void _removeFile(int index) {
    setState(() {
      _filesPicked.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Service Rating"),
          backgroundColor: const Color.fromARGB(255, 124, 210, 231),
          actions: [
            TextButton(
                onPressed: (){

                },
                child: const Text("Submit",style: TextStyle(color: Colors.black),))
          ],
        ),
        body:SingleChildScrollView(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double width = MediaQuery.of(context).size.width;
              double height = MediaQuery.of(context).size.height;
              return SizedBox(
                height: height,
                width: width,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Flexible(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.all(Radius.circular(10))
                            ),
                            height: 100,
                            child:  Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                const Flexible(
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 10, left: 10),
                                    child: Text("Services"),
                                  ),
                                ),
                                Flexible(
                                  child: RatingBar.builder(
                                    initialRating: 0,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemSize: 30,
                                    itemPadding: const EdgeInsets.symmetric(horizontal: 1),
                                    glow: false,
                                    itemBuilder: (context, _) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                  ),
                                    onRatingUpdate: (rating){
                                      setState(() {
                                        ratingValue = rating;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.all(Radius.circular(10))
                            ),
                            height: 200,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                GestureDetector(
                                  onTap : () async {
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
                                  child: const Icon(Icons.camera_alt),
                                ),
                                GestureDetector(
                                  onTap: () async {
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
                                  child: const Icon(Icons.video_collection),
                                ),
                                GestureDetector(
                                  onTap:() async {
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
                                  child: const Icon(Icons.image),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 5,
                        child: _filesPicked.isNotEmpty ? Container(
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
                      ),
                      Flexible(
                          child: ratingValue != 0 ? TextField(
                            maxLength: 500,
                            expands: true,
                            maxLines: null,
                            minLines: null,
                            controller:feedbackController,
                            decoration: const InputDecoration(
                              hintText: "Say something about the freelancer"
                            ),
                          ) : const SizedBox(height:15),
                      )
                    ],
                  ),
                ),
              );
            }
          ),
        ) ,
    );
  }

}