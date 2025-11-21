// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tb_app/constants/api_constants.dart';
import 'package:tb_app/screens/auth/login_page.dart';
import 'package:tb_app/screens/profile/update_profile_page.dart';
import 'package:tb_app/utils/alert.dart';
import 'package:tb_app/utils/loading.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<StatefulWidget> createState() => _mySignUpPage();
}

class _mySignUpPage extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPassword1Visible = false;
  bool _isPassword2Visible = false;
  bool _isError = false;
  String _errorMessage = "Error";
  String? _jwtToken;

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createUser() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.signUp),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _confirmPasswordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        _isError = false;
      } else {
        _isError = true;
        final body = jsonDecode(response.body);
        _errorMessage = body['message'] ?? 'Unknown error';
      }
    } catch (e) {
      _isError = true;
      _errorMessage = e.toString();
    }
  }

  Future<void> _getJWTToken(String email) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.generateJwt),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email.trim()}),
      );

      if (response.statusCode == 200) {
        _isError = false;
        final body = jsonDecode(response.body);
        _jwtToken = body['jwt_token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("user_email", email.trim());
        await prefs.setString('jwt_token', _jwtToken!);
      } else {
        _isError = true;
        final body = jsonDecode(response.body);
        _errorMessage = body['message'] ?? 'Unknown error';
      }
    } catch (e) {
      _isError = true;
      _errorMessage = e.toString();
    }
  }

  Future<void> _registerDevice(String email) async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) {
        debugPrint("FCM token not available");
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final jwtToken = prefs.getString('jwt_token');

      final response = await http.post(
        Uri.parse(ApiConstants.registerDevice),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({'email': email, 'device_id': fcmToken}),
      );

      if (response.statusCode == 200) {
        debugPrint("Device registered successfully: $fcmToken");
      } else {
        debugPrint("Failed to register device: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error registering device: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1114),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1114),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "User Sign-Up",
          style: TextStyle(
            color: Color(0xFFE8ECF2),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF171A1F),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2A2D33)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Sign-Up",
                style: TextStyle(
                  color: Color(0xFFE8ECF2),
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Color(0xFFE8ECF2)),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1F2329),
                  hintText: "Enter E-mail",
                  hintStyle: const TextStyle(color: Color(0xFFA8B2C1)),
                  prefixIcon: const Icon(Icons.email, color: Color(0xFFA8B2C1)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _newPasswordController,
                obscureText: !_isPassword1Visible,
                style: const TextStyle(color: Color(0xFFE8ECF2)),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1F2329),
                  hintText: "Create Password",
                  hintStyle: const TextStyle(color: Color(0xFFA8B2C1)),
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFFA8B2C1)),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(
                        () => _isPassword1Visible = !_isPassword1Visible,
                      );
                    },
                    icon: Icon(
                      _isPassword1Visible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: const Color(0xFF7B4DFF),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _confirmPasswordController,
                obscureText: !_isPassword2Visible,
                style: const TextStyle(color: Color(0xFFE8ECF2)),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1F2329),
                  hintText: "Confirm Password",
                  hintStyle: const TextStyle(color: Color(0xFFA8B2C1)),
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFFA8B2C1)),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(
                        () => _isPassword2Visible = !_isPassword2Visible,
                      );
                    },
                    icon: Icon(
                      _isPassword2Visible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: const Color(0xFF7B4DFF),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B4DFF),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  final email = _emailController.text.trim();
                  final newPass = _newPasswordController.text.trim();
                  final confirmPass = _confirmPasswordController.text.trim();

                  if (email.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
                    showCustomPopup(
                      context: context,
                      title: "ERROR",
                      content: "All fields must be filled.",
                    );
                    return;
                  }

                  if (newPass != confirmPass) {
                    showCustomPopup(
                      context: context,
                      title: "ERROR",
                      content: "Passwords do not match.",
                    );
                    return;
                  }

                  await showLoadingPopup(
                    context: context,
                    loadingText: "Signing up...",
                    asyncFunction: () async {
                      await _createUser();
                      if (_isError) return;

                      await _getJWTToken(email);
                      if (_isError) return;

                      await _registerDevice(email);
                    },
                  );

                  if (_isError) {
                    showCustomPopup(
                      context: context,
                      title: "ERROR",
                      content: _errorMessage,
                    );
                    _isError = false;
                    return;
                  }

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdateProfilePage(emailText: email),
                    ),
                  );
                },
                child: const Text("Sign Up"),
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account?",
                    style: TextStyle(color: Color(0xFFA8B2C1)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Log-in",
                      style: TextStyle(
                        color: Color(0xFF7B4DFF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
