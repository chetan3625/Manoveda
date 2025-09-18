import 'package:erptransportexpress/Common%20Widgets/common_buttons.dart';
import 'package:erptransportexpress/screens/Documents_Screens/documents_screen.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:open_filex/open_filex.dart';

class UploadDoc extends StatefulWidget {
  final String title;
  final String hintText;
  final List<String> AllowedDcoments;

  const UploadDoc({
    super.key,
    required this.title,
    required this.hintText,
    required this.AllowedDcoments,

  });

  @override
  State<UploadDoc> createState() => _UploadDocState();
}

class _UploadDocState extends State<UploadDoc> {
  String? fileName;
  String? filePath;



 Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: widget.AllowedDcoments,
        /*[
          "pdf",
          "doc",
          "docx",
          "xls",
          "xlsx",
          "txt",
          "png",
          "jpg",

        ]*/
    );
    if (result != null) {
      setState(() {
        fileName = result.files.first.name;
        filePath = result.files.first.path!;
      });
    } else {
      print("No file selected");
    }
  }
  void viewfile(){
   if(filePath!=null){
    OpenFilex.open(filePath!);
   }
   else{
     debugPrint('No file path available to open.');

   }

  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth < 600 ? screenWidth * 0.50 : screenWidth * 0.20;
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
              // Title
              Text(
                widget.title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
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
                    horizontal: 10,
                    vertical: 5,
                  ),
                ),
              ),

              // File name preview
              if (fileName != null) ...[
                const SizedBox(height: 8),
                Text(
                  "Selected: $fileName",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 8),

              // Upload Button
              Row(
                children: [
                  CommonButton(
                    text: "Select Document",
                    onPressed: pickFile,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  if (fileName != null)

                    CommonButton(text: "View", onPressed: (){
                      viewfile();
                    },backgroundColor: Colors.deepPurple,)

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
