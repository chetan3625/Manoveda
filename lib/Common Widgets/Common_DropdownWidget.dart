import 'package:flutter/material.dart';

class CommonDropDownWidget<T> extends StatelessWidget {
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? hintText;
  final Color? fillColor;
  final double borderRadius;

  const CommonDropDownWidget({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.hintText,
    this.fillColor,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(
        filled: true,
        fillColor: fillColor ?? Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        hintText:   hintText,
      ),
      value: value,
      items: items,
      onChanged: onChanged,
    );
  }
}