import 'package:flutter/material.dart';
import '../auth/theme.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {

  final TextEditingController _controller = TextEditingController();

  List<Map<String, dynamic>> messages = [
    {"text": "Did you take medicine?", "isMe": true},
    {"text": "Yes, I took it.", "isMe": false},
  ];

  void sendMessage() {
    if (_controller.text.isEmpty) return;

    setState(() {
      messages.add({
        "text": _controller.text,
        "isMe": true,
      });
    });

    _controller.clear();
  }

  Widget chatBubble(Map<String, dynamic> msg) {
    final bool isMe = msg['isMe'];

    return Align(
      alignment:
      isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 260),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.primary
              : AppColors.containerBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          msg['text'],
          style: TextStyle(
            color: isMe
                ? Colors.white
                : AppColors.primaryText,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Messages",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [

          // Elder Info Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: AppColors.sectionBackground,
            child: const Text(
              "Nimal Perera (Father)",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) =>
                  chatBubble(messages[index]),
            ),
          ),

          // Input Bar
          Container(
            padding: const EdgeInsets.all(10),
            color: AppColors.sectionBackground,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      fillColor: AppColors.containerBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send,
                        color: Colors.white),
                    onPressed: sendMessage,
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