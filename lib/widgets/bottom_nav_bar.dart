import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/styles/app_theme.dart';
import 'package:myapp/styles/text_styles.dart';

/// Navigation principale DailyCatch
class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/favorites');
        break;
      case 3:
        context.go('/messages');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppTheme.softBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildNavItem(
              context: context,
              index: 0,
              icon: Icons.home_rounded,
              label: 'Accueil',
            ),
          ),
          Expanded(
            child: _buildNavItem(
              context: context,
              index: 1,
              icon: Icons.search,
              label: 'Explorer',
            ),
          ),
          Expanded(
            child: _buildNavItem(
              context: context,
              index: 2,
              icon: Icons.favorite_border,
              label: 'Favoris',
            ),
          ),
          Expanded(
            child: _buildNavItem(
              context: context,
              index: 3,
              icon: Icons.chat_bubble_outline,
              label: 'Messages',
            ),
          ),
          Expanded(
            child: _buildNavItem(
              context: context,
              index: 4,
              icon: Icons.person_outline,
              label: 'Profil',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = currentIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(context, index),
      child: Container(
        padding: const EdgeInsets.only(top: 8, bottom: 10),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? AppTheme.reef : AppTheme.textSecondary,
                size: 20,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: AppTextStyles.captionS.copyWith(
                  color: isSelected ? AppTheme.reef : AppTheme.textSecondary,
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
