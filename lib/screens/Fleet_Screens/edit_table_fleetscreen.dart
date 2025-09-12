import 'package:erptransportexpress/utils/Colors.dart';
import 'package:flutter/material.dart';
class EditTableFleetscreen extends StatefulWidget {
  const EditTableFleetscreen({super.key});

  @override
  State<EditTableFleetscreen> createState() => _EditTableFleetscreenState();
}

class _EditTableFleetscreenState extends State<EditTableFleetscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        iconTheme: IconThemeData(color: common_Colors.textColor),
        title: Text("Edit Table Fleetscreen",style: TextStyle(
          color: common_Colors.textColor
        ),),
        centerTitle: true,
        backgroundColor: common_Colors.primaryColor,
      ),
    );
  }
}
