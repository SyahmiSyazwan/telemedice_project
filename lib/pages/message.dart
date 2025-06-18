import 'package:flutter/material.dart';
import '../services/ai_chat_service.dart';

class Messages extends StatefulWidget {
  const Messages({super.key});

  @override
  State<Messages> createState() => _MessagePageState();
}

class _MessagePageState extends State<Messages> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final AIChatService aiChat = AIChatService(
      "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");

  final List<Map<String, String>> messages = []; // List of {sender, message}

  bool isLoading = false;

  void _sendMessage() async {
    final message = _controller.text.trim();
    if (message.isEmpty) return;

    setState(() {
      messages.add({'sender': 'user', 'message': message});
      _controller.clear();
      isLoading = true;
    });

    try {
      final response = await aiChat.sendMessage(message);
      setState(() {
        messages.add({'sender': 'ai', 'message': response});
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        messages.add({'sender': 'ai', 'message': '⚠️ Error: $e'});
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _buildAIMessage(String message) {
    const disclaimer =
        "*This is an AI-generated medical suggestion. Please consult a licensed healthcare professional before making any decisions.*";

    if (!message.contains(disclaimer)) {
      return Text(message, style: const TextStyle(fontSize: 16));
    }

    final reply = message.replaceAll(disclaimer, '').trim();

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 16, color: Colors.black),
        children: [
          TextSpan(text: "$reply\n\n"),
          const TextSpan(
            text: disclaimer,
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade100,
        title: const Text(
          'AI VIRTUAL DOCTOR',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg['sender'] == 'user';
                return Container(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.teal[200] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: isUser
                        ? Text(
                            msg['message']!,
                            style: const TextStyle(fontSize: 16),
                          )
                        : _buildAIMessage(msg['message']!),
                  ),
                );
              },
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: const InputDecoration(
                      labelText: "Ask A Question",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.teal,
                  onPressed: isLoading ? null : _sendMessage,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
