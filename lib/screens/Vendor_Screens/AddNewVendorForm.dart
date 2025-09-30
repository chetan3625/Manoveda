import 'package:erptransportexpress/Common%20Widgets/Common_DropdownWidget.dart';
import 'package:erptransportexpress/Common%20Widgets/UploadDoc.dart';
import 'package:erptransportexpress/Common%20Widgets/common_buttons.dart';
import 'package:erptransportexpress/models/UploadDocsInputModel.dart';
import 'package:erptransportexpress/utils/AllowedDocList.dart';
import 'package:flutter/material.dart';
import 'package:erptransportexpress/models/VehicleModel.dart';
import 'package:erptransportexpress/utils/Colors.dart';

import '../../models/VendorModel.dart';
import '../../widgets/custom_form_filed.dart';

class AddNewVendorForm extends StatefulWidget {
  final bool isVendorEditable;


  const AddNewVendorForm({super.key, this.isVendorEditable=false});

  @override
  State<AddNewVendorForm> createState() => _EditTableVendorScreen();
}

class _EditTableVendorScreen extends State<AddNewVendorForm> {
  List<VehicleModel> vehicles = [];

  // Controllers



  final TextEditingController vendorNameController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  String? selectedType;
  final TextEditingController vendorBusinessAddress = TextEditingController();
  final TextEditingController vendorMobileNo = TextEditingController();
  /// Vendor Documents List
  final List<UploadDocsInputModel> vendorDocs = [
    UploadDocsInputModel(
      id: "Adhar Card",
      title: "Adhar Card",
      hintText: "Upload Adhar Card",
      allowedDocuments: [AllowedDocList.pdf, AllowedDocList.docx, AllowedDocList.png],
      isCalendar: false,
    ),
    UploadDocsInputModel(
      id: "panCard",
      title: "PAN Card",
      hintText: "Upload PAN Card File",
      allowedDocuments: [AllowedDocList.pdf, AllowedDocList.jpg, AllowedDocList.png],
      isCalendar: false,
    ),
    UploadDocsInputModel(
      id: "bankDetails",
      title: "Bank Details",
      hintText: "",
      allowedDocuments: [AllowedDocList.pdf, AllowedDocList.jpg],
      isCalendar: false,
    ),
  ];





  void _addVendor() {
    if (!mounted) return;


    List<VendorModel> vendors = [];

    setState(() {
      vendors.add(
        VendorModel(
          vendorName: vendorNameController.text,
          contractId: vendorBusinessAddress.text,
          revenueShare: vendorMobileNo.text,
        ),
      );
    });

    // clear controllers
    vendorNameController.clear();
    vendorBusinessAddress.clear();
    vendorMobileNo.clear();

  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: common_Colors.textColor),
        title: Text(
           "Vendor Profile Management",
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
                      // Vendor Profile Management Section (Row)
                      Row(
                        children: [
                          Expanded(
                            child: CustomFormField(
                              isEditable: widget.isVendorEditable,
                              caplebal: "",
                              label: "",
                              hint: "Enter vendor name",
                              controller: vendorNameController,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12), // spacing between fields
                          Expanded(
                            child: CustomFormField(
                              isEditable: widget.isVendorEditable,
                              caplebal: "",
                              label: "",
                              hint: "Vendor Email ID",
                              controller: vendorBusinessAddress,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: CustomFormField(
                              isEditable: widget.isVendorEditable,
                              caplebal: "",
                              label: "",
                              hint: "Vendor Business Address",
                              controller: vendorMobileNo,
                              keyboardType: TextInputType.number,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12), // spacing between fields
                          Expanded(
                            child: CustomFormField(
                              isEditable: widget.isVendorEditable,
                              caplebal: "",
                              label: "",
                              hint: "Mobile No",
                              controller: vendorMobileNo,
                              keyboardType: TextInputType.number,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12), // spacing between fields
                          Expanded(
                            child: CommonDropDownWidget<String>(
                              hintText: "Select Service Type",
                              items:[
                              DropdownMenuItem(value: "Route_Logistics", child: Text("Route Logistics")),
                              DropdownMenuItem(value: "Last mile Delivery", child: Text("Last mile Delivery")),
                              DropdownMenuItem(value: "Booking Partner", child: Text("Booking Partner")),
                              DropdownMenuItem(value: "Frenchaise Partner", child: Text("Frenchaise Partner")),
                              DropdownMenuItem(value: "Revenue Sharing", child: Text("Revenue Sharing")),
                            ],                                 onChanged: (val) {
                              setState(() {
                                selectedType = val;
                                typeController.text = val ?? '';
                              });
                            },
                            ),
                          )
                        ],
                      ),


                      const SizedBox(height: 12),
                      Row(

                        children: [
                          if(!widget.isVendorEditable)
                            UploadDoc(docModel: vendorDocs[0],
                          ),
                            const SizedBox(width: 12), // spacing between fields
                          if(!widget.isVendorEditable)
                            UploadDoc(docModel: vendorDocs[1],
                          ),
                          if(!widget.isVendorEditable)
                            UploadDoc(docModel: vendorDocs[2],
                             ),

                        ],
                      ),

                      const SizedBox(height: 12),
                      if(!widget.isVendorEditable)
                      Center(
                        child: CommonButton(

                          backgroundColor: Colors.green,
                          text: "Save Vendor & Vehicle",
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Confirm Vendor Profile"),
                                content: Text(
                                  "Do you want to save this vendor profile ?\n\n"
                                      "Vendor: ${vendorNameController.text}\n"
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
                                      _addVendor();
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
                      if(widget.isVendorEditable)
                        CommonButton(text: "View Agreement document", onPressed: (){},backgroundColor: Colors.green,)
                    ]


                ),
              ),
            ),
          ),
        ),
      ),

    );
  }
}

