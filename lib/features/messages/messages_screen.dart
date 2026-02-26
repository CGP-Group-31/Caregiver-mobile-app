import 'package:flutter/material.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {

  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> messages = [];

  void sendMessage() {
    if (_controller.text.isEmpty) return;

    setState(() {
      messages.add({
        "text": _controller.text,
        "isMe": true,
        "time": TimeOfDay.now().format(context),
      });
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          color: Colors.blue.shade50,
          child: const Text(
            "Elder: Nimal Perera (Father)",
            textAlign: TextAlign.center,
          ),
        ),

        Expanded(
          child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              return Align(
                alignment: msg['isMe']
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: msg['isMe']
                        ? Colors.blue
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    msg['text'],
                    style: TextStyle(
                      color: msg['isMe']
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: "Type message...",
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: sendMessage,
            )
          ],
        ),
      ],
    );
  }
}