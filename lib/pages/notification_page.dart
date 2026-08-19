import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/services/notification_api_service.dart';
import 'package:myapp/widgets/bottom_nav_bar.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationApiService _notificationApiService =
      NotificationApiService();
  var _isLoading = true;
  String? _loadError;
  List<_NotificationListItem> _items = const [
    _NotificationListItem(
      title: 'Votre commande à Poissonnerie Yoff',
      body: 'est prête à être récupérée.',
      timeLabel: 'Il y a 5 min',
    ),
    _NotificationListItem(
      title: 'Nouvelle offre près de chez vous',
      body: 'Poissonnerie Yoff propose un panier à prix réduit !',
      timeLabel: 'Il y a 2 h',
    ),
    _NotificationListItem(
      title: 'Votre avis compte !',
      body: 'Donnez votre avis sur votre dernière commande.',
      timeLabel: 'Hier',
    ),
    _NotificationListItem(
      title: 'Mise à jour des CGU',
      body: 'Nos conditions d’utilisation ont été mises à jour.',
      timeLabel: '2 mai',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final notifications = await _notificationApiService.getMyNotifications();
      if (!mounted) return;

      setState(() {
        _items = notifications.map(_NotificationListItem.fromBackend).toList();
        _isLoading = false;
      });
    } on NotificationApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'notifications_unavailable';
        _isLoading = false;
      });
    }
  }

  Future<void> _openNotification(_NotificationListItem item) async {
    if (item.id != null && !item.isRead) {
      setState(() {
        _items = [
          for (final notification in _items)
            notification.id == item.id
                ? notification.copyWith(isRead: true)
                : notification,
        ];
      });
      try {
        await _notificationApiService.markAsRead(item.id!);
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _items = [
            for (final notification in _items)
              notification.id == item.id
                  ? notification.copyWith(isRead: item.isRead)
                  : notification,
          ];
        });
      }
    }

    if (!mounted) return;
    context.push(
      '/notification-detail',
      extra: {
        'title': item.title,
        'body': item.body,
        'orderId': item.orderId,
      },
    );
  }

  Future<void> _markAllAsRead() async {
    final previousItems = _items;
    setState(() {
      _items = [
        for (final notification in _items)
          notification.copyWith(isRead: true),
      ];
    });

    try {
      await _notificationApiService.markAllAsRead();
    } catch (_) {
      if (!mounted) return;
      setState(() => _items = previousItems);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lecture des notifications impossible.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = _items.any((item) => !item.isRead);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            children: [
              Row(
                children: [
                  if (context.canPop())
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.blueBic,
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                  const Spacer(),
                  Text('NOTIFICATIONS', style: _title),
                  const Spacer(),
                  SizedBox(
                    width: 48,
                    child:
                        hasUnread
                            ? IconButton(
                              tooltip: 'Tout marquer comme lu',
                              onPressed: _markAllAsRead,
                              icon: const Icon(
                                Icons.done_all,
                                color: AppColors.blueBic,
                              ),
                            )
                            : null,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child:
                    _isLoading
                        ? const _NotificationLoading(key: ValueKey('loading'))
                        : _loadError == null
                        ? const SizedBox.shrink(key: ValueKey('ready'))
                        : _NotificationNotice(
                          key: const ValueKey('notice'),
                          onRetry: _loadNotifications,
                        ),
              ),
              SizedBox(height: _loadError == null ? 12 : 18),
              Expanded(
                child:
                    _items.isEmpty
                        ? const _NotificationEmpty()
                        : RefreshIndicator(
                          color: AppColors.blueBic,
                          onRefresh: _loadNotifications,
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _items.length,
                            separatorBuilder:
                                (_, __) => const Divider(
                                  height: 24,
                                  thickness: 1,
                                  color: Color(0xFFE6ECEC),
                                ),
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              return _NotificationTile(
                                item: item,
                                onTap: () => _openNotification(item),
                              );
                            },
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item, required this.onTap});

  final _NotificationListItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 35,
              height: 35,
              alignment: Alignment.center,
              child: Icon(
                item.icon,
                size: 27,
                color:
                    item.isRead ? const Color(0xFF718487) : AppColors.blueBic,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: RichText(
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(text: item.title, style: _bodyTitle),
                    TextSpan(text: '\n${item.body}', style: _body),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(item.timeLabel, style: _time),
                  if (!item.isRead) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.blueBic,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationLoading extends StatelessWidget {
  const _NotificationLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 3,
      child: LinearProgressIndicator(
        minHeight: 3,
        color: AppColors.blueBic,
        backgroundColor: Color(0xFFE9F2F0),
      ),
    );
  }
}

class _NotificationNotice extends StatelessWidget {
  const _NotificationNotice({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FAF9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1ECEA)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 18,
            color: AppColors.blueBic,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Notifications hors ligne pour le moment.', style: _body),
          ),
          TextButton(onPressed: onRetry, child: Text('Réessayer', style: _link)),
        ],
      ),
    );
  }
}

class _NotificationEmpty extends StatelessWidget {
  const _NotificationEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.notifications_none_outlined,
            size: 48,
            color: Color(0xFF8AA0A3),
          ),
          const SizedBox(height: 12),
          Text('Aucune notification', style: _bodyTitle),
          const SizedBox(height: 6),
          Text(
            'Les alertes importantes apparaîtront ici.',
            textAlign: TextAlign.center,
            style: _body,
          ),
        ],
      ),
    );
  }
}

class _NotificationListItem {
  const _NotificationListItem({
    required this.title,
    required this.body,
    required this.timeLabel,
    this.id,
    this.orderId,
    this.type = 'order',
    this.isRead = false,
  });

  factory _NotificationListItem.fromBackend(NotificationSummary notification) {
    return _NotificationListItem(
      id: notification.id,
      orderId: notification.orderId,
      type: notification.type,
      title: notification.title,
      body: notification.body,
      timeLabel: _formatNotificationTime(notification.createdAt),
      isRead: notification.isRead,
    );
  }

  final String? id;
  final String? orderId;
  final String type;
  final String title;
  final String body;
  final String timeLabel;
  final bool isRead;

  IconData get icon {
    final normalized = type.toLowerCase();
    if (normalized.contains('payment')) return Icons.credit_card_outlined;
    if (normalized.contains('review')) return Icons.star_border;
    if (normalized.contains('system')) return Icons.info_outline;
    return Icons.shopping_bag_outlined;
  }

  _NotificationListItem copyWith({bool? isRead}) {
    return _NotificationListItem(
      id: id,
      orderId: orderId,
      type: type,
      title: title,
      body: body,
      timeLabel: timeLabel,
      isRead: isRead ?? this.isRead,
    );
  }
}

String _formatNotificationTime(DateTime createdAt) {
  final now = DateTime.now();
  final local = createdAt.toLocal();
  final difference = now.difference(local);

  if (difference.inMinutes < 1) return 'À l’instant';
  if (difference.inMinutes < 60) return 'Il y a ${difference.inMinutes} min';
  if (difference.inHours < 24) return 'Il y a ${difference.inHours} h';

  final today = DateTime(now.year, now.month, now.day);
  final notificationDay = DateTime(local.year, local.month, local.day);
  if (notificationDay == today.subtract(const Duration(days: 1))) return 'Hier';

  return '${local.day.toString().padLeft(2, '0')}/'
      '${local.month.toString().padLeft(2, '0')}';
}

final _title = GoogleFonts.poppins(
  fontSize: 16,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _bodyTitle = GoogleFonts.poppins(
  fontSize: 11.5,
  height: 1.45,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _body = GoogleFonts.poppins(
  fontSize: 11,
  height: 1.45,
  fontWeight: FontWeight.w800,
  color: const Color(0xFF526669),
);
final _time = GoogleFonts.poppins(
  fontSize: 9,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF879395),
);
final _link = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w900,
  color: AppColors.blueBic,
);
