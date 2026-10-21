import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/demo/demo_mode.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/utils/navigation_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/services/auth_api_service.dart';
import 'package:myapp/services/backend_api_client.dart';
import 'package:myapp/styles/app_theme.dart';
import 'package:myapp/utils/api_error_messages.dart';
import 'package:myapp/utils/local_auth_session.dart';
import 'package:myapp/utils/validators.dart';

class RegisterClientPage extends StatefulWidget {
  const RegisterClientPage({super.key});

  @override
  State<RegisterClientPage> createState() => _RegisterClientPageState();
}

class _RegisterClientPageState extends State<RegisterClientPage> {
  static const _heroImage =
      'assets/images/ChatGPT Image 12 août 2026, 16_27_47.png';
  static const _logoAsset = 'assets/images/logo.png';

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _obscureText = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_agreedToTerms) {
      _showErrorSnackBar('Veuillez accepter les conditions générales.');
      return;
    }

    try {
      setState(() => _isLoading = true);
      if (DemoMode.enabled) {
        final route = await LocalAuthSession.registerDemo(
          email: _emailController.text,
          password: _passwordController.text,
          name: _nameController.text,
          role: 'client',
        );
        if (mounted) context.go(route);
        return;
      }
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      await credential.user?.updateDisplayName(_nameController.text.trim());
      await credential.user?.getIdToken(true);
      final session = await AuthApiService().registerClient(
        displayName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      await LocalAuthSession.saveBackendSession(
        user: session.user,
        homeRoute: session.homeRoute,
      );
      if (!mounted) return;
      context.go(session.homeRoute);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(_friendlyAuthError(e.code));
    } on BackendApiException catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(ApiErrorMessages.fromCode(e.code));
    } catch (_) {
      if (!mounted) return;
      _showErrorSnackBar('Erreur lors de l’inscription. Réessayez plus tard.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyAuthError(String code) {
    return switch (code) {
      'email-already-in-use' => 'Un compte existe déjà avec cet email.',
      'invalid-email' => 'Adresse email invalide.',
      'weak-password' => 'Le mot de passe est trop faible.',
      'network-request-failed' => 'Erreur réseau. Vérifiez votre connexion.',
      _ => 'Inscription impossible ($code).',
    };
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

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxWidth = media.size.shortestSide >= 600 ? 430.0 : double.infinity;

    return Scaffold(
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
                SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    media.padding.top + 24,
                    24,
                    media.padding.bottom + 18,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          media.size.height - media.padding.vertical - 56,
                    ),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _BackButton(
                            onTap:
                                () =>
                                    context.canPop()
                                        ? safePop(context)
                                        : context.go('/role-selection'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Image.asset(
                          _logoAsset,
                          width: 204,
                          fit: BoxFit.contain,
                          cacheWidth: 408,
                          filterQuality: FilterQuality.high,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Créer un compte',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: AppColors.blueBic,
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                        Text(
                          'Réservez les meilleurs paniers frais près de vous.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: AppColors.blueBic.withValues(alpha: 0.74),
                            fontSize: 13,
                            height: 1.35,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 22),
                        _ClientFormPanel(
                          formKey: _formKey,
                          nameController: _nameController,
                          emailController: _emailController,
                          phoneController: _phoneController,
                          passwordController: _passwordController,
                          obscureText: _obscureText,
                          agreedToTerms: _agreedToTerms,
                          isLoading: _isLoading,
                          onTogglePassword:
                              () =>
                                  setState(() => _obscureText = !_obscureText),
                          onToggleTerms:
                              () => setState(
                                () => _agreedToTerms = !_agreedToTerms,
                              ),
                          onSubmit: _register,
                        ),
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: Text(
                            'Déjà un compte ? Se connecter',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ClientFormPanel extends StatelessWidget {
  const _ClientFormPanel({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.obscureText,
    required this.agreedToTerms,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onToggleTerms,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final bool obscureText;
  final bool agreedToTerms;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleTerms;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Form(
        key: formKey,
        child: Column(
          children: [
            _AuthField(
              controller: nameController,
              hint: 'Nom complet',
              icon: Icons.person_outline,
              validator: Validators.validateName,
            ),
            const SizedBox(height: 12),
            _AuthField(
              controller: emailController,
              hint: 'Adresse email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
            ),
            const SizedBox(height: 12),
            _AuthField(
              controller: phoneController,
              hint: 'Téléphone',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: Validators.validatePhone,
            ),
            const SizedBox(height: 12),
            _AuthField(
              controller: passwordController,
              hint: 'Mot de passe',
              icon: Icons.lock_outline,
              obscureText: obscureText,
              suffix: IconButton(
                onPressed: onTogglePassword,
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.blueBic.withValues(alpha: 0.62),
                ),
              ),
              validator: Validators.validatePassword,
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: onToggleTerms,
              borderRadius: BorderRadius.circular(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: agreedToTerms ? AppColors.blueBic : Colors.white,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: AppColors.blueBic),
                    ),
                    child:
                        agreedToTerms
                            ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 16,
                            )
                            : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'J’accepte les conditions générales et la politique de confidentialité.',
                      style: GoogleFonts.poppins(
                        color: AppColors.blueBic.withValues(alpha: 0.70),
                        fontSize: 11.5,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: isLoading ? null : onSubmit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.blueBic,
                  disabledBackgroundColor: AppColors.blueBic.withValues(
                    alpha: 0.55,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child:
                    isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : Text(
                          'Créer mon compte',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: GoogleFonts.poppins(
        color: AppColors.blueBic,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.blueBic),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF7FAFA),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE2EAEB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE2EAEB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.blueBic, width: 1.4),
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
