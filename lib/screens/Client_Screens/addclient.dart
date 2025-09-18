import 'package:erptransportexpress/Common%20Widgets/common_buttons.dart';
import 'package:erptransportexpress/utils/Colors.dart';
import 'package:flutter/material.dart';

import '../../widgets/custom_form_filed.dart';

class AddClient extends StatefulWidget {
  final isClientEditable;
  const AddClient({super.key, this.isClientEditable=false});

  @override
  State<AddClient> createState() => _AddClientState();
}

class _AddClientState extends State<AddClient> {
  // Controllers
  final clientNameController = TextEditingController();
  final addressController = TextEditingController();
  final websiteController = TextEditingController();
  final contactNumberController = TextEditingController();
  final rateKmController = TextEditingController();
  final rateTonController = TextEditingController();
  final rateTripController = TextEditingController();
  final rateRouteController = TextEditingController();
  final emailController = TextEditingController();
  final gstNumberController = TextEditingController();
  final businessTypeController = TextEditingController();
  final contractStartController = TextEditingController();
  final contractEndController = TextEditingController();
  final billingEmailController = TextEditingController();
  final billingAddressController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    clientNameController.dispose();
    addressController.dispose();
    websiteController.dispose();
    contactNumberController.dispose();
    rateKmController.dispose();
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
          widget.isClientEditable?"View Client":"Edit Client",
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
                          isEditable: widget.isClientEditable,
                          caplebal: 'Client/Company Name',
                          label: '',
                          hint: 'Enter Client/Company Name',
                          controller: clientNameController,
                          backgroundColor: Colors.white,
                        )),
                    const SizedBox(width: 20),
                    Expanded(
                        child: CustomFormField(
                          isEditable: widget.isClientEditable,
                          caplebal: 'Address',
                          label: '',
                          hint: 'Enter Address',
                          controller: addressController,
                          backgroundColor: Colors.white,
                        )),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                        child: CustomFormField(
                          isEditable: widget.isClientEditable,
                          caplebal: 'Website (Optional)',
                          label: '',
                          hint: 'Enter Your Website',
                          controller: websiteController,
                          backgroundColor: Colors.white,
                        )),
                    const SizedBox(width: 20),
                    Expanded(
                        child: CustomFormField(
                          isEditable: widget.isClientEditable,
                          caplebal: 'Contact Number',
                          label: '',
                          hint: 'Enter Contact Number',
                          controller: contactNumberController,
                          backgroundColor: Colors.white,
                        )),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                        child: CustomFormField(
                          isEditable: widget.isClientEditable,
                          caplebal: 'Rate Per KM',
                          label: '',
                          hint: 'Enter Above Rate',
                          controller: rateKmController,
                          backgroundColor: Colors.white,
                        )),
                    const SizedBox(width: 10),
                    Expanded(
                        child: CustomFormField(
                          isEditable: widget.isClientEditable,
                          caplebal: 'Rate Per Ton',
                          label: '',
                          hint: 'Enter Above Rate',
                          controller: rateTonController,
                          backgroundColor: Colors.white,
                        )),
                    const SizedBox(width: 10),
                    Expanded(
                        child: CustomFormField(
                          isEditable: widget.isClientEditable,
                          caplebal: 'Rate Per Trip',
                          label: '',
                          hint: 'Enter Above Rate',
                          controller: rateTripController,
                          backgroundColor: Colors.white,
                        )),
                    const SizedBox(width: 10),
                    Expanded(
                        child: CustomFormField(
                          isEditable: widget.isClientEditable,
                          caplebal: 'Rate Fixed Route',
                          label: '',
                          hint: 'Enter Above Rate',
                          controller: rateRouteController,
                          backgroundColor: Colors.white,
                        )),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                        child: CustomFormField(
                          isEditable: widget.isClientEditable,
                          caplebal: 'Email',
                          label: '',
                          hint: 'Enter Email',
                          controller: emailController,
                          backgroundColor: Colors.white,
                        )),
                    const SizedBox(width: 20),
                    Expanded(
                        child: CustomFormField(
                          isEditable: widget.isClientEditable,
                          caplebal: 'GST Number',
                          label: '',
                          hint: 'Enter GST Number',
                          controller: gstNumberController,
                          backgroundColor: Colors.white,
                        )),
                  ],
                ),

                CustomFormField(
                  isEditable: widget.isClientEditable,
                  caplebal: "Business Type",
                  label: "",
                  hint: "Enter What Business You Are Serving",
                  controller: businessTypeController,
                  backgroundColor: Colors.white,
                ),

                Row(
                  children: [
                    Expanded(
                        child: CustomFormField(
                          isEditable: widget.isClientEditable,
                          caplebal: "Contract Start Date",
                          label: "",
                          hint: "Enter Starting Date",
                          controller: contractStartController,
                          backgroundColor: Colors.white,
                        )),
                    const SizedBox(width: 20),
                    Expanded(
                        child: CustomFormField(
                          isEditable: widget.isClientEditable,
                          caplebal: "Contract End Date",
                          label: "",
                          hint: "Enter Ending Date of Contract",
                          controller: contractEndController,
                          backgroundColor: Colors.white,
                        )),
                  ],
                ),

                CustomFormField(
                  isEditable: widget.isClientEditable,
                  caplebal: "Billing Email",
                  label: "",
                  hint: "Enter Billing Email",
                  controller: billingEmailController,
                  backgroundColor: Colors.white,
                ),
                CustomFormField(
                  isEditable: widget.isClientEditable,
                  caplebal: "Billing Address",
                  label: "",
                  hint: "Enter Your Billing Address",
                  controller: billingAddressController,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 10),
                if(!widget.isClientEditable)
                CommonButton(text: widget.isClientEditable?"Edit":"Save Changes", onPressed: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
