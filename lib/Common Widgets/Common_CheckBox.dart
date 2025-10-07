import 'package:flutter/material.dart';

class CommonCheckbox extends StatefulWidget {
  String title;
  bool CheckboxBool;
  bool isInputNedded;
  TextEditingController InputController;
  String? hintText;

  CommonCheckbox({
    super.key,
    required this.title,
    required this.CheckboxBool,
    required this.isInputNedded,
    required this.InputController,
    this.hintText
  });

  @override
  State<CommonCheckbox> createState() => _CommonCheckboxState();
}

class _CommonCheckboxState extends State<CommonCheckbox> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      shadowColor: Colors.grey.withOpacity(0.5),
      child: ListTile(
        leading: Checkbox(
          value: widget.CheckboxBool,
          onChanged: (val) {
            setState(() {
              widget.CheckboxBool = val!;
            });
          },
          activeColor: Colors.green,
          checkColor: Colors.white,
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        subtitle: widget.CheckboxBool
            ? SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          child: TextField(
            controller: widget.InputController,
            decoration: InputDecoration(
              hintText: widget.hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding:
              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ),
        )
            : null,
      ),
    );
  }
}
