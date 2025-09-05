import 'dart:async';
import 'dart:ui';

import 'package:erptransportexpress/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'homepage.dart';

class BlurBackGround extends StatefulWidget {
  const BlurBackGround({super.key});

  @override
  State<BlurBackGround> createState() => _BlurBackGroundState();
}

class _BlurBackGroundState extends State<BlurBackGround> {

  @override
  void initState() {
    checkLoginStatus();
  Timer(Duration(seconds: 3), (){

  });
    super.initState();
  }
  Future<void> checkLoginStatus()async{
    final prefs= await SharedPreferences.getInstance();
    bool isLoggedIn=prefs.getBool("isLoggedIn")??false;
    if(isLoggedIn){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Homepage()));
    }
    else{
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));
    }
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
                  "assets/images/bg_splash.jpg")),
          BackdropFilter(filter: ImageFilter.blur(sigmaX: 5,sigmaY: 5),child: Container(
            color: Colors.black.withOpacity(0),

          ),)
        ],
      ),
    );
  }
}
