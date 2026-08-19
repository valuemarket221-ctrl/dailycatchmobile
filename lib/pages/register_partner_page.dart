import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/styles/app_theme.dart';
import 'package:myapp/styles/text_styles.dart';
import 'package:myapp/utils/validators.dart';
import 'package:myapp/widgets/action_button.dart';

/// Register Page pour Partenaires/Vendeurs
class RegisterPartnerPage extends StatefulWidget {
  const RegisterPartnerPage({super.key});

  @override
  State<RegisterPartnerPage> createState() => _RegisterPartnerPageState();
}

class _RegisterPartnerPageState extends State<RegisterPartnerPage> {
  static const _heroImage =
      'assets/images/ChatGPT Image 12 août 2026, 16_27_47.png';
  static const _logoAsset = 'assets/images/logo.png';

  int _currentStep = 0;
  bool _isLoading = false;
  bool _agreedToTerms = false;

  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  // Step 1: Account Info
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _ownerPhoneController = TextEditingController();
  bool _obscureText = true;

  // Step 2: Store Info
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _selectedCategory = 'Poissonnerie';

  final List<String> _categories = [
    'Poissonnerie',
    'Fruits de mer',
    'Crustacés',
    'Coquillages',
    'Restaurant',
    'Boulangerie',
    'Supermarché',
    'Autre',
  ];

  // Step 3: Business Info
  final TextEditingController _siretController = TextEditingController();
  final TextEditingController _vatController = TextEditingController();
  final TextEditingController _bankController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _ownerNameController.dispose();
    _ownerPhoneController.dispose();
    _storeNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _siretController.dispose();
    _vatController.dispose();
    _bankController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _submitRegistration() async {
    if (!_agreedToTerms) {
      _showErrorSnackBar('Veuillez accepter les conditions générales');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      await credential.user?.updateDisplayName(
        _ownerNameController.text.trim(),
      );

      final userId = credential.user!.uid;
      final now = FieldValue.serverTimestamp();
      await FirebaseFirestore.instance
          .collection('partner_applications')
          .doc(userId)
          .set({
            'userId': userId,
            'status': 'pending_review',
            'ownerName': _ownerNameController.text.trim(),
            'ownerPhone': _ownerPhoneController.text.trim(),
            'email': _emailController.text.trim(),
            'storeName': _storeNameController.text.trim(),
            'category': _selectedCategory,
            'description': _descriptionController.text.trim(),
            'address': _addressController.text.trim(),
            'city': _cityController.text.trim(),
            'storePhone': _phoneController.text.trim(),
            'siret': _siretController.text.trim(),
            'vat': _vatController.text.trim(),
            'iban': _bankController.text.trim(),
            'website': _websiteController.text.trim(),
            'createdAt': now,
            'updatedAt': now,
          });

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'role': 'client',
        'requestedRole': 'partner',
        'partnerApplicationStatus': 'pending_review',
        'name': _ownerNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _ownerPhoneController.text.trim(),
        'createdAt': now,
        'updatedAt': now,
      });

      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Demande vendeur envoyée. Connectez-vous après validation admin.',
          ),
          backgroundColor: Color(0xFF10B981),
        ),
      );

      context.go('/login');
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar(_friendlyAuthError(e.code));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar(
          'Erreur lors de l\'inscription vendeur. Réessayez plus tard.',
        );
      }
    }
  }

  String _friendlyAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Un compte existe déjà avec cet email.';
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'weak-password':
        return 'Le mot de passe est trop faible.';
      case 'network-request-failed':
        return 'Erreur réseau. Vérifiez votre connexion.';
      default:
        return 'Inscription impossible ($code).';
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      return;
    }

    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go('/role-selection');
  }

  void _continue() {
    if (_formKeys[_currentStep].currentState!.validate()) {
      if (_currentStep < 2) {
        setState(() => _currentStep++);
      } else {
        _submitRegistration();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxWidth = media.size.shortestSide >= 600 ? 430.0 : double.infinity;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFEFF4F3),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(36),
              border: Border.all(color: const Color(0xFFB7C0C1), width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  _heroImage,
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                  cacheWidth:
                      (media.size.width * media.devicePixelRatio).round(),
                  filterQuality: FilterQuality.medium,
                ),
                const _TopWash(),
                const _BottomWash(),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxHeight < 780;
                    final horizontalPadding = compact ? 18.0 : 24.0;
                    final topPadding = media.padding.top + (compact ? 10 : 18);
                    final bottomPadding =
                        media.padding.bottom + (compact ? 10 : 16);

                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        topPadding,
                        horizontalPadding,
                        bottomPadding,
                      ),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: _BackButton(onTap: _goBack),
                          ),
                          SizedBox(height: compact ? 2 : 8),
                          Image.asset(
                            _logoAsset,
                            width: compact ? 154 : 190,
                            fit: BoxFit.contain,
                            cacheWidth: compact ? 308 : 380,
                            filterQuality: FilterQuality.high,
                          ),
                          SizedBox(height: compact ? 6 : 12),
                          Text(
                            'Inscription vendeur',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: AppColors.blueBic,
                              fontSize: compact ? 23 : 26,
                              height: 1.08,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0,
                            ),
                          ),
                          SizedBox(height: compact ? 2 : 4),
                          Text(
                            'Publiez vos paniers et gérez vos retraits.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: AppColors.blueBic.withValues(alpha: 0.74),
                              fontSize: compact ? 11.5 : 13,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: compact ? 10 : 16),
                          _StepProgress(currentStep: _currentStep),
                          SizedBox(height: compact ? 10 : 14),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, area) {
                                return SingleChildScrollView(
                                  keyboardDismissBehavior:
                                      ScrollViewKeyboardDismissBehavior.onDrag,
                                  physics: const BouncingScrollPhysics(),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: area.maxHeight,
                                    ),
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: _StepCard(
                                        compact: compact,
                                        child: _buildStepContent(
                                          compact: compact,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: compact ? 8 : 14),
                          Row(
                            children: [
                              if (_currentStep > 0)
                                Expanded(
                                  child: SizedBox(
                                    height: compact ? 48 : 54,
                                    child: OutlinedButton(
                                      onPressed: _goBack,
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Colors.white,
                                        ),
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Retour',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (_currentStep > 0) const SizedBox(width: 12),
                              Expanded(
                                child: ActionButton(
                                  label:
                                      _currentStep == 2
                                          ? 'Envoyer'
                                          : 'Continuer',
                                  onPressed: _continue,
                                  isLoading: _isLoading && _currentStep == 2,
                                  isEnabled: !_isLoading,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: compact ? 8 : 12),
                          GestureDetector(
                            onTap: () => context.go('/login'),
                            child: Text(
                              'Déjà un compte ? Se connecter',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: compact ? 12 : 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent({required bool compact}) {
    switch (_currentStep) {
      case 0:
        return _buildStep1(compact: compact);
      case 1:
        return _buildStep2(compact: compact);
      case 2:
        return _buildStep3(compact: compact);
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1({required bool compact}) {
    final gap = compact ? 9.0 : AppTheme.lg;
    final headingGap = compact ? 5.0 : AppTheme.sm;
    final formGap = compact ? 10.0 : AppTheme.xl;

    return Form(
      key: _formKeys[0],
      child: _CompactFieldTheme(
        compact: compact,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vos informations personnelles', style: _stepTitle(compact)),
            SizedBox(height: headingGap),
            Text(
              'Commençons par vos infos personnelles',
              style: _stepSubtitle(compact),
            ),
            SizedBox(height: formGap),
            TextFormField(
              controller: _ownerNameController,
              decoration: const InputDecoration(
                hintText: 'Nom complet',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) => Validators.validateName(value),
            ),
            SizedBox(height: gap),
            TextFormField(
              controller: _ownerPhoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: 'Téléphone personnel',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (value) => Validators.validatePhone(value),
            ),
            SizedBox(height: gap),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (value) => Validators.validateEmail(value),
            ),
            SizedBox(height: gap),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                hintText: 'Mot de passe',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                ),
              ),
              validator: (value) => Validators.validatePassword(value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2({required bool compact}) {
    final gap = compact ? 7.0 : AppTheme.lg;
    final headingGap = compact ? 5.0 : AppTheme.sm;
    final formGap = compact ? 9.0 : AppTheme.xl;

    return Form(
      key: _formKeys[1],
      child: _CompactFieldTheme(
        compact: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Informations de votre boutique', style: _stepTitle(compact)),
            SizedBox(height: headingGap),
            Text(
              'Dites-nous plus sur votre établissement',
              style: _stepSubtitle(compact),
            ),
            SizedBox(height: formGap),
            TextFormField(
              controller: _storeNameController,
              decoration: const InputDecoration(
                hintText: 'Nom de la boutique',
                prefixIcon: Icon(Icons.store_outlined),
              ),
              validator: (value) => Validators.validateName(value),
            ),
            SizedBox(height: gap),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                hintText: 'Catégorie',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items:
                  _categories
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
              onChanged:
                  (value) => setState(
                    () => _selectedCategory = value ?? _selectedCategory,
                  ),
              validator: (value) => value == null ? 'Catégorie requise' : null,
            ),
            SizedBox(height: gap),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'Description de votre boutique',
                prefixIcon: Icon(Icons.description_outlined),
              ),
              maxLines: 1,
              validator:
                  (value) => Validators.validateRequired(value, 'Description'),
            ),
            SizedBox(height: gap),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                hintText: 'Adresse',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              validator:
                  (value) => Validators.validateRequired(value, 'Adresse'),
            ),
            SizedBox(height: gap),
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                hintText: 'Ville',
                prefixIcon: Icon(Icons.location_city_outlined),
              ),
              validator: (value) => Validators.validateRequired(value, 'Ville'),
            ),
            SizedBox(height: gap),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: 'Téléphone de la boutique',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (value) => Validators.validatePhone(value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3({required bool compact}) {
    final gap = compact ? 8.0 : AppTheme.lg;
    final headingGap = compact ? 5.0 : AppTheme.sm;
    final formGap = compact ? 10.0 : AppTheme.xl;

    return Form(
      key: _formKeys[2],
      child: _CompactFieldTheme(
        compact: compact,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Informations commerciales', style: _stepTitle(compact)),
            SizedBox(height: headingGap),
            Text(
              'Pour finaliser votre inscription',
              style: _stepSubtitle(compact),
            ),
            SizedBox(height: formGap),
            TextFormField(
              controller: _siretController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Numéro SIRET',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              validator: (value) => Validators.validateRequired(value, 'SIRET'),
            ),
            SizedBox(height: gap),
            TextFormField(
              controller: _vatController,
              decoration: const InputDecoration(
                hintText: 'Numéro de TVA',
                prefixIcon: Icon(Icons.receipt_outlined),
              ),
              validator: (value) => Validators.validateRequired(value, 'TVA'),
            ),
            SizedBox(height: gap),
            TextFormField(
              controller: _bankController,
              decoration: const InputDecoration(
                hintText: 'IBAN (compte bancaire)',
                prefixIcon: Icon(Icons.account_balance_outlined),
              ),
              validator: (value) => Validators.validateRequired(value, 'IBAN'),
            ),
            SizedBox(height: gap),
            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(
                hintText: 'Site web (optionnel)',
                prefixIcon: Icon(Icons.language_outlined),
              ),
            ),
            SizedBox(height: compact ? 12 : AppTheme.xl),
            GestureDetector(
              onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color:
                          _agreedToTerms
                              ? AppTheme.primaryColor
                              : Colors.transparent,
                      border: Border.all(
                        color:
                            _agreedToTerms
                                ? AppTheme.primaryColor
                                : Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child:
                        _agreedToTerms
                            ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                            : null,
                  ),
                  const SizedBox(width: AppTheme.md),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'J\'accepte les ',
                        style: AppTextStyles.bodyS,
                        children: [
                          TextSpan(
                            text: 'Conditions Générales',
                            style: AppTextStyles.bodyS.copyWith(
                              color: AppTheme.primaryColor,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
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
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.84),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: const SizedBox(
          width: 46,
          height: 46,
          child: Icon(Icons.arrow_back, color: AppColors.blueBic),
        ),
      ),
    );
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        3,
        (index) => Expanded(
          child: Container(
            height: 5,
            margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
            decoration: BoxDecoration(
              color:
                  index <= currentStep
                      ? AppColors.blueBic
                      : Colors.white.withValues(alpha: 0.58),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.child, required this.compact});

  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 14 : 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: KeyedSubtree(key: ValueKey(child.hashCode), child: child),
      ),
    );
  }
}

class _CompactFieldTheme extends StatelessWidget {
  const _CompactFieldTheme({required this.child, required this.compact});

  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(12);
    final border = OutlineInputBorder(
      borderRadius: radius,
      borderSide: const BorderSide(color: AppTheme.softBorder),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: const BorderSide(color: AppColors.blueBic, width: 1.3),
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: const BorderSide(color: AppTheme.errorColor, width: 1.2),
    );

    return Theme(
      data: theme.copyWith(
        inputDecorationTheme: theme.inputDecorationTheme.copyWith(
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: compact ? 10 : 13,
          ),
          prefixIconColor: AppColors.blueBic,
          suffixIconColor: AppColors.blueBic,
          prefixIconConstraints: BoxConstraints(
            minWidth: compact ? 36 : 42,
            minHeight: compact ? 38 : 44,
          ),
          suffixIconConstraints: BoxConstraints(
            minWidth: compact ? 36 : 42,
            minHeight: compact ? 38 : 44,
          ),
          hintStyle: GoogleFonts.poppins(
            fontSize: compact ? 12.5 : 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF9DAEB1),
          ),
          errorStyle: GoogleFonts.poppins(
            fontSize: compact ? 9 : 10,
            height: .9,
            fontWeight: FontWeight.w600,
          ),
          border: border,
          enabledBorder: border,
          focusedBorder: focusedBorder,
          errorBorder: errorBorder,
          focusedErrorBorder: errorBorder,
        ),
      ),
      child: child,
    );
  }
}

TextStyle _stepTitle(bool compact) {
  return GoogleFonts.poppins(
    fontSize: compact ? 19 : 22,
    height: 1.1,
    fontWeight: FontWeight.w900,
    color: const Color(0xFF142D31),
  );
}

TextStyle _stepSubtitle(bool compact) {
  return GoogleFonts.poppins(
    fontSize: compact ? 11.5 : 13,
    height: 1.22,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF526669),
  );
}

class _TopWash extends StatelessWidget {
  const _TopWash();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [
              Colors.white.withValues(alpha: 0.95),
              Colors.white.withValues(alpha: 0.70),
              Colors.white.withValues(alpha: 0.06),
            ],
            stops: const [0, 0.42, 1],
          ),
        ),
      ),
    );
  }
}

class _BottomWash extends StatelessWidget {
  const _BottomWash();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.center,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              AppColors.blueBic.withValues(alpha: 0.16),
              AppColors.blueBic.withValues(alpha: 0.78),
            ],
            stops: const [0, 0.68, 1],
          ),
        ),
      ),
    );
  }
}
