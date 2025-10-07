import 'package:erptransportexpress/Common Widgets/CommonAppBar.dart';
import 'package:erptransportexpress/Common%20Widgets/Common_CheckBox.dart';
import 'package:erptransportexpress/Common%20Widgets/Common_DropdownWidget.dart';
import 'package:erptransportexpress/widgets/custom_form_filed.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddNewLR extends StatefulWidget {
  const AddNewLR({super.key});

  @override
  State<AddNewLR> createState() => _AddNewLRState();
}

class _AddNewLRState extends State<AddNewLR> {
  late final TextEditingController _uniqueIdCtrl;

  String _generateUniqueId() {
    // safer: date + milliseconds (or use uuid package)
    return DateFormat('yyyyMMddHHmmssSSS').format(DateTime.now());
  }

  @override
  void initState() {
    super.initState();
    _uniqueIdCtrl = TextEditingController(text: _generateUniqueId());
  }

  TextEditingController consigneerNameController = TextEditingController();
  TextEditingController consigneerAddressController = TextEditingController();
  TextEditingController consigneerMobileNoController = TextEditingController();
  TextEditingController consigneeNameController = TextEditingController();
  TextEditingController consigneeAddressController = TextEditingController();
  TextEditingController consigneeMobileNoController = TextEditingController();

  bool isgreaterthan50 = false;
  TextEditingController ewaybillNumber = TextEditingController();

  @override
  void dispose() {
    _uniqueIdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: const Text('Add New LR')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 240,
                  child: CustomFormField(
                    isDontWantToEditable: true,
                    label: 'FTL LR Number',
                    hint: '',
                    controller: _uniqueIdCtrl,
                    allowOnlyNumbers: true,
                    caplebal: '',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomFormField(
                    prefixIcon: Icon(Icons.people),
                    caplebal: "",
                    label: "Consigneer Name",
                    hint: "Enter Consigneer Name",
                    controller: consigneerNameController,
                    allowOnlyNumbers: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomFormField(
                    prefixIcon: Icon(Icons.phone),
                    caplebal: "",
                    label: "Consigneer Mobile No",
                    hint: "Enter Consigneer Mobile No",
                    controller: consigneerMobileNoController,
                    allowOnlyNumbers: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomFormField(
                    prefixIcon: Icon(Icons.location_on),
                    caplebal: "",
                    label: "Consigneer Address",
                    hint: "Enter Consigneer Address",
                    controller: consigneerAddressController,
                    allowOnlyNumbers: false,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomFormField(
                    prefixIcon: Icon(Icons.person_pin_circle_sharp),
                    caplebal: "",
                    label: "Consignee Name",
                    hint: "Enter Consignee Name",
                    controller: consigneeNameController,
                    allowOnlyNumbers: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomFormField(
                    prefixIcon: Icon(Icons.phone_forwarded),
                    caplebal: "",
                    label: "Consignee Mobile Number",
                    hint: "Enter Consignee Mobile Number",
                    controller: consigneeMobileNoController,
                    allowOnlyNumbers: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomFormField(
                    prefixIcon: Icon(Icons.location_on),
                    caplebal: "",
                    label: "Consignee Address",
                    hint: "Enter Consignee Address",
                    controller: consigneeAddressController,
                    allowOnlyNumbers: false,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CommonDropDownWidget(
                    hintText: "Select Payment Type",
                    items: [
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
                    onChanged: (val) {},
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: CustomFormField(
                    prefixIcon: Icon(Icons.currency_rupee),
                    caplebal: "",
                    label: "Goods Value",
                    hint: "Enter Goods Value",
                    controller: TextEditingController(),
                    allowOnlyNumbers: true,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: CommonCheckbox(
                    title: "Is Your Consignment Value > 50K ?",
                    hintText: "Enter 12 digit Eway bill Number",
                    CheckboxBool: isgreaterthan50,
                    isInputNedded: true,
                    InputController: ewaybillNumber,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomFormField(
                    prefixIcon: Icon(Icons.share_location_outlined),
                    caplebal: "",
                    label: "From",
                    hint: "",
                    controller: TextEditingController(),
                    allowOnlyNumbers: false,
                  ),
                ),
                Expanded(
                  child: CustomFormField(
                    prefixIcon: Icon(Icons.share_location_sharp),
                    caplebal: "",
                    label: "To",
                    hint: "",
                    controller: TextEditingController(),
                    allowOnlyNumbers: false,
                  ),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}
