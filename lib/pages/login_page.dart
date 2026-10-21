import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/widgets/dailycatch_wordmark.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/services/auth_api_service.dart';
import 'package:myapp/services/backend_api_client.dart';
import 'package:myapp/styles/app_theme.dart';
import 'package:myapp/utils/api_error_messages.dart';
import 'package:myapp/utils/local_auth_session.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const _heroImage =
      'assets/images/ChatGPT Image 12 août 2026, 16_27_47.png';

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _validateAndSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      final localRoute = await LocalAuthSession.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (localRoute != null) {
        if (!mounted) return;
        context.go(localRoute);
        return;
      }

      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await credential.user?.getIdToken(true);
      final session = await AuthApiService().getCurrentSession();
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
    } on LocalAuthException catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(e.message);
    } catch (_) {
      if (!mounted) return;
      _showErrorSnackBar('Connexion impossible pour le moment.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyAuthError(String code) {
    return switch (code) {
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' => 'Email ou mot de passe incorrect.',
      'invalid-email' => 'Adresse email invalide.',
      'user-disabled' => 'Ce compte a été désactivé.',
      'network-request-failed' => 'Erreur réseau. Vérifiez votre connexion.',
      'too-many-requests' => 'Trop de tentatives. Réessayez plus tard.',
      _ => 'Connexion impossible ($code).',
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            _heroImage,
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
            excludeFromSemantics: true,
          ),
          const ColoredBox(color: Color(0xEFFFFFFF)),
          SafeArea(
            child: LayoutBuilder(
              builder:
                  (context, constraints) => SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 32,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const DailyCatchWordmark(),
                                const SizedBox(height: 32),
                                Text(
                                  'Connexion',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: AppColors.blueBic,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Retrouvez vos paniers frais.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: AppColors.blueBic.withValues(
                                      alpha: 0.76,
                                    ),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                _LoginPanel(
                                  formKey: _formKey,
                                  emailController: _emailController,
                                  passwordController: _passwordController,
                                  obscureText: _obscureText,
                                  isLoading: _isLoading,
                                  onTogglePassword:
                                      () => setState(
                                        () => _obscureText = !_obscureText,
                                      ),
                                  onSubmit: _validateAndSubmit,
                                ),
                                const SizedBox(height: 20),
                                TextButton(
                                  onPressed:
                                      _isLoading
                                          ? null
                                          : () => context.go('/role-selection'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.blueBic,
                                    minimumSize: const Size(48, 48),
                                  ),
                                  child: const Text('Créer un compte'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginPanel extends StatelessWidget {
  const _LoginPanel({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscureText,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscureText;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Form(
        key: formKey,
        child: Column(
          children: [
            _AuthField(
              controller: emailController,
              hint: 'Adresse email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Email requis';
                if (!text.contains('@')) return 'Email invalide';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _AuthField(
              controller: passwordController,
              hint: 'Mot de passe',
              icon: Icons.lock_outline,
              obscureText: obscureText,
              suffix: IconButton(
                tooltip:
                    obscureText
                        ? 'Afficher le mot de passe'
                        : 'Masquer le mot de passe',
                onPressed: onTogglePassword,
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.blueBic.withValues(alpha: 0.62),
                ),
              ),
              validator: (value) {
                if ((value ?? '').isEmpty) return 'Mot de passe requis';
                return null;
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.go('/forgot-password'),
                child: Text(
                  'Mot de passe oublié ?',
                  style: GoogleFonts.poppins(
                    color: AppColors.blueBic,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
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
                          'Se connecter',
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
