import 'package:erptransportexpress/Common%20Widgets/common_buttons.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class uploadDoc extends StatefulWidget {
  final String title;
  final String hintText;

  const uploadDoc({
    super.key,
    required this.title,
    required this.hintText,
  });

  @override
  State<uploadDoc> createState() => _uploadDocState();
}

class _uploadDocState extends State<uploadDoc> {
  String? fileName;

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        fileName = result.files.first.name;
        print(fileName);
      });
    } else {
      print("No file selected");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth < 600
        ? screenWidth * 0.50
        : screenWidth * 0.15;
    double cardHeight = 230;

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: Card(
        elevation: 3,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Colors.blue,
            width: 2,
          ),
        ),
        shadowColor: Colors.black12,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Row: icon + title
              Row(
                children: [

                  Text(
                    widget.title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // TextField
              TextField(
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                ),
              ),
              Container(
                child: fileName == null ?Text(""):Text("Selected: $fileName"),
              ),
              const SizedBox(height: 8),

              // Upload Button
              commonButton(
                text: "Select Document",
                onPressed: pickFile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
