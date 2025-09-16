import 'package:erptransportexpress/utils/Colors.dart';
import 'package:erptransportexpress/Common%20Widgets/common_buttons.dart';
import 'package:flutter/material.dart';


class CommonSearchBar extends StatefulWidget {
  final bool isVisibileFloating = true;
  final String screen;

  const CommonSearchBar({super.key, required this.screen});

  @override
  State<CommonSearchBar> createState() => _CommonSearchBarState();
}

class _CommonSearchBarState extends State<CommonSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Container(
        width: screenWidth - screenWidth * 0.06,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: common_Colors.primaryColor.withOpacity(0.4), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Text(
                widget.screen,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: common_Colors.primaryColor,
                ),
              ),
              const Spacer(),
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade50, Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: common_Colors.primaryColor.withOpacity(0.5), width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: common_Colors.primaryColor.withOpacity(0.7)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: "Search in ${widget.screen}",
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: common_Colors.primaryColor,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                        onPressed: () {
                          String searchText = _controller.text;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Searching for: $searchText")),
                          );
                        },
                        label: const Text("Search", style: TextStyle(color: Colors.white, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              CommonButton(
                text: "Filters",
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
