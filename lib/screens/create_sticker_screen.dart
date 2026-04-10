import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class CreateStickerScreen extends StatefulWidget {
  const CreateStickerScreen({super.key});

  @override
  State<CreateStickerScreen> createState() => _CreateStickerScreenState();
}

class _CreateStickerScreenState extends State<CreateStickerScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _pointsController = TextEditingController();
  final _orderController = TextEditingController(text: '1');
  String _selectedRarity = 'comun';

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _pointsController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  void _selectImage() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text('Seleccionar imagen',
            style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        content: Text(
          'Se abrira la galeria para seleccionar la imagen del sticker. Funcionalidad pendiente.',
          style: GoogleFonts.inter(color: AppTheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Entendido',
                style: GoogleFonts.inter(
                    color: AppTheme.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _createSticker() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('El nombre es obligatorio'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text('Crear sticker',
            style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        content: Text(
          'Se creara "${_nameController.text}" y se agregara al album. Funcionalidad pendiente.',
          style: GoogleFonts.inter(color: AppTheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Entendido',
                style: GoogleFonts.inter(
                    color: AppTheme.primary, fontWeight: FontWeight.w700)),
          ),
        ],
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
              _label('Nombre *'),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: GoogleFonts.inter(color: AppTheme.onSurface),
                decoration: const InputDecoration(hintText: 'Ej: Porsche 911 GT3'),
              ),
              const SizedBox(height: 20),
              _label('Descripcion'),
              const SizedBox(height: 8),
              TextField(
                controller: _descController,
                maxLines: 3,
                style: GoogleFonts.inter(color: AppTheme.onSurface),
                decoration: const InputDecoration(hintText: 'Descripcion del sticker...'),
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
                                DropdownMenuItem(value: 'comun', child: Text('comun')),
                                DropdownMenuItem(value: 'raro', child: Text('raro')),
                                DropdownMenuItem(value: 'epico', child: Text('epico')),
                                DropdownMenuItem(value: 'legendario', child: Text('legendario')),
                              ],
                              onChanged: (v) {
                                if (v != null) setState(() => _selectedRarity = v);
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
                  ),
                  child: Column(
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
                      onTap: () => Navigator.pop(context),
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
                      onTap: _createSticker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: AppTheme.pastelPeach,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: AppTheme.subtleLift,
                        ),
                        child: Center(
                          child: Text(
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
