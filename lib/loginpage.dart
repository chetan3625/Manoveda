import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:erptransportexpress/screens/Dashboard_Screens/dashboard_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'utils/Constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool obsecure = true;
  TextEditingController loginController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> saveLogin() async {
    final prefs = await SharedPreferences.getInstance();
    String email = loginController.text.trim();
    String password = passwordController.text.trim();

    await prefs.setBool(PrefKeys.isLoggedIn, true);
    await prefs.setString(PrefKeys.email, email);
    await prefs.setString(PrefKeys.password, password);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: isMobile ? screenWidth * 0.1 : screenWidth * 0.05,
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: Text(
          "Fleet ERP",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.normal,
            fontFamily: "Merriweather",
          ),
        ),
      ),

      // ------------------- for Mobile -------------------
      body: isMobile
          ? Column(
        children: [
          // Top (Image)
          Expanded(
            flex: 1,
            child: Container(
              child: Center(
                child: Image.asset(
                  "assets/images/bg_login.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Bottom (Form)
          Expanded(
            flex: 3,
            child: _buildLoginForm(),
          ),
        ],
      )

      // ------------------- for Web -------------------
          : Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.blue.shade50,
              child: Center(
                child: Image.asset(
                  "assets/images/loginimage/bg_login.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLoginForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔑 Login Form Widget (common for both layouts)
  Widget _buildLoginForm() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.blueAccent),
              borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Login",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "Merriweather",
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Username
                  TextField(
                    controller: loginController,
                    decoration: const InputDecoration(
                      labelText: "LoginId",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password
                  TextField(
                    controller: passwordController,
                    obscureText: obsecure,
                    decoration: InputDecoration(
                      labelText: "Password",
                      suffixIcon: InkWell(
                        onTap: () {
                          setState(() {
                            obsecure = !obsecure;
                          });
                        },
                        child: Icon(
                          obsecure
                              ? Icons.visibility_off
                              : Icons.remove_red_eye,
                        ),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade800,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () async {
                        await saveLogin();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DashboardScreen()),
                        );
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Signup Link
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      children: [
                        const TextSpan(text: "Don’t have an account? "),
                        TextSpan(
                          text: "Sign Up",
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Sign Up Clicked!"),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
