import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();

  final _picker = ImagePicker();
  File? _newAvatar;
  String? _currentAvatarUrl;
  bool _removeAvatar = false;

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await ApiClient.instance.get('/auth/profile/');
      if (!mounted) return;
      if (data is Map<String, dynamic>) {
        _firstNameController.text = (data['first_name'] ?? '').toString();
        _lastNameController.text = (data['last_name'] ?? '').toString();
        _emailController.text = (data['email'] ?? '').toString();
        _bioController.text = (data['bio'] ?? '').toString();
        _currentAvatarUrl = data['avatar']?.toString();
      }
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _snack('No se pudo cargar el perfil: $e');
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _selectAvatar() async {
    final hasPhoto = _newAvatar != null ||
        (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty && !_removeAvatar);
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppTheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Text(
                'Cambiar foto de perfil',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              _sheetOption(
                ctx,
                icon: Icons.camera_alt_rounded,
                label: 'Tomar foto',
                value: 'camera',
              ),
              _sheetOption(
                ctx,
                icon: Icons.photo_library_rounded,
                label: 'Elegir de la galeria',
                value: 'gallery',
              ),
              if (hasPhoto)
                _sheetOption(
                  ctx,
                  icon: Icons.delete_outline_rounded,
                  label: 'Quitar foto',
                  value: 'remove',
                  destructive: true,
                ),
            ],
          ),
        ),
      ),
    );
    if (choice == null) return;

    if (choice == 'remove') {
      setState(() {
        _newAvatar = null;
        _removeAvatar = true;
      });
      return;
    }

    try {
      final picked = await _picker.pickImage(
        source: choice == 'camera' ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _newAvatar = File(picked.path);
          _removeAvatar = false;
        });
      }
    } catch (e) {
      _snack('No se pudo abrir la ${choice == 'camera' ? 'camara' : 'galeria'}: $e');
    }
  }

  Widget _sheetOption(
    BuildContext ctx, {
    required IconData icon,
    required String label,
    required String value,
    bool destructive = false,
  }) {
    final color = destructive ? AppTheme.error : AppTheme.onSurface;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pop(ctx, value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 16),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_firstNameController.text.trim().isEmpty) {
      _snack('El nombre es obligatorio');
      return;
    }
    setState(() => _saving = true);
    try {
      await AuthService.instance.updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        bio: _bioController.text.trim(),
        avatar: _newAvatar,
        resetAvatar: _removeAvatar && _newAvatar == null,
      );
      if (!mounted) return;
      _snack('Perfil actualizado');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _snack('Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: AppTheme.subtleLift,
                            ),
                            child: Icon(Icons.arrow_back_ios_new_rounded,
                                size: 18, color: AppTheme.onSurface),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Editar perfil',
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: AppTheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Center(
                      child: GestureDetector(
                        onTap: _selectAvatar,
                        child: Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    AppTheme.secondaryContainer,
                                    AppTheme.pastelPeach,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                image: _newAvatar != null
                                    ? DecorationImage(
                                        image: FileImage(_newAvatar!),
                                        fit: BoxFit.cover,
                                      )
                                    : (!_removeAvatar &&
                                            _currentAvatarUrl != null &&
                                            _currentAvatarUrl!.isNotEmpty)
                                        ? DecorationImage(
                                            image: NetworkImage(
                                                _currentAvatarUrl!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                              ),
                              child: (_newAvatar == null &&
                                      (_removeAvatar ||
                                          _currentAvatarUrl == null ||
                                          _currentAvatarUrl!.isEmpty))
                                  ? Center(
                                      child: Text(
                                        _firstNameController.text.isNotEmpty
                                            ? _firstNameController.text[0]
                                                .toUpperCase()
                                            : '?',
                                        style: GoogleFonts.inter(
                                          fontSize: 42,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.onSurface,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.pastelPeach,
                                  boxShadow: AppTheme.subtleLift,
                                  border: Border.all(
                                    color: AppTheme.surface,
                                    width: 3,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 16,
                                  color: AppTheme.onPastelPeach,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        'Toca para cambiar foto',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _label('Nombre *'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _firstNameController,
                      style: GoogleFonts.inter(color: AppTheme.onSurface),
                      decoration:
                          const InputDecoration(hintText: 'Tu nombre'),
                    ),
                    const SizedBox(height: 20),
                    _label('Apellido'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _lastNameController,
                      style: GoogleFonts.inter(color: AppTheme.onSurface),
                      decoration:
                          const InputDecoration(hintText: 'Tu apellido'),
                    ),
                    const SizedBox(height: 20),
                    _label('Correo'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.inter(color: AppTheme.onSurface),
                      decoration:
                          const InputDecoration(hintText: 'tucorreo@mail.com'),
                    ),
                    const SizedBox(height: 20),
                    _label('Biografia'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _bioController,
                      maxLines: 3,
                      style: GoogleFonts.inter(color: AppTheme.onSurface),
                      decoration: const InputDecoration(
                          hintText: 'Cuentanos algo de ti...'),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap:
                                _saving ? null : () => Navigator.pop(context),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 18),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Center(
                                child: Text(
                                  'Cancelar',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: _saving ? null : _save,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 18),
                              decoration: BoxDecoration(
                                color: AppTheme.pastelPeach,
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: AppTheme.subtleLift,
                              ),
                              child: Center(
                                child: _saving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppTheme.onPastelPeach,
                                        ),
                                      )
                                    : Text(
                                        'Guardar cambios',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.onPastelPeach,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppTheme.onSurfaceVariant,
        letterSpacing: 0.4,
      ),
    );
  }
}
