// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tb_app/constants/api_constants.dart';
import 'package:tb_app/screens/auth/reset_password_page.dart';
import 'package:tb_app/screens/auth/signup_page.dart';
import 'package:tb_app/screens/home/home_screen_page.dart';
import 'package:tb_app/utils/alert.dart';
import 'package:tb_app/utils/loading.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _myLoginPage();
}

class _myLoginPage extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isError = false;
  String _errorMessage = "Error";
  String? _jwtToken;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.signIn),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
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

  Future<void> _registerDeviceWithServer(String email) async {
    try {
      await FirebaseMessaging.instance.requestPermission();
      final fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken == null) {
        debugPrint("Could not retrieve FCM token");
        return;
      }

      final response = await http.post(
        Uri.parse(ApiConstants.registerDevice),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email.trim(), "device_id": fcmToken}),
      );

      if (response.statusCode == 200) {
        debugPrint("Device registered successfully with FCM token: $fcmToken");
      } else {
        debugPrint("Device registration failed: ${response.body}");
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
          "User Login",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE8ECF2),
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
                "Login",
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
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                style: const TextStyle(color: Color(0xFFE8ECF2)),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1F2329),
                  hintText: "Enter Password",
                  hintStyle: const TextStyle(color: Color(0xFFA8B2C1)),
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFFA8B2C1)),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    icon: Icon(
                      _isPasswordVisible
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

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Resetpasswordpage(),
                      ),
                    );
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: Color(0xFF7B4DFF), fontSize: 12),
                  ),
                ),
              ),

              const SizedBox(height: 8),

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
                  final password = _passwordController.text.trim();

                  if (email.isEmpty || password.isEmpty) {
                    showCustomPopup(
                      context: context,
                      title: "ERROR",
                      content: "Email and Password cannot be empty.",
                    );
                    return;
                  }

                  await showLoadingPopup(
                    context: context,
                    loadingText: "Signing in...",
                    asyncFunction: () async {
                      await _loginUser();
                      if (_isError) return;

                      await _getJWTToken(email);
                      if (_isError) return;

                      await _registerDeviceWithServer(email);
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
                      builder: (context) => HomeScreenPage(emailText: email),
                    ),
                  );
                },
                child: const Text(
                  "Login",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(color: Color(0xFFA8B2C1)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Sign-up",
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
