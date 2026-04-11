import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../models/album.dart';
import '../services/content_api.dart';
import '../theme/app_theme.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key, this.initialAlbum});

  final Album? initialAlbum;

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final _picker = ImagePicker();

  bool _processing = false;
  File? _lastPhoto;
  Album? _selectedAlbum;
  List<Album> _albums = const [];
  bool _loadingAlbums = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _selectedAlbum = widget.initialAlbum;
    _loadAlbums();
  }

  Future<void> _loadAlbums() async {
    try {
      final list = await ContentApi.instance.fetchAlbums();
      if (!mounted) return;
      setState(() {
        _albums = list;
        _loadingAlbums = false;
        _selectedAlbum ??= list.isNotEmpty ? list.first : null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingAlbums = false);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pickFromCamera() => _pickAndMatch(ImageSource.camera);
  Future<void> _pickFromGallery() => _pickAndMatch(ImageSource.gallery);

  Future<void> _pickAndMatch(ImageSource source) async {
    if (_processing) return;
    final album = _selectedAlbum;
    if (album == null) {
      _snack('Primero selecciona un album.');
      return;
    }
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
      final result = await ContentApi.instance.matchAlbumPhoto(
        albumId: album.id,
        photo: _lastPhoto!,
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
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          r.unlocked ? 'Sticker desbloqueado' : 'Sin match',
          style: GoogleFonts.inter(fontWeight: FontWeight.w800),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (r.stickerName != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    r.stickerName!,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              Text(
                r.message.isNotEmpty ? r.message : '—',
                style: GoogleFonts.inter(color: AppTheme.onSurfaceVariant),
              ),
              if (r.carMake != null || r.carModel != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Detectado: ${[r.carMake, r.carModel].where((e) => e != null && e.isNotEmpty).join(' ')}',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppTheme.onSurfaceVariant),
                ),
              ],
              if (r.funFact != null && r.funFact!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  r.funFact!,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppTheme.onSurfaceVariant),
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

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Future<void> _openAlbumPicker() async {
    if (_albums.isEmpty) return;
    final picked = await showModalBottomSheet<Album>(
      context: context,
      backgroundColor: AppTheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _albums.length,
            itemBuilder: (_, i) {
              final a = _albums[i];
              return ListTile(
                title: Text(a.title,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                subtitle: Text(a.theme,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppTheme.onSurfaceVariant)),
                trailing: _selectedAlbum?.id == a.id
                    ? const Icon(Icons.check_rounded, color: AppTheme.primary)
                    : null,
                onTap: () => Navigator.pop(ctx, a),
              );
            },
          ),
        );
      },
    );
    if (picked != null) setState(() => _selectedAlbum = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                'Apunta al carro',
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
                  GestureDetector(
                    onTap: _openAlbumPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.collections_bookmark_rounded,
                              size: 14,
                              color: Colors.white.withValues(alpha: 0.65)),
                          const SizedBox(width: 6),
                          Text(
                            _loadingAlbums
                                ? 'Cargando albums...'
                                : (_selectedAlbum?.title ?? 'Sin albums'),
                            style: GoogleFonts.inter(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: Colors.white.withValues(alpha: 0.65)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _processing
                        ? 'Analizando foto con IA...'
                        : 'Toma una foto y la IA validara el sticker.',
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
                onTap: () => Navigator.pop(context),
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
    );
  }
}
