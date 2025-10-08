import 'package:erptransportexpress/Common%20Widgets/common_buttons.dart';
import 'package:flutter/material.dart';

class CommonAlertBox extends StatelessWidget {
  final String title;
  final Widget content;
  final String positiveText;
  final VoidCallback onPositivePressed;
  final String negativeText;
  final VoidCallback onNegativePressed;

  const CommonAlertBox({
    super.key,
    required this.title,
    required this.content,
    required this.positiveText,
    required this.onPositivePressed,
    required this.negativeText,
    required this.onNegativePressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(child: content),
      actions: <Widget>[
        CommonButton(
          text: negativeText,
          onPressed: (){
            Navigator.of(context).pop();
            onNegativePressed();
          },
        ),
        const SizedBox(width: 10),
        CommonButton(
          backgroundColor: Colors.green,
          text: positiveText,
          onPressed: (){
            // Pop the dialog first
            Navigator.of(context).pop();
            // Then execute the provided callback
            onPositivePressed();
          },
        ),
      ],
    );
  }
}