import 'dart:async';

import 'package:Metre/notifications/model_notification.dart';
import 'package:Metre/notifications/service.dart';
import 'package:flutter/material.dart';

class NotificationManager with ChangeNotifier {
  List<MessageNotif> _notifications = [];
  bool _isLoading = false;

  List<MessageNotif> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await Notiservice.fetchUserNotifications(userId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    await Notiservice.markNotificationAsRead(notificationId);
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  // Pour le polling
  Timer? _pollingTimer;
  void startPolling(String userId) {
    _pollingTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      loadNotifications(userId);
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
  }
}

extension on MessageNotif {
  MessageNotif copyWith({bool? isRead}) {
    return MessageNotif(
      id: id,
      message: message,
      dateCreation: dateCreation,
      isRead: isRead ?? this.isRead,
      userId: userId,
      commandId: commandId,
    );
  }
}
