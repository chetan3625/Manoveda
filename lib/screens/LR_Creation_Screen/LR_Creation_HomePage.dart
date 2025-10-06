import 'package:erptransportexpress/Common%20Widgets/CommonAppBar.dart';
import 'package:erptransportexpress/widgets/sidebar.dart';
import 'package:flutter/material.dart';

class LR_Creation_HomePage extends StatelessWidget {
  const LR_Creation_HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: Text("Lorry Reciept Screen")),
      drawer: Sidebar(),
      floatingActionButton: SizedBox(
          height: 50,
          width: 190,
          child: FloatingActionButton(
            backgroundColor: Colors.blue,
            onPressed: () {
                  },
            child: const Text( // Added const
              "Add New LR",
              style: TextStyle(color: Colors.white),
            ),
          )),
    );
  }
}
