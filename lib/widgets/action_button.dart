import 'package:flutter/material.dart';
import 'package:myapp/styles/app_theme.dart';
import 'package:myapp/styles/text_styles.dart';

/// Bouton d'action réutilisable
enum ActionButtonType { primary, secondary }

class ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final ActionButtonType type;
  final bool isLoading;
  final bool isEnabled;
  final double? width;

  const ActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.type = ActionButtonType.primary,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = type == ActionButtonType.primary;

    return SizedBox(
      width: width ?? double.infinity,
      height: 54,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (isEnabled && !isLoading) ? onPressed : null,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Container(
            decoration: BoxDecoration(
              color: isPrimary
                  ? AppTheme.primaryColor
                  : Colors.white,
              border: isPrimary
                  ? null
                  : Border.all(color: AppTheme.primaryColor),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            color: isPrimary ? Colors.white : AppTheme.primaryColor,
                          ),
                          const SizedBox(width: AppTheme.md),
                        ],
                        Text(
                          label,
                          style: AppTextStyles.subtitleS.copyWith(
                            color: isPrimary ? Colors.white : AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
