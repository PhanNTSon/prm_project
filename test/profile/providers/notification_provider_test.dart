import 'package:flutter_test/flutter_test.dart';
import 'package:prm_project/features/profile/providers/notification_provider.dart';

void main() {
  group('NotificationProvider Tests', () {
    late NotificationProvider notificationProvider;

    setUp(() {
      notificationProvider = NotificationProvider();
    });

    test('Initial state should be empty', () {
      expect(notificationProvider.unreadCount, 0);
      expect(notificationProvider.notifications.isEmpty, true);
    });

    test('updateUnreadCount should set correct count', () {
      notificationProvider.updateUnreadCount(5);
      expect(notificationProvider.unreadCount, 5);
    });

    test('addNotification should increase unread count and add to list', () {
      notificationProvider.addNotification('Test Notification 1');
      expect(notificationProvider.unreadCount, 1);
      expect(notificationProvider.notifications.length, 1);
      expect(notificationProvider.notifications.first, 'Test Notification 1');
      
      notificationProvider.addNotification('Test Notification 2');
      expect(notificationProvider.unreadCount, 2);
      expect(notificationProvider.notifications.first, 'Test Notification 2'); // Adds to top
    });

    test('markAllAsRead should reset unread count to 0', () {
      notificationProvider.updateUnreadCount(10);
      notificationProvider.markAllAsRead();
      expect(notificationProvider.unreadCount, 0);
    });

    test('clearNotifications should clear list and reset count', () {
      notificationProvider.addNotification('Test');
      notificationProvider.clearNotifications();
      expect(notificationProvider.unreadCount, 0);
      expect(notificationProvider.notifications.isEmpty, true);
    });
  });
}
