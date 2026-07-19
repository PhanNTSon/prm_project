import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_project/features/community/providers/chat_provider.dart';
import 'package:prm_project/core/network/websocket_service.dart';
import 'package:prm_project/features/auth/providers/auth_provider.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Chat', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF171D25),
        elevation: 0,
      ),
      body: Consumer2<ChatProvider, WebSocketService>(
        builder: (context, chatProvider, webSocketService, child) {
          final onlineUsers = chatProvider.onlineUsers;
          final recentUsers = chatProvider.getRecentChatUsers();

          return CustomScrollView(
            slivers: [
              if (webSocketService.hasConnectionError)
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.red.shade900,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const Text(
                          'Mất kết nối với máy chủ (Socket Timeout).',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            final token = context.read<AuthProvider>().token;
                            if (token != null) {
                              webSocketService.connect(token);
                            }
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Thử kết nối lại'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (onlineUsers.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'ONLINE NOW',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: onlineUsers.length,
                      itemBuilder: (context, index) {
                        final username = onlineUsers[index];
                        return GestureDetector(
                          onTap: () => context.push('/chat/detail/$username'),
                          child: Container(
                            width: 72,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: const Color(0xFF2A3F5A),
                                      child: Text(
                                        username.substring(0, 1).toUpperCase(),
                                        style: const TextStyle(color: Colors.white, fontSize: 20),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: const Color(0xFF1B2838), width: 2),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  username,
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],

              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    'RECENT CHATS',
                    style: TextStyle(
                      color: Colors.white54,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              
              if (recentUsers.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'No recent chats. Tap on an online user to start chatting!',
                        style: TextStyle(color: Colors.white38),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final username = recentUsers[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF2A3F5A),
                          child: Text(
                            username.substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(username, style: const TextStyle(color: Colors.white)),
                        subtitle: const Text('Tap to open chat', style: TextStyle(color: Colors.white54)),
                        onTap: () => context.push('/chat/detail/$username'),
                      );
                    },
                    childCount: recentUsers.length,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
