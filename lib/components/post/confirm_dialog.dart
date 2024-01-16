import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmButtonText;
  final VoidCallback confirmAction;
  final EdgeInsets? padding;

  const ConfirmDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.confirmButtonText,
    required this.confirmAction,
    this.padding
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(30),
      surfaceTintColor: Colors.grey,
      alignment: Alignment.center,
      title: Text(title, textAlign: TextAlign.center,),
      content: Text(message, textAlign: TextAlign.center,),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            OutlinedButton(
              style: ButtonStyle(
                  enableFeedback: true,
                  side: MaterialStateProperty.all<BorderSide>(const BorderSide(color: Colors.green)),
                  overlayColor: MaterialStateProperty.all<Color>(const Color.fromARGB(15, 0, 255, 0))
              ),
              onPressed: () {
                confirmAction();
              },
              child: Text(confirmButtonText, style: const TextStyle(color: Colors.green)),
            ),
            ElevatedButton(
              style: ButtonStyle(
                  shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
                  backgroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(200, 200, 200, 100)),
                  overlayColor: MaterialStateProperty.all<Color>(const Color.fromARGB(25, 50, 50, 50))
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ],
    );
  }
}