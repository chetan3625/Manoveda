import 'package:erptransportexpress/Common Widgets/CommonAppBar.dart';
import 'package:erptransportexpress/Common%20Widgets/CommonAlertBox.dart';
import 'package:erptransportexpress/Common%20Widgets/Common_CheckBox.dart';
import 'package:erptransportexpress/Common%20Widgets/Common_DropdownWidget.dart';
import 'package:erptransportexpress/Common%20Widgets/common_buttons.dart';
import 'package:erptransportexpress/widgets/custom_form_filed.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddNewLR extends StatefulWidget {
  const AddNewLR({super.key});

  @override
  State<AddNewLR> createState() => _AddNewLRState();
}

class _AddNewLRState extends State<AddNewLR> {
  // All controllers declared
  late final TextEditingController _uniqueIdCtrl;
  TextEditingController consigneerNameController = TextEditingController();
  TextEditingController consigneerAddressController = TextEditingController();
  TextEditingController consigneerMobileNoController = TextEditingController();
  TextEditingController consigneeNameController = TextEditingController();
  TextEditingController consigneeAddressController = TextEditingController();
  TextEditingController consigneeMobileNoController = TextEditingController();
  TextEditingController goodsValueController = TextEditingController();
  TextEditingController ewaybillNumber = TextEditingController();
  TextEditingController fromLocationController = TextEditingController();
  TextEditingController toLocationController = TextEditingController();
  TextEditingController noOfItemsController = TextEditingController();
  TextEditingController descriptionOfItemsController = TextEditingController();
  TextEditingController actualWeightController = TextEditingController();
  TextEditingController chargedWeightController = TextEditingController();

  DateTime? expectedDate;
  bool isgreaterthan50 = false; // State variable for the checkbox

  String _generateUniqueId() {
    // Generates a unique ID (example format: 11:56:53.123)
    return DateFormat('ssSSSss').format(DateTime.now());
  }

  @override
  void initState() {
    super.initState();
    _uniqueIdCtrl = TextEditingController(text: _generateUniqueId());
  }

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    _uniqueIdCtrl.dispose();
    consigneerNameController.dispose();
    consigneerAddressController.dispose();
    consigneerMobileNoController.dispose();
    consigneeNameController.dispose();
    consigneeAddressController.dispose();
    consigneeMobileNoController.dispose();
    goodsValueController.dispose();
    ewaybillNumber.dispose();
    fromLocationController.dispose();
    toLocationController.dispose();
    noOfItemsController.dispose();
    descriptionOfItemsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: const Text('Add New LR')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 240,
                    child: CustomFormField(
                      isDontWantToEditable: false,
                      label: 'Docket Number',
                      hint: '',
                      controller: _uniqueIdCtrl, // Assigned
                      allowOnlyNumbers: true,
                      caplebal: '',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomFormField(
                      prefixIcon: const Icon(Icons.people),
                      caplebal: "",
                      label: "Consigneer Name",
                      hint: "Enter Consigneer Name",
                      controller: consigneerNameController, // Assigned
                      allowOnlyNumbers: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomFormField(
                      prefixIcon: const Icon(Icons.phone),
                      caplebal: "",
                      label: "Consigneer Mobile No",
                      hint: "Enter Consigneer Mobile No",
                      controller: consigneerMobileNoController, // Assigned
                      allowOnlyNumbers: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomFormField(
                      prefixIcon: const Icon(Icons.location_on),
                      caplebal: "",
                      label: "Consigneer Address",
                      hint: "Enter Consigneer Address",
                      controller: consigneerAddressController, // Assigned
                      allowOnlyNumbers: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomFormField(
                      prefixIcon: const Icon(Icons.person_pin_circle_sharp),
                      caplebal: "",
                      label: "Consignee Name",
                      hint: "Enter Consignee Name",
                      controller: consigneeNameController, // Assigned
                      allowOnlyNumbers: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomFormField(
                      prefixIcon: const Icon(Icons.phone_forwarded),
                      caplebal: "",
                      label: "Consignee Mobile Number",
                      hint: "Enter Consignee Mobile Number",
                      controller: consigneeMobileNoController, // Assigned
                      allowOnlyNumbers: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomFormField(
                      prefixIcon: const Icon(Icons.location_on),
                      caplebal: "",
                      label: "Consignee Address",
                      hint: "Enter Consignee Address",
                      controller: consigneeAddressController, // Assigned
                      allowOnlyNumbers: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CommonDropDownWidget(
                      hintText: "Select Payment Type",
                      items: const [
                        DropdownMenuItem(
                          value: "paid",
                          child: Text("Paid (Prepaid)"),
                        ),
                        DropdownMenuItem(
                          value: "To‑Pay",
                          child: Text("To‑Pay (Collect/FOD)"),
                        ),
                        DropdownMenuItem(
                          value: "TBB",
                          child: Text("To Be Billed"),
                        ),
                      ],
                      onChanged: (val) {
                        // Implement logic for payment type change here
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomFormField(
                      prefixIcon: const Icon(Icons.currency_rupee),
                      caplebal: "",
                      label: "Goods Value",
                      hint: "Enter Goods Value",
                      controller: goodsValueController, // Assigned
                      allowOnlyNumbers: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CommonCheckbox(
                      title: "Is Your Consignment Value > 50K ?",
                      hintText: "Enter 12 digit Eway bill Number",
                      CheckboxBool: isgreaterthan50,
                      isInputNedded: true,
                      InputController: ewaybillNumber, // Assigned
                      // FIX: The onChanged callback to update the parent state
                      onChanged: (bool? newValue) {
                        if (newValue != null) {
                          setState(() {
                            isgreaterthan50 = newValue; // Updates the state
                            // Clear E-way bill number if unchecked
                            if (!!newValue) {
                              ewaybillNumber.clear();
                            }
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomFormField(
                      prefixIcon: const Icon(Icons.share_location_outlined),
                      caplebal: "",
                      label: "From",
                      hint: "Start Location",
                      controller: fromLocationController, // Assigned
                      allowOnlyNumbers: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomFormField(
                      prefixIcon: const Icon(Icons.share_location_sharp),
                      caplebal: "",
                      label: "To",
                      hint: "Destinie",
                      controller: toLocationController, // Assigned
                      allowOnlyNumbers: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomFormField(
                      prefixIcon: const Icon(Icons.format_list_numbered_sharp),
                      caplebal: "",
                      label: "No of Items",
                      hint: "Enter Number of Items",
                      controller: noOfItemsController, // Assigned
                      allowOnlyNumbers: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomFormField(
                      prefixIcon: const Icon(Icons.medical_information),
                      caplebal: "",
                      label: "Description of Items",
                      hint: "",
                      controller: descriptionOfItemsController, // Assigned
                      allowOnlyNumbers: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(
                    width: 200,
                    child: CommonButton(
                      backgroundColor: Colors.green,
                      text:
                          expectedDate != null
                              ? DateFormat('dd-MM-yyyy').format(expectedDate!)
                              : "Expeceted Delivery",
                      onPressed: () async {
                        DateTime? selectedDeliveryDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(3000),
                        );
                        if (selectedDeliveryDate != null) {
                          setState(() {
                            // This setState triggers a rebuild but the checkbox state is now preserved
                            expectedDate = selectedDeliveryDate;
                          });
                        }
                      },
                      borderRadius: 55,
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: CommonDropDownWidget<String>(
                      hintText: "Enter Delivery Type",
                      items: [
                        DropdownMenuItem(
                          child: Text("Basic Freight"),
                          value: "Basic Freight",
                        ),
                        DropdownMenuItem(
                          child: Text("Docket No"),
                          value: "Docket No",
                        ),
                        DropdownMenuItem(child: Text("FSC"), value: "FSC"),
                        DropdownMenuItem(
                          child: Text("Handling"),
                          value: "Handling",
                        ),
                        DropdownMenuItem(
                          child: Text("Door Delivery"),
                          value: "Door Delivery",
                        ),
                        DropdownMenuItem(child: Text("FOB"), value: "FOB"),
                        DropdownMenuItem(
                          child: Text("FOD to Pay"),
                          value: "FOD to Pay",
                        ),
                      ],
                      onChanged: (val) {},
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: CustomFormField(
                      prefixIcon: Icon(Icons.line_weight_outlined),
                      caplebal: "",
                      label: "Acutal Weight",
                      hint: "Enter Actual Weight",
                      controller: actualWeightController,
                      allowOnlyNumbers: true,
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: CommonButton(text: "", onPressed: (){
                      showDialog(context: context, builder: (BuildContext context){
                        return CommonAlertBox(title: "Alert !", content: Text("Are you sure to save this entry ?"), positiveText: "Yes", onPositivePressed: (){}, negativeText: '', onNegativePressed: () {  },);
                      });
                    }),
                  )

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
