import 'package:intl/intl.dart';

/// Formatters pour afficher les données
class AppFormatters {
  // ── Currency ─────────────────────────────────────
  static String formatPrice(double price, {String currency = '€'}) {
    return '${price.toStringAsFixed(2)}$currency';
  }

  static String formatCfa(num amount) {
    final rounded = amount.round();
    final formatted = NumberFormat.decimalPattern('fr_SN').format(rounded);
    return '$formatted FCFA';
  }

  static String formatMoney(num amount, {String currency = 'XOF'}) {
    if (currency.toUpperCase() == 'XOF') return formatCfa(amount);
    return '${amount.toStringAsFixed(2)} ${currency.toUpperCase()}';
  }

  // ── Discount Percentage ─────────────────────────
  static String formatDiscount(int percentage) {
    return '-$percentage%';
  }

  // ── Distance ────────────────────────────────────
  static String formatDistance(double km) {
    if (km < 1) {
      return '${(km * 1000).toStringAsFixed(0)}m';
    }
    return '${km.toStringAsFixed(1)} km';
  }

  // ── Date ────────────────────────────────────────
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  static String formatDateRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return formatDate(date);
    }
  }

  // ── Time ────────────────────────────────────────
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  // ── Rating ──────────────────────────────────────
  static String formatRating(double rating) {
    return rating.toStringAsFixed(1);
  }

  // ── Number ──────────────────────────────────────
  static String formatNumber(int number) {
    return NumberFormat('#,###').format(number);
  }

  // ── Savings ─────────────────────────────────────
  static String formatSavings(double savings) {
    return '${savings.toStringAsFixed(2)}€ économisés';
  }

  static String formatSavingsCfa(num savings) {
    return '${formatCfa(savings)} économisés';
  }

  // ── CO2 ─────────────────────────────────────────
  static String formatCO2(double kg) {
    return '${kg.toStringAsFixed(1)} kg de CO₂';
  }
}
