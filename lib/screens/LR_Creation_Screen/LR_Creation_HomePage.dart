import 'package:erptransportexpress/Common%20Widgets/CommonAppBar.dart';
import 'package:erptransportexpress/Common%20Widgets/Common_Floating_Action_Button.dart';
import 'package:erptransportexpress/screens/LR_Creation_Screen/Add_New_LR.dart';
import 'package:erptransportexpress/widgets/sidebar.dart';
import 'package:flutter/material.dart';

class LR_Creation_HomePage extends StatelessWidget {
  const LR_Creation_HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: Text("Lorry Reciept Screen")),
      drawer: Sidebar(),
      floatingActionButton: CommonFloatingActionButton(onPressed: (){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>AddNewLR()));
      }, text: "Create New LR"),

    );
  }
}
