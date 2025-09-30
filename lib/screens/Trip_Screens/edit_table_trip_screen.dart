import 'package:erptransportexpress/Common%20Widgets/UploadDoc.dart';
import 'package:erptransportexpress/models/UploadDocsInputModel.dart';
import 'package:erptransportexpress/utils/AllowedDocList.dart';
import 'package:flutter/material.dart';
import '../../Common Widgets/common_buttons.dart';
import '../../widgets/custom_form_filed.dart';

class EditTableTripScreen extends StatefulWidget {
  const EditTableTripScreen({super.key});

  @override
  State<EditTableTripScreen> createState() => _EditTableTripScreenState();
}

class _EditTableTripScreenState extends State<EditTableTripScreen> {
  final TextEditingController tripIdController = TextEditingController();
  final TextEditingController lrNumberController = TextEditingController();
  final TextEditingController routeController = TextEditingController();
  final TextEditingController vehicleController = TextEditingController();
  final TextEditingController driverController = TextEditingController();

  /// Trip-related documents list
  final List<UploadDocsInputModel> tripDocs = [
    UploadDocsInputModel(
      id: "pod",
      title: "POD Document",
      hintText: "Upload POD File",
      allowedDocuments: [AllowedDocList.pdf, AllowedDocList.jpg, AllowedDocList.png],
      isCalendar: false,
    ),
    UploadDocsInputModel(
      id: "ewaybill",
      title: "E-Way Bill",
      hintText: "Upload E-Way Bill",
      allowedDocuments: [AllowedDocList.pdf, AllowedDocList.jpg],
      isCalendar: false,
    ),
    UploadDocsInputModel(
      id: "invoice",
      title: "Invoice",
      hintText: "Upload Invoice File",
      allowedDocuments: [AllowedDocList.pdf, AllowedDocList.png],
      isCalendar: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trip & LR Management"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip Details
            const Text("Trip Details",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            CustomFormField(
              caplebal: "Trip ID",
              label: "",
              hint: "Enter Trip ID",
              controller: tripIdController,
              width: 0.9,
            ),
            const SizedBox(height: 12),
            CustomFormField(
              caplebal: "LR Number",
              label: "",
              hint: "Enter LR Number",
              controller: lrNumberController,
              width: 0.9,
            ),
            const SizedBox(height: 12),
            CustomFormField(
              caplebal: "Route",
              label: "",
              hint: "Enter Route",
              controller: routeController,
              width: 0.9,
            ),

            const SizedBox(height: 24),

            // Vehicle & Driver Assignment
            const Text("Vehicle & Driver",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            CustomFormField(
              caplebal: "Vehicle",
              label: "",
              hint: "Select Vehicle",
              controller: vehicleController,
              width: 0.9,
            ),
            const SizedBox(height: 12),
            CustomFormField(
              caplebal: "Driver",
              label: "",
              hint: "Select Driver",
              controller: driverController,
              width: 0.9,
            ),

            const SizedBox(height: 24),

            // Trip Documents Upload
            const Text("Trip Documents Upload",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: tripDocs.map((doc) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: 320,
                      height: 200,
                      child: UploadDoc(
                        docModel: doc,
                        dataController: TextEditingController(),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Save / Update Buttons
            CommonButton(
              backgroundColor: Colors.green,
              text: "Save / Update LR",
              onPressed: () {
                // handle save
              },
            ),
            const SizedBox(height: 12),
            CommonButton(
              backgroundColor: Colors.blue,
              text: "Print / Download LR",
              onPressed: () {
                // handle print/download
              },
            ),
          ],
        ),
      ),
    );
  }
}
