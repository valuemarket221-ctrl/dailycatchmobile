import 'package:flutter/material.dart';
import 'package:myapp/widgets/responsive_form_row.dart';
import 'package:myapp/styles/app_theme.dart';
import 'package:myapp/styles/text_styles.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _originalPriceController =
      TextEditingController();
  final TextEditingController _discountedPriceController =
      TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  String _selectedCategory = 'Poisson';
  DateTime? _expiryDate;
  final List<String> _selectedAllergens = [];

  final List<String> _categories = [
    'Poisson',
    'Crustacés',
    'Coquillages',
    'Viande',
    'Crémerie',
  ];
  final List<String> _allergensList = [
    'Arachides',
    'Noix',
    'Lait',
    'Œufs',
    'Poisson',
    'Gluten',
    'Soja',
    'Sésame',
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
                    'Ajouter un panier',
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
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Informations du panier', style: AppTextStyles.headingS),
            const SizedBox(height: 24),
            ResponsiveFormRow(
              children: [
                Expanded(
                  child: _buildTextField(
                    _nameController,
                    'Nom du panier',
                    'Nom',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: _buildDropdown()),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              _descriptionController,
              'Description',
              'Contenu possible du panier...',
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Text('Prix et disponibilités', style: AppTextStyles.headingS),
            const SizedBox(height: 16),
            ResponsiveFormRow(
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
            Text('Date de retrait', style: AppTextStyles.headingS),
            const SizedBox(height: 16),
            _buildDatePicker(),
            const SizedBox(height: 24),
            Text('Allergènes', style: AppTextStyles.headingS),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _allergensList
                      .map(
                        (allergen) => FilterChip(
                          label: Text(allergen),
                          selected: _selectedAllergens.contains(allergen),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedAllergens.add(allergen);
                              } else {
                                _selectedAllergens.remove(allergen);
                              }
                            });
                          },
                          selectedColor: const Color(
                            0xFFEF4444,
                          ).withValues(alpha: 0.2),
                          checkmarkColor: const Color(0xFFEF4444),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 32),
            Wrap(
              alignment: WrapAlignment.end,
              runSpacing: 12,
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
                    backgroundColor: const Color(0xFF10B981),
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
                            'Enregistrer',
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

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catégorie',
          style: AppTextStyles.bodyM.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: _selectedCategory,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items:
              _categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
          onChanged: (val) => setState(() => _selectedCategory = val!),
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
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _expiryDate != null
                    ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
                    : 'Sélectionner une date',
                style: AppTextStyles.bodyM.copyWith(
                  color: _expiryDate != null ? Colors.black : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;

        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Panier ajouté avec succès!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        Navigator.pop(context);
      });
    }
  }
}
