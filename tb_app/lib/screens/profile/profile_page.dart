import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tb_app/constants/api_constants.dart';
import 'package:tb_app/screens/profile/update_profile_page.dart';

class ProfilePage extends StatefulWidget {
  final String emailText;

  const ProfilePage({Key? key, required this.emailText}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Map<String, dynamic>> favorites = [];
  late Future<Map<String, dynamic>> profileFuture;

  Future<Map<String, dynamic>> fetchProfile() async {
    final response = await http.post(
      Uri.parse(ApiConstants.fetchProfile),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": widget.emailText}),
    );

    final jsonData = jsonDecode(response.body);

    if (response.statusCode == 200 && jsonData["status_code"] == 200) {
      return jsonData["users"];
    } else {
      throw Exception(jsonData["message"]);
    }
  }

  Future<void> loadFavorites() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.listFavorites),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": widget.emailText}),
      );

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonData["status_code"] == 200) {
        setState(() {
          favorites = List<Map<String, dynamic>>.from(jsonData["favorites"]);
        });
      }
    } catch (e) {
      print("Error loading favorites: $e");
    }
  }

  Future<void> removeFavorite(int conversationId) async {
    await http.post(
      Uri.parse(ApiConstants.removeFavorite),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": widget.emailText.trim(),
        "conversation_id": conversationId,
      }),
    );
    await loadFavorites();
  }

  Future<void> refreshPage() async {
    profileFuture = fetchProfile();
    await loadFavorites();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    profileFuture = fetchProfile();
    loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1114),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(color: Color(0xFFE8ECF2)),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFE8ECF2)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF7B4DFF)),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateProfilePage(
                    emailText: widget.emailText,
                    fromProfile: true,
                  ),
                ),
              );
              await refreshPage();
            },
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: refreshPage,
        color: Colors.white,
        backgroundColor: const Color(0xFF7B4DFF),
        child: FutureBuilder<Map<String, dynamic>>(
          future: profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(
                child: Text(
                  "Unable to load profile.",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final data = snapshot.data!;
            final fullName = "${data["first_name"]} ${data["last_name"] ?? ""}"
                .trim();
            final email = data["email"];
            final createdOn = DateTime.parse(data["created_on"]);

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF171A1F),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2A2D33)),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFF2A2D33),
                          child: Text(
                            email.isNotEmpty ? email[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: Color(0xFF7B4DFF),
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        Text(
                          fullName,
                          style: const TextStyle(
                            color: Color(0xFFE8ECF2),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          email,
                          style: const TextStyle(color: Color(0xFFA8B2C1)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Joined: ${createdOn.day}-${createdOn.month}-${createdOn.year}",
                          style: const TextStyle(color: Color(0xFFA8B2C1)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Text(
                          "Favorites",
                          style: TextStyle(
                            color: Color(0xFFE8ECF2),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          " (Swipe left to remove)",
                          style: TextStyle(
                            color: Color(0xFFE8ECF2),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  favorites.isEmpty
                      ? const Text(
                          "No favorites yet",
                          style: TextStyle(color: Color(0xFF7D8695)),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: favorites.length,
                          itemBuilder: (context, index) {
                            final item = favorites[index];
                            final displayName =
                                item["conversation_type"] == "private"
                                ? item["participant_name"] ??
                                      item["conversation_name"]
                                : item["conversation_name"];

                            return Dismissible(
                              key: Key(item["conversation_id"].toString()),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                padding: const EdgeInsets.only(right: 20),
                                alignment: Alignment.centerRight,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              onDismissed: (_) =>
                                  removeFavorite(item["conversation_id"]),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF171A1F),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF2A2D33),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Color(0xFF7B4DFF),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      displayName ?? "Unnamed Chat",
                                      style: const TextStyle(
                                        color: Color(0xFFE8ECF2),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
