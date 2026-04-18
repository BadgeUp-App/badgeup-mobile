import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../services/content_api.dart';
import '../services/location_service.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final _picker = ImagePicker();

  bool _processing = false;
  bool _didUnlock = false;
  File? _lastPhoto;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pickFromCamera() => _pickAndScan(ImageSource.camera);
  Future<void> _pickFromGallery() => _pickAndScan(ImageSource.gallery);

  Future<void> _pickAndScan(ImageSource source) async {
    if (_processing) return;
    XFile? picked;
    try {
      picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
    } catch (e) {
      _snack('No se pudo abrir la camara: $e');
      return;
    }
    if (picked == null) return;

    setState(() {
      _processing = true;
      _lastPhoto = File(picked!.path);
    });

    try {
      final position = await LocationService.instance.getCurrentPosition();
      final result = await ContentApi.instance.scanPhoto(
        photo: _lastPhoto!,
        lat: position?.latitude,
        lng: position?.longitude,
      );
      if (!mounted) return;
      _showResult(result);
    } catch (e) {
      if (!mounted) return;
      _snack('Error al analizar la foto: $e');
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  void _showResult(MatchPhotoResult r) {
    if (r.unlocked) {
      SoundService.instance.playUnlockSound();
      HapticFeedback.heavyImpact();
      _didUnlock = true;
      ContentApi.instance.clearCache();
    }

    String title;
    if (r.alreadyUnlocked && r.photoAdded) {
      title = 'Foto agregada';
    } else if (r.unlocked) {
      title = 'Sticker desbloqueado';
    } else {
      title = 'Sin match';
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          title,
          style: GoogleFonts.inter(fontWeight: FontWeight.w800),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (r.stickerName != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    r.stickerName!,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              if (r.alreadyUnlocked && r.photoAdded)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Nueva foto guardada en tu coleccion. Puedes verla en el carrusel del sticker.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ),
              if (r.albumTitle != null && r.unlocked && !r.alreadyUnlocked)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Album: ${r.albumTitle}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ),
              if (r.detectedItem != null && r.detectedItem!.isNotEmpty) ...[
                Text(
                  'Detectado: ${r.detectedItem}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (!r.unlocked && r.detectedItem == null)
                Text(
                  r.message.isNotEmpty ? r.message : '---',
                  style: GoogleFonts.inter(color: AppTheme.onSurfaceVariant),
                ),
              if (r.funFact != null && r.funFact!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  r.funFact!,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppTheme.onSurfaceVariant),
                ),
              ],
              if (!r.unlocked &&
                  r.detectedItem != null &&
                  r.stickerName == null) ...[
                const SizedBox(height: 8),
                Text(
                  r.message,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurface,
                  ),
                ),
              ],
              if (r.matchScore > 0) ...[
                const SizedBox(height: 10),
                Text(
                  'Confianza: ${(r.matchScore * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (r.unlocked && r.stickerId != null && !r.alreadyUnlocked)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showThoughtsDialog(r.stickerId!);
              },
              child: Text(
                'Escribir nota',
                style: GoogleFonts.inter(
                    color: AppTheme.secondary, fontWeight: FontWeight.w700),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cerrar',
              style: GoogleFonts.inter(
                  color: AppTheme.primary, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showThoughtsDialog(int stickerId) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Tus pensamientos',
          style: GoogleFonts.inter(fontWeight: FontWeight.w800),
        ),
        content: TextField(
          controller: controller,
          maxLines: 4,
          maxLength: 280,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Que sentiste al capturar este sticker?',
            hintStyle: GoogleFonts.inter(
                color: AppTheme.onSurfaceVariant, fontSize: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppTheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.primary, width: 2),
            ),
          ),
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Saltar',
                style: GoogleFonts.inter(
                    color: AppTheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text('Guardar',
                style: GoogleFonts.inter(
                    color: AppTheme.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (result == null || result.isEmpty || !mounted) return;
    try {
      await ContentApi.instance.setStickerMessage(
        stickerId: stickerId,
        message: result,
      );
      _snack('Nota guardada');
    } catch (_) {}
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, _didUnlock);
      },
      child: Scaffold(
      backgroundColor: const Color(0xFF0C0E12),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 260,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(
                            alpha: 0.04 + (_pulseController.value * 0.05),
                          ),
                          borderRadius: BorderRadius.circular(24),
                          image: _lastPhoto != null
                              ? DecorationImage(
                                  image: FileImage(_lastPhoto!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: child,
                      );
                    },
                    child: _lastPhoto != null
                        ? const SizedBox.shrink()
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt_outlined,
                                size: 48,
                                color: Colors.white.withValues(alpha: 0.65),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Toma una foto',
                                style: GoogleFonts.inter(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _processing
                        ? 'Analizando foto con IA...'
                        : 'La IA buscara un sticker en todos los albums.',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 12,
              left: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context, _didUnlock),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.close_rounded,
                      size: 22, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 16,
              child: GestureDetector(
                onTap: _processing ? null : _pickFromGallery,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.photo_library_rounded,
                          size: 14, color: AppTheme.tertiaryContainer),
                      const SizedBox(width: 6),
                      Text(
                        'Galeria',
                        style: GoogleFonts.inter(
                          color: AppTheme.tertiaryContainer,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 44,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _processing ? null : _pickFromCamera,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.pastelPeach,
                      ),
                      child: _processing
                          ? const Padding(
                              padding: EdgeInsets.all(18),
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: AppTheme.onPastelPeach,
                              ),
                            )
                          : const Icon(Icons.camera_rounded,
                              color: AppTheme.onPastelPeach, size: 28),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
