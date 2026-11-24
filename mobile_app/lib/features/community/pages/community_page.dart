import 'package:flutter/material.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  String selectedFilter = 'General';

  final List<Map<String, dynamic>> users = [
    {
      'name': 'Vishnu',
      'username': '@vishnu',
      'message': 'Hey! Did you see the new short film?',
      'time': '2m',
      'unread': 2,
      'color': Colors.blue,
    },
    {
      'name': 'Kanniyappan',
      'username': '@kanniyappan',
      'message': 'The shooting starts tomorrow 🎬',
      'time': '15m',
      'unread': 1,
      'color': Colors.orange,
    },
    {
      'name': 'Tholkapian',
      'username': '@tholkapian',
      'message': 'That camera setup looks amazing!',
      'time': '32m',
      'unread': 0,
      'color': Colors.green,
    },
    {
      'name': 'Monish',
      'username': '@monish',
      'message': 'I uploaded the behind-the-scenes clip.',
      'time': '1h',
      'unread': 3,
      'color': Colors.purple,
    },
    {
      'name': 'Aravind',
      'username': '@aravind',
      'message': 'Can we collaborate on the next project?',
      'time': '2h',
      'unread': 0,
      'color': Colors.red,
    },
    {
      'name': 'Dinesh',
      'username': '@dinesh',
      'message': 'Nice work on the cinematography 🔥',
      'time': '3h',
      'unread': 1,
      'color': Colors.teal,
    },
    {
      'name': 'Ruthesh',
      'username': '@ruthesh',
      'message': 'I have an idea for a new story.',
      'time': '5h',
      'unread': 0,
      'color': Colors.indigo,
    },
    {
      'name': 'Vikram',
      'username': '@vikram',
      'message': 'Let me know when the trailer is ready.',
      'time': 'Yesterday',
      'unread': 0,
      'color': Colors.deepOrange,
    },
    {
      'name': 'Swetha',
      'username': '@swetha',
      'message': 'Loved your latest video! ❤️',
      'time': 'Yesterday',
      'unread': 2,
      'color': Colors.pink,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Column(
        children: [
          // =====================================================
          // FILTER CHIPS
          // =====================================================
          SizedBox(
            height: 58,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: [
                _filterChip('General'),
                _filterChip('Community'),
                _filterChip('Directors'),
              ],
            ),
          ),

          const Divider(height: 1),

          // =====================================================
          // CONVERSATIONS
          // =====================================================
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];

                return _conversationTile(user);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // FILTER CHIP
  // ===========================================================

  Widget _filterChip(String label) {
    final bool selected = selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() {
            selectedFilter = label;
          });
        },
        selectedColor: Colors.deepPurple,
        backgroundColor: Colors.grey.shade900,
        labelStyle: TextStyle(
          color: selected ? Colors.white : Colors.grey.shade300,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color: selected ? Colors.deepPurple : Colors.grey.shade800,
        ),
      ),
    );
  }

  // ===========================================================
  // CONVERSATION TILE
  // ===========================================================

  Widget _conversationTile(Map<String, dynamic> user) {
    return InkWell(
      onTap: () {
        _openConversation(user);
      },

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

        child: Row(
          children: [
            // ---------------------------------------------------
            // AVATAR
            // ---------------------------------------------------
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: user['color'],
                  child: Text(
                    user['name'][0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Online indicator
                Positioned(
                  right: 1,
                  bottom: 1,
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 14),

            // ---------------------------------------------------
            // USER INFORMATION
            // ---------------------------------------------------
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Text(
                        user['time'],
                        style: TextStyle(
                          color: user['unread'] > 0
                              ? Colors.deepPurpleAccent
                              : Colors.grey,
                          fontSize: 12,
                          fontWeight: user['unread'] > 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  Text(
                    user['username'],
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user['message'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: user['unread'] > 0
                                ? Colors.white
                                : Colors.grey.shade500,
                            fontSize: 14,
                            fontWeight: user['unread'] > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ),

                      // ------------------------------------------------
                      // UNREAD BADGE
                      // ------------------------------------------------
                      if (user['unread'] > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.deepPurple,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${user['unread']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================
  // OPEN CONVERSATION
  // ===========================================================

  void _openConversation(Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DummyChatPage(
          name: user['name'],
          username: user['username'],
          color: user['color'],
        ),
      ),
    );
  }
}

// =============================================================
// DUMMY CHAT PAGE
// =============================================================

class DummyChatPage extends StatelessWidget {
  final String name;
  final String username;
  final Color color;

  const DummyChatPage({
    super.key,
    required this.name,
    required this.username,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,

        title: Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: color,
              child: Text(
                name[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 10),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  username,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                _MessageBubble(message: 'Hey! How are you?', isMe: false),
                _MessageBubble(
                  message: 'I am good! Working on a new film 🎬',
                  isMe: true,
                ),
                _MessageBubble(message: 'That sounds awesome!', isMe: false),
                _MessageBubble(message: 'I will share it soon.', isMe: true),
              ],
            ),
          ),

          // Message input
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Message...',
                      filled: true,
                      fillColor: Colors.grey.shade900,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
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

// =============================================================
// MESSAGE BUBBLE
// =============================================================

class _MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe ? Colors.deepPurple : Colors.grey.shade900,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}
