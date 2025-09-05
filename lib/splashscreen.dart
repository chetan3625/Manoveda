import 'dart:async';
import 'dart:ui';

import 'package:erptransportexpress/loginpage.dart';
import 'package:flutter/material.dart';

class BlurBackGround extends StatefulWidget {
  const BlurBackGround({super.key});

  @override
  State<BlurBackGround> createState() => _BlurBackGroundState();
}

class _BlurBackGroundState extends State<BlurBackGround> {
  @override
  void initState() {
  Timer(Duration(seconds: 3), (){
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));
  });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Expanded(
              child: Image.asset(
                fit: BoxFit.cover,
                  "assets/images/splashscreenimg/vehicles-laptop-supply-chain-representation.jpg")),
          BackdropFilter(filter: ImageFilter.blur(sigmaX: 5,sigmaY: 5),child: Container(
            color: Colors.black.withOpacity(0),

          ),)
        ],
      ),
    );
  }
}
