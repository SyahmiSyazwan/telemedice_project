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
      ""); //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

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
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade100,
        title: const Text(
          'MESSAGES',
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
                    child: Text(
                      msg['message']!,
                      style: const TextStyle(fontSize: 16),
                    ),
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
