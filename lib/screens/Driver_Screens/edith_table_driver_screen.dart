import 'package:erptransportexpress/Common%20Widgets/UploadDoc.dart';
import 'package:flutter/material.dart';

import '../../Common Widgets/uploadComponent.dart';
import '../../widgets/custom_form_filed.dart';

class DriverManagementScreen extends StatefulWidget {
  const DriverManagementScreen({super.key});

  @override
  State<DriverManagementScreen> createState() => _DriverManagementScreenState();
}

class _DriverManagementScreenState extends State<DriverManagementScreen> {
  // Controllers for driver profile
  final TextEditingController nameController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController aadhaarController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver Management"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40), // overall padding for the whole form
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Driver Profile",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16), // spacing

              // Row 1: License Number | Driver Name
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(top: 8, right: 6),
                      child: CustomFormField(
                        caplebal: "License Number",
                        label: "",
                        hint: "Enter license number",
                        controller: licenseController,
                        width: 1.0,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(top: 8, left: 6),
                      child: CustomFormField(
                        caplebal: "Driver Name",
                        label: "",
                        hint: " Enter driver name ",
                        controller: nameController,
                        width: 1.0,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Row 2: Salary (Per Trip / Fixed) | Contact Number
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(top: 8, right: 6),
                      child: CustomFormField(
                        caplebal: " Salary (per Trip / Fixed ",
                        label: "",
                        hint: " Enter the salary ",
                        controller: licenseController,
                        width: 1.0,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(top: 8, left: 6),
                      child: CustomFormField(
                        caplebal: "Contact Number ",
                        label: "",
                        hint: "Enter contact number ",
                        controller: nameController,
                        width: 1.0,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 185,
                      child: Container(
                        padding: const EdgeInsets.only(top: 8, right: 6),
                        child: UploadDoc(
                          title: "Aadhaar Details",
                          hintText: "Upload certificate file",
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 185,
                      child: Container(
                        padding: const EdgeInsets.only(top: 8, left: 6),
                        child: UploadDoc(
                          title: "Medical Fitness Certificate",
                          hintText: "Upload certificate file",
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}
