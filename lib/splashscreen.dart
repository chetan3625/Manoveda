import 'dart:async';
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
      final data = await ApiService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
        phone: _selectedRole == 'doctor' ? _phoneController.text.trim() : null,
        specialization: _selectedRole == 'doctor' ? _specializationController.text.trim() : null,
        experience: _selectedRole == 'doctor' ? int.tryParse(_experienceController.text.trim()) : null,
        qualification: _selectedRole == 'doctor' ? _qualificationController.text.trim() : null,
        consultationFee: _selectedRole == 'doctor' ? double.tryParse(_consultationFeeController.text.trim()) : null,
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
            SnackBar(content: Text(data['message'] ?? 'Registration failed')),
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
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
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.6))),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _showRegister ? _buildRegisterForm() : _buildLoginForm(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        const Text('Manoveda', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 8),
        const Text('Mental Health ERP + Telemedicine', style: TextStyle(fontSize: 14, color: Colors.white70)),
        const SizedBox(height: 48),
        TextField(
          controller: _emailController,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('Email', Icons.email),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('Password', Icons.lock),
          obscureText: true,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoggingIn ? null : _login,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: _isLoggingIn ? const CircularProgressIndicator(color: Colors.white) : const Text('Login', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() => _showRegister = true),
          child: const Text("Don't have an account? Sign Up", style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        const Text('Create Account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 24),
        TextField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('Full Name', Icons.person),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('Email', Icons.email),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _selectedRole,
          dropdownColor: Colors.grey[800],
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('I am a', Icons.category),
          items: const [
            DropdownMenuItem(value: 'patient', child: Text('Patient')),
            DropdownMenuItem(value: 'doctor', child: Text('Doctor')),
            DropdownMenuItem(value: 'medical_keeper', child: Text('Medical Keeper / Pharmacy')),
          ],
          onChanged: (value) => setState(() => _selectedRole = value!),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _phoneController,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('Phone Number', Icons.phone),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        if (_selectedRole == 'doctor') ...[
          TextField(
            controller: _specializationController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Specialization', Icons.medical_services),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _experienceController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Experience (years)', Icons.work),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _qualificationController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Qualification', Icons.school),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _consultationFeeController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Consultation Fee (₹)', Icons.currency_rupee),
            keyboardType: TextInputType.number,
          ),
        ],
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('Password', Icons.lock),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmPasswordController,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('Confirm Password', Icons.lock),
          obscureText: true,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoggingIn ? null : _register,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: _isLoggingIn ? const CircularProgressIndicator(color: Colors.white) : const Text('Sign Up', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() => _showRegister = false),
          child: const Text('Already have an account? Login', style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white54)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white)),
    );
  }
}
