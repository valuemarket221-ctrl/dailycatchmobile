import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/utils/profile_photo_store.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _name = TextEditingController(text: 'Amadou Fall');
  final _email = TextEditingController(text: 'amadou.fall@email.sn');
  final _phone = TextEditingController(text: '+221 77 123 45 67');
  final ImagePicker _imagePicker = ImagePicker();
  bool _isPickingPhoto = false;

  @override
  void initState() {
    super.initState();
    ProfilePhotoStore.load();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profil mis à jour', style: GoogleFonts.poppins()),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.blueBic,
      ),
    );
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
                  onPressed: () => context.pop(),
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
            _Input(label: 'Nom complet', controller: _name),
            _Input(label: 'Email', controller: _email),
            _Input(label: 'Téléphone', controller: _phone),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.blueBic,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Enregistrer', style: _button),
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
final _button = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w900,
  color: Colors.white,
);
