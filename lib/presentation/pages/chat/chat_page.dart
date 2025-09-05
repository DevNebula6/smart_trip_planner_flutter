import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String? initialPrompt;
  
  const ChatPage({super.key, this.initialPrompt});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Center(
        child: Text('Chat Page - ${widget.initialPrompt ?? "No initial prompt"}'),
      ),
    );
  }
}
