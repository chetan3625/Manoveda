import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomFormField extends StatelessWidget {
  final String caplebal; // top label
  final String label; // inside label (optional)
  final String hint;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final double? width; // fraction of screen width (0.0 - 1.0)
  final double? height; // fraction of screen height (0.0 - 1.0)
  final Color? backgroundColor;

  const CustomFormField({
    Key? key,
    required this.caplebal,
    required this.label,
    required this.hint,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.width, // 0.8 = 80% of screen width
    this.height, // 0.08 = 8% of screen height
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: SizedBox(
        width: width != null ? screenWidth * width! : double.infinity,
        height: height != null ? screenHeight * height! : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top label
            if (caplebal.isNotEmpty)
              Text(
                "  $caplebal",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            if (caplebal.isNotEmpty) const SizedBox(height: 6),

            // Input field
            TextFormField(
              controller: controller,
              obscureText: isPassword,
              keyboardType: keyboardType,
              validator: validator,
              inputFormatters: inputFormatters,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: backgroundColor ?? Colors.grey.shade100,
                labelText: label.isNotEmpty ? label : null,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
                prefixIcon: prefixIcon,
                suffixIcon: suffixIcon,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.shade400,
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.blue,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 1.5,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 1.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
