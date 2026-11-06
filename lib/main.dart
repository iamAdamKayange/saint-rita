import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saint_rita/services/not_services.dart';
import 'package:saint_rita/provider/notification_provider.dart';
import 'package:saint_rita/provider/theme_provider.dart';
import 'package:saint_rita/provider/language_provider.dart';
import 'package:saint_rita/provider/prayer_favorites_provider.dart';
import 'package:saint_rita/localization/app_localizations.dart';
import 'package:saint_rita/glassmorphism/glass_app_backdrop.dart';
import 'package:saint_rita/glassmorphism/screens/glass_splash_screen.dart';
import 'package:saint_rita/glassmorphism/screens/glass_onboarding_screen.dart';
import 'package:saint_rita/glassmorphism/screens/glass_sanctuary_screen.dart';
import 'package:saint_rita/glassmorphism/screens/glass_settings_screen.dart';
import 'package:saint_rita/glassmorphism/screens/glass_language_screen.dart';
import 'package:saint_rita/glassmorphism/screens/glass_notification_screen.dart';
import 'package:saint_rita/glassmorphism/screens/glass_history_screen.dart';
import 'package:saint_rita/glassmorphism/screens/glass_favorites_screen.dart';
import 'package:saint_rita/firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final NotServices _notServices = NotServices();

bool get _supportsRemotePush =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // The UI is not running here, so queue the push for the in-app inbox.
  try {
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList(kPendingRemoteNotificationsKey) ?? [];
    queue.add(
      jsonEncode({
        'title': message.notification?.title ?? message.data['title'],
        'body': message.notification?.body ?? message.data['body'],
        'type': message.data['type'] ?? 'general',
        'remoteId': message.messageId,
        'timestamp': (message.sentTime ?? DateTime.now()).toIso8601String(),
      }),
    );
    await prefs.setStringList(kPendingRemoteNotificationsKey, queue);
  } catch (error) {
    debugPrint('Could not queue background push: $error');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (_supportsRemotePush) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    try {
      await FirebaseMessaging.instance.subscribeToTopic('rita_prayer_updates');
    } catch (error) {
      debugPrint('FCM topic subscription will retry next launch: $error');
    }
  }
  await _notServices.initNotification(navigatorKey: navigatorKey);

  // Initialize Mobile Ads with new AdMob Config
  await MobileAds.instance.initialize();

  final prefs = await SharedPreferences.getInstance();
  bool isFirstTimeUser = prefs.getBool('isFirstTimeUser') ?? true;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => PrayerFavoritesProvider()),
      ],
      child: MyApp(isFirstTimeUser: isFirstTimeUser),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool isFirstTimeUser;

  const MyApp({super.key, required this.isFirstTimeUser});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenForFirebaseMessages();
      _checkNotificationLaunch();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    // Pick up pushes that arrived in the background and refresh due reminders.
    final provider = _providerFromNavigator();
    provider?.ready.then((_) => provider.mergePendingRemoteNotifications());
  }

  bool get _isSwahili =>
      Provider.of<LanguageProvider>(
        navigatorKey.currentContext ?? context,
        listen: false,
      ).isSwahili;

  String _remoteTitle(RemoteMessage message) =>
      message.notification?.title ??
      message.data['title']?.toString() ??
      (_isSwahili ? 'Novena ya Mt. Rita' : 'St. Rita Novena');

  String _remoteBody(RemoteMessage message) =>
      message.notification?.body ??
      message.data['body']?.toString() ??
      (_isSwahili ? 'Una ujumbe mpya wa kiroho.' : 'You have a new prayer message.');

  void _listenForFirebaseMessages() {
    if (!_supportsRemotePush) return;
    final provider = _providerFromNavigator();
    if (provider == null) return;
    FirebaseMessaging.onMessage.listen((message) async {
      final title = _remoteTitle(message);
      final body = _remoteBody(message);
      final payload = message.data['type']?.toString() ?? 'general';
      final id = DateTime.now().millisecondsSinceEpoch.remainder(2147483647);
      await provider.ready;

      await _notServices.showInstantNotification(
        title: title,
        body: body,
        payload: payload,
        notificationId: id,
      );
      if (!mounted) return;
      final notificationId = provider.addNotification(
        notificationTypeFromPayload(payload),
        title,
        body,
        '',
        remoteId: message.messageId,
      );
      provider.markAsShown(notificationId);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _openRemoteMessage(message, provider);
    });
  }

  NotificationProvider? _providerFromNavigator() {
    final context = navigatorKey.currentContext;
    if (context == null) return null;
    return Provider.of<NotificationProvider>(context, listen: false);
  }

  Future<void> _openRemoteMessage(
    RemoteMessage message,
    NotificationProvider provider,
  ) async {
    final payload = message.data['type']?.toString() ?? 'general';
    await provider.ready;
    if (!mounted) return;
    await provider.mergePendingRemoteNotifications();
    if (!mounted) return;
    final notificationId = provider.addNotification(
      notificationTypeFromPayload(payload),
      _remoteTitle(message),
      _remoteBody(message),
      '',
      remoteId: message.messageId,
    );
    provider.markAsRead(notificationId);
    _handleNotificationTap(payload);
  }

  Future<void> _checkNotificationLaunch() async {
    if (_supportsRemotePush) {
      final remoteMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (remoteMessage != null) {
        final provider = _providerFromNavigator();
        if (provider == null) return;
        await _openRemoteMessage(remoteMessage, provider);
        return;
      }
    }

    final details = await _notServices.plugin.getNotificationAppLaunchDetails();

    if (details != null && details.didNotificationLaunchApp) {
      final payload = details.notificationResponse?.payload;
      final notificationId = details.notificationResponse?.id;

      final provider = _providerFromNavigator();
      if (provider == null) return;
      await provider.ready;
      if (!mounted) return;

      if (notificationId != null) {
        provider.markAsShown(notificationId);
        provider.markAsRead(notificationId);
      }
      if (payload != null) {
        _handleNotificationTap(payload);
      }
    }
  }

  void _handleNotificationTap(String payload) {
    int index = 0;

    switch (payload) {
      case "daily":
        index = 1;
        break;
      case "hourly":
        index = 2;
        break;
      case "general":
      default:
        index = 0;
    }

    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => GlassNotificationScreen(initialIndex: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    Widget initialScreen;
    if (widget.isFirstTimeUser) {
      initialScreen = const GlassSplashScreen();
    } else {
      initialScreen = const GlassSanctuaryScreen();
    }

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Rita Wa Kashia',
      theme: themeProvider.themeData,
      locale: languageProvider.currentLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('sw')],
      builder: (context, child) => Stack(
        fit: StackFit.expand,
        children: [const GlassAppBackdrop(), if (child != null) child],
      ),
      home: initialScreen,
      routes: {
        '/onboarding': (context) => const GlassOnboardingScreen(),
        '/sanctuary': (context) => const GlassSanctuaryScreen(),
        '/settings': (context) => const GlassSettingsScreen(),
        '/language': (context) => const GlassLanguageScreen(),
        '/notifications': (context) => const GlassNotificationScreen(),
        '/history': (context) => const GlassHistoryScreen(),
        '/favorites': (context) => const GlassFavoritesScreen(),
      },
    );
  }
}
