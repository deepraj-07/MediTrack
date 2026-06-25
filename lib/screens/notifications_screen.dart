import 'package:flutter/material.dart';
import 'package:meditrack/l10n/app_localizations.dart';
import 'package:meditrack/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> notifications;
  final void Function(String) onMarkRead;
  final VoidCallback onMarkAllRead;

  const NotificationsScreen({
    super.key,
    required this.notifications,
    required this.onMarkRead,
    required this.onMarkAllRead,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final unreadCount = notifications.where((n) => n['isRead'] == false).length;

    return Column(
      children: [
        // Header with count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.notifications_rounded, color: Color(0xFF7F56D9), size: 24),
                  const SizedBox(width: 10),
                  Text(
                    AppLocalizations.of(context)!.newNotifications('$unreadCount'),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: c.secondaryText,
                    ),
                  ),
                ],
              ),
              if (unreadCount > 0)
                InkWell(
                  onTap: onMarkAllRead,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      AppLocalizations.of(context)!.markAllRead,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF7F56D9),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Divider(height: 1, color: c.border),
        // List
        Expanded(
          child: notifications.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.notifications_off_rounded, size: 48, color: c.divider),
                        const SizedBox(height: 12),
                        Text(
                          AppLocalizations.of(context)!.noNotifications,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: c.tertiaryText,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: notifications.length,
                    separatorBuilder: (_, _) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(height: 1, color: c.border),
                    ),
                    itemBuilder: (context, index) {
                      final notif = notifications[index];
                      final isRead = notif['isRead'] == true;
                      return _NotificationTile(
                        icon: notif['icon'] as IconData,
                        iconColor: notif['iconColor'] as Color,
                        title: notif['title'] as String,
                        body: notif['body'] as String,
                        time: notif['time'] as String,
                        isRead: isRead,
                        onTap: () => onMarkRead(notif['id'] as String),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
        ],
      );
  }
}

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String time;
  final bool isRead;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unread dot or icon
            if (!isRead)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 4, right: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF7F56D9),
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(width: 22),
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                      color: c.primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: c.secondaryText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: c.tertiaryText,
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
