import 'dart:async';
import 'package:flutter/material.dart';
import 'package:prm_project/features/community/data/models/friend_model.dart';
import 'package:prm_project/features/community/data/models/user_search_model.dart';
import 'package:prm_project/features/community/data/models/friend_invite_model.dart';
import 'package:prm_project/features/community/data/repositories/friend_repository.dart';

import 'package:prm_project/core/network/websocket_service.dart';

class FriendProvider extends ChangeNotifier {
  final FriendRepository _repository;
  final WebSocketService _webSocketService;

  List<FriendModel> _friends = [];
  List<FriendInviteModel> _receivedInvites = [];
  final Set<String> _sentInvites = {};
  UserSearchModel? _searchResult;
  bool _isLoading = false;
  bool _isSearching = false;
  Timer? _debounce;

  FriendProvider(this._repository, this._webSocketService) {
    loadFriends();
  }

  void initializeSubscriptions() {
    _webSocketService.subscribe('/user/queue/friend.invitations', (data) {
      // Khi có invite mới đến hoặc thay đổi (từ chối/chấp nhận), tải lại danh sách
      refreshData();
    });
  }

  Future<void> refreshData() async {
    await loadFriends();
  }

  List<FriendModel> get friends => _friends;
  List<FriendInviteModel> get receivedInvites => _receivedInvites;
  UserSearchModel? get searchResult => _searchResult;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;

  bool isFriend(String userId) {
    return _friends.any((f) => f.friendId.toString() == userId);
  }

  bool hasSentInvite(String userId) {
    return _sentInvites.contains(userId);
  }

  Future<void> loadFriends() async {
    _isLoading = true;
    notifyListeners();

    try {
      _friends = await _repository.getFriends();
      _receivedInvites = await _repository.getReceivedInvites();
    } catch (e) {
      debugPrint("Lỗi khi tải danh sách bạn bè: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchUser(String keyword) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    
    if (keyword.trim().isEmpty) {
      _searchResult = null;
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        _searchResult = await _repository.findUser(keyword.trim());
      } catch (e) {
        _searchResult = null;
      } finally {
        _isSearching = false;
        notifyListeners();
      }
    });
  }

  Future<bool> sendInvite(String friendId) async {
    final success = await _repository.sendInvite(friendId);
    if (success) {
      _sentInvites.add(friendId);
      // Clear search result after sending invite
      _searchResult = null;
      notifyListeners();
    }
    return success;
  }

  Future<void> acceptInvite(String friendId) async {
    final success = await _repository.acceptInvite(friendId);
    if (success) {
      _receivedInvites.removeWhere((inv) => inv.senderId.toString() == friendId);
      loadFriends(); // reload friends after accepting
    }
  }

  Future<void> declineInvite(String friendId) async {
    final success = await _repository.declineInvite(friendId);
    if (success) {
      _receivedInvites.removeWhere((inv) => inv.senderId.toString() == friendId);
      notifyListeners();
    }
  }

  void clearData() {
    _friends.clear();
    _receivedInvites.clear();
    _sentInvites.clear();
    _searchResult = null;
    notifyListeners();
  }
}
