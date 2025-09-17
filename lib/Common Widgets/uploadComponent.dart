
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'UploadDoc.dart';
import 'common_buttons.dart';

class _UploadDocState extends State<UploadDoc> {
  String? fileName;

  void pickFile() async {

    // Corrected code: Add the type: FileType.custom parameter
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, // <-- This line is the fix
        allowedExtensions: [
          "pdf",
          "doc",
          "docx",
          "xls",
          "xlsx",
          "txt",
          "png",
          "jpg",

        ]
    );
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
        : screenWidth * 0.20;
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    widget.title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Center(
                    child: Text(
                      widget.title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
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
                child: fileName == null ? const Text("") : Text("Selected: $fileName"),
              ),
              const SizedBox(height: 8),

              // Upload Button
              CommonButton(
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