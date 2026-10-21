import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/services/backend_api_client.dart';
import 'package:myapp/utils/api_error_messages.dart';

void main() {
  group('ApiErrorMessages', () {
    test('maps database outages to a clear user-facing message', () {
      const error = BackendApiException(
        statusCode: 503,
        code: 'database_unavailable',
      );

      expect(
        ApiErrorMessages.fromObject(error),
        'La base de données est momentanément indisponible. Réessayez dans un instant.',
      );
    });

    test('keeps network failures distinct from backend outages', () {
      const error = BackendApiException(
        statusCode: 0,
        code: 'network_unavailable',
      );

      expect(
        ApiErrorMessages.fromObject(error),
        'Connexion impossible au serveur. Vérifiez votre réseau.',
      );
    });

    test('maps partner payout failures to actionable messages', () {
      expect(
        ApiErrorMessages.fromCode('insufficient_payout_balance'),
        'Solde insuffisant pour demander ce versement.',
      );
      expect(
        ApiErrorMessages.fromCode('partner_payment_method_not_found'),
        'Ce moyen de versement n’est plus disponible. Ajoutez-en un autre.',
      );
    });
  });
}
