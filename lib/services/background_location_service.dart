import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

// ─── Notification constants ──────────────────────────────────────────────────
const int _kNotificationId = 888;
const String _kChannelId = 'location_tracking_channel';
const String _kChannelName = 'Location Tracking';

// ─── SharedPreferences keys ──────────────────────────────────────────────────
const String _kIsWorkingKey = 'bg_is_working';
const String _kTokenKey = 'user_token';

/// Call this once in main() before runApp().
Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  // Android foreground notification channel
  if (Platform.isAndroid) {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _kChannelId,
      _kChannelName,
      description: 'Used to show location tracking status',
      importance: Importance.low,
    );
    final FlutterLocalNotificationsPlugin plugin =
        FlutterLocalNotificationsPlugin();
    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onBackgroundServiceStart,
      autoStart: false, // ✅ We start it manually when work begins
      isForegroundMode: true,
      notificationChannelId: _kChannelId,
      initialNotificationTitle: 'Location Tracking',
      initialNotificationContent: 'Uploading your location…',
      foregroundServiceNotificationId: _kNotificationId,
      foregroundServiceTypes: [AndroidForegroundType.location],
    ),
    iosConfiguration: IosConfiguration(
      // iOS: we don't use background service, just foreground timer
      autoStart: false,
      onForeground: onBackgroundServiceStart,
    ),
  );
}

/// Top-level entry point for the background isolate.
/// IMPORTANT: must be a top-level function (not a method).
@pragma('vm:entry-point')
void onBackgroundServiceStart(ServiceInstance service) async {
  // Background isolate doesn't share memory with the UI isolate.
  // We use SharedPreferences and HTTP directly.

  log('🚀 Background service started', name: 'bg_location');

  final battery = Battery();
  final dio = _buildDio();

  // Update notification helper (Android only)
  void updateNotification(String content) {
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: 'Location Tracking Active',
        content: content,
      );
    }
  }

  // ── Listen for commands from the UI isolate ─────────────────────────────
  service.on('stopTracking').listen((_) async {
    log('⛔ Received stopTracking command.', name: 'bg_location');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsWorkingKey, false);
    await service.stopSelf();
  });

  // ── Immediately send one location update, then repeat every 60 s ────────
  Future<void> sendLocationUpdate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isWorking = prefs.getBool(_kIsWorkingKey) ?? false;

      if (!isWorking) {
        log('ℹ️ isWorking=false — stopping service.', name: 'bg_location');
        await service.stopSelf();
        return;
      }

      final token = prefs.getString(_kTokenKey);
      if (token == null || token.isEmpty) {
        log('⚠️ No auth token found. Skipping location update.', name: 'bg_location');
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final batteryLevel = await battery.batteryLevel;
      final location = '${position.latitude},${position.longitude}';

      log(
        '📍 Uploading location: $location | battery=$batteryLevel% | accuracy=${position.accuracy}m',
        name: 'bg_location',
      );

      updateNotification(
        'lat: ${position.latitude.toStringAsFixed(4)}, lng: ${position.longitude.toStringAsFixed(4)}',
      );

      // POST to server
      final response = await dio.post(
        '${ApiRoutes.baseUri}${ApiRoutes.locationEndpoint}',
        data: {
          'location': location,
          'accuracy': position.accuracy,
          'battery_percentage': batteryLevel,
          'speed': position.speed,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      log('✅ Location uploaded. Status: ${response.statusCode}', name: 'bg_location');
    } catch (e) {
      log('❌ Error in background location update: $e', name: 'bg_location');
    }
  }

  // Send immediately on start
  await sendLocationUpdate();

  // Then repeat every 60 seconds
  Timer.periodic(const Duration(minutes: 1), (_) async {
    await sendLocationUpdate();
  });
}

/// Mark the employee as working and start the background service.
Future<void> startBackgroundTracking(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kIsWorkingKey, true);
  await prefs.setString(_kTokenKey, token);

  final service = FlutterBackgroundService();
  final isRunning = await service.isRunning();
  if (!isRunning) {
    await service.startService();
    log('▶️ Background tracking service started.', name: 'bg_location');
  } else {
    log('ℹ️ Background tracking service already running.', name: 'bg_location');
  }
}

/// Mark the employee as not working and stop the background service.
Future<void> stopBackgroundTracking() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kIsWorkingKey, false);

  final service = FlutterBackgroundService();
  final isRunning = await service.isRunning();
  if (isRunning) {
    service.invoke('stopTracking');
    log('⏹️ Background tracking service stopped.', name: 'bg_location');
  }
}

/// Returns true if the background service is currently running.
Future<bool> isBackgroundTrackingRunning() async {
  return FlutterBackgroundService().isRunning();
}

// ── Internal helpers ──────────────────────────────────────────────────────────

Dio _buildDio() {
  final dio = Dio();
  dio.options.connectTimeout = const Duration(seconds: 15);
  dio.options.receiveTimeout = const Duration(seconds: 15);
  dio.options.headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    final client = HttpClient();
    // Bypass SSL for dev API
    if (ApiRoutes.baseUri.contains('dev-api') ||
        ApiRoutes.baseUri.contains('192.168')) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      client.findProxy = (uri) => 'DIRECT';
    }
    return client;
  };
  return dio;
}
