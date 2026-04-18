import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/album.dart';
import '../services/content_api.dart';
import '../services/user_session.dart';
import '../theme/app_theme.dart';
import 'album_detail_screen.dart';
import 'create_album_screen.dart';
import 'create_sticker_screen.dart';

class AlbumsScreen extends StatefulWidget {
  const AlbumsScreen({super.key});

  @override
  State<AlbumsScreen> createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends State<AlbumsScreen> {
  late Future<List<Album>> _future;

  @override
  void initState() {
    super.initState();
    _future = ContentApi.instance.fetchAlbums();
  }

  Future<void> _reload() async {
    setState(() {
      _future = ContentApi.instance.fetchAlbums();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Stack(
        children: [
          Positioned(
            top: -180,
            left: -120,
            child: IgnorePointer(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                child: Container(
                  width: 340,
                  height: 340,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryContainer.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _reload,
              child: FutureBuilder<List<Album>>(
                future: _future,
                builder: (context, snapshot) {
                  final loading = snapshot.connectionState == ConnectionState.waiting;
                  final error = snapshot.hasError;
                  final albums = snapshot.data ?? const <Album>[];

                  return CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
                          child: Row(
                            children: [
                              Text(
                                'Mis albumes',
                                style: GoogleFonts.inter(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const Spacer(),
                              if (UserSession.instance.user?.isStaff == true)
                                GestureDetector(
                                  onTap: _showCreateSheet,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceContainerLowest,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: AppTheme.subtleLift,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.add_rounded,
                                            size: 16, color: AppTheme.primary),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Nuevo',
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
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 30, 24, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'COLECCIONES',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2.0,
                                  color: AppTheme.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tus albumes',
                                style: GoogleFonts.inter(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1.6,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${albums.length} colecciones activas - ${_totalStickers(albums)} figuritas por desbloquear.',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppTheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (loading)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (error)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'No se pudieron cargar los albumes.',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AppTheme.onSurfaceVariant,
                                  ),
                                ),
                                TextButton(
                                  onPressed: _reload,
                                  child: const Text('Reintentar'),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (albums.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Text(
                              'Aun no hay colecciones.',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(24, 28, 24, 140),
                          sliver: SliverList.separated(
                            itemCount: albums.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 18),
                            itemBuilder: (_, i) => _AlbumListCard(album: albums[i]),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _totalStickers(List<Album> a) =>
      a.fold(0, (sum, al) => sum + al.totalCount);

  Future<void> _showCreateSheet() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppTheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Que quieres crear?',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              _sheetTile(
                ctx,
                icon: Icons.collections_bookmark_rounded,
                title: 'Nuevo album',
                subtitle: 'Arma una coleccion completa',
                value: 'album',
              ),
              const SizedBox(height: 10),
              _sheetTile(
                ctx,
                icon: Icons.style_rounded,
                title: 'Nuevo sticker',
                subtitle: 'Agrega una figurita a un album',
                value: 'sticker',
              ),
            ],
          ),
        ),
      ),
    );

    if (!mounted || choice == null) return;

    if (choice == 'album') {
      final created = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const CreateAlbumScreen()),
      );
      if (created == true) _reload();
    } else if (choice == 'sticker') {
      final created = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const CreateStickerScreen()),
      );
      if (created == true) _reload();
    }
  }

  Widget _sheetTile(
    BuildContext ctx, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pop(ctx, value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.pastelPeach,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 20, color: AppTheme.onPastelPeach),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppTheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _AlbumListCard extends StatelessWidget {
  final Album album;
  const _AlbumListCard({required this.album});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AlbumDetailScreen(album: album)),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(28),
          boxShadow: AppTheme.subtleLift,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: CachedNetworkImage(
                imageUrl: album.coverUrl,
                width: 92,
                height: 118,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 92,
                  height: 118,
                  color: AppTheme.surfaceContainerHigh,
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 92,
                  height: 118,
                  color: AppTheme.surfaceContainerHigh,
                  child: Icon(Icons.collections_rounded,
                      color: AppTheme.onSurfaceVariant),
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          album.title,
                          style: GoogleFonts.inter(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      if (album.isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.pastelPeach,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'PREMIUM',
                            style: GoogleFonts.inter(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: AppTheme.onPastelPeach,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    album.theme.isNotEmpty ? album.theme : album.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(
                        '${album.unlockedCount}',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                        ),
                      ),
                      Text(
                        ' / ${album.totalCount}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 8,
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
}
