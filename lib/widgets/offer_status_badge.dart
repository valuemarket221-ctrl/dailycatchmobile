import 'package:flutter/material.dart';
import 'package:myapp/styles/app_theme.dart';
import 'package:myapp/styles/text_styles.dart';

enum OfferStatus { available, lowStock, soldOut, closed, soon }

class OfferStatusBadge extends StatelessWidget {
  final OfferStatus status;
  final String? label;

  const OfferStatusBadge({super.key, required this.status, this.label});

  factory OfferStatusBadge.fromStock({
    Key? key,
    required int quantity,
    String? label,
  }) {
    final status =
        quantity <= 0
            ? OfferStatus.soldOut
            : quantity <= 2
            ? OfferStatus.lowStock
            : OfferStatus.available;
    return OfferStatusBadge(key: key, status: status, label: label);
  }

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      OfferStatus.available => AppTheme.accentColor,
      OfferStatus.lowStock => AppTheme.warningColor,
      OfferStatus.soldOut => Colors.black54,
      OfferStatus.closed => Colors.grey,
      OfferStatus.soon => AppTheme.primaryColor,
    };
    final text =
        label ??
        switch (status) {
          OfferStatus.available => 'Disponible',
          OfferStatus.lowStock => 'Presque épuisé',
          OfferStatus.soldOut => 'Épuisé',
          OfferStatus.closed => 'Fermé',
          OfferStatus.soon => 'Bientôt',
        };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.sm,
        vertical: AppTheme.xs,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(
        text,
        style: AppTextStyles.captionS.copyWith(color: Colors.white),
      ),
    );
  }
}
