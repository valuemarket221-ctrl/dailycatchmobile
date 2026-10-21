import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/utils/navigation_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/services/client_api_service.dart';

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  final ClientApiService _clientApiService = ClientApiService();
  var _isLoading = true;
  String? _loadError;
  List<ClientAddressDto> _addresses = const [];

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final addresses = await _clientApiService.getMyAddresses();
      if (!mounted) return;
      setState(() {
        _addresses = addresses;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Adresses indisponibles. Réessayez.';
        _isLoading = false;
      });
    }
  }

  Future<void> _addAddress() async {
    await context.push('/new-address');
    if (mounted) await _loadAddresses();
  }

  Future<void> _deleteAddress(ClientAddressDto address) async {
    try {
      await _clientApiService.deleteAddress(address.id);
      if (mounted) await _loadAddresses();
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
  Widget build(BuildContext context) => _SecondaryShell(
    title: 'MES ADRESSES',
    child: Column(
      children: [
        if (_isLoading)
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.blueBic),
            ),
          )
        else if (_loadError != null)
          Expanded(
            child: Center(
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
                    onPressed: _loadAddresses,
                    child: Text('Réessayer', style: _link),
                  ),
                ],
              ),
            ),
          )
        else if (_addresses.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                'Aucune adresse enregistrée',
                style: _subtitle,
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          Expanded(
            child: RefreshIndicator(
              color: AppColors.blueBic,
              onRefresh: _loadAddresses,
              child: ListView(
                children: [
                  ..._addresses.map((address) {
                    return _CardRow(
                      icon:
                          address.isDefault
                              ? Icons.home_outlined
                              : Icons.location_on_outlined,
                      title: address.label,
                      subtitle: [
                        address.address,
                        if ((address.complement ?? '').isNotEmpty)
                          address.complement!,
                        address.country,
                      ].join(', '),
                      trailing: address.isDefault ? 'Par défaut' : 'Supprimer',
                      onTap:
                          () =>
                              address.isDefault
                                  ? _message('Adresse par défaut')
                                  : _deleteAddress(address),
                    );
                  }),
                ],
              ),
            ),
          ),
        _PrimaryButton(label: 'Ajouter une adresse', onPressed: _addAddress),
      ],
    ),
  );
}

class _SecondaryShell extends StatelessWidget {
  const _SecondaryShell({required this.title, required this.child});
  final String title;
  final Widget child;

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
                Text(title, style: _header),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(child: child),
          ],
        ),
      ),
    ),
  );
}

class _CardRow extends StatelessWidget {
  const _CardRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2EAEA)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.blueBic, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _title),
                const SizedBox(height: 4),
                Text(subtitle, style: _subtitle),
              ],
            ),
          ),
          Text(trailing, style: _link),
        ],
      ),
    ),
  );
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 48,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.blueBic,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: _button),
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
  fontSize: 10.5,
  fontWeight: FontWeight.w900,
  color: AppColors.blueBic,
);
final _button = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w900,
  color: Colors.white,
);
