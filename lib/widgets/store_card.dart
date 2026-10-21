import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/models/store_model.dart';
import 'package:myapp/styles/app_theme.dart';
import 'package:myapp/styles/text_styles.dart';
import 'package:myapp/widgets/app_remote_image.dart';

class StoreCard extends StatelessWidget {
  const StoreCard({super.key, required this.store, this.onTap});

  final Store store;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: InkWell(
        onTap: onTap ?? () => context.push('/store/${store.id}', extra: store),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          height: 108,
          color: Colors.white,
          child: Row(
            children: [
              _ImageBlock(store: store),
              const SizedBox(width: 14),
              Expanded(child: _InfoBlock(store: store)),
              const SizedBox(width: 8),
              Column(
                children: [
                  const SizedBox(height: 2),
                  Icon(
                    store.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: AppTheme.lagoon,
                    size: 20,
                  ),
                  const Spacer(),
                  Text(
                    store.distance,
                    style: AppTextStyles.captionS.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageBlock extends StatelessWidget {
  const _ImageBlock({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 96,
        height: 96,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppRemoteImage(
              path: store.image,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
              cacheWidth: (96 * MediaQuery.devicePixelRatioOf(context)).round(),
              filterQuality: FilterQuality.medium,
            ),
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 9),
                    const SizedBox(width: 2),
                    Text(
                      store.ratingClipped.toStringAsFixed(1),
                      style: AppTextStyles.captionS.copyWith(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            store.name,
            style: AppTextStyles.captionL.copyWith(
              color: const Color(0xFF142D31),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            'Panier surprise',
            style: AppTextStyles.captionS.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Text(
                _formatPrice(store.discountedPrice),
                style: AppTextStyles.captionL.copyWith(
                  color: const Color(0xFF142D31),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  _formatPrice(store.originalPrice),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.captionS.copyWith(
                    color: AppTheme.textSecondary,
                    decoration: TextDecoration.lineThrough,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            'Aujourd’hui ${store.timeRemaining}',
            style: AppTextStyles.captionS.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.star, color: AppTheme.saffron, size: 12),
              const SizedBox(width: 3),
              Text(
                store.ratingClipped.toStringAsFixed(1),
                style: AppTextStyles.captionS.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice(double value) {
    final rounded = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < rounded.length; i++) {
      final remaining = rounded.length - i;
      buffer.write(rounded[i]);
      if (remaining > 1 && remaining % 3 == 1) buffer.write(' ');
    }
    return '$buffer FCFA';
  }
}
