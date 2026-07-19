import 'package:flutter/foundation.dart';
import 'package:prm_project/core/network/websocket_service.dart';
import 'package:prm_project/features/community/data/models/message_model.dart';

import 'package:prm_project/features/auth/providers/auth_provider.dart';
import 'package:prm_project/core/network/dio_client.dart';

class ChatProvider extends ChangeNotifier {
  final WebSocketService _webSocketService;
  final AuthProvider _authProvider;
  final DioClient _dioClient;

  // Lưu tin nhắn cá nhân: receiverUsername -> danh sách tin nhắn
  final Map<String, List<MessageModel>> _privateMessages = {};
  
  // Lưu conversationId cho từng cuộc trò chuyện
  final Map<String, int> _conversationIds = {};
  
  // Lưu danh sách user đang online
  List<String> _onlineUsers = [];

  ChatProvider(this._webSocketService, this._authProvider, this._dioClient) {
    _initializeSubscriptions();
  }

  String get _currentUsername => _authProvider.currentUser?.username ?? '';
  String get _currentUserId => _authProvider.currentUser?.userId ?? '';

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

    final conversationId = _conversationIds[toUsername];

    final data = {
      if (conversationId != null) 'conversationId': conversationId,
      'senderId': _currentUserId,
      'receiverUsername': toUsername,
      'content': content,
    };
    
    _webSocketService.send('/app/chat/private.send', data);

    // Thêm tin nhắn vào danh sách cục bộ ngay lập tức vì server không echo lại cho người gửi
    final myMessage = MessageModel(
      senderName: _currentUsername,
      receiverUsername: toUsername,
      content: content,
      sentAt: DateTime.now(),
      isMine: true,
    );

    if (!_privateMessages.containsKey(toUsername)) {
      _privateMessages[toUsername] = [];
    }
    _privateMessages[toUsername]!.add(myMessage);
    notifyListeners();
  }

  // Giả lập lấy danh sách cuộc trò chuyện gần đây dựa trên _privateMessages map keys
  List<String> getRecentChatUsers() {
    return _privateMessages.keys.toList();
  }

  Future<void> loadChatHistory(int friendId, String friendUsername) async {
    try {
      final response = await _dioClient.get('/user/conversation/$friendId');
      if (response.statusCode == 200) {
        if (response.data['conversationId'] != null) {
          _conversationIds[friendUsername] = response.data['conversationId'] is int 
              ? response.data['conversationId'] 
              : int.tryParse(response.data['conversationId'].toString()) ?? 0;
        }

        final List<dynamic> messagesData = response.data['messages'] ?? [];
        final messages = messagesData.map((e) => MessageModel.fromJson(e, currentUsername: _currentUsername)).toList();
        _privateMessages[friendUsername] = messages;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Lỗi tải lịch sử chat: $e");
    }
  }

  void clearData() {
    _privateMessages.clear();
    _conversationIds.clear();
    _onlineUsers.clear();
    notifyListeners();
  }
}
