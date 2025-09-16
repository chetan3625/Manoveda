import 'package:erptransportexpress/Common%20Widgets/common_buttons.dart';
import 'package:erptransportexpress/utils/Colors.dart';
import 'package:flutter/material.dart';

import '../../widgets/custom_form_filed.dart';

class addClient extends StatefulWidget {
  const addClient({super.key});

  @override
  State<addClient> createState() => _addClientState();
}

class _addClientState extends State<addClient> {
  TextEditingController clientNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController websiteController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController gstNumberController = TextEditingController();
  TextEditingController businessController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      iconTheme: IconThemeData(
        color: Colors.white
      ),
      backgroundColor: common_Colors.primaryColor,
      title: Text("Add Client",style: TextStyle(
        color: common_Colors.textColor
      ),),
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
                      caplebal: 'Client/Company Name', label: '', hint: 'Enter Client/Company Name', controller: clientNameController,backgroundColor: Colors.white,)),
                SizedBox(
                  width: 20,
                ),
                Expanded(child: CustomFormField(caplebal: 'Address', label: '', hint: 'Enter Address', controller: clientNameController,backgroundColor: Colors.white,)),

              ],
            ),
      
            Row(
              children: [
                Expanded(child: CustomFormField(caplebal: 'Website (Optional)', label: '', hint: 'Enter Your  WebSite', controller: websiteController,backgroundColor: Colors.white,)),
                SizedBox(
                  width: 20,
                ),
                Expanded(child: CustomFormField(caplebal: 'Contact Number', label: '', hint: 'Enter Contact Number', controller: clientNameController,backgroundColor: Colors.white,)),



              ],
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                    child: CustomFormField(caplebal: 'Rate Per KM', label: '', hint: 'Enter Above Rate', controller: websiteController,backgroundColor: Colors.white,)),
                SizedBox(
                  width: 10,
                ),

                Expanded(
                  flex: 1,
                    child: CustomFormField(caplebal: 'Rate Per Ton', label: '', hint: 'Enter Above Rate', controller: websiteController,backgroundColor: Colors.white,)),
                SizedBox(
                  width: 10,
                ),

                Expanded(
                  flex: 1,
                    child: CustomFormField(caplebal: 'Rate Per Trip', label: '', hint: 'Enter Above Rate', controller: websiteController,backgroundColor: Colors.white,)),
                SizedBox(
                  width: 10,
                ),

                Expanded(
                  flex: 1,
                    child: CustomFormField(caplebal: 'Rate Fixed Route', label: '', hint: 'Enter Above Rate', controller: websiteController,backgroundColor: Colors.white,)),
                SizedBox(
                  width: 10,
                )


              ],
            ),
      
            Row(
              children: [
                Expanded(child: CustomFormField(caplebal: 'Email', label: '', hint: 'Enter Email', controller: clientNameController,backgroundColor: Colors.white,)),
                SizedBox(
                  width: 20,
                ),
                Expanded(child: CustomFormField(caplebal: 'GST Number', label: '', hint: 'Enter GST Number', controller: clientNameController,backgroundColor: Colors.white,)),
      
              ],
            ),
           CustomFormField(caplebal: "Business Type", label: "", hint: "Enter What Business You Are Serving", controller: businessController,backgroundColor: Colors.white,),
           Row(
             children: [

               Expanded(child: CustomFormField(caplebal: "Contract Start Date", label: "", hint: "Enter Starting Date", controller: businessController,backgroundColor: Colors.white,)),
               SizedBox(
                 width: 20,
               ),
               Expanded(child: CustomFormField(caplebal: "Contract End Date", label: "", hint: "Enter Ending Date of Contract", controller: businessController,backgroundColor: Colors.white,)),

             ],
           ),
           CustomFormField(caplebal: "Billing Email", label: "", hint: "Enter Billing Email", controller: businessController,backgroundColor: Colors.white,),
           CustomFormField(caplebal: "Billing Address", label: "", hint: "Enter Your Billing Address", controller: businessController,backgroundColor: Colors.white,),
            SizedBox(
              height: 10,
            ),
            CommonButton(text: "Add Client", onPressed: (){})
          ],
        ),
      ),
      ),
    )
    );
  }
}
