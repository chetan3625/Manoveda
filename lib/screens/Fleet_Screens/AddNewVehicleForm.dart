import 'package:erptransportexpress/Common%20Widgets/Common_DropdownWidget.dart';
import 'package:erptransportexpress/Common%20Widgets/UploadDoc.dart';
import 'package:erptransportexpress/Common%20Widgets/common_buttons.dart';
import 'package:erptransportexpress/models/UploadDocsInputModel.dart';
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
  List<VehicleModel> vehicles = [];
  String? selectedType; // <-- Use this for dropdown value

  // Controllers
  final TextEditingController vehNoController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final TextEditingController driverController = TextEditingController();
  final TextEditingController lastServiceController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController insurenceController = TextEditingController();


  @override
  void initState() {
    super.initState();

    if (widget.vehicle != null) {
      vehNoController.text = widget.vehicle!.vehileNo;
      typeController.text = widget.vehicle!.type;
      capacityController.text = widget.vehicle!.capacity;
      statusController.text = widget.vehicle!.status;
      driverController.text = widget.vehicle!.driver;
      lastServiceController.text = widget.vehicle!.lastService;
      startDateController.text = widget.vehicle!.startdate;
      endDateController.text = widget.vehicle!.enddate;
      selectedType = widget.vehicle!.type; // Pre-select dropdown if editing
    }
  }
  final List<UploadDocsInputModel> docs = [
    UploadDocsInputModel(
      id: "RC_Book",
      title: "RC Book",
      allowedDocuments: ["pdf", "jpg", "png"],
      isCalendar: false, // PAN साठी date लागणार नाही
    ),
    UploadDocsInputModel(
      id: "insurance",
      title: "Insurance",
      hintText: "Enter amount",
      allowedDocuments: ["pdf", "jpg"],
      isCalendar: true, // Insurance ला start-end date लागतील
    ),
    UploadDocsInputModel(
        id: "Ownership_Proof",
        title: "Ownership Proof",
        allowedDocuments: ["pdf,jpg"],
        isCalendar: false),
    UploadDocsInputModel(
        id: "Tax_document",
        title: "Tax Documents",
        allowedDocuments: ["pdf,doc"],
        isCalendar: false)
  ];
  final TextEditingController panController = TextEditingController();
  final TextEditingController insuranceController = TextEditingController();


  void _addVehicle() {
    if (!mounted) return;

    setState(() {
      vehicles.add(VehicleModel(
        vehNoController.text,
        selectedType ?? '', // Use dropdown value
        capacityController.text,
        statusController.text,
        driverController.text,
        lastServiceController.text,
        startDateController.text,
        endDateController.text,
      ));
    });

    vehNoController.clear();
    typeController.clear();
    capacityController.clear();
    statusController.clear();
    driverController.clear();
    lastServiceController.clear();
    startDateController.clear();
    endDateController.clear();
    setState(() {
      selectedType = null;
    });
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
                              caplebal: "",
                              label: "Vehicle No",
                              hint: "",
                              controller: vehNoController,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                           Expanded(
                            child: CustomFormField(
                              isEditable: widget.isEditable,
                              caplebal: "",
                              label: "Company Name",
                              hint: "",
                              controller:companyNameController ,
                              backgroundColor: Colors.white,
                            ),
                          ),

                        ],
                      ),
                    ),

                    // Capacity
                    Row(
                      children: [
                        Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CommonDropDownWidget<String>(
                                hintText: "Select Vehicle Type",
                                fillColor: Colors.grey[200],
                                items: const [
                                  DropdownMenuItem(value: "Maxi Truck", child: Text("Maxi Truck")),
                                  DropdownMenuItem(value: "Open Body Truck", child: Text("Open Body Truck")),
                                  DropdownMenuItem(value: "Container Truck", child: Text("Container Truck")),
                                  DropdownMenuItem(value: "Box Truck", child: Text("Box Truck")),
                                  DropdownMenuItem(value: "Multi-axle", child: Text("Multi-axle")),
                                ],
                                value: selectedType,
                                onChanged: (val) {
                                  setState(() {
                                    selectedType = val;
                                    typeController.text = val ?? '';
                                  });
                                },

                              ),
                            ),
                          ),
                          SizedBox(width: 1),
                        Expanded(
                          child: CommonDropDownWidget(
                            hintText: "Select Status",
                            fillColor: Colors.grey[200],
                            items: [
                            DropdownMenuItem(value: "PayLoad", child: Text("Pay Load")),
                            DropdownMenuItem(value: "GrossWeight", child: Text("Gross Weight")),
                          ], onChanged: (String? value) { setState(() {
                            capacityController.text = value ?? '';
                          }); }, value: capacityController.text.isEmpty ? null : capacityController.text
                          ),
                        ),

                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: CustomFormField(
                        isEditable: widget.isEditable,
                        caplebal: "",
                        label: "Driver Name",
                        hint: "",
                        controller: driverController,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: CustomFormField(
                        isEditable: widget.isEditable,
                        caplebal: "",
                        label: "Last Service",
                        hint: "",
                        controller: lastServiceController,
                        backgroundColor: Colors.white,
                      ),
                    ),

                    // Start Date + End Date

                    const SizedBox(height: 20),
                    if (!widget.isEditable)
                      // Inside SingleChildScrollView Row
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            UploadDoc(
                              docModel: docs[0],
                            ),
                            UploadDoc(
                                docModel: docs[1],
                                dataController: insuranceController,
                            ),
                            UploadDoc(docModel: docs[2]),
                            UploadDoc(docModel: docs[3]),


                            // UploadDoc(
                            //   docModel: UploadDocsInputModel(
                            //     "Registration Certificate",
                            //     "Upload certificate file",
                            //     "file",
                            //     TextEditingController(),
                            //   ),
                            //   listUploadDocsInputModel: [
                            //     UploadDocsInputModel(
                            //       "Registration Certificate",
                            //       "Upload certificate file",
                            //       "file",
                            //       TextEditingController(),
                            //   ],
                            //   AllowedDcoments: [
                            //     AllowedDocList.pdf,
                            //     AllowedDocList.jpg,
                            //     AllowedDocList.png,
                            //   ],
                            // ),
                            // const SizedBox(width: 10),
                            // UploadDoc(
                            //   listUploadDocsInputModel:[
                            //     UploadDocsInputModel(
                            //       "Insurence",
                            //       "Enter amount or select date",
                            //       "calendar",
                            //       insurenceController,
                            //     ),
                            //   ], title: '', AllowedDcoments: [AllowedDocList.pdf,],
                            //
                            // ),
                            // const SizedBox(width: 10),
                            // UploadDoc(
                            //   docModel: UploadDocsInputModel(
                            //     "Ownership Proof",
                            //     "Enter Ownership ID",
                            //     "file",
                            //     TextEditingController(),
                            //   ),
                            //   allowedDocuments: [
                            //     AllowedDocList.pdf,
                            //   ],
                            // ),
                            // const SizedBox(width: 10),
                            // UploadDoc(
                            //   docModel: UploadDocsInputModel(
                            //     "Tax Certificate",
                            //     "Upload tax certificate",
                            //     "file",
                            //     TextEditingController(),
                            //   ),
                            //   allowedDocuments: [
                            //     AllowedDocList.pdf,
                            //     AllowedDocList.jpg,
                            //     AllowedDocList.png,
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                    if (!widget.isEditable)
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
                                    "Type: ${selectedType ?? ''}\n"
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
                          CommonButton(
                            text: "View Registration Certificate",
                            onPressed: () {},
                            backgroundColor: Colors.green,
                          ),
                        if (widget.isEditable)
                          CommonButton(
                            text: "View Insurence Certificate",
                            onPressed: () {},
                            backgroundColor: Colors.green,
                          ),
                        if (widget.isEditable)
                          CommonButton(
                            text: "View Ownership Certificate",
                            onPressed: () {},
                            backgroundColor: Colors.green,
                          )
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