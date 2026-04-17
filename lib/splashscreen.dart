import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';
import 'role_portal.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  bool _isLoading = true;
  bool _isLoggingIn = false;
  bool _showRegister = false;
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specializationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _consultationFeeController = TextEditingController();
  String _selectedRole = 'patient';

  String? _token;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');

    if (_token != null) {
      Timer(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const RolePortalPage()),
          );
        }
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => _isLoggingIn = true);

    try {
      final data = await ApiService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (data['success'] == true) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const RolePortalPage()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Login failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoggingIn = false);
      }
    }
  }

  Future<void> _register() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    // Validate doctor-specific fields
    if (_selectedRole == 'doctor') {
      if (_specializationController.text.isEmpty ||
          _experienceController.text.isEmpty ||
          _qualificationController.text.isEmpty ||
          _consultationFeeController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all doctor-specific fields')),
        );
        return;
      }

      final fee = double.tryParse(_consultationFeeController.text.trim());
      if (fee == null || fee <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid consultation fee')),
        );
        return;
      }
    }

    setState(() => _isLoggingIn = true);

    try {
      final registrationPayload = <String, dynamic>{
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': _selectedRole,
        'phone': _selectedRole == 'doctor' ? _phoneController.text.trim() : null,
        'specialization': _selectedRole == 'doctor'
            ? _specializationController.text.trim()
            : null,
        'experience': _selectedRole == 'doctor'
            ? int.tryParse(_experienceController.text.trim())
            : null,
        'qualification': _selectedRole == 'doctor'
            ? _qualificationController.text.trim()
            : null,
        'consultationFee': _selectedRole == 'doctor'
            ? double.tryParse(_consultationFeeController.text.trim())
            : null,
      };
      debugPrint('Register request payload: $registrationPayload');

      final data = await ApiService.register(
        name: registrationPayload['name'] as String,
        email: registrationPayload['email'] as String,
        password: _passwordController.text,
        role: registrationPayload['role'] as String,
        phone: registrationPayload['phone'] as String?,
        specialization: registrationPayload['specialization'] as String?,
        experience: registrationPayload['experience'] as int?,
        qualification: registrationPayload['qualification'] as String?,
        consultationFee: registrationPayload['consultationFee'] as double?,
      );
      debugPrint('Register response: $data');

      if (data['success'] == true) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const RolePortalPage()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Registration failed')),
          );
        }
      }
    } catch (e) {
      debugPrint('Register exception: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoggingIn = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _specializationController.dispose();
    _experienceController.dispose();
    _qualificationController.dispose();
    _consultationFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset("assets/splashscreen.jpg", fit: BoxFit.cover),
            ),
            Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.4))),
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Lottie.asset("assets/lottie/Background_shooting_star.json", fit: BoxFit.cover, repeat: true),
          ),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.4))),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 0.05),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _showRegister ? _buildRegisterForm() : _buildLoginForm(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassmorphicContainer({required Key key, required Widget child}) {
    return ClipRRect(
      key: key,
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 30,
                spreadRadius: -5,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return _buildGlassmorphicContainer(
      key: const ValueKey('login_form'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.psychology, size: 64, color: Colors.blueAccent),
          const SizedBox(height: 16),
          const Text('Manoveda', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          const Text('Mental Health ERP + Telemedicine', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 40),
          TextField(
            controller: _emailController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Email', Icons.email_outlined),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _passwordController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Password', Icons.lock_outline),
            obscureText: true,
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoggingIn ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: Colors.blueAccent.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoggingIn ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => setState(() => _showRegister = true),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text("Don't have an account? Sign Up", style: TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return _buildGlassmorphicContainer(
      key: const ValueKey('register_form'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Create Account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.1)),
          const SizedBox(height: 8),
          const Text('Join Manoveda today', style: TextStyle(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Full Name', Icons.person_outline),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _emailController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Email', Icons.email_outlined),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            initialValue: _selectedRole,
            dropdownColor: Colors.grey[900],
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: _inputDecoration('I am a', Icons.category_outlined),
            items: const [
              DropdownMenuItem(value: 'patient', child: Text('Patient')),
              DropdownMenuItem(value: 'doctor', child: Text('Doctor')),
              DropdownMenuItem(value: 'medical_keeper', child: Text('Medical Keeper / Pharmacy')),
            ],
            onChanged: (value) => setState(() => _selectedRole = value!),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _phoneController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Phone Number', Icons.phone_outlined),
            keyboardType: TextInputType.phone,
          ),
          if (_selectedRole == 'doctor') ...[
            const SizedBox(height: 20),
            TextField(
              controller: _specializationController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Specialization', Icons.medical_services_outlined),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _experienceController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Experience (years)', Icons.work_outline),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _qualificationController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Qualification', Icons.school_outlined),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _consultationFeeController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Consultation Fee (₹)', Icons.currency_rupee),
              keyboardType: TextInputType.number,
            ),
          ],
          const SizedBox(height: 20),
          TextField(
            controller: _passwordController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Password', Icons.lock_outline),
            obscureText: true,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _confirmPasswordController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Confirm Password', Icons.lock_outline),
            obscureText: true,
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoggingIn ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent.shade700,
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: Colors.tealAccent.shade700.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoggingIn ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Sign Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => setState(() => _showRegister = false),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('Already have an account? Login', style: TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.06),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16), 
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2))
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16), 
        borderSide: const BorderSide(color: Colors.white, width: 1.5)
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16), 
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.0)
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16), 
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }
}
