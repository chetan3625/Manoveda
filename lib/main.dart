import 'package:erptransportexpress/screens/Driver_Screens/edith_table_driver_screen.dart';
import 'package:erptransportexpress/screens/Vendor_Screens/edit_table_vendor_screen.dart';
import 'package:erptransportexpress/splashscreen.dart';

import 'package:flutter/material.dart';
void main(){
  runApp(ERP());
}
class ERP extends StatelessWidget {
  const ERP({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(

      ),
      debugShowCheckedModeBanner: false,
      home:SplashScreen(),
    );
  }
}


