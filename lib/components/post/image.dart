import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImagePost extends StatefulWidget {
  final String imgUrl;
  final bool zoomed;
  const ImagePost({super.key, required this.imgUrl, required this.zoomed});

  @override
  State<ImagePost> createState() => _ImagePostState();
}

class _ImagePostState extends State<ImagePost> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      child: GestureDetector(
        onTap: () {
        },
        child: ClipRRect(
            child: Container(
                child: !widget.zoomed ?
                Image.network(
                  widget.imgUrl,
                  fit: widget.zoomed ? BoxFit.contain : BoxFit.cover,
                  width: width,
                  height: height,
                ) :
                Container(
                  child: PhotoView(
                      enablePanAlways: true,
                      backgroundDecoration: const BoxDecoration(
                        color: Colors.transparent
                      ),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: 1.3,
                      imageProvider: NetworkImage(widget.imgUrl)
                  ),
                )
            )
        ),
      ),
    );
  }
}