import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';

/// Partner Registration Page - Clone TGTG Style
/// Page d'inscription pour les commerçants qui veulent vendre leurs produits
class PartnerRegistrationPage extends StatefulWidget {
  const PartnerRegistrationPage({super.key});

  @override
  State<PartnerRegistrationPage> createState() => _PartnerRegistrationPageState();
}

class _PartnerRegistrationPageState extends State<PartnerRegistrationPage> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _selectedCategory = 'Poissonnerie';
  bool _agreedToTerms = false;

  final List<String> _categories = [
    'Poissonnerie',
    'Fruits de mer',
    'Crustacés',
    'Coquillages',
    'Restauration',
    'Epicerie',
  ];

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _submitForm();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Demande de partenariat soumise avec succès!'),
          backgroundColor: Colors.green,
        ),
      );
      // Navigate to pending validation page
      context.go('/admin/partners/pending');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Devenir partenaire',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildProgressStep(0, 'Infos'),
                  _buildProgressLine(0),
                  _buildProgressStep(1, 'Boutique'),
                  _buildProgressLine(1),
                  _buildProgressStep(2, 'Compte'),
                ],
              ),
            ),
            // Step content
            Expanded(
              child: PageView(
                controller: PageController(),
                onPageChanged: (index) => setState(() => _currentStep = index),
                children: [
                  _buildStoreInfoStep(),
                  _buildBusinessStep(),
                  _buildAccountStep(),
                ],
              ),
            ),
            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppColors.blueBic),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Retour',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blueBic,
                          ),
                        ),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _currentStep < 2 ? _nextStep : _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.blueBic,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentStep < 2 ? 'Suivant' : 'Soumettre',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStep(int step, String label) {
    final isActive = _currentStep >= step;
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive ? AppColors.blueBic : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : Colors.grey[600],
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: isActive ? AppColors.blueBic : Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(int step) {
    final isComplete = _currentStep > step;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
        decoration: BoxDecoration(
          color: isComplete ? AppColors.blueBic : Colors.grey[300],
        ),
      ),
    );
  }

  Widget _buildStoreInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations sur votre boutique',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Commencez par nous parler de votre commerce',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          // Store name
          _buildTextField(
            controller: _storeNameController,
            label: 'Nom de la boutique',
            hint: 'Ex: DailyCatch Store',
            icon: Icons.storefront,
            validator: (value) => value!.isEmpty ? 'Nom requis' : null,
          ),
          const SizedBox(height: 16),
          // Category dropdown
          _buildDropdownField(),
          const SizedBox(height: 16),
          // Address
          _buildTextField(
            controller: _addressController,
            label: 'Adresse',
            hint: 'Ex: 15 Rue du Port, Dakar',
            icon: Icons.location_on,
            validator: (value) => value!.isEmpty ? 'Adresse requise' : null,
          ),
          const SizedBox(height: 32),
          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.blueBic.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info, color: AppColors.blueBic),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Vous pourrez ajouter vos produits après validation de votre demande.',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations légales',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ces informations nous aideront à vous contacter',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          // Owner name
          _buildTextField(
            controller: _ownerNameController,
            label: 'Nom du responsable',
            hint: 'Votre nom complet',
            icon: Icons.person,
            validator: (value) => value!.isEmpty ? 'Nom requis' : null,
          ),
          const SizedBox(height: 16),
          // Email
          _buildTextField(
            controller: _emailController,
            label: 'Email professionnel',
            hint: 'contact@boutique.com',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value!.isEmpty) return 'Email requis';
              if (!value.contains('@')) return 'Email invalide';
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Phone
          _buildTextField(
            controller: _phoneController,
            label: 'Téléphone',
            hint: '+221 XX XXX XX XX',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) => value!.isEmpty ? 'Téléphone requis' : null,
          ),
          const SizedBox(height: 32),
          // Additional info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Heures d'ouverture",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTimeField('Ouverture matin', '08:00'),
                const SizedBox(height: 8),
                _buildTimeField('Fermeture matin', '12:00'),
                const SizedBox(height: 8),
                _buildTimeField('Ouverture soir', '14:00'),
                const SizedBox(height: 8),
                _buildTimeField('Fermeture soir', '20:00'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Créer votre compte',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Définissez votre mot de passe pour accéder à votre espace',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          // Password
          _buildTextField(
            controller: _passwordController,
            label: 'Mot de passe',
            hint: 'Minimum 8 caractères',
            icon: Icons.lock,
            obscureText: true,
            validator: (value) {
              if (value!.isEmpty) return 'Mot de passe requis';
              if (value.length < 8) return 'Minimum 8 caractères';
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Confirm password
          _buildTextField(
            label: 'Confirmer le mot de passe',
            hint: 'Répétez votre mot de passe',
            icon: Icons.lock_outline,
            obscureText: true,
            validator: (value) {
              if (value!.isEmpty) return 'Confirmation requise';
              if (value != _passwordController.text) return 'Les mots de passe ne correspondent pas';
              return null;
            },
          ),
          const SizedBox(height: 24),
          // Terms agreement
          GestureDetector(
            onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: _agreedToTerms ? AppColors.blueBic : Colors.transparent,
                    border: Border.all(
                      color: _agreedToTerms ? AppColors.blueBic : Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: _agreedToTerms
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: 'J\'accepte les ',
                      style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
                      children: [
                        TextSpan(
                          text: 'Conditions Générales',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.blueBic,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(
                          text: ' et la ',
                          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
                        ),
                        TextSpan(
                          text: 'Politique de confidentialité',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.blueBic,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(
                          text: ' pour devenir partenaire DailyCatch.',
                          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Récapitulatif',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSummaryRow('Boutique:', _storeNameController.text),
                _buildSummaryRow('Catégorie:', _selectedCategory),
                _buildSummaryRow('Responsable:', _ownerNameController.text),
                _buildSummaryRow('Email:', _emailController.text),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    TextEditingController? controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.blueBic),
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catégorie',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.category, color: AppColors.blueBic),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          items: _categories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(category, style: GoogleFonts.poppins()),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedCategory = value!),
        ),
      ],
    );
  }

  Widget _buildTimeField(String label, String defaultValue) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: GoogleFonts.poppins(fontSize: 13)),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              defaultValue,
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
