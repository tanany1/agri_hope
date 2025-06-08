import 'package:agri_hope/ui/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatBotIcon extends StatefulWidget {
  @override
  _ChatBotIconState createState() => _ChatBotIconState();
}

class _ChatBotIconState extends State<ChatBotIcon> {
  bool _isChatOpen = false; // Controls whether the chat window is open
  final TextEditingController _controller = TextEditingController();
  List<String> messages = [];
  bool _isLoading = false; // Track if bot is responding

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      messages.add('You: $message');
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/chat'), // Replace with your server URL
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userInput': message}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          messages.add('AgriHopeBot: ${responseData['response']}');
        });
      } else {
        setState(() {
          messages.add('Error: Failed to send message');
        });
      }
    } catch (e) {
      setState(() {
        messages.add('Error: Unable to connect to server');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleChat() {
    setState(() {
      _isChatOpen = !_isChatOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand( // Ensures Stack has a defined size
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 0, 30, 20),
        child: Stack(
          children: [
            if (_isChatOpen)
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  margin: EdgeInsets.only(bottom: 80, right: 20), // Adjusted positioning
                  width: 400, // Adjust width for better UI
                  height: 450, // Adjust height for better fit
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Chat Header
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary3,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.chat, color: Colors.white),
                                SizedBox(width: 10),
                                Text(
                                  'AgriHopeBot',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.white),
                              onPressed: _toggleChat,
                            ),
                          ],
                        ),
                      ),
                      // Chat Messages
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: ListView.builder(
                            reverse: true, // Keep the latest message at the bottom
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              return Align(
                                alignment: messages[index].startsWith('You:')
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: messages[index].startsWith('You:')
                                        ? Colors.green[100]
                                        : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(messages[index]),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      if (_isLoading)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: CircularProgressIndicator(),
                        ),
                      // Input Field & Send Button
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                maxLength: 5000, // Limit to 5000 characters
                                decoration: InputDecoration(
                                  hintText: 'Ask AgriHopeBot... (Max 5000 characters)',
                                  border: InputBorder.none,
                                  counterText: '', // Hide the character counter
                                ),
                                onSubmitted: (message) {
                                  sendMessage(message);
                                  _controller.clear();
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.send, color: Colors.green),
                              onPressed: () {
                                final message = _controller.text;
                                _controller.clear();
                                sendMessage(message);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Floating Chat Icon
            Container(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: FloatingActionButton(
                    onPressed: _toggleChat,
                    child: Icon(_isChatOpen ? Icons.close : Icons.chat, color: Colors.white),
                    backgroundColor: AppColors.primary3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}