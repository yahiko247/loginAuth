import 'package:flutter/material.dart';

class EmptyView extends StatelessWidget {
  final String message;
  final bool displayIcon;
  final Color? textColor;
  final EdgeInsets? padding;

  const EmptyView({super.key, required this.message, required this.displayIcon, this.textColor, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(padding: padding ?? const EdgeInsets.fromLTRB(35, 0, 35, 0), child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        displayIcon ? const Icon(Icons.question_mark, color: Colors.red,) : Container(),
        Text(message, textAlign: TextAlign.center, style: TextStyle(color: textColor ?? Colors.black),),
      ],
    ));
  }
}