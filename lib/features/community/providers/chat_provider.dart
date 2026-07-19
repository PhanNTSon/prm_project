import 'package:flutter/foundation.dart';
import 'package:prm_project/core/network/websocket_service.dart';
import 'package:prm_project/features/community/data/models/message_model.dart';

import 'package:prm_project/features/auth/providers/auth_provider.dart';

class ChatProvider extends ChangeNotifier {
  final WebSocketService _webSocketService;
  final AuthProvider _authProvider;

  // Lưu tin nhắn cá nhân: receiverUsername -> danh sách tin nhắn
  final Map<String, List<MessageModel>> _privateMessages = {};
  
  // Lưu danh sách user đang online
  List<String> _onlineUsers = [];

  ChatProvider(this._webSocketService, this._authProvider) {
    _initializeSubscriptions();
  }

  String get _currentUsername => _authProvider.currentUser?.username ?? '';

  List<String> get onlineUsers => _onlineUsers;

  List<MessageModel> getMessagesForUser(String username) {
    return _privateMessages[username] ?? [];
  }

  void _initializeSubscriptions() {
    // Đăng ký nhận danh sách user online
    _webSocketService.subscribe('/app/online', (data) {
      if (data is List) {
        _onlineUsers = data.map((e) => e.toString()).toList();
        // Xóa chính mình khỏi danh sách hiển thị (nếu cần)
        _onlineUsers.remove(_currentUsername);
        notifyListeners();
      }
    });

    // Đăng ký nhận tin nhắn cá nhân đến/đi
    _webSocketService.subscribe('/user/queue/messages/$_currentUsername', (data) {
      final message = MessageModel.fromJson(data, currentUsername: _currentUsername);
      
      // Xác định luồng hội thoại thuộc về user nào
      // Nếu mình gửi, luồng đó là receiver. Nếu người khác gửi cho mình, luồng đó là sender.
      final conversationPartner = message.isMine ? message.receiverUsername : message.senderName;
      
      if (conversationPartner != null) {
        if (!_privateMessages.containsKey(conversationPartner)) {
          _privateMessages[conversationPartner] = [];
        }
        _privateMessages[conversationPartner]!.add(message);
        notifyListeners();
      }
    });
  }

  void sendPrivateMessage(String toUsername, String content) {
    if (content.trim().isEmpty) return;

    final data = {
      'receiverUsername': toUsername,
      'content': content,
    };
    
    _webSocketService.send('/app/chat/private.send', data);
  }

  // Giả lập lấy danh sách cuộc trò chuyện gần đây dựa trên _privateMessages map keys
  List<String> getRecentChatUsers() {
    return _privateMessages.keys.toList();
  }
}
