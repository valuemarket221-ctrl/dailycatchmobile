import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:myapp/services/support_api_service.dart';
import 'package:myapp/utils/environment.dart';

class PushTokenRegistrationService {
  PushTokenRegistrationService({
    FirebaseMessaging? messaging,
    SupportApiService? supportApiService,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _supportApiService = supportApiService ?? SupportApiService();

  final FirebaseMessaging _messaging;
  final SupportApiService _supportApiService;

  static StreamSubscription<String>? _tokenRefreshSubscription;
  static StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;

  Future<void> registerDeviceToken() async {
    try {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return;
      }

      final token = await _messaging.getToken(
        vapidKey:
            kIsWeb && Environment.firebaseWebVapidKey.isNotEmpty
                ? Environment.firebaseWebVapidKey
                : null,
      );

      if (token == null || token.isEmpty) {
        return;
      }

      await _registerToken(token);
      _listenForTokenRefresh();
      _listenForForegroundMessages();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Push registration skipped: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }

  Future<void> _registerToken(String token) async {
    await _supportApiService.registerPushToken(
      platform: _platformName,
      token: token,
    );
  }

  void _listenForTokenRefresh() {
    _tokenRefreshSubscription ??= _messaging.onTokenRefresh.listen((newToken) {
      _registerToken(newToken).ignore();
    });
  }

  void _listenForForegroundMessages() {
    _foregroundMessageSubscription ??= FirebaseMessaging.onMessage.listen((
      message,
    ) {
      if (kDebugMode) {
        debugPrint(
          'Push foreground message: ${message.notification?.title ?? message.messageId ?? 'notification'}',
        );
      }
    });
  }

  String get _platformName {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      default:
        return 'web';
    }
  }
}
