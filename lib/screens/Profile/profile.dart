import 'package:erptransportexpress/Common%20Widgets/CommonAppBar.dart';
import 'package:flutter/material.dart';

import '../../widgets/sidebar.dart';
class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Sidebar(),

      backgroundColor: Colors.white,
      appBar: CommonAppBar(title: Text("profile")),

    );
  }
}
