import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tb_app/constants/api_constants.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatPage extends StatefulWidget {
  final int conversationId;
  final String conversationName;
  final String conversationType;
  final String emailText;

  const ChatPage({
    super.key,
    required this.conversationId,
    required this.conversationName,
    required this.conversationType,
    required this.emailText,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool isFavorite = false;
  WebSocketChannel? channel;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> messages = [];
  bool isLoading = true;

  List<Map<String, String>> groupParticipants = [];

  @override
  void initState() {
    super.initState();

    debugPrint(
      "🔹 initState called for conversationId: ${widget.conversationId}",
    );
    loadMessages();
    loadFavoriteStatus();
    connectWebSocket();
    if (widget.conversationType.toLowerCase() == "group") {
      debugPrint("🔹 Conversation type is group. Loading participants...");
      loadGroupParticipants();
    } else {
      debugPrint("ℹConversation type is not group: ${widget.conversationType}");
    }
  }

  @override
  void dispose() {
    debugPrint(
      "Disposing ChatPage for conversationId: ${widget.conversationId}",
    );
    if (channel != null) {
      debugPrint("Closing WebSocket connection...");
      channel?.sink.close();
      channel = null;
    }

    debugPrint("Disposing controllers...");
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
    debugPrint("Dispose complete.");
  }

  Future<void> loadGroupParticipants() async {
    debugPrint(
      "Fetching group participants for conversationId: ${widget.conversationId}",
    );
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.getGroupParticipants),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"conversation_id": widget.conversationId}),
      );

      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          groupParticipants = (data["participants"] as List)
              .map<Map<String, String>>(
                (p) => {
                  "email": (p["email"] ?? "").toString(),
                  "name":
                      (p["name"] ?? (p["email"] ?? "").toString().split("@")[0])
                          .toString(),
                },
              )
              .toList();
        });
        debugPrint(
          "Group participants loaded successfully: $groupParticipants",
        );
      } else {
        debugPrint(
          "Failed to load participants. Status: ${response.statusCode}",
        );
      }
    } catch (e, stack) {
      debugPrint("Error loading participants: $e");
      debugPrint(stack.toString());
    }
  }

  void connectWebSocket() {
    final wsUrl = ApiConstants.sendMessageWs(
      widget.conversationId,
      widget.emailText.trim(),
    );

    debugPrint("Connecting to WebSocket: $wsUrl");

    try {
      channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      debugPrint("WebSocket connected.");

      channel!.stream.listen(
        (event) {
          debugPrint("WebSocket message received: $event");
          try {
            final data = jsonDecode(event);
            handleWebSocketMessage(data);
          } catch (e) {
            debugPrint("Error parsing WebSocket message: $e");
          }
        },
        onError: (error) {
          debugPrint("WebSocket error: $error");
        },
        onDone: () {
          debugPrint(
            "WebSocket closed for conversationId: ${widget.conversationId}",
          );
        },
      );
    } catch (e) {
      debugPrint("Failed to connect WebSocket: $e");
    }
  }

  void handleWebSocketMessage(Map<String, dynamic> data) {
    debugPrint("Handling WebSocket data: $data");

    final messageId = data["message_id"];
    final sender = data["sender"]?.toString().toLowerCase();
    final senderName = data["sender_name"] ?? "U";
    final myEmail = widget.emailText.trim().toLowerCase();
    final status = data["status"];
    final text = data["text"];

    debugPrint(
      "Parsed - messageId: $messageId, sender: $sender, text: $text, status: $status",
    );

    setState(() {
      if (text == null && messageId != null) {
        debugPrint(
          "Updating message status for messageId: $messageId → $status",
        );
        for (var m in messages) {
          if (m["message_id"] == messageId && m["sender"] == "me") {
            m["status"] = status;
            break;
          }
        }
        return;
      }

      if (sender == myEmail && text != null) {
        debugPrint("Message from self detected.");
        bool found = false;
        for (var m in messages) {
          if (m["message_id"] == messageId && m["sender"] == "me") {
            debugPrint("Updating existing message with new status: $status");
            m["status"] = status;
            found = true;
            break;
          }
        }
        if (!found) {
          for (var m in messages) {
            if (m["message_id"] == null &&
                m["text"] == text &&
                m["sender"] == "me") {
              debugPrint(
                "Matching temp message found. Assigning message_id: $messageId",
              );
              m["message_id"] = messageId;
              m["status"] = status;
              m.remove("temp_id");
              found = true;
              break;
            }
          }
        }
      } else if (sender != myEmail && text != null) {
        bool exists = messages.any((m) => m["message_id"] == messageId);
        if (!exists) {
          debugPrint("New incoming message from $senderName <$sender>");
          messages.add({
            "message_id": messageId,
            "text": text,
            "sender": "other",
            "status": status ?? "delivered",
            "sender_name": senderName,
            "sender_email": sender,
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollToBottom();
          });
          markMessagesAsRead();
        } else {
          debugPrint("Duplicate message ignored for messageId: $messageId");
        }
      }
    });
  }

  Future<void> loadMessages() async {
    debugPrint("Loading messages for conversationId: ${widget.conversationId}");
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.getMessages),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": widget.emailText.trim(),
          "conversation_id": widget.conversationId,
        }),
      );

      debugPrint("Messages API status: ${response.statusCode}");
      debugPrint("Messages response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          messages = (data["message"] as List).map((msg) {
            String status = msg["status"] ?? "sent";
            if (msg["sent_by_me"] == true && status == "delivered") {
              status = "delivered";
            } else if (msg["sent_by_me"] == true && status == "read") {
              status = "read";
            }
            return {
              "message_id": msg["message_id"],
              "text": msg["text"],
              "sender": msg["sent_by_me"] ? "me" : "other",
              "status": status,
              "sender_name": msg["sent_by_me"] ? "" : msg["sender_name"] ?? "U",
              "sender_email": msg["sent_by_me"]
                  ? widget.emailText
                  : msg["sender"],
            };
          }).toList();
          isLoading = false;
        });

        debugPrint("Loaded ${messages.length} messages successfully.");

        await markMessagesAsRead();
        WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
      } else {
        debugPrint(
          "Failed to load messages. Status code: ${response.statusCode}",
        );
        setState(() => isLoading = false);
      }
    } catch (e, stack) {
      debugPrint("Error loading messages: $e");
      debugPrint(stack.toString());
      setState(() => isLoading = false);
    }
  }

  Future<void> markMessagesAsRead() async {
    debugPrint(
      "Marking messages as read for conversationId: ${widget.conversationId}",
    );
    try {
      await http.post(
        Uri.parse(ApiConstants.messageRead),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": widget.emailText.trim(),
          "conversation_id": widget.conversationId,
        }),
      );
      debugPrint("Messages marked as read successfully.");
    } catch (e) {
      debugPrint("Failed to mark messages as read: $e");
    }
  }

  void sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      debugPrint("Tried to send empty message.");
      return;
    }
    if (channel == null) {
      debugPrint("WebSocket not connected. Cannot send message.");
      return;
    }

    _messageController.clear();
    final tempId = DateTime.now().millisecondsSinceEpoch;
    debugPrint("Sending message: \"$text\" (tempId: $tempId)");

    setState(() {
      messages.add({
        "message_id": null,
        "temp_id": tempId,
        "text": text,
        "sender": "me",
        "status": "sent",
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());

    try {
      channel?.sink.add(jsonEncode({"body": text}));
      debugPrint("Message sent successfully over WebSocket.");
    } catch (e) {
      debugPrint("Failed to send message: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to send message")));
    }
  }

  void scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget buildMessage(Map msg) {
    final isMe = msg["sender"] == "me";
    Icon? tick;

    if (isMe) {
      final status = msg["status"] ?? "sent";
      if (status == "sent")
        tick = const Icon(Icons.check, size: 16, color: Colors.white70);
      if (status == "delivered")
        tick = const Icon(Icons.done_all, size: 16, color: Colors.white70);
      if (status == "read")
        tick = const Icon(
          Icons.done_all,
          size: 16,
          color: Colors.lightBlueAccent,
        );
    }

    Widget? avatar;
    if (!isMe && widget.conversationType.toLowerCase() == "group") {
      final senderName = msg["sender_name"] ?? "U";
      final senderEmail = msg["sender_email"] ?? "";
      avatar = GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: const Color(0xFF1C1F26),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            builder: (_) => ListView(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF4EA7FF),
                    child: Text(
                      senderName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    senderName,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    senderEmail,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          );
        },
        child: CircleAvatar(
          radius: 16,
          backgroundColor: const Color(0xFF7B4DFF),
          child: Text(
            senderName.isNotEmpty ? senderName[0].toUpperCase() : "U",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) avatar ?? const SizedBox(width: 0),
          if (!isMe) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(vertical: 4),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF7B4DFF) : const Color(0xFF1C1F26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      msg["text"],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  if (isMe && tick != null) ...[const SizedBox(width: 6), tick],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> loadFavoriteStatus() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.isFavorite),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": widget.emailText.trim(),
          "conversation_id": widget.conversationId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          isFavorite = data["is_favorite"] == true;
        });
      }
    } catch (e) {
      debugPrint("Failed to load favorite status: $e");
    }
  }

  Future<void> addToFavorites() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.addFavorite),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": widget.emailText.trim(),
          "conversation_id": widget.conversationId,
        }),
      );

      if (response.statusCode == 200) {
        setState(() => isFavorite = true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Added to Favorites")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to Add")));
    }
  }

  Future<void> removeFromFavorites() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.removeFavorite),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": widget.emailText.trim(),
          "conversation_id": widget.conversationId,
        }),
      );

      if (response.statusCode == 200) {
        setState(() => isFavorite = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Removed from Favorites")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to Remove")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171A1F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF171A1F),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: GestureDetector(
          onTap: () {
            debugPrint(
              "Chat title tapped. Conversation type: ${widget.conversationType}",
            );

            if (widget.conversationType.toLowerCase() == "group") {
              debugPrint("Opening group participants bottom sheet");
              showModalBottomSheet(
                context: context,
                backgroundColor: const Color(0xFF1C1F26),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                builder: (_) => ListView(
                  children: groupParticipants.map((p) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF7B4DFF),
                        child: Text(
                          p["name"]![0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        p["name"]!,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        p["email"]!,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    );
                  }).toList(),
                ),
              );
            } else {
              debugPrint("Private chat detected, looking for recipient info");

              // Try to get recipient from messages
              final recipient = messages.firstWhere(
                (m) => m["sender"] != "me",
                orElse: () => <String, dynamic>{},
              );

              String recipientName = "";
              String recipientEmail = "";

              if (recipient.isNotEmpty) {
                recipientName =
                    recipient["sender_name"] ??
                    recipient["sender_email"] ??
                    "Unknown";
                recipientEmail =
                    recipient["sender_email"] ?? "unknown@example.com";
                debugPrint(
                  "Found recipient from messages: $recipientName <$recipientEmail>",
                );
              } else {
                // If no messages exist yet, fallback to conversationName or placeholder
                recipientName = widget.conversationName;
                recipientEmail = "unknown@example.com";
                debugPrint(
                  "No messages yet, using fallback: $recipientName <$recipientEmail>",
                );
              }

              showModalBottomSheet(
                context: context,
                backgroundColor: const Color(0xFF1C1F26),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                builder: (_) => ListView(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF7B4DFF),
                        child: Text(
                          recipientName.isNotEmpty
                              ? recipientName[0].toUpperCase()
                              : "U",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        recipientName,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        recipientEmail,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
          child: Text(
            widget.conversationName,
            style: const TextStyle(color: Colors.white),
          ),
        ),

        elevation: 1,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: const Color(0xFF1C1F26),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) async {
              if (value == 'Toggle Favorite') {
                if (isFavorite) {
                  await removeFromFavorites();
                } else {
                  await addToFavorites();
                }
              } else if (value == 'Clear Chat') {
                try {
                  final response = await http.post(
                    Uri.parse(ApiConstants.clearChat),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({
                      "email": widget.emailText.trim(),
                      "conversation_id": widget.conversationId,
                    }),
                  );

                  if (response.statusCode == 200) {
                    await loadMessages();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Chat cleared")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed: ${response.body}")),
                    );
                  }
                } catch (e) {
                  if (Navigator.of(context, rootNavigator: true).canPop()) {
                    Navigator.of(context, rootNavigator: true).pop();
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error clearing chat: $e")),
                  );
                }
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'Toggle Favorite',
                child: Text(
                  isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const PopupMenuItem(
                value: 'Clear Chat',
                child: Text(
                  'Clear Chat',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4EA7FF)),
                  )
                : messages.isEmpty
                ? const Center(
                    child: Text(
                      "No messages yet. Start the conversation!",
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    itemCount: messages.length,
                    itemBuilder: (_, index) => buildMessage(messages[index]),
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: const Color(0xFF1C1F26),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Type message...",
                        hintStyle: const TextStyle(color: Colors.white60),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white38),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white38),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF7B4DFF),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF7B4DFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
