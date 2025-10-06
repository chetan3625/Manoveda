import 'package:erptransportexpress/Common%20Widgets/CommonAppBar.dart';
import 'package:erptransportexpress/Common%20Widgets/Common_DropdownWidget.dart';
import 'package:erptransportexpress/Common%20Widgets/UploadDoc.dart';
import 'package:erptransportexpress/Common%20Widgets/common_buttons.dart';
import 'package:erptransportexpress/models/UploadDocsInputModel.dart';
import 'package:flutter/material.dart';
import '../../widgets/custom_form_filed.dart';

class AddNewEmployee extends StatefulWidget {
  final bool isDriverEditable; // Editable mode
  const AddNewEmployee({super.key, this.isDriverEditable = false});

  @override
  State<AddNewEmployee> createState() => _AddNewEmployeeState();
}

class _AddNewEmployeeState extends State<AddNewEmployee> {
  // Controllers
  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController driverEmailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController driverAddressController = TextEditingController();
  String? selectedType; // <-- Use this for dropdown value
  final TextEditingController typeController = TextEditingController();



  // Driver Documents List using model
  final List<UploadDocsInputModel> driverDocs = [
    UploadDocsInputModel(
      id: "adhar",
      title: "Adhar Card(KYC)",
      allowedDocuments: ["pdf"],
      isCalendar: false,
    ),
    UploadDocsInputModel(
      id: "pan",
      title: "Pan(KYC)",
      allowedDocuments: ["jpg", "png"],
      isCalendar: false,
    ),
    UploadDocsInputModel(
      id: "bankpassbook",
      title: "Bank Passbook",
      allowedDocuments: ["pdf", "jpg", "png"],
      isCalendar: false,
    ),
    UploadDocsInputModel(
      id: "salary",
      title: "Salary",
      allowedDocuments: ["pdf", "jpg", "png"],
      isCalendar: false,
    ),
    UploadDocsInputModel(
      id: "Photo",
      title: "Passport photo",
      allowedDocuments: ["pdf", "jpg", "png"],
      isCalendar: false,
    ),
    UploadDocsInputModel(
      id: "Driving License",
      title: "Driving License",
      allowedDocuments: ["pdf", "jpg", "png"],
      isCalendar: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: const Text("Employee Management")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              // Row 1: License Number | Driver Name
              Row(
                children: [
                  Expanded(
                    child: CustomFormField(
                      allowOnlyNumbers: false,
                      isEditable: widget.isDriverEditable,
                      caplebal: "",
                      label: "",
                      hint: "Enter Employee name",
                      controller: driverNameController,
                      width: 1.0,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomFormField(
                      allowOnlyNumbers: false,
                      isEditable: widget.isDriverEditable,
                      caplebal: "",
                      label: "",
                      hint: "Enter Driver Email",
                      controller: driverEmailController,
                      width: 1.0,
                    ),
                  ),

                ],
              ),

              const SizedBox(height: 16),

              // Row 2: Salary | Contact Number
              Row(
                children: [
                  Expanded(
                    child: CustomFormField(
                      allowOnlyNumbers: true,
                      isEditable: widget.isDriverEditable,
                      caplebal: "",
                      label: "",
                      hint: "Mobile No",
                      controller: contactController,
                      width: 1.0,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomFormField(
                      allowOnlyNumbers: false,
                      isEditable: widget.isDriverEditable,
                      caplebal: "",
                      label: "",
                      hint: "Enter Address ",
                      controller: driverAddressController,
                      width: 1.0,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(child:CommonDropDownWidget(
                    hintText: "Enter the Type",
                      items: [
                    DropdownMenuItem(child: Text("Permenant"),value: "Permenant",),
                    DropdownMenuItem(child: Text("Contracted"),value: "Contracted",)
                  ], onChanged: (val){
                    setState(() {
                      selectedType = val as String?;
                      typeController.text = val ?? '';
                    });
                  })
                  // DropdownButton(
                  //   borderRadius: BorderRadius.circular(6),
                  //   hint: Text("Select Deal Type"),
                  //   value: selectedType,
                  //   isExpanded: true,
                  //   items: [
                  //
                  //     DropdownMenuItem(value: "permenant", child: Text("Permenant")),
                  //     DropdownMenuItem(value: "contracted", child: Text("Contracted")),
                  //   ],
                  //   onChanged: (val) {
                  //     setState(() {
                  //       selectedType = val;
                  //       typeController.text = val ?? '';
                  //     });
                  //   },
                  // )),

                  )],
              ),

              const SizedBox(height: 16),

              // UploadDoc Row for Non-editable mode
              if (!widget.isDriverEditable)
                Column(
                    children:[
                      Wrap(
                      children: [
                        UploadDoc(docModel: driverDocs[0]),
                        UploadDoc(docModel: driverDocs[1]),
                        UploadDoc(docModel: driverDocs[2]),
                        UploadDoc(docModel: driverDocs[3]),
                        UploadDoc(docModel: driverDocs[4]),
                        UploadDoc(docModel: driverDocs[5]),
                      ],)


                      // Container(
                      //   child: SingleChildScrollView(
                      //     scrollDirection: Axis.horizontal,
                      //     child: Row(
                      //       children: [
                      //         UploadDoc(docModel: driverDocs[0]),
                      //         UploadDoc(docModel: driverDocs[1]),
                      //         UploadDoc(docModel: driverDocs[2]),
                      //         UploadDoc(docModel: driverDocs[3]),
                      //         UploadDoc(docModel: driverDocs[4]),
                      //         UploadDoc(docModel: driverDocs[5]),
                      //       ],
                      //     ),
                      //   ),
                      // )

                    ]
                  ),


              // View Buttons for Editable mode
              if (widget.isDriverEditable)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: driverDocs.map((doc) {
                    return CommonButton(
                      backgroundColor: Colors.green,
                      text: "View ${doc.title}",
                      onPressed: () {
                        // TODO: Implement view logic (open file / preview)
                      },
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
