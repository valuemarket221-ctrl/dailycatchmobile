import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/styles/app_theme.dart';
import 'package:myapp/styles/text_styles.dart';

class PartnerBottomNavBar extends StatelessWidget {
  const PartnerBottomNavBar({super.key, required this.currentIndex});

  final int currentIndex;

  void _go(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/partner/mobile-dashboard');
        break;
      case 1:
        context.go('/partner/baskets');
        break;
      case 2:
        context.go('/partner/orders');
        break;
      case 3:
        context.go('/partner/validated-pickups');
        break;
      case 4:
        context.go('/partner/commerce-settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    height: 78,
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: AppTheme.softBorder)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _Item(
          index: 0,
          currentIndex: currentIndex,
          icon: Icons.dashboard_outlined,
          label: 'Espace',
          onTap: () => _go(context, 0),
        ),
        _Item(
          index: 1,
          currentIndex: currentIndex,
          icon: Icons.add_box_outlined,
          label: 'Publier',
          onTap: () => _go(context, 1),
        ),
        _Item(
          index: 2,
          currentIndex: currentIndex,
          icon: Icons.receipt_long_outlined,
          label: 'Commandes',
          onTap: () => _go(context, 2),
        ),
        _Item(
          index: 3,
          currentIndex: currentIndex,
          icon: Icons.lock_open_outlined,
          label: 'Retraits',
          onTap: () => _go(context, 3),
        ),
        _Item(
          index: 4,
          currentIndex: currentIndex,
          icon: Icons.person_outline,
          label: 'Profil',
          onTap: () => _go(context, 4),
        ),
      ],
    ),
  );
}

class _Item extends StatelessWidget {
  const _Item({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final int index;
  final int currentIndex;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = index == currentIndex;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.only(top: 8, bottom: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? AppTheme.reef : AppTheme.textSecondary,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: AppTextStyles.captionS.copyWith(
                  fontSize: 9,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? AppTheme.reef : AppTheme.textSecondary,
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
