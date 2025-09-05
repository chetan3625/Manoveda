import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool obsecure = true;
  TextEditingController loginid = TextEditingController();
  TextEditingController pass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; // 👈 screen size घेतो
    final bool isMobile = screenWidth < 600; // threshold (mobile < 600px)

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: screenWidth*0.1,
        centerTitle: true,
        backgroundColor:Colors.blue ,
        title:Text("Fleet ERP",

        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.normal,
          fontFamily: "Merriweather",

        ),)
      ),
      body: isMobile
          ? Column(
        children: [
          // -------- Top (Image) --------
          Expanded(
            flex: 2,
            child: Container(

                color: Colors.blue.shade50,
                child: Center(
                child: Image.asset(
                  "assets/images/loginimage/7053246-removebg-preview.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // -------- Bottom (Form) --------
          Expanded(
            flex: 3,
            child: _buildLoginForm(),
          ),
        ],
      )
          : Row(
        children: [

          // -------- Left Column (Image) --------
          Expanded(

            flex: 1,
            child: Container(
              color: Colors.blue.shade50,
              child: Center(
                child: Image.asset(
                  "assets/images/loginimage/7053246-removebg-preview.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // -------- Right Column (Form) --------
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
            side: BorderSide(
              color: Colors.blueAccent,
            ),
              borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView( // 👉 mobile वर keyboard मुळे scroll होईल
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
                    controller: loginid,
                    decoration: const InputDecoration(
                      labelText: "LoginId",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password
                  TextField(
                    controller: pass,
                    obscureText: obsecure,
                    decoration: InputDecoration(
                      labelText: "Password",
                      suffixIcon: InkWell(
                        onTap: () {
                          setState(() {
                            obsecure = !obsecure; // ✅ toggle
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
                      onPressed: () {
                        // handle login here
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // RichText Example (Signup link)
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
