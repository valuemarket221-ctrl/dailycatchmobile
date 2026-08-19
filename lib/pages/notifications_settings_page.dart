import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/services/support_api_service.dart';
import 'package:myapp/styles/app_theme.dart';

/// Page des notifications
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final SupportApiService _supportApiService = SupportApiService();
  bool _promotionsEnabled = true;
  bool _ordersEnabled = true;
  bool _reservationsEnabled = true;
  bool _newsEnabled = false;
  bool _isLoadingPreferences = true;
  bool _isSavingPreferences = false;

  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'Nouvelle offre disponible',
      message: 'Un panier crevettes est disponible à -50% près de vous.',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      type: NotificationType.promotion,
    ),
    NotificationItem(
      id: '2',
      title: 'Panier confirmé',
      message: 'Votre réservation DC-003 est prête pour le retrait demain.',
      date: DateTime.now().subtract(const Duration(days: 1)),
      isRead: false,
      type: NotificationType.order,
    ),
    NotificationItem(
      id: '3',
      title: 'Rappel de récupération',
      message: 'N\'oubliez pas de récupérer votre panier avant 18h.',
      date: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      type: NotificationType.reservation,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadNotificationPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.mutedSurface,
        appBar: AppBar(
          title: Text(
            'Notifications',
            style: GoogleFonts.poppins(
              color: AppColors.blueBic,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.blueBic,
          elevation: 0,
          bottom: TabBar(
            labelColor: AppColors.blueBic,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: AppColors.greenTGTG,
            tabs: const [Tab(text: 'Alertes'), Tab(text: 'Préférences')],
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color:
              notification.isRead
                  ? Colors.white
                  : AppColors.blueBic.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.softBorder),
          boxShadow: AppTheme.shadowSm,
        ),
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
                  ).withValues(alpha: 0.1),
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
                              color: AppColors.greenTGTG,
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
          'Alertes DailyCatch',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.blueBic,
          ),
        ),
        const SizedBox(height: 16),
        if (_isLoadingPreferences)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else ...[
          _buildSwitchTile(
            title: 'Paniers proches',
            subtitle: 'Recevoir les nouveaux paniers autour de vous',
            value: _promotionsEnabled,
            onChanged: (value) {
              setState(() => _promotionsEnabled = value);
            },
          ),
          _buildSwitchTile(
            title: 'Réservations',
            subtitle: 'Confirmation, paiement et code de retrait',
            value: _ordersEnabled,
            onChanged: (value) {
              setState(() => _ordersEnabled = value);
            },
          ),
          _buildSwitchTile(
            title: 'Réservations',
            subtitle: 'Rappels pour récupérer vos paniers',
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
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed:
                _isSavingPreferences ? null : _saveNotificationPreferences,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.blueBic,
              side: const BorderSide(color: AppColors.blueBic),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _isSavingPreferences ? 'Enregistrement...' : 'Enregistrer',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveNotificationPreferences() async {
    setState(() => _isSavingPreferences = true);
    final pushEnabled =
        _promotionsEnabled ||
        _ordersEnabled ||
        _reservationsEnabled ||
        _newsEnabled;

    try {
      await _supportApiService.updateNotificationPreferences(
        nearbyOffersEnabled: _promotionsEnabled,
        ordersEnabled: _ordersEnabled,
        pickupRemindersEnabled: _reservationsEnabled,
        newsEnabled: _newsEnabled,
      );
      await _supportApiService.updatePushNotificationsEnabled(pushEnabled);
      if (!mounted) return;
      _showPreferenceMessage('Préférences enregistrées');
    } catch (_) {
      if (!mounted) return;
      _showPreferenceMessage(
        'Impossible d’enregistrer les préférences.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingPreferences = false);
      }
    }
  }

  Future<void> _loadNotificationPreferences() async {
    try {
      final preferences = await _supportApiService.getNotificationPreferences();
      if (!mounted) return;
      setState(() {
        _promotionsEnabled = preferences.nearbyOffersEnabled;
        _ordersEnabled = preferences.ordersEnabled;
        _reservationsEnabled = preferences.pickupRemindersEnabled;
        _newsEnabled = preferences.newsEnabled;
        _isLoadingPreferences = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingPreferences = false);
    }
  }

  void _showPreferenceMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: isError ? Colors.red.shade700 : AppColors.greenTGTG,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.softBorder),
        boxShadow: AppTheme.shadowSm,
      ),
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
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.blueBic,
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
        return AppColors.greenTGTG;
      case NotificationType.order:
        return AppColors.blueBic;
      case NotificationType.reservation:
        return AppTheme.warningColor;
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
