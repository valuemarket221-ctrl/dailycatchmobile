import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/utils/navigation_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/services/client_api_service.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  final ClientApiService _clientApiService = ClientApiService();
  var _isLoading = true;
  String? _loadError;
  List<ClientPaymentMethodDto> _methods = const [];

  @override
  void initState() {
    super.initState();
    _loadMethods();
  }

  Future<void> _loadMethods() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final methods = await _clientApiService.getMyPaymentMethods();
      if (!mounted) return;
      setState(() {
        _methods = methods;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Moyens de paiement indisponibles. Réessayez.';
        _isLoading = false;
      });
    }
  }

  Future<void> _addPayment() async {
    await context.push('/add-payment');
    if (mounted) await _loadMethods();
  }

  Future<void> _deleteMethod(ClientPaymentMethodDto method) async {
    try {
      await _clientApiService.deletePaymentMethod(method.id);
      if (mounted) await _loadMethods();
    } catch (_) {
      if (mounted) _message('Suppression impossible');
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, style: GoogleFonts.poppins()),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.blueBic,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => safePop(context),
                  icon: const Icon(Icons.arrow_back, color: AppColors.blueBic),
                ),
                const Spacer(),
                Text('PAIEMENT', style: _header),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 28),
            Expanded(
              child:
                  _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.blueBic,
                        ),
                      )
                      : _loadError != null
                      ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _loadError!,
                              style: _subtitle,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 14),
                            TextButton(
                              onPressed: _loadMethods,
                              child: Text('Réessayer', style: _link),
                            ),
                          ],
                        ),
                      )
                      : _methods.isEmpty
                      ? Center(
                        child: Text(
                          'Aucun moyen de paiement enregistré',
                          style: _subtitle,
                          textAlign: TextAlign.center,
                        ),
                      )
                      : RefreshIndicator(
                        color: AppColors.blueBic,
                        onRefresh: _loadMethods,
                        child: ListView.builder(
                          itemCount: _methods.length,
                          itemBuilder: (context, index) {
                            final method = _methods[index];
                            return _MethodTile(
                              icon:
                                  method.type == 'mobile_money'
                                      ? Icons.phone_android
                                      : Icons.credit_card,
                              title:
                                  method.type == 'mobile_money'
                                      ? 'Mobile Money'
                                      : 'Carte bancaire',
                              subtitle: method.label,
                              onTap:
                                  () => _message('${method.label} sélectionné'),
                              onDelete: () => _deleteMethod(method),
                            );
                          },
                        ),
                      ),
            ),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _addPayment,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.blueBic,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Ajouter un moyen de paiement', style: _button),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.onDelete,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      height: 70,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2EAEA)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.blueBic, size: 25),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _title),
                const SizedBox(height: 4),
                Text(subtitle, style: _subtitle),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: Color(0xFF9AA8AA)),
          ),
        ],
      ),
    ),
  );
}

final _header = GoogleFonts.poppins(
  fontSize: 15,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _title = GoogleFonts.poppins(
  fontSize: 13,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _subtitle = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w600,
  color: const Color(0xFF526669),
);
final _link = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w900,
  color: AppColors.blueBic,
);
final _button = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w900,
  color: Colors.white,
);
