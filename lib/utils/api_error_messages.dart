import 'package:myapp/services/backend_api_client.dart';

class ApiErrorMessages {
  const ApiErrorMessages._();

  static String fromObject(Object error, {String? fallback}) {
    if (error is BackendApiException) {
      return fromCode(error.code, statusCode: error.statusCode);
    }

    try {
      final dynamic dynamicError = error;
      final message = dynamicError.message;
      final statusCode = dynamicError.statusCode;
      if (message is String) {
        return fromCode(
          message,
          statusCode: statusCode is int ? statusCode : null,
          fallback: fallback,
        );
      }
    } catch (_) {
      // Unknown exception shape.
    }

    return fallback ?? 'Une erreur est survenue. Réessayez.';
  }

  static String fromCode(String code, {int? statusCode, String? fallback}) {
    if (statusCode == 0) {
      return 'Connexion impossible au serveur. Vérifiez votre réseau.';
    }

    return switch (code) {
      'network_unavailable' =>
        'Connexion impossible au serveur. Vérifiez votre réseau.',
      'request_timeout' => 'Le serveur met trop de temps à répondre.',
      'database_not_configured' =>
        'Le backend est démarré sans base de données disponible.',
      'database_unavailable' =>
        'La base de données est momentanément indisponible. Réessayez dans un instant.',
      'invalid_backend_response' =>
        'La réponse du serveur est invalide pour cette version de l’app.',
      'unauthorized' || 'auth_required' => 'Connectez-vous pour continuer.',
      'verified_user_required' =>
        'Une connexion Firebase valide est nécessaire pour continuer.',
      'user_not_authorized' =>
        'Votre compte existe, mais il n’est pas encore autorisé sur DailyCatch.',
      'user_profile_not_found' =>
        'Votre profil DailyCatch est introuvable. Veuillez finaliser votre inscription.',
      'user_inactive' => 'Ce compte a été désactivé.',
      'email_already_registered' =>
        'Cette adresse email est déjà utilisée par un autre compte.',
      'authenticated_email_mismatch' =>
        'L’email Firebase ne correspond pas à l’email du formulaire.',
      'partner_profile_not_approved' =>
        'Votre compte vendeur doit être validé avant de publier un panier.',
      'partner_payment_method_not_found' =>
        'Ce moyen de versement n’est plus disponible. Ajoutez-en un autre.',
      'insufficient_payout_balance' =>
        'Solde insuffisant pour demander ce versement.',
      'store_owner_mismatch' || 'pickup_store_owner_mismatch' =>
        'Ce commerce n’est pas rattaché à votre compte vendeur.',
      'upload_intent_required' =>
        'Veuillez sélectionner le fichier à nouveau avant l’envoi.',
      'upload_intent_expired' =>
        'Le délai d’envoi du fichier a expiré. Sélectionnez-le à nouveau.',
      'upload_intent_already_used' =>
        'Ce fichier a déjà été envoyé. Sélectionnez un autre fichier si nécessaire.',
      'upload_intent_content_type_mismatch' ||
      'unsupported_upload_content_type' =>
        'Ce format de fichier n’est pas accepté.',
      'upload_content_mismatch' =>
        'Le contenu du fichier ne correspond pas au format annoncé.',
      'upload_size_mismatch' =>
        'La taille du fichier ne correspond plus. Sélectionnez-le à nouveau.',
      'forbidden' => 'Votre compte n’a pas accès à cette action.',
      'not_found' => 'Cette ressource n’existe plus.',
      'too_many_requests' => 'Trop de requêtes. Réessayez dans un moment.',
      'quantity_unavailable' || 'insufficient_quantity' =>
        'Ce panier n’est plus disponible en quantité suffisante.',
      'order_not_ready_for_pickup' =>
        'Cette commande n’est pas encore prête pour le retrait.',
      'invalid_pickup_code' => 'Le code de retrait est invalide ou expiré.',
      'payment_intent_failed' ||
      'payment_failed' => 'Le paiement n’a pas pu être finalisé.',
      _ => fallback ?? 'Service momentanément indisponible. Réessayez.',
    };
  }
}
