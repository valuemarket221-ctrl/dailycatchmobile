/// Validateurs pour les formulaires
class Validators {
  // ── Email ────────────────────────────────────────
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email requis';
    }

    const emailRegex =
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regex = RegExp(emailRegex);

    if (!regex.hasMatch(value)) {
      return 'Email invalide';
    }

    return null;
  }

  // ── Password ─────────────────────────────────────
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mot de passe requis';
    }

    if (value.length < 6) {
      return 'Minimum 6 caractères';
    }

    return null;
  }

  // ── Confirm Password ────────────────────────────
  static String? validateConfirmPassword(
    String? value,
    String? originalPassword,
  ) {
    final passwordError = validatePassword(value);
    if (passwordError != null) return passwordError;

    if (value != originalPassword) {
      return 'Les mots de passe ne correspondent pas';
    }

    return null;
  }

  // ── Phone ────────────────────────────────────────
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Téléphone requis';
    }

    const phoneRegex = r'^[+]?[(]?[0-9]{3}[)]?[-\s.]?[0-9]{3}[-\s.]?[0-9]{4,6}';
    final regex = RegExp(phoneRegex);

    if (!regex.hasMatch(value)) {
      return 'Numéro de téléphone invalide';
    }

    return null;
  }

  // ── Name ─────────────────────────────────────────
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nom requis';
    }

    if (value.length < 2) {
      return 'Minimum 2 caractères';
    }

    return null;
  }

  // ── Required field ──────────────────────────────
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName est requis';
    }
    return null;
  }
}
