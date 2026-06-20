import 'package:flutter/foundation.dart';

class NotificationProvider extends ChangeNotifier {
  int _unreadCount = 0;
  final List<String> _notifications = [];

  int get unreadCount => _unreadCount;
  List<String> get notifications => List.unmodifiable(_notifications);

  void updateUnreadCount(int count) {
    if (_unreadCount != count) {
      _unreadCount = count;
      notifyListeners();
    }
  }

  void addNotification(String message) {
    _notifications.insert(0, message);
    _unreadCount++;
    notifyListeners();
  }

  void markAllAsRead() {
    _unreadCount = 0;
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    _unreadCount = 0;
    notifyListeners();
  }
}
