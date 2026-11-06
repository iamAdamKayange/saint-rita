import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saint_rita/glassmorphism/glass_design_system.dart';
import 'package:saint_rita/provider/language_provider.dart';
import 'package:saint_rita/provider/notification_provider.dart';

class GlassNotificationScreen extends StatelessWidget {
  const GlassNotificationScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? Colors.white : GlassDesignSystem.deepForestGreen;
    final sw = context.watch<LanguageProvider>().isSwahili;
    final tabs = [
      _NotificationTab(type: NotificationType.general, title: sw ? 'Jumla' : 'General'),
      _NotificationTab(type: NotificationType.daily, title: sw ? 'Siku' : 'Daily'),
      _NotificationTab(type: NotificationType.hourly, title: sw ? 'Saa' : 'Hourly'),
    ];

    return DefaultTabController(
      length: tabs.length,
      initialIndex: initialIndex.clamp(0, tabs.length - 1).toInt(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            const _NotificationBackdrop(),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 7, 18, 8),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'Back',
                          onPressed: () => Navigator.maybePop(context),
                          icon: Icon(Icons.arrow_back_rounded, color: text),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(sw ? 'TAARIFA' : 'NOTIFICATIONS', style: TextStyle(color: text.withValues(alpha: .5), fontSize: 10, letterSpacing: 1.7, fontWeight: FontWeight.w700)),
                              Text(sw ? 'Kumbusho zako' : 'Your reminders', style: TextStyle(color: text, fontSize: 21, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                        Consumer<NotificationProvider>(
                          builder: (_, provider, __) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _UnreadCount(count: provider.totalUnread, sw: sw),
                              if (provider.totalUnread > 0)
                                IconButton(
                                  tooltip: sw ? 'Weka zote zimesomwa' : 'Mark all as read',
                                  onPressed: provider.markAllAsRead,
                                  icon: Icon(Icons.done_all_rounded, color: text),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: dark ? .08 : .58),
                            border: Border.all(color: Colors.white.withValues(alpha: .7)),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: TabBar(
                            labelColor: Colors.white,
                            unselectedLabelColor: text.withValues(alpha: .66),
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: const LinearGradient(colors: [Color(0xFF2A91B8), Color(0xFF32C1CC)]),
                            ),
                            dividerColor: Colors.transparent,
                            tabs: tabs.map((tab) => Tab(text: tab.title)).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: tabs.map((tab) => _NotificationList(type: tab.type, sw: sw)).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTab {
  const _NotificationTab({required this.type, required this.title});
  final NotificationType type;
  final String title;
}

class _UnreadCount extends StatelessWidget {
  const _UnreadCount({required this.count, required this.sw});
  final int count;
  final bool sw;

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: GlassDesignSystem.emerald.withValues(alpha: .15), borderRadius: BorderRadius.circular(30)),
      child: Text('$count ${sw ? 'hazijasomwa' : 'unread'}', style: const TextStyle(color: GlassDesignSystem.deepForestGreen, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class _NotificationList extends StatelessWidget {
  const _NotificationList({required this.type, required this.sw});
  final NotificationType type;
  final bool sw;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        final notifications = provider.notifications.where((item) => item.type == type).toList();
        if (notifications.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(35),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: .56), shape: BoxShape.circle, border: Border.all(color: Colors.white)),
                    child: Icon(Icons.notifications_none_rounded, size: 34, color: GlassDesignSystem.emerald.withValues(alpha: .8)),
                  ),
                  const SizedBox(height: 16),
                  Text(sw ? 'Hakuna taarifa mpya' : 'All caught up', style: TextStyle(color: dark ? Colors.white : GlassDesignSystem.deepForestGreen, fontWeight: FontWeight.w700, fontSize: 17)),
                  const SizedBox(height: 6),
                  Text(sw ? 'Kumbusho na taarifa za sala zitaonekana hapa.' : 'Reminders and prayer updates will appear here.', textAlign: TextAlign.center, style: TextStyle(color: dark ? Colors.white60 : GlassDesignSystem.subtleBrown.withValues(alpha: .7), height: 1.45)),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(18, 17, 18, 28),
          itemCount: notifications.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = notifications[index];
            return Dismissible(
              key: ValueKey(item.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 22),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: .18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              ),
              onDismissed: (_) {
                provider.removeNotification(item.id);
                ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                  SnackBar(content: Text(sw ? 'Taarifa imeondolewa' : 'Notification removed')),
                );
              },
              child: _NotificationCard(notification: item),
            );
          },
        );
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});
  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? Colors.white : GlassDesignSystem.deepForestGreen;
    final accent = switch (notification.type) {
      NotificationType.general => GlassDesignSystem.divineBlue,
      NotificationType.daily => GlassDesignSystem.softGold,
      NotificationType.hourly => GlassDesignSystem.emerald,
    };
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Material(
          color: (dark ? const Color(0xFF18344B) : Colors.white).withValues(alpha: .68),
          child: InkWell(
            onTap: () => _showNotification(context),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(border: Border.all(color: Colors.white.withValues(alpha: .73)), borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 52,
                      height: 58,
                      child: notification.imagePath.isNotEmpty
                          ? Image.asset(notification.imagePath, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _IconTile(color: accent))
                          : _IconTile(color: accent),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(notification.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: text, fontWeight: FontWeight.w700, fontSize: 14))),
                            if (!notification.isRead) Container(width: 7, height: 7, decoration: BoxDecoration(color: GlassDesignSystem.emerald, shape: BoxShape.circle)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(notification.message, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: text.withValues(alpha: .65), height: 1.35, fontSize: 12)),
                        const SizedBox(height: 6),
                        Text(_formatTime(notification.timestamp), style: TextStyle(color: text.withValues(alpha: .45), fontSize: 10, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right_rounded, color: text.withValues(alpha: .43)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showNotification(BuildContext context) async {
    final provider = context.read<NotificationProvider>();
    provider.markAsRead(notification.id);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _NotificationDetail(notification: notification),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (time.year == now.year && time.month == now.month && time.day == now.day) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    return '${time.day}/${time.month}/${time.year}';
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => ColoredBox(
        color: color.withValues(alpha: .15),
        child: Icon(Icons.volunteer_activism_rounded, color: color, size: 23),
      );
}

class _NotificationDetail extends StatelessWidget {
  const _NotificationDetail({required this.notification});
  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? Colors.white : GlassDesignSystem.deepForestGreen;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
          decoration: BoxDecoration(color: dark ? const Color(0xFF153049) : const Color(0xFFF4FAFD), borderRadius: const BorderRadius.vertical(top: Radius.circular(28)), border: Border.all(color: Colors.white.withValues(alpha: .75))),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 38, height: 38, decoration: BoxDecoration(color: GlassDesignSystem.emerald.withValues(alpha: .15), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.notifications_active_outlined, color: GlassDesignSystem.emerald)),
                const SizedBox(height: 16),
                Text(notification.title, style: TextStyle(color: text, fontWeight: FontWeight.w700, fontSize: 19)),
                const SizedBox(height: 9),
                Text(notification.message, style: TextStyle(color: text.withValues(alpha: .75), height: 1.55)),
                const SizedBox(height: 12),
                Text('${notification.timestamp.day}/${notification.timestamp.month}/${notification.timestamp.year}', style: TextStyle(color: text.withValues(alpha: .48), fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationBackdrop extends StatelessWidget {
  const _NotificationBackdrop();
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: dark ? const [Color(0xFF102940), Color(0xFF0B1D30)] : const [Color(0xFFEAF6FC), Color(0xFFF5FAFD)])),
        child: Stack(children: [Positioned(top: -80, right: -60, child: Container(width: 220, height: 220, decoration: BoxDecoration(color: GlassDesignSystem.emerald.withValues(alpha: .11), shape: BoxShape.circle))), Positioned(bottom: 20, left: -130, child: Container(width: 250, height: 250, decoration: BoxDecoration(color: GlassDesignSystem.divineBlue.withValues(alpha: .09), shape: BoxShape.circle)))]),
      ),
    );
  }
}
