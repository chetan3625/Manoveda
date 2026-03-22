import 'package:flutter/material.dart';
import 'dart:math';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // List of student data
    final List<Map<String, String>> students = [
      {'name': 'Omkar Manohar Pawar', 'Section': 'TE Electronics and Computer Engineering', 'icon': 'engineering'},
      {'name': 'Dhanashree Manikrao Nikhade', 'Section': 'TE Electronics and Computer Engineering', 'role': 'UI/UX Designer', 'icon': 'palette'},
      {'name': 'Sakshi Sanjay Nathe', 'Section': 'TE Electronics and Computer Engineering', 'role': 'Backend Developer', 'icon': 'code'},
      ];

    // Shuffle the list of students randomly
    final random = Random();
    students.shuffle(random);

    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade100, Colors.blue.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Our Vision Section
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Our Vision',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'We are the of students of TE Electronics and Computer Engineering who designed this app to help reduce mental stress among students. We believe in harnessing technology for a better and healthier life.',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),

              // Meet the Team Section
              const SizedBox(height: 20),
              const Text(
                'Meet the Team',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),

              // List of student cards
              ...students.map((student) {
                IconData icon;
                switch (student['icon']) {
                  case 'engineering':
                    icon = Icons.engineering;
                    break;
                  case 'palette':
                    icon = Icons.palette;
                    break;
                  case 'code':
                    icon = Icons.code;
                    break;
                  case 'web':
                    icon = Icons.web;
                    break;
                  case 'bug_report':
                    icon = Icons.bug_report;
                    break;
                  default:
                    icon = Icons.school;
                }

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: Colors.lightBlue,
                      child: Icon(icon, color: Colors.white),
                    ),
                    title: Text(
                      student['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      '${student['Section']}${student['role'] != null ? ' - ${student['role']}' : ''} Branch',
                      style: const TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}