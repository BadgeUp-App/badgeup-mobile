import 'dart:math' as math;
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/album.dart';
import '../models/sticker.dart';
import '../services/content_api.dart';
import '../services/user_session.dart';
import '../theme/app_theme.dart';
import 'edit_album_screen.dart';
import 'sticker_detail_screen.dart';

class AlbumDetailScreen extends StatefulWidget {
  final Album album;

  const AlbumDetailScreen({super.key, required this.album});

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  late Album album;
  bool _loadingStickers = false;

  @override
  void initState() {
    super.initState();
    final cached = ContentApi.instance.getCachedDetail(widget.album.id);
    if (cached != null && cached.stickers.isNotEmpty) {
      album = cached;
      _loadingStickers = false;
      _refreshInBackground();
    } else {
      album = widget.album;
      _loadDetail();
    }
  }

  Future<void> _refreshInBackground() async {
    try {
      final full = await ContentApi.instance
          .fetchAlbumDetail(album.id, forceRefresh: true);
      if (mounted) setState(() => album = full);
    } catch (_) {}
  }

  Future<void> _loadDetail() async {
    setState(() => _loadingStickers = true);
    try {
      final full = await ContentApi.instance.fetchAlbumDetail(album.id);
      if (mounted) {
        setState(() {
          album = full;
          _loadingStickers = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingStickers = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Stack(
        children: [
          Positioned(
            top: -160,
            right: -140,
            child: IgnorePointer(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                child: Container(
                  width: 380,
                  height: 380,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 80,
            left: -120,
            child: IgnorePointer(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    color: AppTheme.tertiaryContainer.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _TopBar(
                    canEdit: UserSession.instance.user?.isStaff == true,
                    onEdit: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EditAlbumScreen(album: album)),
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: _EditorialHeader(album: album)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 18),
                    child: Row(
                      children: [
                        Text(
                          'Tus figuritas',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const Spacer(),
                        if (album.theme.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              album.theme,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (_loadingStickers)
                  const SliverPadding(
                    padding: EdgeInsets.only(top: 40, bottom: 140),
                    sliver: SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                else if (album.stickers.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 30, bottom: 140),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          'Este album aun no tiene figuritas.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 140),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.68,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final sticker = album.stickers[index];
                          return _GridStickerTile(
                            sticker: sticker,
                            onTap: sticker.unlocked
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => StickerDetailScreen(sticker: sticker),
                                      ),
                                    );
                                  }
                                : null,
                          );
                        },
                        childCount: album.stickers.length,
                      ),
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

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onEdit, required this.canEdit});
  final VoidCallback onEdit;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
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
              child: Icon(Icons.arrow_back_rounded,
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
          if (canEdit)
            GestureDetector(
              onTap: onEdit,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppTheme.subtleLift,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.edit_rounded,
                        color: AppTheme.primary, size: 15),
                    const SizedBox(width: 6),
                    Text(
                      'Editar',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EditorialHeader extends StatelessWidget {
  const _EditorialHeader({required this.album});
  final Album album;

  @override
  Widget build(BuildContext context) {
    final unlocked = album.unlockedCount;
    final total = album.totalCount;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Transform.rotate(
              angle: -math.pi / 80,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: AppTheme.softShadow,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: album.coverUrl,
                    width: 180,
                    height: 240,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 180,
                      height: 240,
                      color: AppTheme.surfaceContainerHigh,
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 180,
                      height: 240,
                      color: AppTheme.surfaceContainerHigh,
                      child: Icon(Icons.collections_rounded,
                          size: 48, color: AppTheme.onSurfaceVariant),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: Text(
              'EDICION DE COLECCIONISTA',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
                color: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              album.title,
              style: GoogleFonts.inter(
                fontSize: 44,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.8,
                color: AppTheme.onSurface,
                height: 1.05,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              album.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Text(
                'Progreso de la coleccion',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                '$unlocked / $total',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(999),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: album.progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.tertiary, AppTheme.tertiaryContainer],
                  ),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.tertiaryContainer.withValues(alpha: 0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridStickerTile extends StatelessWidget {
  const _GridStickerTile({required this.sticker, required this.onTap});
  final Sticker sticker;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = _rarityAccent(sticker.rarity);
    final idLabel = '#${sticker.id.toString().padLeft(3, '0')}';

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: sticker.unlocked
                ? Stack(
                    children: [
                      Positioned.fill(
                        child: CachedNetworkImage(
                          imageUrl: sticker.imageUrl,
                          fit: BoxFit.contain,
                          placeholder: (_, __) => const SizedBox.shrink(),
                          errorWidget: (_, __, ___) => Icon(
                              Icons.emoji_events_rounded,
                              color: AppTheme.onSurfaceVariant, size: 28),
                        ),
                      ),
                      Positioned(
                        left: 4,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            idLabel,
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: _onAccent(sticker.rarity),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            color: AppTheme.surfaceContainerHigh
                                .withValues(alpha: 0.4),
                            child: Center(
                              child: Icon(Icons.lock_rounded,
                                  size: 28, color: AppTheme.outlineVariant),
                            ),
                          ),
                          Positioned(
                            left: 6,
                            bottom: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.onSurfaceVariant
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                idLabel,
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.onSurfaceVariant
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            sticker.unlocked ? sticker.name : 'Bloqueado',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: sticker.unlocked ? FontWeight.w700 : FontWeight.w500,
              color: sticker.unlocked
                  ? AppTheme.onSurface
                  : AppTheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Color _rarityAccent(Rarity r) {
    switch (r) {
      case Rarity.legendario:
        return AppTheme.pastelPeach;
      case Rarity.epico:
        return AppTheme.secondaryContainer;
      case Rarity.raro:
        return AppTheme.tertiaryContainer;
      case Rarity.comun:
        return AppTheme.surfaceContainerHigh;
    }
  }

  Color _onAccent(Rarity r) {
    switch (r) {
      case Rarity.legendario:
        return AppTheme.onPastelPeach;
      case Rarity.epico:
        return AppTheme.onSecondaryContainer;
      case Rarity.raro:
        return AppTheme.onTertiaryContainer;
      case Rarity.comun:
        return AppTheme.onSurface;
    }
  }
}
