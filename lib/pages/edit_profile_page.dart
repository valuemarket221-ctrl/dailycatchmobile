import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:myapp/utils/navigation_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/services/client_api_service.dart';
import 'package:myapp/utils/api_environment.dart';
import 'package:myapp/utils/local_auth_session.dart';
import 'package:myapp/utils/profile_photo_store.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final ClientApiService _clientApiService = ClientApiService();
  bool _isPickingPhoto = false;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    ProfilePhotoStore.load();
    _loadProfile();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final profile = await _clientApiService.getMyProfile();
      await LocalAuthSession.updateProfileSnapshot(
        name: profile.displayName,
        email: profile.email,
        phone: profile.phone ?? '',
      );
      if (!mounted) return;
      setState(() {
        _name.text = profile.displayName;
        _email.text = profile.email;
        _phone.text = profile.phone ?? '';
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      if (ApiEnvironment.isDemoFallbackAllowed) {
        final profile = await LocalAuthSession.profileSnapshot();
        if (!mounted) return;
        setState(() {
          _name.text = profile['name'] ?? '';
          _email.text = profile['email'] ?? '';
          _phone.text = profile['phone'] ?? '';
          _loadError = 'Profil local affiché. API indisponible.';
          _isLoading = false;
        });
        return;
      }
      setState(() {
        _loadError = 'Profil indisponible. Vérifiez votre connexion.';
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final profile = await _clientApiService.updateMyProfile(
        displayName: _name.text,
        email: _email.text,
        phone: _phone.text,
      );
      await LocalAuthSession.updateProfileSnapshot(
        name: profile.displayName,
        email: profile.email,
        phone: profile.phone ?? '',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil mis à jour', style: GoogleFonts.poppins()),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.blueBic,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Impossible d’enregistrer le profil',
            style: GoogleFonts.poppins(),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.blueBic,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _changePhoto() async {
    if (_isPickingPhoto) return;
    setState(() => _isPickingPhoto = true);
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 82,
        maxWidth: 900,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      await ProfilePhotoStore.saveBytes(bytes);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Photo importée', style: GoogleFonts.poppins()),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.blueBic,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Impossible d’ouvrir la galerie',
            style: GoogleFonts.poppins(),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.blueBic,
        ),
      );
    } finally {
      if (mounted) setState(() => _isPickingPhoto = false);
    }
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
                Text('MES INFORMATIONS', style: _header),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 28),
            const _EditableProfileAvatar(),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _isPickingPhoto ? null : _changePhoto,
              child: Text(
                _isPickingPhoto ? 'Ouverture...' : 'Importer une photo',
                style: _link,
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: LinearProgressIndicator(
                  minHeight: 3,
                  color: AppColors.blueBic,
                  backgroundColor: Color(0xFFE8F4F2),
                ),
              ),
            if (_loadError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _loadError!,
                  style: _helper,
                  textAlign: TextAlign.center,
                ),
              ),
            _Input(label: 'Nom complet', controller: _name),
            _Input(label: 'Email', controller: _email),
            _Input(label: 'Téléphone', controller: _phone),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _isSaving || _isLoading ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.blueBic,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isSaving ? 'Enregistrement...' : 'Enregistrer',
                  style: _button,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _EditableProfileAvatar extends StatelessWidget {
  const _EditableProfileAvatar();

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Uint8List?>(
    valueListenable: ProfilePhotoStore.bytes,
    builder:
        (context, bytes, _) => ValueListenableBuilder<String>(
          valueListenable: ProfilePhotoStore.asset,
          builder:
              (context, asset, _) => CircleAvatar(
                radius: 40,
                backgroundImage:
                    bytes == null
                        ? AssetImage(asset) as ImageProvider
                        : MemoryImage(bytes),
                backgroundColor: const Color(0xFFE8F4F2),
              ),
        ),
  );
}

class _Input extends StatelessWidget {
  const _Input({required this.label, required this.controller});
  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: _field,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2EAEA)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2EAEA)),
            ),
          ),
        ),
      ],
    ),
  );
}

final _header = GoogleFonts.poppins(
  fontSize: 15,
  fontWeight: FontWeight.w900,
  color: const Color(0xFF142D31),
);
final _label = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w800,
  color: const Color(0xFF526669),
);
final _field = GoogleFonts.poppins(
  fontSize: 13,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF142D31),
);
final _link = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w900,
  color: AppColors.blueBic,
);
final _helper = GoogleFonts.poppins(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF6D7F82),
);
final _button = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w900,
  color: Colors.white,
);
