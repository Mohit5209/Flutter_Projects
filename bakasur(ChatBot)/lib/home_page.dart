import 'package:bakasur/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  void _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      String userMessage = _messageController.text.trim();

      setState(() {
        _messages.add({'text': userMessage, 'isUser': true});
      });

      _messageController.clear();

      await _getApiResponse(userMessage);
    }
  }

  Future<void> _getApiResponse(String userMessage) async {
    try {
      final url = Uri.parse('http://127.0.0.1:5000/chat');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': userMessage}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String apiResponse = data['bot_response'];

        setState(() {
          _messages.add({'text': apiResponse, 'isUser': false});
        });
      } else {
        setState(() {
          _messages.add({'text': 'Something went wrong. Please try again.', 'isUser': false});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({'text': 'Error: $e', 'isUser': false});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            setState(() {
              _messages.clear();
            });
          },
          icon: const Icon(Icons.edit_square),
        ),
        title: const Text('Bakasur'),
        elevation: 10,
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                if (Theme.of(context).brightness == Brightness.light) {
                  MyApp.of(context).setThemeMode(ThemeMode.dark);
                } else {
                  MyApp.of(context).setThemeMode(ThemeMode.light);
                }
              });
            },
            icon: const Icon(Icons.dark_mode),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              reverse: true,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                final isUser = message['isUser'];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!isUser)
                        const CircleAvatar(
                          backgroundImage: AssetImage('assets/images/bakasur.jpg'),
                          radius: 20,
                        ),
                      if (!isUser) const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            message['text'],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
