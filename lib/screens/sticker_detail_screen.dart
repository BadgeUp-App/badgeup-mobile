import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/sticker.dart';
import '../theme/app_theme.dart';

class StickerDetailScreen extends StatelessWidget {
  final Sticker sticker;

  const StickerDetailScreen({super.key, required this.sticker});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _TopBar()),
                SliverToBoxAdapter(child: _HeroStickerPanel(sticker: sticker)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                    child: Column(
                      children: [
                        Text(
                          'SERIE COLECCIONABLE N. ${sticker.id.toString().padLeft(3, '0')}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.0,
                            color: AppTheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          sticker.name,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.6,
                            color: AppTheme.onSurface,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          sticker.description,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppTheme.onSurfaceVariant,
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                    child: Row(
                      children: const [
                        Expanded(
                          child: _SpecTile(
                            icon: Icons.speed_rounded,
                            iconColor: AppTheme.secondary,
                            iconBg: AppTheme.secondaryContainer,
                            label: 'VEL. MAX',
                            value: '293 km/h',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _SpecTile(
                            icon: Icons.timer_rounded,
                            iconColor: AppTheme.tertiary,
                            iconBg: AppTheme.tertiaryContainer,
                            label: '0-100 KM/H',
                            value: '4.2s',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _SpecTile(
                            icon: Icons.bolt_rounded,
                            iconColor: AppTheme.primaryContainer,
                            iconBg: Color(0x33007AFF),
                            label: 'POTENCIA',
                            value: '385 HP',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: _DatoCuriosoCard(text: sticker.description),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 12),
                      child: Text(
                        'DETALLES TECNICOS',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                    child: _TechnicalTable(
                      rows: [
                        _TechRow(
                          icon: Icons.settings_rounded,
                          label: 'Motor',
                          value: 'Boxer trasero',
                        ),
                        const _TechRow(
                          icon: Icons.sync_alt_rounded,
                          label: 'Transmision',
                          value: '8 vel. PDK',
                        ),
                        _TechRow(
                          icon: Icons.local_gas_station_rounded,
                          label: 'Consumo',
                          value: '9.4 l/100km',
                        ),
                        if (sticker.captureLocation != null)
                          _TechRow(
                            icon: Icons.place_rounded,
                            label: 'Ubicacion',
                            value: sticker.captureLocation!,
                          ),
                        if (sticker.captureDate != null)
                          _TechRow(
                            icon: Icons.calendar_today_rounded,
                            label: 'Capturado',
                            value: sticker.captureDate!,
                          ),
                        _TechRow(
                          icon: Icons.workspace_premium_rounded,
                          label: 'Puntos',
                          value: '${sticker.points} pts',
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 160)),
              ],
            ),
          ),
          _FloatingActionTray(sticker: sticker),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
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
              child: Icon(Icons.close_rounded,
                  color: AppTheme.onSurface, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Overview',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: AppTheme.onSurface,
            ),
          ),
          const Spacer(),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppTheme.subtleLift,
            ),
            child: Icon(Icons.ios_share_rounded,
                color: AppTheme.onSurface, size: 18),
          ),
        ],
      ),
    );
  }
}

class _HeroStickerPanel extends StatelessWidget {
  const _HeroStickerPanel({required this.sticker});
  final Sticker sticker;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF6D9FF),
                  Color(0xFFE9FFE5),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -60,
                  right: -60,
                  child: IgnorePointer(
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          color: AppTheme.secondary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Hero(
                    tag: 'sticker_${sticker.id}',
                    child: CachedNetworkImage(
                      imageUrl: sticker.imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const SizedBox.shrink(),
                      errorWidget: (_, __, ___) => Icon(
                        Icons.directions_car_rounded,
                        size: 80,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 18,
                  right: 18,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.workspace_premium_rounded,
                                color: AppTheme.secondary, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              _rarityLabel(sticker.rarity),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.6,
                                color: AppTheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  String _rarityLabel(Rarity r) {
    switch (r) {
      case Rarity.legendario:
        return 'LEGENDARY';
      case Rarity.epico:
        return 'EPIC';
      case Rarity.raro:
        return 'RARE';
      case Rarity.comun:
        return 'COMMON';
    }
  }
}

class _SpecTile extends StatelessWidget {
  const _SpecTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppTheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _DatoCuriosoCard extends StatelessWidget {
  const _DatoCuriosoCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.surfaceContainerHighest.withValues(alpha: 0.9),
                Colors.white.withValues(alpha: 0.55),
              ],
            ),
            border: Border.all(
              color: AppTheme.outlineVariant.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lightbulb_rounded,
                    color: AppTheme.secondary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dato curioso',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      text,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.onSurfaceVariant,
                        height: 1.55,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TechnicalTable extends StatelessWidget {
  const _TechnicalTable({required this.rows});
  final List<_TechRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++)
            Container(
              color: i.isEven
                  ? AppTheme.surfaceContainerLow.withValues(alpha: 0.5)
                  : AppTheme.surfaceContainerLowest,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  Icon(rows[i].icon,
                      size: 18, color: AppTheme.onSurfaceVariant),
                  const SizedBox(width: 14),
                  Text(
                    rows[i].label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    rows[i].value,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TechRow {
  final IconData icon;
  final String label;
  final String value;
  const _TechRow({required this.icon, required this.label, required this.value});
}

class _FloatingActionTray extends StatelessWidget {
  const _FloatingActionTray({required this.sticker});
  final Sticker sticker;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 24,
      right: 24,
      bottom: 28,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppTheme.outlineVariant.withValues(alpha: 0.15),
              ),
              boxShadow: AppTheme.softShadow,
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${sticker.points} pts',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    Text(
                      'BadgeUp',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppTheme.onSurface,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        content: Text(
                          'Sticker guardado en el album',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.pastelPeach,
                          Color(0xFFFBCFE8),
                        ],
                      ),
                      boxShadow: AppTheme.subtleLift,
                    ),
                    child: Text(
                      'Anadir al album',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.onPastelPeach,
                      ),
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
