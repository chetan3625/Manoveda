import 'package:erptransportexpress/Common%20Widgets/UploadDoc.dart';
import 'package:erptransportexpress/Common%20Widgets/common_buttons.dart';
import 'package:erptransportexpress/utils/AllowedDocList.dart';
import 'package:flutter/material.dart';
import 'package:erptransportexpress/models/VehicleModel.dart';
import 'package:erptransportexpress/utils/Colors.dart';

import '../../widgets/custom_form_filed.dart'; // Ensure this is the correct path

class AddNewVehicleForm extends StatefulWidget {
  final bool isEditable;
  final VehicleModel? vehicle; // Make vehicle optional for new entries

  const AddNewVehicleForm({super.key, this.isEditable = false, this.vehicle});

  @override
  State<AddNewVehicleForm> createState() => _AddNewVehicleFormState();
}

class _AddNewVehicleFormState extends State<AddNewVehicleForm> {
  // Use a List for state management, though it might be better handled by a provider or bloc
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

  @override
  void initState() {
    super.initState();
    if (widget.vehicle != null) {
      // Pre-populate fields if a vehicle is passed for editing
      vehNoController.text = widget.vehicle!.vehileNo;
      typeController.text = widget.vehicle!.type;
      capacityController.text = widget.vehicle!.capacity;
      statusController.text = widget.vehicle!.status;
      driverController.text = widget.vehicle!.driver;
      lastServiceController.text = widget.vehicle!.lastService;
      startDateController.text = widget.vehicle!.startdate;
      endDateController.text = widget.vehicle!.enddate;
    }
  }

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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: common_Colors.textColor),
        title: Text(
          widget.isEditable ? "Edit Vehicle" : "Add New Vehicle",
          style: TextStyle(color: common_Colors.textColor),
        ),
        backgroundColor: common_Colors.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.only(left: 60),
          child: SizedBox(
            width: screenWidth * 0.9,
            child: Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vehicle No + Type
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomFormField(
                              isEditable: widget.isEditable,
                              caplebal: "Vehicle No",
                              label: "",
                              hint: "",
                              controller: vehNoController,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomFormField(
                              isEditable: widget.isEditable,
                              caplebal: "Type",
                              label: "",
                              hint: "",
                              controller: typeController,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Capacity
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: CustomFormField(
                        isEditable: widget.isEditable,
                        caplebal: "Capacity",
                        label: "",
                        hint: "",
                        controller: capacityController,
                        keyboardType: TextInputType.number,
                        backgroundColor: Colors.white,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: CustomFormField(
                        isEditable: widget.isEditable,
                        caplebal: "Status",
                        label: "",
                        hint: "",
                        controller: statusController,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: CustomFormField(
                        isEditable: widget.isEditable,
                        caplebal: "Driver",
                        label: "",
                        hint: "",
                        controller: driverController,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: CustomFormField(
                        isEditable: widget.isEditable,
                        caplebal: "Last Service",
                        label: "",
                        hint: "",
                        controller: lastServiceController,
                        backgroundColor: Colors.white,
                      ),
                    ),

                    // Start Date + End Date
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomFormField(
                              isEditable: widget.isEditable,
                              caplebal: "Start Date",
                              label: "",
                              hint: "",
                              controller: startDateController,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomFormField(
                              isEditable: widget.isEditable,
                              caplebal: "End Date",
                              label: "",
                              hint: "",
                              controller: endDateController,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (!widget.isEditable) // Hide upload docs in edit/view mode
                      Row(
                        children: [
                          UploadDoc(
                            title: "Registration Certificate",
                            hintText: "Enter Date",
                            AllowedDcoments: [AllowedDocList.pdf],
                          ),
                          const SizedBox(width: 10),
                          UploadDoc(
                            title: "Insurence",
                            hintText: "Insurence ID",
                            AllowedDcoments: [AllowedDocList.pdf],
                          ),
                          const SizedBox(width: 10),
                          UploadDoc(
                            title: "Ownership Proof",
                            hintText: "Ownership ID",
                            AllowedDcoments: [AllowedDocList.pdf],
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    if (!widget.isEditable) // Hide upload docs in edit/view mode
                      Padding(
                      padding: const EdgeInsets.all(8.0),
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
                                    onPressed: () => Navigator.pop(context),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (widget.isEditable)
                            CommonButton(text: "View Registration Certificate", onPressed: (){},backgroundColor: Colors.green,),
                          if (widget.isEditable)
                            CommonButton(text: "View Insurence Certificate", onPressed: (){},backgroundColor: Colors.green,),
                          if (widget.isEditable)
                            CommonButton(text: "View Ownership Certificate", onPressed: (){},backgroundColor: Colors.green,)
                        ],
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