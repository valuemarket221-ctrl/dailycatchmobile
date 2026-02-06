import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/constants.dart';

/// Bottom Navigation Bar - Clone TGTG Style
/// 5 onglets: Découvrir, Rechercher, Favoris (central), Mes sauvés, Profil
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
        context.go('/pickup');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Découvrir (Home)
          _buildNavItem(
            context: context,
            index: 0,
            icon: Icons.storefront_outlined,
            label: 'Découvrir',
          ),
          // Rechercher
          _buildNavItem(
            context: context,
            index: 1,
            icon: Icons.search,
            label: 'Rechercher',
          ),
          // Favoris (central button)
          _buildCentralButton(context),
          // Mes sauvés (Pickup)
          _buildNavItem(
            context: context,
            index: 3,
            icon: Icons.qr_code_2,
            label: 'Mes sauvés',
          ),
          // Profil
          _buildNavItem(
            context: context,
            index: 4,
            icon: Icons.person_outline,
            label: 'Profil',
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
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(context, index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.blueBic : const Color(0xFF767676),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.blueBic : const Color(0xFF767676),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCentralButton(BuildContext context) {
    final isSelected = currentIndex == 2;
    return GestureDetector(
      onTap: () => _onItemTapped(context, 2),
      child: Container(
        width: 64,
        height: 48,
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: AppColors.blueBic,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.blueBic.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.favorite, color: Colors.white, size: 28),
      ),
    );
  }
}
