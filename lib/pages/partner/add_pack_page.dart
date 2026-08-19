import 'package:flutter/material.dart';
import 'package:myapp/services/partner_api_service.dart';
import 'package:myapp/styles/app_theme.dart';
import 'package:myapp/styles/text_styles.dart';

class AddPackPage extends StatefulWidget {
  const AddPackPage({super.key});

  @override
  State<AddPackPage> createState() => _AddPackPageState();
}

class _AddPackPageState extends State<AddPackPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _originalPriceController =
      TextEditingController();
  final TextEditingController _discountedPriceController =
      TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final PartnerApiService _partnerApiService = PartnerApiService();

  DateTime? _expiryDate;
  final List<String> _selectedProducts = [];
  final List<String> _availableProducts = [
    'Saumon frais (500g)',
    'Crevettes (250g)',
    'Homard entier (800g)',
    'Moules (400g)',
    'Huîtres (6 pièces)',
    'Maquereau (600g)',
    'Sardines (350g)',
    'Truite (450g)',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _originalPriceController.dispose();
    _discountedPriceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.mutedSurface,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Créer un panier',
                    style: AppTextStyles.headingM,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.primaryColor,
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildForm(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.softBorder),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Informations du panier', style: AppTextStyles.headingS),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _nameController,
                    'Nom du panier',
                    'ex: Panier Poisson',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    _descriptionController,
                    'Description',
                    'Description...',
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Contenu possible', style: AppTextStyles.headingS),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _availableProducts
                      .map(
                        (product) => FilterChip(
                          label: Text(product),
                          selected: _selectedProducts.contains(product),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedProducts.add(product);
                              } else {
                                _selectedProducts.remove(product);
                              }
                            });
                          },
                          selectedColor: const Color(
                            0xFF3B82F6,
                          ).withValues(alpha: 0.2),
                          checkmarkColor: const Color(0xFF3B82F6),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 24),
            Text('Prix et disponibilités', style: AppTextStyles.headingS),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _originalPriceController,
                    'Prix original (€)',
                    '0.00',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    _discountedPriceController,
                    'Prix réduit (€)',
                    '0.00',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    _quantityController,
                    'Paniers disponibles',
                    '0',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Retrait', style: AppTextStyles.headingS),
            const SizedBox(height: 16),
            _buildDatePicker(),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text('Annuler', style: AppTextStyles.bodyM),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Text(
                            'Créer le panier',
                            style: AppTextStyles.bodyM.copyWith(
                              color: Colors.white,
                            ),
                          ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(const Duration(days: 7)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) setState(() => _expiryDate = date);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.softBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.grey),
            const SizedBox(width: 12),
            Text(
              _expiryDate != null
                  ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
                  : 'Sélectionner une date de retrait',
              style: AppTextStyles.bodyM.copyWith(
                color: _expiryDate != null ? Colors.black : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final originalPrice = double.tryParse(_originalPriceController.text) ?? 0;
    final discountedPrice =
        double.tryParse(_discountedPriceController.text) ?? 0;
    final quantity = int.tryParse(_quantityController.text) ?? 0;

    if (discountedPrice <= 0 ||
        originalPrice < discountedPrice ||
        quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vérifiez le prix réduit et les quantités.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _partnerApiService.createOffer(
        PartnerOfferRequest(
          storeId: 'store_port',
          storeName: 'Poissonnerie du Port',
          name: _nameController.text.trim(),
          description:
              _descriptionController.text.trim().isEmpty
                  ? _selectedProducts.join(', ')
                  : _descriptionController.text.trim(),
          unitAmount: (discountedPrice * 100).round(),
          originalUnitAmount: (originalPrice * 100).round(),
          availableQuantity: quantity,
          pickupStartsAt: _expiryDate,
          pickupEndsAt: _expiryDate?.add(const Duration(hours: 2)),
          latitude: 14.6928,
          longitude: -17.4467,
        ),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Panier publié avec succès.'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backend indisponible: panier conservé en mode démo.'),
          backgroundColor: Color(0xFFF59E0B),
        ),
      );
    }
  }
}
