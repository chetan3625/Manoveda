import 'package:erptransportexpress/Common%20Widgets/CommonAppBar.dart';
import 'package:erptransportexpress/Common%20Widgets/UploadDoc.dart';
import 'package:erptransportexpress/Common%20Widgets/common_buttons.dart';
import 'package:erptransportexpress/utils/AllowedDocList.dart';
import 'package:flutter/material.dart';
import '../../widgets/custom_form_filed.dart';

class AddNewDriverForm extends StatefulWidget {
  final bool isDriverEditable; // Make this a bool
  const AddNewDriverForm({super.key, this.isDriverEditable = false});

  @override
  State<AddNewDriverForm> createState() => _AddNewDriverFormState();
}

class _AddNewDriverFormState extends State<AddNewDriverForm> {
  // Controllers for driver profile
  final TextEditingController nameController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController aadhaarController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: const Text("Driver Management")),
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
                        isEditable: widget.isDriverEditable,
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
                        isEditable: widget.isDriverEditable,
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
                        isEditable: widget.isDriverEditable,
                        caplebal: " Salary (per Trip / Fixed) ",
                        label: "",
                        hint: " Enter the salary ",
                        controller: salaryController, // Corrected controller
                        width: 1.0,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(top: 8, left: 6),
                      child: CustomFormField(
                        isEditable: widget.isDriverEditable,
                        caplebal: "Contact Number ",
                        label: "",
                        hint: "Enter contact number ",
                        controller: contactController, // Corrected controller
                        width: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Corrected Conditional Logic
              if (!widget.isDriverEditable) ...[
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
                            AllowedDcoments: const [AllowedDocList.pdf],
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
                            AllowedDcoments: const [AllowedDocList.pdf],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (widget.isDriverEditable) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CommonButton(
                      backgroundColor: Colors.green,
                      text: "View Aadhaar Detail",
                      onPressed: () {},
                    ),
                    const SizedBox(width: 10),
                    CommonButton(
                      backgroundColor: Colors.green,
                      text: "View Medical Fitness Certificate",
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}