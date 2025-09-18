import 'package:erptransportexpress/Common%20Widgets/UploadDoc.dart';
import 'package:erptransportexpress/Common%20Widgets/common_buttons.dart';
import 'package:erptransportexpress/utils/AllowedDocList.dart';
import 'package:flutter/material.dart';
import 'package:erptransportexpress/models/VehicleModel.dart';
import 'package:erptransportexpress/utils/Colors.dart';

import '../../models/VendorModel.dart';
import '../../widgets/custom_form_filed.dart'; // तुझा colors file

class AddNewVendorForm extends StatefulWidget {
  final bool isVendorEditable;

  const AddNewVendorForm({super.key, this.isVendorEditable=true});

  @override
  State<AddNewVendorForm> createState() => _EditTableVendorScreen();
}

class _EditTableVendorScreen extends State<AddNewVendorForm> {
  List<VehicleModel> vehicles = [];

  // Controllers



  final TextEditingController vendorNameController = TextEditingController();
  final TextEditingController contractIdController = TextEditingController();
  final TextEditingController revenueShareController = TextEditingController();




  void _addVendor() {
    if (!mounted) return;


    List<VendorModel> vendors = [];

    setState(() {
      vendors.add(
        VendorModel(
          vendorName: vendorNameController.text,
          contractId: contractIdController.text,
          revenueShare: revenueShareController.text,
        ),
      );
    });

    // clear controllers
    vendorNameController.clear();
    contractIdController.clear();
    revenueShareController.clear();

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
                              caplebal: "Vendor Name",
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
                              caplebal: "Email ID",
                              label: "",
                              hint: "Enter Email ID",
                              controller: contractIdController,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      CustomFormField(
                        isEditable: widget.isVendorEditable,
                        caplebal: "Revenue Sharing (%)",
                        label: "",
                        hint: "Enter percentage",
                        controller: revenueShareController,
                        keyboardType: TextInputType.number,
                        backgroundColor: Colors.white,
                      ),

                      const SizedBox(height: 12),
                      if(!widget.isVendorEditable)
                      SizedBox(
                        width: 300,   // set your width
                        height: 200,  // set your height
                        child: UploadDoc(
                          title: "Agreement Document",
                          hintText: "Upload agreement file",
                          AllowedDcoments: [
                            AllowedDocList.text,
                            AllowedDocList.pdf,
                            AllowedDocList.docx,
                          ],
                        ),
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
                                  "Do you want to save this vendor & vehicle?\n\n"
                                      "Vendor: ${vendorNameController.text}\n"
                                      "Contract ID: ${contractIdController.text}\n"
                                      "Revenue Share: ${revenueShareController.text}%\n",
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

