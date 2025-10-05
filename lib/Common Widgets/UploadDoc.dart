import 'package:erptransportexpress/Common%20Widgets/common_buttons.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:erptransportexpress/models/UploadDocsInputModel.dart';

bool hasone = false;
bool hastow = false;

// import ... (your existing imports)

// bool hasone = false; // These global variables are problematic for multiple instances.
// bool hastow = false; // Remove them. State should be managed within each widget.

class UploadDoc extends StatefulWidget {
  // final String title; // Will come from docModel
  // final String? hintText; // Will come from docModel
  // final List<String> AllowedDcoments; // Will come from docModel
  // final List<UploadDocsInputModel> listUploadDocsInputModel; // Remove, parent will manage the list
  final TextEditingController? dataController; // Renamed for clarity

  final UploadDocsInputModel docModel; // This specific model instance for this widget

  const UploadDoc({ // Use const for constructor
    super.key,
    required this.docModel,
    this.dataController, // Pass if this controller is managed EXTERNALLY for this specific instance
  });

  @override
  State<UploadDoc> createState() => _UploadDocState();
}

class _UploadDocState extends State<UploadDoc> {
  String? fileName;
  String? filePath;
  String? fileExt;

  DateTime? pickedStartDate;
  DateTime? pickedEndDate; // Initialize if needed from docModel.initialEndDate

  // If DataController is NOT passed from parent, initialize it here:
  // late TextEditingController _internalDataController;

  @override
  void initState() {
    super.initState();
    // Initialize based on docModel if needed
    // pickedStartDate = widget.docModel.initialStartDate;
    // pickedEndDate = widget.docModel.initialEndDate ?? DateTime(2025, 3, 31);

    // If you want each UploadDoc to have its own independent TextEditingController
    // and it's not passed from the parent:
    // _internalDataController = TextEditingController(text: widget.docModel.initialTextValue);

    // If dataController IS passed from the parent, you don't need to initialize it here,
    // but ensure the parent is managing its lifecycle and providing the correct one.
  }

  // @override
  // void dispose() {
  //   // If _internalDataController was created:
  //   // _internalDataController.dispose();
  //   super.dispose();
  // }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: widget.docModel.allowedDocuments, // Use from docModel
    );

    if (result != null) {
      if (!mounted) return; // Add mounted check before setState
      setState(() {
        fileName = result.files.first.name;
        filePath = result.files.first.path!;
        fileExt = result.files.first.extension?.toLowerCase();
      });
      debugPrint("Selected extension for ${widget.docModel.title}: $fileExt");
    } else {
      print("No file selected for ${widget.docModel.title}");
    }
  }

  void viewFile() {
    if (filePath != null) {
      OpenFilex.open(filePath!);
    } else {
      debugPrint('No file path available to open for ${widget.docModel.title}.');
    }
  }

  Widget buildFileIcon() {
    // ... your existing buildFileIcon logic ...
    // No changes needed here if it's based on 'fileExt' state variable
    switch (fileExt) {
      case 'pdf':
        return Image.asset('assets/images/filetypeicons/pdf.png', height: 80, width: 80);
      case 'jpg':
      case 'jpeg':
        return Image.asset('assets/images/filetypeicons/jpg.png', height: 80, width: 80);
      case 'png':
        return Image.asset('assets/images/filetypeicons/png.png', height: 80, width: 80);
      case 'xls':
        return Image.asset('assets/images/filetypeicons/xls.png', height: 80, width: 80);
      case 'xlsx':
        return Image.asset('assets/images/filetypeicons/xlsx.png', height: 80, width: 80);
      case 'doc':
      case 'docx':
        return Image.asset('assets/images/filetypeicons/docx.png', height: 80, width: 80);
      default:
        return Image.asset('assets/images/filetypeicons/upload-file.png', height: 80, width: 80);
    }
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    // Consider making baseWidth and widthMultiplier configurable via docModel or theme
    double baseWidth = screenWidth < 800 ? screenWidth * 0.45 : screenWidth * 0.22; // Adjusted for multiple items

    // Use widget.docModel.isCalendar and widget.dataController for conditions
    bool shouldShowTextField = widget.dataController != null;
    bool shouldShowCalendar = widget.docModel.isCalendar;

    double widthMultiplier = 1.0;
    // Simplified width logic (adjust as needed)
    if (shouldShowTextField && shouldShowCalendar) {
      widthMultiplier = 1.2; // May need more space
    } else if (shouldShowTextField || shouldShowCalendar) {
      widthMultiplier = 1.0;
    } else {
      widthMultiplier = 0.8; // Only file picker
    }

    return SizedBox(
      
      width: baseWidth * widthMultiplier,
      child: Card(
        elevation: 3,
        color: Colors.white30,
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
            mainAxisSize: MainAxisSize.min, // Important for fitting in a list/row
            children: [
              Text(
                widget.docModel.title, // Use from docModel
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start, // Align items to top
                children: [
                  InkWell(
                    onTap: pickFile, // Directly call method
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: buildFileIcon(),
                    ),
                  ),
                  // Conditionally add spacing only if other elements are present
                  if (shouldShowTextField || shouldShowCalendar)
                    const SizedBox(width: 10),

                  // Flexible wrapper for TextField and Calendar Column
                  if (shouldShowTextField || shouldShowCalendar)
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (shouldShowTextField)
                            TextField(
                              controller: widget.dataController, // Or _internalDataController
                              decoration: InputDecoration(
                                hintText: widget.docModel.hintText, // Use from docModel
                                border: const OutlineInputBorder(),
                                isDense: true, // Make it more compact
                              ),
                              style: TextStyle(fontSize: 13), // Smaller font
                            ),
                          if (shouldShowTextField && shouldShowCalendar)
                            const SizedBox(height: 8), // Spacing between them
                          if (shouldShowCalendar) ...[ // Use spread operator for conditional list
                            // Start Date Button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Flexible(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      DateTime? date = await showDatePicker(
                                        context: context,
                                        initialDate: pickedStartDate ?? DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                      );
                                      if (date != null && mounted) {
                                        setState(() {
                                          pickedStartDate = date;
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.white),
                                    label: Text(
                                      pickedStartDate != null
                                          ? "${pickedStartDate!.day}/${pickedStartDate!.month}/${pickedStartDate!.year}"
                                          : "Start Date",
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      backgroundColor: Colors.lightBlue[400],
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      elevation: 2,
                                      textStyle: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      DateTime? date = await showDatePicker(
                                        context: context,
                                        initialDate:DateTime(2025,3,30), // Use DateTime.now() if pickedEndDate is null
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                      );
                                      if (date != null && mounted) {
                                        setState(() {
                                          pickedEndDate = DateTime(2025,3,30);
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.white),
                                    label: Text(
                                      pickedEndDate != null
                                          ? "${pickedEndDate!.day}/${pickedEndDate!.month}/${pickedEndDate!.year}"
                                          : "End Date",
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12),
                                      overflow: TextOverflow.ellipsis,


                                    ),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      backgroundColor: Colors.blue[700],
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      elevation: 2,
                                      textStyle: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // End Date Button

                          ],
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (fileName != null)
                Text(
                  "Selected: $fileName",
                  style: const TextStyle(fontSize: 12, color: Colors.black54), // Smaller font
                  overflow: TextOverflow.ellipsis,
                ),
              if (fileName == null)
                const Text(
                  "No file selected",
                  style: TextStyle(fontSize: 12, color: Colors.black54), // Smaller font
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Better spacing for buttons
                children: [
                  Expanded( // Make buttons take available space
                    child: CommonButton( // Assuming CommonButton can be sized
                      text: "Select", // Shorter text
                      onPressed: pickFile,
                      // You might need to adjust CommonButton's internal padding/style
                    ),
                  ),
                  if (fileName != null) ...[ // Use spread operator
                    const SizedBox(width: 8),
                    Expanded(
                      child: CommonButton(
                        text: "View",
                        onPressed: viewFile,
                        backgroundColor: Colors.deepPurple,
                      ),
                    ),
                  ]
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
