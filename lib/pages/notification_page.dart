import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  // Liste de notifications - Style TGTG
  final List<Map<String, dynamic>> notifications = [
    {
      "title": "Votre produit est prêt !",
      "subtitle": "Venez récupérer votre commande à la Poissonnerie du Port",
      "time": "Il y a 2 min",
      "isRead": false,
      "type": "order",
      "icon": Icons.shopping_bag,
    },
    {
      "title": "Nouveau produit disponible",
      "subtitle": "Découvrez les nouveaux produits sauvés près de chez vous",
      "time": "Il y a 30 min",
      "isRead": false,
      "type": "promo",
      "icon": Icons.local_offer,
    },
    {
      "title": "-20% sur votre prochaine commande",
      "subtitle": "Utilisez le code SAVE20 pour bénéficier de cette offre",
      "time": "Aujourd'hui",
      "isRead": true,
      "type": "promo",
      "icon": Icons.discount,
    },
    {
      "title": "Rappel: Retrait dans 2 heures",
      "subtitle": "N'oubliez pas de récupérer votre commande",
      "time": "Aujourd'hui",
      "isRead": false,
      "type": "order",
      "icon": Icons.access_time,
    },
  ];

  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification['isRead'] = true;
      }
    });
  }

  void _markAsRead(int index) {
    setState(() {
      notifications[index]['isRead'] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = notifications.where((n) => !(n['isRead'] as bool)).length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Tout marquer comme lu',
                style: GoogleFonts.poppins(
                  color: AppColors.blueBic,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
      body:
          notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Aucune notification",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Vous êtes à jour !",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return GestureDetector(
                      onTap: () => _markAsRead(index),
                      child: _buildNotificationCard(notification),
                    );
                  },
                ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final bool isRead = notification['isRead'] as bool;
    final String type = notification['type'] as String;
    final Color iconColor = _getIconColor(type);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isRead ? Colors.grey[100]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge non lu
          if (!isRead)
            Container(
              margin: const EdgeInsets.only(top: 6, right: 8),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.blueBic,
                shape: BoxShape.circle,
              ),
            ),
          // Icône
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              notification['icon'] as IconData,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification['title'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification['subtitle'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notification['time'] as String,
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
    );
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'order':
        return AppColors.blueBic;
      case 'promo':
        return const Color(0xFFFF6B6B);
      default:
        return AppColors.greenTGTG;
    }
  }
}
