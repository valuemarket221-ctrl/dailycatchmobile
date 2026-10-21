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
                    media.padding.top + 34,
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
                        const DailyCatchWordmark(),
                        const SizedBox(height: 12),
                        Text(
                          'Connexion',
                          style: GoogleFonts.poppins(
                            color: AppColors.blueBic,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                        Text(
                          'Retrouvez vos paniers frais.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: AppColors.blueBic.withValues(alpha: 0.76),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 34),
                        _LoginPanel(
                          formKey: _formKey,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          obscureText: _obscureText,
                          isLoading: _isLoading,
                          onTogglePassword:
                              () =>
                                  setState(() => _obscureText = !_obscureText),
                          onSubmit: _validateAndSubmit,
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => context.go('/role-selection'),
                          child: Text(
                            'Créer un compte',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
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
