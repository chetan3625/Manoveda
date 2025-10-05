import 'package:flutter/material.dart';

class CommonDropDownWidget<T> extends StatelessWidget {
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? hintText;
  final Color? fillColor;
  final double borderRadius;
  final Widget? disableHint;
  final bool isReadOnly;

  const CommonDropDownWidget({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.hintText,
    this.fillColor,
    this.borderRadius = 12.0,
    this.disableHint,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2, // subtle shadow
      borderRadius: BorderRadius.circular(borderRadius),
      child: DropdownButtonFormField<T>(
        value: value,
        // DropdownButtonFormField मध्ये items मॅप करताना,
        // DropdownMenuItem च्या child मध्ये Text Overflow सेट केला आहे.
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item.value,
            child: Text(
              item.value.toString(),
              // ✨ मजकूर ओव्हरफ्लो झाल्यास ellipsis ("...") दाखवण्यासाठी
              overflow: TextOverflow.ellipsis,
              maxLines: 1, // एका ओळीत बसवण्यासाठी
            ),
          );
        }).toList(),
        onChanged: isReadOnly ? null : onChanged,
        icon: const Icon(Icons.arrow_drop_down_circle, color: Colors.green),
        isExpanded: true,
        dropdownColor: Colors.white,
        decoration: InputDecoration(
          labelText: hintText,
          floatingLabelStyle: const TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
            overflow: TextOverflow.ellipsis,
          ),
          filled: true,
          fillColor: fillColor ?? Colors.white,
          // बॉर्डर काढण्यासाठी
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          // Focused असतानाची बॉर्डर
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        disabledHint: disableHint,
      ),
    );
  }
}
