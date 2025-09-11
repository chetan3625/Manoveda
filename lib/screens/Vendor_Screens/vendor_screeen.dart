import 'package:erptransportexpress/screens/Vendor_Screens/vendor_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/custom_form_filed.dart';


class VendorScreen extends StatefulWidget {


  const VendorScreen({super.key});



  @override
  State<VendorScreen> createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vendor Form"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomFormField(
                label: "Vendor Name",
                hint: "Enter vendor name",
                controller: nameController,
                height: 60,
                width: 350,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Name cannot be empty";
                  }
                  return null;
                },
                prefixIcon: const Icon(Icons.person),
              ),

              Container(
                child: CustomFormField(
                  label: "Email",
                  hint: "Enter email",
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  height: 60,
                  width: 350,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email cannot be empty";
                    }
                    return null;
                  },
                  prefixIcon: const Icon(Icons.email),
                ),
                
              ),
            CustomFormField(
              label: "Phone",
              hint: "Enter phone number",
              controller: phoneController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              height: 60,
              width: 350,// Only numbers
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Phone cannot be empty";
                } else if (value.length != 10) {
                  return "Phone number must be 10 digits";
                }
                return null;
              },
              prefixIcon: const Icon(Icons.phone),
            ),
            const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VendorDetailsScreen(
                          name: nameController.text,
                          email: emailController.text,
                          phone: phoneController.text,
                        ),
                      ),
                    );
                  }
                },
                child: const Text("Submit"),
              )

            ],
          ),
        ),
      ),
    );
  }
}
