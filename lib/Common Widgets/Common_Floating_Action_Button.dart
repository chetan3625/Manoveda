import 'package:erptransportexpress/utils/Colors.dart';
import 'package:flutter/material.dart';

class CommonFloatingActionButton extends StatefulWidget {
  VoidCallback onPressed;
  String text;
  Color backgroundColor=common_Colors.primaryColor;
  Color textColor=common_Colors.textColor;


   CommonFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.text,

  });

  @override
  State<CommonFloatingActionButton> createState() => _CommonFloatingActionButtonState();
}

class _CommonFloatingActionButtonState extends State<CommonFloatingActionButton> {
  Color backgroundColor=common_Colors.primaryColor;
  Color textColor=common_Colors.textColor;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: 190,
      child: FloatingActionButton(
        backgroundColor: widget.backgroundColor,

        child: Text(widget.text,style: TextStyle(
          color: widget.textColor
        ),),
          onPressed: (){
            widget.onPressed();
      }),
    );
  }
}
