import 'package:flutter/material.dart';
import 'package:saint_rita/glassmorphism/screens/glass_notification_screen.dart';

/// Keeps existing notification entry points on the current Glass UI.
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key, required this.initialIndex});

  final int initialIndex;

  @override
  Widget build(BuildContext context) =>
      GlassNotificationScreen(initialIndex: initialIndex);
}
