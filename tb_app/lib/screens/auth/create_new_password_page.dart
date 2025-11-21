import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tb_app/constants/api_constants.dart';
import 'package:tb_app/utils/alert.dart';
import 'package:tb_app/utils/loading.dart';

class Createnewpasspage extends StatefulWidget {
  final String email;
  const Createnewpasspage({super.key, required this.email});

  @override
  State<Createnewpasspage> createState() => _CreatenewpasspageState();
}

class _CreatenewpasspageState extends State<Createnewpasspage> {
  final newpassText = TextEditingController();
  final confirmpassText = TextEditingController();
  bool isobscene1 = true;
  bool isobscene2 = true;
  bool isError = false;
  String message = "Error";

  @override
  void dispose() {
    newpassText.dispose();
    confirmpassText.dispose();
    super.dispose();
  }

  Future<void> createNewPassword() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.resetPassword),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'email': widget.email.trim(),
          'password': confirmpassText.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        isError = false;
      } else {
        isError = true;
        final body = jsonDecode(response.body);
        message = body['message'] ?? 'Unknown error';
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
        backgroundColor: const Color(0xFF0F1114),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Create New Password",
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
                "Reset Password",
                style: TextStyle(
                  color: Color(0xFFE8ECF2),
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),

              TextField(
                controller: newpassText,
                obscureText: isobscene1,
                style: const TextStyle(color: Color(0xFFE8ECF2)),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1F2329),
                  hintText: "New Password",
                  hintStyle: const TextStyle(color: Color(0xFFA8B2C1)),
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFFA8B2C1)),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => isobscene1 = !isobscene1),
                    icon: Icon(
                      isobscene1 ? Icons.visibility_off : Icons.visibility,
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
                controller: confirmpassText,
                obscureText: isobscene2,
                style: const TextStyle(color: Color(0xFFE8ECF2)),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1F2329),
                  hintText: "Confirm Password",
                  hintStyle: const TextStyle(color: Color(0xFFA8B2C1)),
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFFA8B2C1)),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => isobscene2 = !isobscene2),
                    icon: Icon(
                      isobscene2 ? Icons.visibility_off : Icons.visibility,
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
                  await showLoadingPopup(
                    context: context,
                    asyncFunction: () async => await createNewPassword(),
                    loadingText: "Updating...",
                  );

                  if (newpassText.text.trim() != confirmpassText.text.trim()) {
                    showCustomPopup(
                      context: context,
                      title: "ERROR",
                      content: "Passwords do not match",
                    );
                  } else if (newpassText.text.isEmpty) {
                    showCustomPopup(
                      context: context,
                      title: "ERROR",
                      content: "Password cannot be empty.",
                    );
                  } else if (isError) {
                    showCustomPopup(
                      context: context,
                      title: "ERROR",
                      content: message,
                    );
                  } else {
                    showCustomPopup(
                      context: context,
                      title: "Success",
                      content: "Password Reset Successfully",
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    );
                  }
                },

                child: const Text("Reset Password"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
