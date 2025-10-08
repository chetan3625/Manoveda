import 'package:flutter/material.dart';
import 'package:manoveda/Loginpage.dart';
void main(){
  runApp(Manoveda());
}
class Manoveda extends StatefulWidget {
  const Manoveda({super.key});

  @override
  State<Manoveda> createState() => _ManovedaState();
}

class _ManovedaState extends State<Manoveda> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Loginpage()
    );
  }
}
