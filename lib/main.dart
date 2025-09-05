import 'package:erptransportexpress/splashscreen.dart';
import 'package:flutter/material.dart';

import 'loginpage.dart';

void main(){
  runApp(ERP());
}
class ERP extends StatelessWidget {
  const ERP({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlurBackGround(),
    );
  }
}


