import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:practice_login/pages/post/create_post.dart';

import '../services/feedback_services.dart';

class Ratings extends StatefulWidget{
  final String freelancerID;
   const Ratings({super.key, required this.freelancerID});

  @override
  State<Ratings> createState() => _Ratings();
}

class _Ratings extends State<Ratings>{
  TextEditingController feedbackController = TextEditingController();
  double ratingValue = 0;
  final List<PlatformFile> _filesPicked = [];
  final FeedbackService _feedbackService = FeedbackService();

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

  void feedback() async {
    if (feedbackController.text.isEmpty || _filesPicked.isEmpty) {
      Navigator.pop(context);
    }
    try {
      if (feedbackController.text.isNotEmpty || _filesPicked.isNotEmpty) {
        await _feedbackService.addFeedback(feedbackController.text,_filesPicked,widget.freelancerID,ratingValue);
      }
    } finally {
      Navigator.pop(context);
    }
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
                  feedback();
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