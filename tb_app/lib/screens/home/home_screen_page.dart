import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tb_app/constants/api_constants.dart';
import 'package:tb_app/screens/auth/login_page.dart';
import 'package:tb_app/screens/chat/add_users_page.dart';
import 'package:tb_app/screens/chat/chat_page.dart';
import 'package:tb_app/screens/profile/profile_page.dart';
import 'package:tb_app/utils/alert.dart';
import 'package:tb_app/utils/loading.dart';
import 'package:tb_app/utils/selection_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';

class HomeScreenPage extends StatefulWidget {
  final String emailText;
  final String profileImageUrl;
  const HomeScreenPage({
    super.key,
    required this.emailText,
    this.profileImageUrl = '',
  });

  @override
  State<HomeScreenPage> createState() => HomeScreenPageState();
}

enum ConversationFilter { all, unread, groups, favorites }

class HomeScreenPageState extends State<HomeScreenPage> {
  bool _isError = false;
  Timer? _refreshTimer;
  String _errorMessage = "Error";
  List<dynamic> _conversations = [];
  List<dynamic> _favoriteConversations = [];
  List<dynamic> _pinnedConversations = [];
  List<dynamic> _searchResults = [];

  bool _isSearching = false;
  TextEditingController searchController = TextEditingController();

  final List<ButtonSegment<ConversationFilter>> segments = [
    ButtonSegment(value: ConversationFilter.all, label: Text('All')),
    ButtonSegment(value: ConversationFilter.unread, label: Text('Unread')),
    ButtonSegment(value: ConversationFilter.groups, label: Text('Groups')),
    ButtonSegment(
      value: ConversationFilter.favorites,
      label: Text('Favorites'),
    ),
  ];

  Set<ConversationFilter> selected = {ConversationFilter.all};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showLoadingPopup(
        context: context,
        asyncFunction: () async {
          await _getConversations(widget.emailText);
          await _getFavorites();
          await _getPinned();
        },
        loadingText: 'Loading conversations...',
      );
      if (!mounted) return;
      setState(() {});
    });

    searchController.addListener(() {
      _performSearch(searchController.text.trim());
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    searchController.dispose();
    super.dispose();
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove("user_email");
  }

  Future<void> _getConversations(String email) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.conversations),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email.trim()}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        setState(() {
          _isError = false;
          _conversations = (body['conversations'] ?? []);
          _sortConversations();
        });
      } else {
        final body = jsonDecode(response.body);
        _isError = true;
        _errorMessage = body['message'] ?? 'Unknown error';
      }
    } catch (e) {
      _isError = true;
      _errorMessage = e.toString();
    }
  }

  Future<void> _getFavorites() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.listFavorites),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': widget.emailText.trim()}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        setState(() {
          _favoriteConversations = body['favorites'] ?? [];
        });
      }
    } catch (_) {}
  }

  Future<void> _getPinned() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.listPinned),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': widget.emailText.trim()}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        print(body);
        _pinnedConversations = body['pinned'] ?? [];
        for (var convo in _conversations) {
          convo['is_pinned'] = _pinnedConversations.any(
            (p) => p['conversation_id'] == convo['conversation_id'],
          );
        }
        setState(() {
          _sortConversations();
        });
      }
    } catch (_) {}
  }

  void _sortConversations() {
    _conversations.sort((a, b) {
      bool pinnedA = (a['is_pinned'] == true || a['is_pinned'] == 'yes');
      bool pinnedB = (b['is_pinned'] == true || b['is_pinned'] == 'yes');

      if (pinnedA != pinnedB) return pinnedB ? 1 : -1;

      DateTime timeA =
          DateTime.tryParse(a['last_message']?['created_at'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      DateTime timeB =
          DateTime.tryParse(b['last_message']?['created_at'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);

      return timeB.compareTo(timeA);
    });

    setState(() {});
  }

  Future<void> _refreshConversations() async {
    try {
      final responses = await Future.wait([
        _getConversationsRaw(widget.emailText),
        _getFavoritesRaw(),
        _getPinnedRaw(),
      ]);

      List<dynamic> convos = responses[0];
      List<dynamic> favorites = responses[1];
      List<dynamic> pinned = responses[2];

      for (var convo in convos) {
        convo['is_pinned'] = pinned.any(
          (p) => p['conversation_id'] == convo['conversation_id'],
        );
      }

      setState(() {
        _conversations = convos;
        _favoriteConversations = favorites;
        _pinnedConversations = pinned;
        _sortConversations();
      });
    } catch (e) {
      debugPrint("Error refreshing conversations: $e");
    }
  }

  Future<List<dynamic>> _getConversationsRaw(String email) async {
    final response = await http.post(
      Uri.parse(ApiConstants.conversations),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'email': email.trim()}),
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['conversations'] ?? [];
    }
    return [];
  }

  Future<List<dynamic>> _getFavoritesRaw() async {
    final response = await http.post(
      Uri.parse(ApiConstants.listFavorites),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'email': widget.emailText.trim()}),
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['favorites'] ?? [];
    }
    return [];
  }

  Future<List<dynamic>> _getPinnedRaw() async {
    final response = await http.post(
      Uri.parse(ApiConstants.listPinned),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'email': widget.emailText.trim()}),
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['pinned'] ?? [];
    }
    return [];
  }

  Future<void> unregisterDeviceFromServer() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) return;

      final response = await http.post(
        Uri.parse(ApiConstants.unregisterDevice),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"device_id": fcmToken}),
      );

      if (response.statusCode == 200) {
        debugPrint("Device unregistered from notifications");
      } else {
        debugPrint("Unregister failed: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error unregistering device: $e");
    }
  }

  String _resolveConversationName(Map convo) {
    final type = convo['conversation_type'] ?? '';
    final participants = (convo['participants'] ?? []) as List<dynamic>;
    final myEmail = widget.emailText.toLowerCase().trim();

    if (type == "group") {
      String name = (convo['conversation_name'] ?? "").toString().trim();
      return name.isEmpty ? "Group" : name;
    }

    final other = participants.firstWhere(
      (p) => (p['email'] ?? "").toString().toLowerCase() != myEmail,
      orElse: () => participants.isNotEmpty ? participants.first : null,
    );

    if (other == null) return "Chat";

    String first = (other["first_name"] ?? "").toString();
    String last = (other["last_name"] ?? "").toString();
    String displayName = "$first $last".trim();
    return displayName.isEmpty ? other["email"] ?? "Chat" : displayName;
  }

  void _performSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _searchResults = List.from(currentList);
      } else {
        _searchResults = currentList.where((c) {
          final name = _resolveConversationName(c).toLowerCase();
          return name.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  List<dynamic> get currentList {
    if (selected.contains(ConversationFilter.favorites)) {
      return _conversations
          .where(
            (c) => _favoriteConversations.any(
              (f) => f['conversation_id'] == c['conversation_id'],
            ),
          )
          .toList();
    }
    return _conversations;
  }

  List<dynamic> get filteredConversations {
    List<dynamic> list = _isSearching ? _searchResults : currentList;

    if (selected.contains(ConversationFilter.unread)) {
      list = list.where((c) => (c['unread_count'] ?? 0) > 0).toList();
    } else if (selected.contains(ConversationFilter.groups)) {
      list = list.where((c) => c['conversation_type'] == 'group').toList();
    }

    return list;
  }

  Future<void> _togglePin(Map convo) async {
    bool newState = !(convo['is_pinned'] == true);

    setState(() {
      convo['is_pinned'] = newState;
      _sortConversations();
    });

    final url = newState
        ? ApiConstants.addToPinned
        : ApiConstants.removeFromPinned;

    await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        "email": widget.emailText.trim(),
        'conversation_id': convo['conversation_id'],
      }),
    );

    await _getPinned();
  }

  void _showConversationActions(Map convo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF171A1F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(
                convo['is_pinned'] == true
                    ? Icons.push_pin
                    : Icons.push_pin_outlined,
                color: const Color(0xFF7B4DFF),
              ),
              title: Text(
                convo['is_pinned'] == true ? "Unpin Chat" : "Pin Chat",
                style: const TextStyle(color: Color(0xFFE8ECF2)),
              ),
              onTap: () {
                Navigator.pop(context);
                _togglePin(convo);
              },
            ),
            if ((convo['unread_count'] ?? 0) > 0)
              ListTile(
                leading: const Icon(
                  Icons.mark_email_read_outlined,
                  color: Color(0xFF7B4DFF),
                ),
                title: const Text(
                  "Mark as Read",
                  style: TextStyle(color: Color(0xFFE8ECF2)),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    convo['unread_count'] = 0;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1114),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1114),
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 40,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfilePage(emailText: widget.emailText),
              ),
            ).then((_) => _refreshConversations()),
            child: CircleAvatar(
              radius: 12,
              backgroundColor: const Color(0xFF1C1F26),
              backgroundImage: widget.profileImageUrl.isNotEmpty
                  ? NetworkImage(widget.profileImageUrl)
                  : null,
              child: widget.profileImageUrl.isEmpty
                  ? Text(
                      widget.emailText.trim().isNotEmpty
                          ? widget.emailText.trim()[0].toUpperCase()
                          : '',
                      style: const TextStyle(
                        color: Color(0xFFE8ECF2),
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
        ),

        title: _isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                style: const TextStyle(color: Color(0xFFE8ECF2)),
                decoration: const InputDecoration(
                  hintText: "Search...",
                  hintStyle: TextStyle(color: Color(0xFFA8B2C1)),
                  border: InputBorder.none,
                ),
              )
            : const Text(
                "TB App",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE8ECF2),
                ),
              ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: const Color(0xFFE8ECF2),
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) searchController.clear();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFFE8ECF2)),
            onPressed: () {
              showMenu<String>(
                context: context,
                position: const RelativeRect.fromLTRB(1000, 80, 0, 0),
                color: const Color(0xFF1C1F26),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                items: [
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Text(
                      "Logout",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ).then((value) {
                if (value == 'logout') {
                  showCustomPopup(
                    context: context,
                    title: "Logout",
                    content: "Are you sure you want to logout?",
                    buttonText: "Logout",
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await showLoadingPopup(
                        context: context,
                        loadingText: "Logging out...",
                        asyncFunction: () async {
                          await unregisterDeviceFromServer();
                          await clearToken();
                          await FirebaseMessaging.instance.deleteToken();
                        },
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                  );
                }
              });
            },
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ToggleButtons(
                isSelected: segments
                    .map((s) => selected.contains(s.value))
                    .toList(),
                onPressed: (index) {
                  setState(() {
                    selected = {segments[index].value};
                  });
                },
                borderRadius: BorderRadius.circular(12),
                selectedColor: const Color(0xFFE8ECF2),
                fillColor: const Color(0xFF171A1F),
                color: const Color(0xFFA8B2C1),
                constraints: const BoxConstraints(),
                children: segments.map((s) {
                  final isSel = selected.contains(s.value);
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSel ? 30 : 20,
                      vertical: 8,
                    ),
                    child: s.label,
                  );
                }).toList(),
              ),
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshConversations,
              color: const Color(0xFF7B4DFF),
              backgroundColor: const Color(0xFF171A1F),
              child: _isError
                  ? Center(
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : filteredConversations.isEmpty
                  ? const Center(
                      child: Text(
                        "No conversations found",
                        style: TextStyle(color: Color(0xFFE8ECF2)),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: filteredConversations.length,
                      itemBuilder: (context, index) {
                        final convo = filteredConversations[index];
                        final displayName = _resolveConversationName(convo);
                        final type = convo['conversation_type'] ?? '';
                        final lastMessage =
                            convo['last_message']?['text'] ?? 'No messages yet';
                        final unread = convo['unread_count'] ?? 0;

                        return GestureDetector(
                          onLongPress: () => _showConversationActions(convo),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF171A1F),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF2A2D33),
                              ),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: type == 'group'
                                    ? const Color(0xFF4EA7FF)
                                    : const Color(0xFF7B4DFF),
                                child: Builder(
                                  builder: (_) {
                                    if (type == 'group') {
                                      final name = convo['conversation_name']
                                          ?.toString()
                                          .trim();
                                      return Text(
                                        (name != null && name.isNotEmpty)
                                            ? name[0].toUpperCase()
                                            : 'G',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    } else {
                                      final participants =
                                          convo['participants']
                                              as List<dynamic>? ??
                                          [];
                                      final other = participants.firstWhere(
                                        (p) =>
                                            (p['email'] ?? '')
                                                .toString()
                                                .toLowerCase() !=
                                            widget.emailText.toLowerCase(),
                                        orElse: () => {'first_name': '?'},
                                      );
                                      final firstName =
                                          (other['first_name'] ?? '')
                                              .toString();
                                      return Text(
                                        firstName.isNotEmpty
                                            ? firstName[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_favoriteConversations.any(
                                    (f) =>
                                        f['conversation_id'] ==
                                        convo['conversation_id'],
                                  ))
                                    const Icon(
                                      Icons.star,
                                      size: 18,
                                      color: Colors.yellow,
                                    ),
                                  if (convo['is_pinned'] == true)
                                    const Icon(
                                      Icons.push_pin,
                                      size: 18,
                                      color: Colors.orange,
                                    ),
                                  if (unread > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                      child: CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.red,
                                        child: Text(
                                          unread.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              title: Text(
                                displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE8ECF2),
                                ),
                              ),
                              subtitle: Text(
                                lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFFA8B2C1),
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatPage(
                                      conversationId: convo['conversation_id'],
                                      conversationName: displayName,
                                      conversationType: type,
                                      emailText: widget.emailText,
                                    ),
                                  ),
                                ).then((_) => _refreshConversations());
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final selected = await showSelectionDialog(
            context: context,
            initial: 'Private',
          );
          if (selected != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    AddUsersPage(emailText: widget.emailText, mode: selected),
              ),
            ).then((_) => _refreshConversations());
          }
        },
        label: const Text("Add User"),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF7B4DFF),
        foregroundColor: Colors.white,
      ),
    );
  }
}
