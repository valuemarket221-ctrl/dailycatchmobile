import 'package:flutter/material.dart';
import 'package:myapp/styles/app_theme.dart';
import 'package:myapp/utils/api_environment.dart';

class AppRemoteImage extends StatelessWidget {
  const AppRemoteImage({
    super.key,
    required this.path,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.cacheWidth,
    this.filterQuality = FilterQuality.medium,
  });

  final String path;
  final double width;
  final double height;
  final BoxFit fit;
  final int? cacheWidth;
  final FilterQuality filterQuality;

  @override
  Widget build(BuildContext context) {
    final resolved = _resolvePath(path);
    if (resolved == null) {
      return _ImageFallback(width: width, height: height);
    }

    if (resolved.isNetwork) {
      return Image.network(
        resolved.value,
        width: width,
        height: height,
        fit: fit,
        filterQuality: filterQuality,
        errorBuilder: (_, __, ___) => _ImageFallback(width: width, height: height),
      );
    }

    return Image.asset(
      resolved.value,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cacheWidth,
      filterQuality: filterQuality,
      errorBuilder: (_, __, ___) => _ImageFallback(width: width, height: height),
    );
  }

  _ResolvedImagePath? _resolvePath(String rawPath) {
    final value = rawPath.trim();
    if (value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri?.hasScheme == true) {
      return _ResolvedImagePath(value: value, isNetwork: true);
    }

    if (value.startsWith('/api/')) {
      final base = ApiEnvironment.baseUrl.replaceAll(RegExp(r'/$'), '');
      return _ResolvedImagePath(value: '$base$value', isNetwork: true);
    }

    return _ResolvedImagePath(value: value, isNetwork: false);
  }
}

class _ResolvedImagePath {
  const _ResolvedImagePath({required this.value, required this.isNetwork});

  final String value;
  final bool isNetwork;
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    color: const Color(0xFFEFF3EF),
    alignment: Alignment.center,
    child: const Icon(
      Icons.image_not_supported_outlined,
      color: AppTheme.textSecondary,
    ),
  );
}
