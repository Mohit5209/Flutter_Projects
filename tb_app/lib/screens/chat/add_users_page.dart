import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tb_app/constants/api_constants.dart';
import 'package:tb_app/utils/loading.dart';

class AddUsersPage extends StatefulWidget {
  final String emailText;
  final String mode;
  const AddUsersPage({
    super.key,
    required this.emailText,
    this.mode = 'Private',
  });

  @override
  State<StatefulWidget> createState() {
    return AddUsersPageState();
  }
}

Color getColor(String color) {
  switch (color.toLowerCase()) {
    case 'red':
      return Colors.red;
    case 'blue':
      return Colors.blue;
    case 'green':
      return Colors.green;
    case "orange":
      return Colors.orange;
    case 'cyan':
      return Colors.cyan;
    case 'brown':
      return Colors.brown;
    case "purple":
      return Colors.deepPurple;
    default:
      return Colors.grey;
  }
}

class AddUsersPageState extends State<AddUsersPage> {
  late String mode;
  var isError = false;
  var message = "Error";
  Map userNames = {};
  Map filteredUserNames = {};
  List participants = [];
  String groupName = "Group Chat";
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    mode = widget.mode;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await showLoadingPopup(
          context: context,
          asyncFunction: () async {
            await getUsersData();
          },
          loadingText: 'Loading users...',
        );
      } catch (_) {}
      if (!mounted) return;
      setState(() {});
    });

    searchController.addListener(_filterUsers);
  }

  void _filterUsers() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredUserNames = Map.from(userNames);
      } else {
        filteredUserNames = Map.fromEntries(
          userNames.entries.where((entry) {
            final user = entry.value;
            final name =
                ((user['first_name'] ?? '') + ' ' + (user['last_name'] ?? ''))
                    .toLowerCase();
            final email = entry.key.toLowerCase();
            return name.contains(query) || email.contains(query);
          }),
        );
      }
    });
  }

  @override
  void dispose() {
    userNames.clear();
    filteredUserNames.clear();
    searchController.dispose();
    super.dispose();
  }

  Future<void> getUsersData() async {
    try {
      final uri = Uri.parse(
        mode == 'Group'
            ? ApiConstants.getAllUsers
            : ApiConstants.getDirectUsers,
      );

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': widget.emailText}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final users = body['users'];
        if (users is Map) {
          userNames = Map<String, dynamic>.from(users);
        } else if (users is List) {
          final Map<String, dynamic> map = {};
          for (var u in users) {
            if (u is Map && u['email'] != null) {
              map[u['email'].toString()] = u;
            }
          }
          userNames = map;
        } else {
          userNames = {};
        }
        filteredUserNames = Map.from(userNames);
        isError = false;
      } else {
        isError = true;
        try {
          final body = jsonDecode(response.body);
          message = body['message']?.toString() ?? 'Unknown error';
        } catch (_) {
          message = 'Unexpected server response';
        }
        userNames = {};
        filteredUserNames = {};
      }
    } catch (e) {
      isError = true;
      message = e.toString();
      userNames = {};
      filteredUserNames = {};
    }
  }

  Future<void> startConversation(
    String email,
    List participants,
    String conversationName,
    String conversationType,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.conversationStart),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'created_by_email': email.trim(),
          'participants': participants,
          'conversation_name': conversationName,
          'conversation_type': conversationType,
        }),
      );

      if (response.statusCode != 200) {
        isError = true;
        final body = jsonDecode(response.body);
        message = '${body['message'] ?? 'Unknown error'}';
      } else {
        isError = false;
      }
    } catch (e) {
      isError = true;
      message = e.toString();
    }
  }

  Future<String> getGroupName() async {
    await showDialog<String>(
      context: context,
      builder: (context) {
        var controller = TextEditingController();
        return AlertDialog(
          backgroundColor: const Color(0xFF171A1F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Enter Group Name',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Group Chat",
              hintStyle: TextStyle(color: Colors.white60),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white38),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.blue),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                groupName = controller.text.trim().isEmpty
                    ? "Group Chat"
                    : controller.text.trim();
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFF7B4DFF)),
              ),
            ),
          ],
        );
      },
    );
    return groupName;
  }

  @override
  Widget build(BuildContext context) {
    var iconcolors = [
      "Red",
      "Blue",
      "Green",
      "Orange",
      "Cyan",
      "Brown",
      "Purple",
      "Green",
      "Red",
      "Blue",
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF171A1F),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: isSearching
            ? TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Search users...",
                  hintStyle: TextStyle(color: Colors.white60),
                  border: InputBorder.none,
                ),
                autofocus: true,
              )
            : const Text(
                "Add Users",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  searchController.clear();
                }
                isSearching = !isSearching;
              });
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF171A1F),
        child: isError
            ? Center(
                child: Text(message, style: const TextStyle(color: Colors.red)),
              )
            : filteredUserNames.isEmpty
            ? const Center(
                child: Text(
                  'No users found',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : ListView.separated(
                itemCount: filteredUserNames.keys.length,
                itemBuilder: (context, index) {
                  final email = filteredUserNames.keys.elementAt(index);
                  final user = filteredUserNames[email];
                  final displayName =
                      (user != null &&
                          (user['first_name'] != null ||
                              user['last_name'] != null))
                      ? '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'
                            .trim()
                      : email;

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF171A1F),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2A2D33)),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: getColor(
                          iconcolors[index % iconcolors.length],
                        ),
                        child: Text(
                          (user != null &&
                                  (user['first_name'] ?? '').isNotEmpty)
                              ? user['first_name'][0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),

                      title: Text(
                        displayName,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        email,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7B4DFF),
                        ),
                        onPressed: () {
                          setState(() {
                            if (!participants.contains(email)) {
                              participants.add(email);
                            }
                            userNames.remove(email);
                            filteredUserNames.remove(email);
                          });
                        },
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider(
                    height: 20,
                    thickness: 1,
                    color: Colors.white12,
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (participants.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'No users selected. Please select at least one user.',
                ),
              ),
            );
          } else if (mode == 'Group' && participants.length < 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Please select at least 2 users for a group chat.',
                ),
              ),
            );
          } else {
            if (mode == 'Group') await getGroupName();
            await showLoadingPopup(
              context: context,
              asyncFunction: () async {
                await startConversation(
                  widget.emailText,
                  participants,
                  mode == 'Group' ? groupName : 'Private Chat',
                  mode.toLowerCase(),
                );
              },
              loadingText: 'Starting conversation...',
            );
            if (!mounted) return;
            if (!isError) {
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error starting conversation: $message'),
                ),
              );
            }
          }
        },
        label: Text(
          'Start ${mode == 'Group' ? 'Group' : 'Private'} Conversation',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF7B4DFF),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
