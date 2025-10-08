import 'package:flutter/material.dart';

class CommonCheckbox extends StatelessWidget {
  final String title;
  final bool CheckboxBool;
  final bool isInputNedded;
  final TextEditingController InputController;
  final String? hintText;
  // FIX 1: Add the required callback to notify the parent
  final ValueChanged<bool?>? onChanged;

  const CommonCheckbox({
    super.key,
    required this.title,
    required this.CheckboxBool,
    required this.isInputNedded,
    required this.InputController,
    this.hintText,
    this.onChanged, // FIX 2: Include it in the constructor
  });

  @override
  Widget build(BuildContext context) {
    // Note: Changed to StatelessWidget as state management is delegated to the parent
    // but kept the build method structure the same.

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      shadowColor: Colors.grey.withOpacity(0.5),
      child: ListTile(
        leading: Checkbox(
          value: CheckboxBool, // Use the value passed from the parent
          // FIX 3: Call the provided onChanged callback to inform the parent
          onChanged: onChanged,
          activeColor: Colors.green,
          checkColor: Colors.white,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        subtitle: CheckboxBool && isInputNedded
            ? SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          child: TextField(
            controller: InputController,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ),
        )
            : null,
      ),
    );
  }
}