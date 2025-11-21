import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:tb_app/constants/api_constants.dart';
import 'package:tb_app/screens/home/home_screen_page.dart';
import 'package:tb_app/utils/alert.dart';
import 'package:tb_app/utils/loading.dart';

class UpdateProfilePage extends StatefulWidget {
  final String emailText;
  final bool fromProfile;
  const UpdateProfilePage({
    super.key,
    required this.emailText,
    this.fromProfile = false,
  });

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  var firstName = TextEditingController();
  var lastName = TextEditingController();
  var profileImageUrl = TextEditingController();
  var isError = false;
  var message = "Error";

  @override
  void dispose() {
    firstName.dispose();
    lastName.dispose();
    profileImageUrl.dispose();
    super.dispose();
  }

  Future<void> updateProfile() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.profile),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'email': widget.emailText.trim(),
          'first_name': firstName.text.trim(),
          'last_name': lastName.text.trim(),
          'profile_image': profileImageUrl.text.trim().isNotEmpty
              ? profileImageUrl.text.trim()
              : 'https://ui-avatars.com/api/?name=${firstName.text.trim()}+${lastName.text.trim()}&background=random',
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
          "Update Profile",
          style: TextStyle(
            color: Color(0xFFE8ECF2),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Container(
          width: 380,
          height: 400,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF171A1F),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2A2D33)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar
              GestureDetector(
                onTap: () async {
                  final pickedFile = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      profileImageUrl.text = pickedFile.path;
                    });
                  }
                },
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: const Color(0xFF7B4DFF),
                  child: CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.grey[600],
                    backgroundImage: profileImageUrl.text.isNotEmpty
                        ? FileImage(File(profileImageUrl.text))
                        : null,
                    child: profileImageUrl.text.isEmpty
                        ? const Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.white70,
                          )
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // First Name Input
              TextField(
                controller: firstName,
                style: const TextStyle(color: Color(0xFFE8ECF2)),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1F2329),
                  hintText: "Enter First Name",
                  hintStyle: const TextStyle(color: Color(0xFFA8B2C1)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(
                    Icons.person,
                    color: Color(0xFF7B4DFF),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: lastName,
                style: const TextStyle(color: Color(0xFFE8ECF2)),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1F2329),
                  hintText: "Enter Last Name",
                  hintStyle: const TextStyle(color: Color(0xFFA8B2C1)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(
                    Icons.person,
                    color: Color(0xFF7B4DFF),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B4DFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    await showLoadingPopup(
                      context: context,
                      asyncFunction: updateProfile,
                      loadingText: "Updating Profile...",
                    );

                    if (!isError) {
                      showCustomPopup(
                        context: context,
                        title: "Success",
                        content: "Profile Updated Successfully",
                        onPressed: () {
                          Navigator.of(context).pop();
                          if (widget.fromProfile) {
                            Navigator.of(context).pop();
                          } else {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomeScreenPage(
                                  emailText: widget.emailText,
                                  profileImageUrl: profileImageUrl.text,
                                ),
                              ),
                              (route) => false,
                            );
                          }
                        },
                      );
                    } else if (firstName.text.isEmpty) {
                      showCustomPopup(
                        context: context,
                        title: "Error",
                        content: "First Name cannot be empty",
                      );
                    } else if (lastName.text.isEmpty) {
                      showCustomPopup(
                        context: context,
                        title: "Error",
                        content: "Last Name cannot be empty",
                      );
                    } else {
                      showCustomPopup(
                        context: context,
                        title: "Error",
                        content: message,
                      );
                    }
                  },
                  child: const Text(
                    "Update Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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
