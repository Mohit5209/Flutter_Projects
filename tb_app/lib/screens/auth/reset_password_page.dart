import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tb_app/constants/api_constants.dart';
import 'package:tb_app/screens/auth/otp_validation_page.dart';
import 'package:tb_app/utils/alert.dart';
import 'package:tb_app/utils/loading.dart';

class Resetpasswordpage extends StatefulWidget {
  const Resetpasswordpage({super.key});

  @override
  State<StatefulWidget> createState() => _ResetpasswordpageState();
}

class _ResetpasswordpageState extends State<Resetpasswordpage> {
  final emailText = TextEditingController();
  bool isError = false;
  String message = "Error";

  @override
  void dispose() {
    emailText.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.forgotPassword),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': emailText.text.trim()}),
      );

      if (response.statusCode == 200) {
        isError = false;
      } else {
        isError = true;
        final body = jsonDecode(response.body);
        message = body['message'] ?? "Unknown Error";
      }
    } catch (e) {
      isError = true;
      message = e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1114),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Reset Password",
          style: TextStyle(
            color: Color(0xFFE8ECF2),
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Center(
        child: Container(
          padding: const EdgeInsets.all(22),
          margin: const EdgeInsets.symmetric(horizontal: 24),
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
                "Forgot Password?",
                style: TextStyle(
                  color: Color(0xFFE8ECF2),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 6),
              const Text(
                "Enter your registered email to receive OTP.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFA8B2C1), fontSize: 14),
              ),

              const SizedBox(height: 26),

              TextField(
                controller: emailText,
                style: const TextStyle(color: Color(0xFFE8ECF2)),
                decoration: InputDecoration(
                  hintText: "E-mail Address",
                  hintStyle: const TextStyle(color: Color(0xFFA8B2C1)),
                  filled: true,
                  fillColor: const Color(0xFF1F2329),
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Color(0xFFA8B2C1),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 26),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B4DFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    await showLoadingPopup(
                      context: context,
                      asyncFunction: () async {
                        await resetPassword();
                      },
                      loadingText: "Sending OTP...",
                    );

                    if (emailText.text.isEmpty) {
                      return showCustomPopup(
                        context: context,
                        title: "Error",
                        content: "E-mail cannot be empty.",
                      );
                    }

                    if (!isError) {
                      return showCustomPopup(
                        context: context,
                        title: "Success",
                        content: "OTP Sent Successfully",
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  OTPValidationPage(email: emailText.text),
                            ),
                          );
                        },
                      );
                    }

                    return showCustomPopup(
                      context: context,
                      title: "Error",
                      content: message,
                    );
                  },
                  child: const Text(
                    "Send OTP",
                    style: TextStyle(
                      color: Color(0xFF0F1114),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
