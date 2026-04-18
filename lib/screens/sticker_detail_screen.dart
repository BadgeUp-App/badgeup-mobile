import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/sticker.dart';
import '../services/content_api.dart';
import '../theme/app_theme.dart';

class StickerDetailScreen extends StatefulWidget {
  final Sticker sticker;

  const StickerDetailScreen({super.key, required this.sticker});

  @override
  State<StickerDetailScreen> createState() => _StickerDetailScreenState();
}

class _StickerDetailScreenState extends State<StickerDetailScreen> {
  late Sticker sticker;

  @override
  void initState() {
    super.initState();
    sticker = widget.sticker;
    _loadFull();
  }

  Future<void> _loadFull() async {
    try {
      final full = await ContentApi.instance.fetchStickerDetail(sticker.id);
      if (mounted) setState(() => sticker = full);
    } catch (_) {}
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    final local = dt.toLocal();
    final d = local.day.toString().padLeft(2, '0');
    final m = local.month.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$d/$m/${local.year} a las $h:$min';
  }

  Future<void> _showMessageDialog() async {
    final controller = TextEditingController(text: sticker.userMessage ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Tu nota',
          style: GoogleFonts.inter(fontWeight: FontWeight.w800),
        ),
        content: TextField(
          controller: controller,
          maxLines: 4,
          maxLength: 280,
          decoration: InputDecoration(
            hintText: 'Escribe tus pensamientos...',
            hintStyle: GoogleFonts.inter(color: AppTheme.onSurfaceVariant),
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
            child: Text('Cancelar',
                style: GoogleFonts.inter(
                    color: AppTheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
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
    if (result == null || !mounted) return;
    try {
      final updated = await ContentApi.instance.setStickerMessage(
        stickerId: sticker.id,
        message: result,
      );
      if (mounted) setState(() => sticker = updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = sticker.unlockedPhotoUrl != null &&
        sticker.unlockedPhotoUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _TopBar()),
                SliverToBoxAdapter(
                  child: _HeroPanel(
                    sticker: sticker,
                    showPhoto: hasPhoto,
                  ),
                ),
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
                        if (sticker.albumTitle != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            sticker.albumTitle!,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
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
                if (sticker.funFact != null && sticker.funFact!.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: _DatoCuriosoCard(text: sticker.funFact!),
                    ),
                  ),
                if (sticker.userMessage != null &&
                    sticker.userMessage!.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: GestureDetector(
                        onTap: _showMessageDialog,
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.edit_note_rounded,
                                  color: AppTheme.primary, size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tu nota',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      sticker.userMessage!,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: AppTheme.onSurfaceVariant,
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
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          if (sticker.captureDate != null)
                            _techRow(
                              Icons.calendar_today_rounded,
                              'Capturado',
                              _formatDate(sticker.captureDate),
                              even: true,
                            ),
                          if (sticker.captureLocation != null &&
                              sticker.captureLocation!.isNotEmpty)
                            _techRow(
                              Icons.place_rounded,
                              'Ubicacion',
                              sticker.captureLocation!,
                              even: sticker.captureDate == null,
                            ),
                          _techRow(
                            Icons.workspace_premium_rounded,
                            'Puntos',
                            '${sticker.points} pts',
                            even: false,
                          ),
                          _techRow(
                            Icons.diamond_rounded,
                            'Rareza',
                            _rarityLabel(sticker.rarity),
                            even: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 140)),
              ],
            ),
          ),
          _FloatingActionTray(
            sticker: sticker,
            onNoteTap: _showMessageDialog,
          ),
        ],
      ),
    );
  }

  Widget _techRow(IconData icon, String label, String value,
      {required bool even}) {
    return Container(
      color: even
          ? AppTheme.surfaceContainerLow.withValues(alpha: 0.5)
          : AppTheme.surfaceContainerLowest,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.onSurfaceVariant),
          const SizedBox(width: 14),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _rarityLabel(Rarity r) {
    switch (r) {
      case Rarity.legendario:
        return 'Legendario';
      case Rarity.epico:
        return 'Epico';
      case Rarity.raro:
        return 'Raro';
      case Rarity.comun:
        return 'Comun';
    }
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
            'Detalle',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: AppTheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPanel extends StatefulWidget {
  const _HeroPanel({required this.sticker, required this.showPhoto});
  final Sticker sticker;
  final bool showPhoto;

  @override
  State<_HeroPanel> createState() => _HeroPanelState();
}

class _HeroPanelState extends State<_HeroPanel> {
  int _currentPage = 0;

  List<String> _buildUrls() {
    final urls = <String>[];
    if (widget.showPhoto && widget.sticker.capturePhotos.isNotEmpty) {
      for (final cp in widget.sticker.capturePhotos) {
        if (cp.url.isNotEmpty) urls.add(cp.url);
      }
    }
    if (urls.isEmpty && widget.showPhoto && widget.sticker.unlockedPhotoUrl != null) {
      urls.add(widget.sticker.unlockedPhotoUrl!);
    }
    if (urls.isEmpty) {
      urls.add(widget.sticker.imageUrl);
    }
    return urls;
  }

  @override
  Widget build(BuildContext context) {
    final urls = _buildUrls();
    final hasMultiple = urls.length > 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          children: [
            if (hasMultiple)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => _openFullscreen(context, urls, _currentPage),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: PageView.builder(
                      itemCount: urls.length,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemBuilder: (_, i) => _photoImage(urls[i]),
                    ),
                  ),
                ),
              )
            else
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => _openFullscreen(context, urls, 0),
                  child: Hero(
                    tag: 'sticker_${widget.sticker.id}',
                    child: _photoImage(urls.first),
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
                          _rarityLabel(widget.sticker.rarity),
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
            if (hasMultiple)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(urls.length, (i) {
                              return Container(
                                width: i == _currentPage ? 18 : 6,
                                height: 6,
                                margin: EdgeInsets.only(left: i > 0 ? 4 : 0),
                                decoration: BoxDecoration(
                                  color: i == _currentPage
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openFullscreen(BuildContext context, List<String> urls, int initial) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => _FullscreenViewer(
          urls: urls,
          initialIndex: initial,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  Widget _photoImage(String url) {
    final isCapture = widget.showPhoto;
    return CachedNetworkImage(
      imageUrl: url,
      fit: isCapture ? BoxFit.cover : BoxFit.contain,
      imageBuilder: (context, provider) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            image: DecorationImage(
              image: provider,
              fit: isCapture ? BoxFit.cover : BoxFit.contain,
            ),
          ),
        );
      },
      placeholder: (_, __) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(36),
        ),
      ),
      errorWidget: (_, __, ___) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(36),
        ),
        child: Icon(Icons.emoji_events_rounded,
            size: 80, color: AppTheme.onSurfaceVariant),
      ),
    );
  }

  String _rarityLabel(Rarity r) {
    switch (r) {
      case Rarity.legendario:
        return 'LEGENDARIO';
      case Rarity.epico:
        return 'EPICO';
      case Rarity.raro:
        return 'RARO';
      case Rarity.comun:
        return 'COMUN';
    }
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lightbulb_rounded,
                    color: AppTheme.secondary, size: 24),
              ),
              const SizedBox(width: 14),
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

class _FloatingActionTray extends StatelessWidget {
  const _FloatingActionTray({required this.sticker, required this.onNoteTap});
  final Sticker sticker;
  final VoidCallback onNoteTap;

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
                  onTap: onNoteTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 14),
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.edit_rounded,
                            size: 16, color: AppTheme.onPastelPeach),
                        const SizedBox(width: 6),
                        Text(
                          'Escribir nota',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.onPastelPeach,
                          ),
                        ),
                      ],
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

class _FullscreenViewer extends StatefulWidget {
  const _FullscreenViewer({required this.urls, this.initialIndex = 0});
  final List<String> urls;
  final int initialIndex;

  @override
  State<_FullscreenViewer> createState() => _FullscreenViewerState();
}

class _FullscreenViewerState extends State<_FullscreenViewer> {
  late int _current;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageController = PageController(initialPage: _current);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final multi = widget.urls.length > 1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.urls.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.0,
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: widget.urls[i],
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const CircularProgressIndicator(
                    color: Colors.white24,
                    strokeWidth: 2,
                  ),
                  errorWidget: (_, __, ___) => const Icon(
                    Icons.broken_image_rounded,
                    color: Colors.white38,
                    size: 64,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 22),
              ),
            ),
          ),
          if (multi)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(widget.urls.length, (i) {
                        return Container(
                          width: i == _current ? 20 : 6,
                          height: 6,
                          margin: EdgeInsets.only(left: i > 0 ? 5 : 0),
                          decoration: BoxDecoration(
                            color: i == _current
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          if (multi)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${_current + 1} / ${widget.urls.length}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
