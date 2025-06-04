import 'package:flutter/material.dart';

class Message {
  final String avatarUrl;
  final String name;
  final String lastMessage;
  final String time;
  final bool isUnread;

  Message({
    required this.avatarUrl,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.isUnread = false,
  });
}

class Messages extends StatelessWidget {
  Messages({super.key});

  final List<Message> messages = [
    Message(
      avatarUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
      name: 'Dr Frank Ufondu',
      lastMessage: "It's always my pleasure",
      time: '9:41 AM',
      isUnread: true,
    ),
    Message(
      avatarUrl: 'https://randomuser.me/api/portraits/men/2.jpg',
      name: 'Support',
      lastMessage: 'Your issue has been escalated...',
      time: 'Wed',
    ),
    Message(
      avatarUrl: 'https://randomuser.me/api/portraits/women/3.jpg',
      name: 'Dr. Eze',
      lastMessage: "When you're free come...",
      time: '19/06/2022',
    ),
    // Add more message samples...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade100,
        title: const Text('MESSAGES',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            )),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
              ),
            ),
          ),

          // Message list
          Expanded(
            child: ListView.separated(
              itemCount: messages.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                color: Colors.black,
              ),
              itemBuilder: (context, index) {
                final msg = messages[index];
                return ListTile(
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(msg.avatarUrl),
                      ),
                      if (msg.isUnread)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    msg.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    msg.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  trailing: Text(
                    msg.time,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  onTap: () {
                    // Navigate to detailed chat page or do other action
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
