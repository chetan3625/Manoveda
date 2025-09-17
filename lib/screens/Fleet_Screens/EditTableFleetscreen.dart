import 'package:erptransportexpress/Common%20Widgets/UploadDoc.dart';
import 'package:erptransportexpress/Common%20Widgets/common_buttons.dart';
import 'package:flutter/material.dart';
import 'package:erptransportexpress/models/VehicleModel.dart';
import 'package:erptransportexpress/utils/Colors.dart';

import '../../Common Widgets/uploadComponent.dart';
import '../../widgets/custom_form_filed.dart';

class EditTableFleetscreen extends StatefulWidget {
  const EditTableFleetscreen({super.key});

  @override
  State<EditTableFleetscreen> createState() => _EditTableFleetscreenState();
}

class _EditTableFleetscreenState extends State<EditTableFleetscreen> {
  List<VehicleModel> vehicles = [];

  // Controllers
  final TextEditingController vehNoController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final TextEditingController driverController = TextEditingController();
  final TextEditingController lastServiceController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  void _addVehicle() {
    if (!mounted) return;

    setState(() {
      vehicles.add(VehicleModel(
        vehNoController.text,
        typeController.text,
        capacityController.text,
        statusController.text,
        driverController.text,
        lastServiceController.text,
        startDateController.text,
        endDateController.text,
      ));
    });

    // clear controllers
    vehNoController.clear();
    typeController.clear();
    capacityController.clear();
    statusController.clear();
    driverController.clear();
    lastServiceController.clear();
    startDateController.clear();
    endDateController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; // ✅ responsive width
    final screenHeight = MediaQuery.of(context).size.height; // ✅ responsive height
    final padding = screenWidth * 0.04; // ✅ dynamic padding
    final spacing = screenHeight * 0.015; // ✅ dynamic spacing

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: common_Colors.textColor),
        title: Text(
          "Vehicle Management",
          style: TextStyle(color: common_Colors.textColor),
        ),
        backgroundColor: common_Colors.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.08),
          child: SizedBox(
            width: screenWidth * 0.9,
            child: Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vehicle No + Type
                    Row(
                      children: [
                        Expanded(
                          child: CustomFormField(
                            caplebal: "Vehicle No",
                            label: "",
                            hint: "",
                            controller: vehNoController,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        SizedBox(width: spacing),
                        Expanded(
                          child: CustomFormField(
                            caplebal: "Type",
                            label: "",
                            hint: "",
                            controller: typeController,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing),

                    CustomFormField(
                      caplebal: "Capacity",
                      label: "",
                      hint: "",
                      controller: capacityController,
                      keyboardType: TextInputType.number,
                      backgroundColor: Colors.white,
                    ),
                    SizedBox(height: spacing),

                    CustomFormField(
                      caplebal: "Status",
                      label: "",
                      hint: "",
                      controller: statusController,
                      backgroundColor: Colors.white,
                    ),
                    SizedBox(height: spacing),

                    CustomFormField(
                      caplebal: "Driver",
                      label: "",
                      hint: "",
                      controller: driverController,
                      backgroundColor: Colors.white,
                    ),
                    SizedBox(height: spacing),

                    CustomFormField(
                      caplebal: "Last Service",
                      label: "",
                      hint: "",
                      controller: lastServiceController,
                      backgroundColor: Colors.white,
                    ),
                    SizedBox(height: spacing),

                    // Start Date + End Date
                    Row(
                      children: [
                        Expanded(
                          child: CustomFormField(
                            caplebal: "Start Date",
                            label: "",
                            hint: "",
                            controller: startDateController,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        SizedBox(width: spacing),
                        Expanded(
                          child: CustomFormField(
                            caplebal: "End Date",
                            label: "",
                            hint: "",
                            controller: endDateController,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing * 2),

                    // Upload Section
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          UploadDoc(
                            title: "Upload RC",
                            hintText: "Enter Date",
                          ),
                          SizedBox(width: spacing),
                          UploadDoc(
                              title: "Insurance", hintText: "Insurance ID"),
                          SizedBox(width: spacing),
                          UploadDoc(
                              title: "Ownership Proof",
                              hintText: "Ownership ID"),
                        ],
                      ),
                    ),
                    SizedBox(height: spacing * 2),

                    // Button
                    Padding(
                      padding: EdgeInsets.all(spacing),
                      child: Center(
                        child: CommonButton(
                          backgroundColor: Colors.green,
                          text: "Add Vehicle",
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Confirm Vehicle"),
                                content: Text(
                                  "Do you want to save this vehicle?\n\n"
                                      "Vehicle No: ${vehNoController.text}\n"
                                      "Type: ${typeController.text}\n"
                                      "Capacity: ${capacityController.text}\n"
                                      "Status: ${statusController.text}\n"
                                      "Driver: ${driverController.text}\n"
                                      "Last Service: ${lastServiceController.text}\n"
                                      "Start Date: ${startDateController.text}\n"
                                      "End Date: ${endDateController.text}",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context),
                                    child: const Text(
                                      "Cancel",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _addVehicle();
                                      Navigator.pop(context);
                                      setState(() {});
                                    },
                                    child: const Text(
                                      "Confirm",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
