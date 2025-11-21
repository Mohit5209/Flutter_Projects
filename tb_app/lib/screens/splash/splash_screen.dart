import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tb_app/constants/api_constants.dart';
import 'package:tb_app/screens/auth/login_page.dart';
import 'package:tb_app/screens/home/home_screen_page.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<Splashscreen>
    with TickerProviderStateMixin {
  late AnimationController _circleController;
  late Animation<double> _circleDrop;
  late Animation<double> _circleScale;

  late AnimationController _lettersController;
  late Animation<double> _tOpacity;
  late Animation<double> _bOpacity;

  @override
  void initState() {
    super.initState();

    _lettersController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _tOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _lettersController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _bOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _lettersController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _lettersController.forward();

    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _circleDrop = Tween<double>(begin: -600, end: 0).animate(
      CurvedAnimation(
        parent: _circleController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _circleScale = Tween<double>(begin: 0, end: 3.0).animate(
      CurvedAnimation(
        parent: _circleController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _circleController.forward();
    });

    Future.delayed(const Duration(seconds: 3), () async {
      if (mounted) await _checkAuthAndNavigate();
    });
  }

  @override
  void dispose() {
    _lettersController.dispose();
    _circleController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("jwt_token");
    final email = prefs.getString("user_email");

    if (token != null && email != null && !JwtDecoder.isExpired(token)) {
      await _registerDeviceWithServer(email);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreenPage(emailText: email),
        ),
      );
    } else {
      await prefs.remove("jwt_token");
      await prefs.remove("user_email");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  Future<void> _registerDeviceWithServer(String email) async {
    try {
      await FirebaseMessaging.instance.requestPermission();
      final fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken == null) return;

      final body = jsonEncode({"email": email, "device_id": fcmToken});

      final response = await http.post(
        Uri.parse(ApiConstants.registerDevice),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        debugPrint("Device registered successfully: $fcmToken");
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
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: AnimatedBuilder(
              animation: _circleController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _circleDrop.value),
                  child: Transform.scale(
                    scale: _circleScale.value,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 59, 43, 90),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _tOpacity,
                  builder: (context, child) => Opacity(
                    opacity: _tOpacity.value,
                    child: const Text(
                      "T",
                      style: TextStyle(
                        fontSize: 58,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedBuilder(
                  animation: _bOpacity,
                  builder: (context, child) => Opacity(
                    opacity: _bOpacity.value,
                    child: const Text(
                      "B",
                      style: TextStyle(
                        fontSize: 58,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
