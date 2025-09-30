import 'package:erptransportexpress/Common%20Widgets/Common_DropdownWidget.dart';
import 'package:erptransportexpress/Common%20Widgets/common_buttons.dart';
import 'package:erptransportexpress/utils/Colors.dart';
import 'package:flutter/material.dart';

import '../../widgets/custom_form_filed.dart';

class AddClient extends StatefulWidget {
  final bool isClientEditable;
  const AddClient({super.key, this.isClientEditable = false});

  @override
  State<AddClient> createState() => _AddClientState();
}

class _AddClientState extends State<AddClient> {
  // Controllers
  String? selectedType; // <-- For dropdown

  final clientNameController = TextEditingController();
  final addressController = TextEditingController();
  final logisticsHeadName = TextEditingController();
  final logisticsHeadMobile = TextEditingController();
  final logisticsHeadEmail = TextEditingController();
  final rateTonController = TextEditingController();
  final rateTripController = TextEditingController();
  final TextEditingController typeController = TextEditingController();

  final rateRouteController = TextEditingController();
  final emailController = TextEditingController();
  final gstNumberController = TextEditingController();
  final businessTypeController = TextEditingController();
  final contractStartController = TextEditingController();
  final contractEndController = TextEditingController();
  final billingEmailController = TextEditingController();
  final billingAddressController = TextEditingController();




  //rateslabs  controller

  final TextEditingController fifty_to_hundred = TextEditingController();
  final TextEditingController hundred_to_fivehundred=TextEditingController();
  final TextEditingController five_hundred_to_one_thousand=TextEditingController();
  final TextEditingController one_thousand_to_one_thousand_fivehundred=TextEditingController();
  final TextEditingController one_thousand_five_hundred_to_three_thousand=TextEditingController();
  final TextEditingController three_thousand_to_five_thousand=TextEditingController();

  //adress


  final TextEditingController districtController = TextEditingController();
  final TextEditingController townController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController landmark = TextEditingController();
  final TextEditingController warehouselandmark=TextEditingController();

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    clientNameController.dispose();
    addressController.dispose();
    logisticsHeadName.dispose();
    logisticsHeadMobile.dispose();
    logisticsHeadEmail.dispose();
    rateTonController.dispose();
    rateTripController.dispose();
    rateRouteController.dispose();
    emailController.dispose();
    gstNumberController.dispose();
    businessTypeController.dispose();
    contractStartController.dispose();
    contractEndController.dispose();
    billingEmailController.dispose();
    billingAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: common_Colors.primaryColor,
        title: Text(
          widget.isClientEditable ? "View Client" : "Edit Client",
          style: TextStyle(color: common_Colors.textColor),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomFormField(
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.blueGrey,
                        ),
                        isEditable: widget.isClientEditable,
                        caplebal: '',
                        label: 'Client/Company Name',
                        hint: 'Enter Client/Company Name',
                        controller: clientNameController,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: CustomFormField(
                        prefixIcon: const Icon(
                          Icons.location_on,
                          color: Colors.blueGrey,
                        ),
                        isEditable: widget.isClientEditable,
                        caplebal: '',
                        label: 'Address',
                        hint: 'Enter Address',
                        controller: addressController,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: CommonDropDownWidget<String>(
                        hintText: "Service Type",
                        items: const [
                          DropdownMenuItem(

                              value: "Courier✉️", child: Text("✉️  Courier")),
                          DropdownMenuItem(value: "PTL", child: Text("🚛  PTL")),
                          DropdownMenuItem(value: "FTL", child: Text("🚚  FTL")),
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
                    const SizedBox(width: 20),
                    Expanded(
                      child:
                      CustomFormField(
                        prefixIcon: Icon(Icons.call, color: Colors.blueGrey),
                        isEditable: widget.isClientEditable,
                        caplebal: '',
                        label: ' Logistics Head Contact Number',
                        hint: 'Enter Contact Number',
                        controller: logisticsHeadMobile,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 20),

                    Expanded(
                      child:
                      CustomFormField(
                        prefixIcon: Icon(Icons.person_pin_circle_sharp, color: Colors.blueGrey),
                        isEditable: widget.isClientEditable,
                        caplebal: '',
                        label: ' Logistics Head Name',
                        hint: 'Enter Logistics Head Name',
                        controller: logisticsHeadName,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 20),

                    Expanded(
                      child:
                      CustomFormField(
                        prefixIcon: Icon(Icons.alternate_email_outlined, color: Colors.blueGrey),
                        isEditable: widget.isClientEditable,
                        caplebal: '',
                        label: ' Logistics Head Email',
                        hint: 'Enter Logistics Head Email',
                        controller: logisticsHeadEmail,
                        backgroundColor: Colors.white,
                      ),
                    ),

                  ],

                ),
                Row(

                  children: [
                    Expanded(
                      child: CustomFormField(
                        prefixIcon: Icon(Icons.currency_rupee,color:Colors.blueGrey),
                        caplebal: '',
                          label: 'Rate 50-100',
                        hint: 'Rate 50-100',
                        controller: fifty_to_hundred,

                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: CustomFormField(
                        prefixIcon: Icon(Icons.currency_rupee,color:Colors.blueGrey),

                        caplebal: '',
                        label: 'Rate 100-500',
                        hint: 'Rate 100-500',
                        controller: hundred_to_fivehundred,

                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: CustomFormField(
                        prefixIcon: Icon(Icons.currency_rupee,color:Colors.blueGrey),

                        caplebal: '',
                        label: 'Rate 500-1000',
                        hint: 'Rate 500-1000',
                        controller: five_hundred_to_one_thousand,

                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: CustomFormField(
                        prefixIcon: Icon(Icons.currency_rupee,color:Colors.blueGrey),

                        caplebal: '',
                        label: 'Rate 1000-1500',
                        hint: 'Rate 1000-1500',
                        controller: one_thousand_to_one_thousand_fivehundred,

                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: CustomFormField(
                        prefixIcon: Icon(Icons.currency_rupee,color:Colors.blueGrey),

                        caplebal: '',
                        label: 'Rate 1500-3000',
                        hint: 'Rate 1500-3000',
                        controller: one_thousand_five_hundred_to_three_thousand,

                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: CustomFormField(
                        prefixIcon: Icon(Icons.currency_rupee,color:Colors.blueGrey),
                        caplebal: '',
                        label: 'Rate 3000-5000',
                        hint: 'Rate 3000-5000',
                        controller: three_thousand_to_five_thousand,

                      ),
                    )





                  ],
                ),
                Column(
                  children: [
                    Row(
                      children: [

                        Column(
                          children: [
                            Text("Location Business"),
                            SizedBox(
                              width: 400,
                              child: CustomFormField(
                                prefixIcon: Icon(Icons.search,color: Colors.blueGrey,),
                                  suffixIcon: Icon(
                                    color:Colors.green,
                                      Icons.add_circle_sharp),
                                  caplebal: "",
                                  label: "Search Location here",
                                  hint: "Search",
                                  controller: districtController),
                            ),
                            SizedBox(
                              width: 400,
                              height: 80,
                              child:
                              Card(
                                color: Colors.pink[90],
                                borderOnForeground: false,
                                elevation: 1,
                                child: ListTile(
                                  leading: Icon(Icons.location_on,color: Colors.blueGrey,),
                                  title: Text("District"),
                                  subtitle: Text("Town"),
                                  trailing: Icon(Icons.delete,color: Colors.red,),

                                )
                              ),
                            ),

                          ],
                        ),


                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
