import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get screen size
    double screenHeight = MediaQuery.of(context).size.height;
    double headerHeight = 60.0; // Set header height
// Set input field height

    return Scaffold(
      appBar: AppBar(title: const Text('Chat Screen')),
      body: SizedBox(
        height: screenHeight, // Set height based on screen size
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              // Header Section
              Container(
                height: headerHeight,
                padding: const EdgeInsets.symmetric(vertical: 10),
                color: Colors.blueAccent, // Set background color directly
                child: const Center(
                  child: Text(
                    "Chat with Pedagang",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Divider(),

              // Chat Messages
              Expanded(
                child: ListView(
                  children: const [
                    _ChatMessage(
                      isSender: false,
                      message: "Hello! I'm on the way.",
                      time: "10:30 AM",
                    ),
                    _ChatMessage(
                      isSender: true,
                      message: "Great! Looking forward to it.",
                      time: "10:31 AM",
                    ),
                  ],
                ),
              ),

              // Input Section
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    // Message input field
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Type your message...",
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    // Send button
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.blueAccent),
                      onPressed: () {
                        // Implement send message action here
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatMessage extends StatelessWidget {
  final bool isSender;
  final String message;
  final String time;

  const _ChatMessage({
    required this.isSender,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
      child: Row(
        mainAxisAlignment:
            isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // Message Bubble
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            decoration: BoxDecoration(
              color: isSender ? Colors.blueAccent : Colors.grey[300],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment:
                  isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: isSender ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSender ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
