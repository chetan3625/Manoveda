import 'package:flutter/material.dart';

import '../utils/Colors.dart';

class CommonAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Widget title;
  const CommonAppBar({super.key, required this.title});

  @override
  State<CommonAppBar> createState() => _CommonAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CommonAppBarState extends State<CommonAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      backgroundColor: common_Colors.primaryColor,
      title: widget.title,
      titleTextStyle: TextStyle(
        color: common_Colors.textColor, // Changed title color here
        fontSize: 20, // Example of another style property
        fontWeight: FontWeight.bold,
      ),
    );
  }
}