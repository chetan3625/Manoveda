import 'package:erptransportexpress/Common%20Widgets/UploadDoc.dart';
import 'package:erptransportexpress/utils/AllowedDocList.dart';
import 'package:flutter/material.dart';
import '../../Common Widgets/common_buttons.dart';
import '../../Common Widgets/uploadComponent.dart';
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

            // POD Upload
            const Text("POD Upload",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            SizedBox(
              width: 350,
              height: 220,
              child: UploadDoc(
                title: "POD Document",
                hintText: "Upload POD file",
                AllowedDcoments: [
                  AllowedDocList.pdf,
                  AllowedDocList.document,
                  AllowedDocList.docx,
                ],
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
