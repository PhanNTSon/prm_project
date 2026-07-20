import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prm_project/features/community/providers/chat_provider.dart';
import 'package:prm_project/features/community/views/widgets/chat_bubble.dart';
import 'package:intl/intl.dart';

class ChatDetailScreen extends StatefulWidget {
  final String username;
  final int friendId;
  const ChatDetailScreen({super.key, required this.username, required this.friendId});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _textController = TextEditingController();
  late ChatProvider _chatProvider;

  @override
  void initState() {
    super.initState();
    _chatProvider = context.read<ChatProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatProvider.loadChatHistory(widget.friendId, widget.username);
      _chatProvider.subscribeToChat(widget.username);
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      _chatProvider.sendPrivateMessage(widget.username, text);
      _textController.clear();
    }
  }

  @override
  void dispose() {
    _chatProvider.unsubscribeFromChat(widget.username);
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF2A3F5A),
              child: Text(
                widget.username.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            const SizedBox(width: 12),
            Text(widget.username, style: const TextStyle(fontSize: 16)),
          ],
        ),
        backgroundColor: const Color(0xFF171D25),
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                final messages = chatProvider.getMessagesForUser(widget.username);
                
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet.\nSay hello!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38),
                    ),
                  );
                }

                // Đảo ngược danh sách vì ListView reverse = true
                final reversedMessages = messages.reversed.toList();

                return ListView.builder(
                  reverse: true, // Cuộn từ dưới lên
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: reversedMessages.length,
                  itemBuilder: (context, index) {
                    final msg = reversedMessages[index];
                    String? timeStr;
                    if (msg.sentAt != null) {
                      timeStr = DateFormat('HH:mm').format(msg.sentAt!.toLocal());
                    }
                    return ChatBubble(
                      message: msg.content ?? '',
                      isMine: msg.isMine,
                      time: timeStr,
                    );
                  },
                );
              },
            ),
          ),
          
          // Thanh nhập text
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF171D25),
              border: Border(top: BorderSide(color: Color(0xFF2A3F5A), width: 1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Message...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      filled: true,
                      fillColor: const Color(0xFF1F2E43),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF1A9FFF),
                  radius: 24,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}
