import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../services/content_api.dart';
import '../theme/app_theme.dart';

class CreateAlbumScreen extends StatefulWidget {
  const CreateAlbumScreen({super.key});

  @override
  State<CreateAlbumScreen> createState() => _CreateAlbumScreenState();
}

class _CreateAlbumScreenState extends State<CreateAlbumScreen> {
  final _titleController = TextEditingController();
  final _themeController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isPremium = false;

  final _picker = ImagePicker();
  File? _cover;
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _themeController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectCover() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 85,
      );
      if (picked != null) setState(() => _cover = File(picked.path));
    } catch (e) {
      _snack('No se pudo abrir la galeria: $e');
    }
  }

  Future<void> _createAlbum() async {
    if (_titleController.text.trim().isEmpty) {
      _snack('El titulo es obligatorio');
      return;
    }
    setState(() => _submitting = true);
    try {
      double? price;
      final rawPrice = _priceController.text.trim();
      if (rawPrice.isNotEmpty) {
        price = double.tryParse(rawPrice);
      }
      await ContentApi.instance.createAlbum(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        theme: _themeController.text.trim(),
        isPremium: _isPremium,
        price: price,
        coverImage: _cover,
      );
      if (!mounted) return;
      _snack('Album creado');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _snack('Error al crear album: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
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
        child: SingleChildScrollView(
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
                    'Nuevo album',
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
              Text(
                'Crear',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.9,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Arma una nueva coleccion para que la comunidad la complete.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),
              _label('Titulo *'),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                style: GoogleFonts.inter(color: AppTheme.onSurface),
                decoration: const InputDecoration(
                    hintText: 'Ej: Clasicos europeos'),
              ),
              const SizedBox(height: 20),
              _label('Tema'),
              const SizedBox(height: 8),
              TextField(
                controller: _themeController,
                style: GoogleFonts.inter(color: AppTheme.onSurface),
                decoration:
                    const InputDecoration(hintText: 'Ej: Deportivos, SUVs...'),
              ),
              const SizedBox(height: 20),
              _label('Descripcion'),
              const SizedBox(height: 8),
              TextField(
                controller: _descController,
                maxLines: 3,
                style: GoogleFonts.inter(color: AppTheme.onSurface),
                decoration: const InputDecoration(
                    hintText: 'De que trata este album...'),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isPremium = !_isPremium),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 18),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: _isPremium
                                    ? AppTheme.pastelPeach
                                    : AppTheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _isPremium
                                  ? const Icon(Icons.check_rounded,
                                      size: 16,
                                      color: AppTheme.onPastelPeach)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Premium',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      enabled: _isPremium,
                      style: GoogleFonts.inter(
                        color: _isPremium
                            ? AppTheme.onSurface
                            : AppTheme.onSurfaceVariant,
                      ),
                      decoration: const InputDecoration(hintText: '0.00'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _selectCover,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                    image: _cover != null
                        ? DecorationImage(
                            image: FileImage(_cover!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _cover != null
                      ? null
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.surfaceContainerLowest,
                              ),
                              child: const Icon(Icons.image_outlined,
                                  size: 24, color: AppTheme.primary),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Seleccionar portada',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap:
                          _submitting ? null : () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
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
                      onTap: _submitting ? null : _createAlbum,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: AppTheme.pastelPeach,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: AppTheme.subtleLift,
                        ),
                        child: Center(
                          child: _submitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.onPastelPeach,
                                  ),
                                )
                              : Text(
                                  'Crear album',
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
