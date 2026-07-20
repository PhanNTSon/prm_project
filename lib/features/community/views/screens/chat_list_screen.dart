import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_project/features/community/providers/chat_provider.dart';
import 'package:prm_project/features/community/providers/friend_provider.dart';
import 'package:prm_project/core/network/websocket_service.dart';
import 'package:prm_project/features/auth/providers/auth_provider.dart';
import 'package:prm_project/core/theme/app_colors.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSendInvite(BuildContext context, String friendId) async {
    final success = await context.read<FriendProvider>().sendInvite(friendId);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi lời mời kết bạn!'), backgroundColor: Colors.green),
      );
      _searchController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi gửi lời mời (hoặc đã gửi rồi).'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final webSocketService = context.watch<WebSocketService>();
    final friendProvider = context.watch<FriendProvider>();
    final chatProvider = context.watch<ChatProvider>();
    final currentUser = context.read<AuthProvider>().currentUser;

    final onlineUsers = chatProvider.onlineUsers;
    final friends = friendProvider.friends;

    final onlineFriends = friends.where((f) => onlineUsers.contains(f.friendName)).toList();
    final offlineFriends = friends.where((f) => !onlineUsers.contains(f.friendName)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF171D25),
      appBar: AppBar(
        title: const Text('Community & Friends', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF171D25),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<FriendProvider>().refreshData(),
        child: CustomScrollView(
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
                        fixedSize: const Size(200, 40),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // BOX TRÊN: KHU VỰC KẾT BẠN
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2838),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF2A3F5A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thêm bạn bè',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Mã kết bạn của bạn', style: TextStyle(color: Colors.white54, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(
                              currentUser?.userId ?? 'Unknown',
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (currentUser?.userId != null) {
                              Clipboard.setData(ClipboardData(text: currentUser!.userId));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đã sao chép mã kết bạn!')),
                              );
                            }
                          },
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('Sao chép'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            fixedSize: const Size(120, 40),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('Nhập mã để tìm bạn bè', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Nhập mã kết bạn',
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: const Color(0xFF2A3F5A),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        suffixIcon: friendProvider.isSearching
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 16, height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : null,
                      ),
                      onChanged: (val) {
                        context.read<FriendProvider>().searchUser(val);
                      },
                    ),
                    
                    if (friendProvider.searchResult != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF171D25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFF2A3F5A),
                              backgroundImage: friendProvider.searchResult!.avatarUrl != null 
                                  ? NetworkImage(friendProvider.searchResult!.avatarUrl!)
                                  : null,
                              child: friendProvider.searchResult!.avatarUrl == null
                                  ? Text(friendProvider.searchResult!.username.substring(0, 1).toUpperCase())
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                friendProvider.searchResult!.username,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (friendProvider.isFriend(friendProvider.searchResult!.userId.toString()))
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text('Đã là bạn bè', style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic)),
                              )
                            else if (friendProvider.hasSentInvite(friendProvider.searchResult!.userId.toString()))
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text('Đã gửi lời mời', style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic)),
                              )
                            else
                              ElevatedButton(
                                onPressed: () => _handleSendInvite(context, friendProvider.searchResult!.userId.toString()),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  fixedSize: const Size(140, 40),
                                ),
                                child: const Text('Gửi kết bạn', style: TextStyle(color: Colors.white)),
                              )
                          ],
                        ),
                      ),
                    ] else if (_searchController.text.isNotEmpty && !friendProvider.isSearching) ...[
                       const SizedBox(height: 16),
                       const Text('Không tìm thấy người dùng nào.', style: TextStyle(color: Colors.white38)),
                    ]
                  ],
                ),
              ),
            ),
          ),
          
          // LỜI MỜI KẾT BẠN
          if (friendProvider.receivedInvites.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'LỜI MỜI KẾT BẠN',
                  style: TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final invite = friendProvider.receivedInvites[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B2838),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFF2A3F5A),
                            backgroundImage: invite.senderAvatar != null ? NetworkImage(invite.senderAvatar!) : null,
                            child: invite.senderAvatar == null ? Text(invite.senderName.substring(0, 1).toUpperCase()) : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              invite.senderName,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => context.read<FriendProvider>().acceptInvite(invite.senderId.toString()),
                                icon: const Icon(Icons.check, color: Colors.green),
                                tooltip: 'Chấp nhận',
                              ),
                              IconButton(
                                onPressed: () => context.read<FriendProvider>().declineInvite(invite.senderId.toString()),
                                icon: const Icon(Icons.close, color: Colors.red),
                                tooltip: 'Từ chối',
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
                childCount: friendProvider.receivedInvites.length,
              ),
            ),
          ],
          
          // BOX DƯỚI: DANH SÁCH BẠN BÈ
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'DANH SÁCH BẠN BÈ',
                style: TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          
          if (friendProvider.isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (friends.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Text(
                    'Bạn chưa có người bạn nào. Hãy thêm bạn bè để trò chuyện!',
                    style: TextStyle(color: Colors.white38),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          else ...[
            if (onlineFriends.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text('ONLINE', style: TextStyle(color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final friend = onlineFriends[index];
                    return ListTile(
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFF2A3F5A),
                            backgroundImage: friend.friendAvatarUrl != null ? NetworkImage(friend.friendAvatarUrl!) : null,
                            child: friend.friendAvatarUrl == null ? Text(friend.friendName.substring(0, 1).toUpperCase()) : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF171D25), width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      title: Text(friend.friendName, style: const TextStyle(color: Colors.white)),
                      onTap: () => context.push('/chat/detail/${friend.friendId}/${friend.friendName}'),
                    );
                  },
                  childCount: onlineFriends.length,
                ),
              ),
            ],
            
            if (offlineFriends.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text('OFFLINE', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final friend = offlineFriends[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF2A3F5A),
                        backgroundImage: friend.friendAvatarUrl != null ? NetworkImage(friend.friendAvatarUrl!) : null,
                        child: friend.friendAvatarUrl == null ? Text(friend.friendName.substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white54)) : null,
                      ),
                      title: Text(friend.friendName, style: const TextStyle(color: Colors.white54)),
                      onTap: () => context.push('/chat/detail/${friend.friendId}/${friend.friendName}'),
                    );
                  },
                  childCount: offlineFriends.length,
                ),
              ),
            ],
          ],
          
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
        ),
      ),
    );
  }
}
