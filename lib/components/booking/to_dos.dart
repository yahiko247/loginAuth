import 'package:flutter/material.dart';
import 'package:practice_login/components/chat/warning_dialog.dart';

class ToDos extends StatefulWidget {
  final List<dynamic> toDos;
  const ToDos({super.key, required this.toDos});

  @override
  State<ToDos> createState() => _ToDosState();
}

class _ToDosState extends State<ToDos> {
  late List<dynamic> _toDos;
  final PageController _toDoController = PageController(initialPage: 0);
  int _toDoIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _toDos = widget.toDos;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        width: width,
        child: Container(
            height: 150,
            child: Stack(
              children: [
                PageView.builder(
                  physics: AlwaysScrollableScrollPhysics(),
                  controller: _toDoController,
                  onPageChanged: (index) {
                    setState(() {
                      _toDoIndex = index;
                    });
                  },
                  scrollDirection: Axis.horizontal,
                  itemCount: _toDos.length,
                  itemBuilder: (context, index) {
                    return Padding(
                        padding: EdgeInsets.only(bottom: 5, left: 25, right: 25),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            color: Color.fromRGBO(225, 225, 225, 1),
                          ),
                          child: RichText(
                            text: TextSpan(
                                text: '${_toDos[index]['title']}\n',
                                style: TextStyle(fontSize: 14.5, color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: '${_toDos[index]['description']}',
                                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.normal, color: Color.fromRGBO(100, 100, 100, 1)),
                                  )
                                ]
                            ),
                          ),
                        ),
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(right: width - (width * 0.935), bottom: 3),
                  child: Align(
                      alignment: Alignment.bottomRight,
                      child: AnimatedOpacity(
                        opacity: _toDoIndex == _toDos.length - 1 ? 0 : 1,
                        duration: Duration(milliseconds: 300),
                        child: IconButton(
                            onPressed: () {
                              _toDoController.animateToPage(_toDos.length - 1, duration: Duration(milliseconds: 400), curve: Curves.linearToEaseOut);
                            },
                            icon: Icon(Icons.arrow_circle_right_outlined, color: Color.fromRGBO(150, 150, 150, 0.7),)
                        ),
                      )
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: width - (width * 0.935), bottom: 3),
                  child: Align(
                      alignment: Alignment.bottomLeft,
                      child: AnimatedOpacity(
                        opacity: _toDoIndex == 0 ? 0 : 1,
                        duration: Duration(milliseconds: 300),
                        child: IconButton(
                            onPressed: () {
                              _toDoController.animateToPage(0, duration: Duration(milliseconds: 400), curve: Curves.linearToEaseOut);
                            },
                            icon: Icon(Icons.arrow_circle_left_outlined, color: Color.fromRGBO(150, 150, 150, 0.7),)
                        ),
                      )
                  ),
                )
              ],
            )
        )
    );
  }
}