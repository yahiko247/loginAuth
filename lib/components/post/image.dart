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
      color: const Color.fromRGBO(190, 190, 190, 1),
      child: GestureDetector(
        onTap: () {},
        child: ClipRRect(
            child: Container(
                child: !widget.zoomed ?
                Image.network(
                  widget.imgUrl,
                  fit: widget.zoomed ? BoxFit.contain : BoxFit.cover,
                  width: width,
                  height: height,
                  errorBuilder: (context, url, error) => const SizedBox(
                    height: 400,
                    child: Center(child: CircularProgressIndicator(color: Color.fromARGB(100, 0, 0, 0)),),
                  )
                ) :
                Container(
                  color: Colors.red,
                  constraints: BoxConstraints(
                    maxHeight: height - (height * (95 / 100))
                  ),
                  child: PhotoView(
                      enablePanAlways: true,
                      backgroundDecoration: const BoxDecoration(
                        color: Colors.transparent
                      ),
                      maxScale: 1.3,
                      minScale: PhotoViewComputedScale.contained,
                      imageProvider: NetworkImage(widget.imgUrl)
                  ),
                )
            )
        ),
      ),
    );
  }
}