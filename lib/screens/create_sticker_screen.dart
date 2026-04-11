import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../models/album.dart';
import '../services/content_api.dart';
import '../theme/app_theme.dart';

class CreateStickerScreen extends StatefulWidget {
  const CreateStickerScreen({super.key, this.initialAlbum});

  final Album? initialAlbum;

  @override
  State<CreateStickerScreen> createState() => _CreateStickerScreenState();
}

class _CreateStickerScreenState extends State<CreateStickerScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _pointsController = TextEditingController(text: '10');
  final _orderController = TextEditingController(text: '1');
  String _selectedRarity = 'comun';

  final _picker = ImagePicker();
  File? _pickedImage;

  List<Album> _albums = const [];
  Album? _selectedAlbum;
  bool _loadingAlbums = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
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
    _nameController.dispose();
    _descController.dispose();
    _pointsController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (picked != null) setState(() => _pickedImage = File(picked.path));
    } catch (e) {
      _snack('No se pudo abrir la galeria: $e');
    }
  }

  Future<void> _createSticker() async {
    if (_nameController.text.trim().isEmpty) {
      _snack('El nombre es obligatorio');
      return;
    }
    final album = _selectedAlbum;
    if (album == null) {
      _snack('Selecciona un album para este sticker');
      return;
    }
    setState(() => _submitting = true);
    try {
      await ContentApi.instance.createSticker(
        albumId: album.id,
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        rarity: _selectedRarity,
        points: int.tryParse(_pointsController.text.trim()) ?? 0,
        order: int.tryParse(_orderController.text.trim()) ?? 0,
        image: _pickedImage,
      );
      if (!mounted) return;
      _snack('Sticker creado');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _snack('Error al crear sticker: $e');
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

  Future<void> _openAlbumPicker() async {
    if (_loadingAlbums) {
      await _loadAlbums();
    }
    if (!mounted) return;
    if (_albums.isEmpty) {
      _snack('No hay albums disponibles. Crea uno primero.');
      return;
    }
    final picked = await showModalBottomSheet<Album>(
      context: context,
      backgroundColor: AppTheme.surfaceContainerLowest,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text(
                      'Selecciona un album',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: AppTheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                  itemCount: _albums.length,
                  itemBuilder: (_, i) {
                    final a = _albums[i];
                    final selected = _selectedAlbum?.id == a.id;
                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Navigator.pop(ctx, a),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppTheme.pastelPeach.withValues(alpha: 0.35)
                              : AppTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a.title,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.onSurface,
                                    ),
                                  ),
                                  if (a.theme.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      a.theme,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: AppTheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (selected)
                              const Icon(Icons.check_rounded,
                                  size: 18, color: AppTheme.primary),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) setState(() => _selectedAlbum = picked);
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
                    'Nuevo sticker',
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
              const SizedBox(height: 28),
              _label('Album *'),
              const SizedBox(height: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _openAlbumPicker,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 18),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _loadingAlbums
                                ? 'Cargando albums...'
                                : (_selectedAlbum?.title ??
                                    'Toca para seleccionar'),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _selectedAlbum == null
                                  ? AppTheme.onSurfaceVariant
                                  : AppTheme.onSurface,
                            ),
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down_rounded,
                            color: AppTheme.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _label('Nombre *'),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: GoogleFonts.inter(color: AppTheme.onSurface),
                decoration:
                    const InputDecoration(hintText: 'Ej: Porsche 911 GT3'),
              ),
              const SizedBox(height: 20),
              _label('Descripcion'),
              const SizedBox(height: 8),
              TextField(
                controller: _descController,
                maxLines: 3,
                style: GoogleFonts.inter(color: AppTheme.onSurface),
                decoration: const InputDecoration(
                    hintText: 'Descripcion del sticker...'),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Puntos'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _pointsController,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.inter(color: AppTheme.onSurface),
                          decoration: const InputDecoration(hintText: '0'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Rareza'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedRarity,
                              isExpanded: true,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppTheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: 'comun', child: Text('comun')),
                                DropdownMenuItem(
                                    value: 'raro', child: Text('raro')),
                                DropdownMenuItem(
                                    value: 'epico', child: Text('epico')),
                                DropdownMenuItem(
                                    value: 'legendario',
                                    child: Text('legendario')),
                              ],
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() => _selectedRarity = v);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _label('Orden'),
              const SizedBox(height: 8),
              TextField(
                controller: _orderController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.inter(color: AppTheme.onSurface),
                decoration: const InputDecoration(hintText: '1'),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _selectImage,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                    image: _pickedImage != null
                        ? DecorationImage(
                            image: FileImage(_pickedImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _pickedImage != null
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
                              child: const Icon(Icons.camera_alt_outlined,
                                  size: 24, color: AppTheme.primary),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Toca para seleccionar imagen',
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
                      onTap: _submitting ? null : _createSticker,
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
                                  'Crear sticker',
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
