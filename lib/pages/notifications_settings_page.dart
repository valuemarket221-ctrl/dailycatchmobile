import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';

/// Page des notifications
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _promotionsEnabled = true;
  bool _ordersEnabled = true;
  bool _reservationsEnabled = true;
  bool _newsEnabled = false;

  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'Nouvelle offre disponible',
      message: 'Découvrez nos sacs de crevettes à -50%!',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      type: NotificationType.promotion,
    ),
    NotificationItem(
      id: '2',
      title: 'Votre commande est en route',
      message: 'Votre commande CMD-003 sera livrée demain.',
      date: DateTime.now().subtract(const Duration(days: 1)),
      isRead: false,
      type: NotificationType.order,
    ),
    NotificationItem(
      id: '3',
      title: 'Rappel de récupération',
      message: 'N\'oubliez pas de récupérer votre réservation avant 18h!',
      date: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      type: NotificationType.reservation,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Notifications', style: GoogleFonts.poppins()),
          backgroundColor: AppColors.blueBic,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [Tab(text: 'Notifications'), Tab(text: 'Préférences')],
          ),
        ),
        body: TabBarView(
          children: [_buildNotificationsList(), _buildPreferences()],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    if (_notifications.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        return _buildNotificationCard(_notifications[index]);
      },
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Dismissible(
      key: Key(notification.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Notification supprimée',
              style: GoogleFonts.poppins(),
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color:
            notification.isRead
                ? Colors.white
                : AppColors.blueBic.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getNotificationColor(
                    notification.type,
                  ).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getNotificationColor(notification.type),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: GoogleFonts.poppins(
                              fontWeight:
                                  notification.isRead
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(notification.date),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferences() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Notifications push',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.blueBic,
          ),
        ),
        const SizedBox(height: 16),
        _buildSwitchTile(
          title: 'Promotions et offres',
          subtitle: 'Recevez des alertes sur les nouvelles offres',
          value: _promotionsEnabled,
          onChanged: (value) {
            setState(() => _promotionsEnabled = value);
          },
        ),
        _buildSwitchTile(
          title: 'Commandes',
          subtitle: 'Suivi de vos commandes et livraison',
          value: _ordersEnabled,
          onChanged: (value) {
            setState(() => _ordersEnabled = value);
          },
        ),
        _buildSwitchTile(
          title: 'Réservations',
          subtitle: 'Rappels pour récupérer vos produits',
          value: _reservationsEnabled,
          onChanged: (value) {
            setState(() => _reservationsEnabled = value);
          },
        ),
        _buildSwitchTile(
          title: 'Actualités',
          subtitle: 'Dernières nouvelles de l\'application',
          value: _newsEnabled,
          onChanged: (value) {
            setState(() => _newsEnabled = value);
          },
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Préférences enregistrées',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.blueBic,
              side: const BorderSide(color: AppColors.blueBic),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Enregistrer',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.blueBic,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Aucune notification',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.promotion:
        return Colors.purple;
      case NotificationType.order:
        return AppColors.blueBic;
      case NotificationType.reservation:
        return Colors.orange;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.promotion:
        return Icons.local_offer;
      case NotificationType.order:
        return Icons.shopping_bag;
      case NotificationType.reservation:
        return Icons.event;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inHours < 1) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Il y a ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Modèle de notification
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime date;
  final bool isRead;
  final NotificationType type;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.isRead,
    required this.type,
  });
}

/// Type de notification
enum NotificationType { promotion, order, reservation }
