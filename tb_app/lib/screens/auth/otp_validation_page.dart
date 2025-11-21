import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tb_app/constants/api_constants.dart';
import 'package:tb_app/screens/auth/create_new_password_page.dart';
import 'package:tb_app/utils/alert.dart';
import 'package:tb_app/utils/loading.dart';

class OTPValidationPage extends StatefulWidget {
  final String email;
  const OTPValidationPage({super.key, required this.email});

  @override
  State<StatefulWidget> createState() => _OTPValidationPageState();
}

class _OTPValidationPageState extends State<OTPValidationPage> {
  final otpController = TextEditingController();
  bool isError = false;
  String message = "Error";

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  Future<void> validateOTP() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.otpValidate),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'email': widget.email.trim(),
          'otp': otpController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        isError = false;
      } else {
        isError = true;
        final body = jsonDecode(response.body);
        message = body['message'] ?? 'Unknown Error';
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
          "Validate OTP",
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
                "OTP Verification",
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFFE8ECF2),
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Color(0xFFE8ECF2)),
                decoration: InputDecoration(
                  hintText: "Enter OTP",
                  hintStyle: const TextStyle(color: Color(0xFFA8B2C1)),
                  filled: true,
                  fillColor: const Color(0xFF1F2329),
                  prefixIcon: const Icon(
                    Icons.numbers,
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
                        await validateOTP();
                      },
                      loadingText: "Validating OTP...",
                    );

                    if (otpController.text.isEmpty) {
                      return showCustomPopup(
                        context: context,
                        title: "Error",
                        content: "OTP cannot be empty",
                      );
                    }

                    if (!isError) {
                      return showCustomPopup(
                        context: context,
                        title: "Success",
                        content: "OTP Verified",
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Createnewpasspage(email: widget.email),
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
                    "Validate OTP",
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
