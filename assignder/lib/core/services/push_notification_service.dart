import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'notification_service.dart';
import 'firestore_service.dart';

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirestoreService _firestoreService = FirestoreService();

  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<String>? _tokenRefreshSub;
  String? _currentToken;
  String? _currentUserId;
  bool _initialized = false;

  String? get currentToken => _currentToken;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _messaging.setAutoInitEnabled(true);
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint(
      'FCM authorization status: ${settings.authorizationStatus.name}',
    );

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    _currentToken = await _messaging.getToken();
    debugPrint('Initial FCM token available: ${_currentToken != null}');

    _foregroundSub = FirebaseMessaging.onMessage.listen((message) async {
      debugPrint('Received foreground push: ${message.messageId}');
      if (defaultTargetPlatform == TargetPlatform.android) {
        await NotificationService().showRemoteNotification(message);
      }
    });

    _tokenRefreshSub = _messaging.onTokenRefresh.listen((token) async {
      final previousToken = _currentToken;
      _currentToken = token;

      if (_currentUserId == null) return;
      if (previousToken != null && previousToken != token) {
        await _firestoreService.removeUserDeviceToken(
          _currentUserId!,
          previousToken,
        );
      }
      await _firestoreService.addUserDeviceToken(_currentUserId!, token);
    });
  }

  Future<void> attachUser(String userId) async {
    _currentUserId = userId;
    final token = _currentToken ?? await _messaging.getToken();
    _currentToken = token;

    if (token == null || token.isEmpty) {
      debugPrint('FCM token was not available for user $userId yet.');
      return;
    }

    await _firestoreService.addUserDeviceToken(userId, token);
  }

  Future<void> detachUser([String? userId]) async {
    final resolvedUserId = userId ?? _currentUserId;
    final token = _currentToken ?? await _messaging.getToken();
    if (resolvedUserId != null && token != null && token.isNotEmpty) {
      await _firestoreService.removeUserDeviceToken(resolvedUserId, token);
    }
    if (resolvedUserId == _currentUserId) {
      _currentUserId = null;
    }
  }

  Future<void> dispose() async {
    await _foregroundSub?.cancel();
    await _tokenRefreshSub?.cancel();
    _foregroundSub = null;
    _tokenRefreshSub = null;
    _initialized = false;
  }
}
