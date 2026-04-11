import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/album.dart';
import '../models/user_profile.dart';
import '../services/content_api.dart';
import '../services/user_session.dart';
import '../theme/app_theme.dart';
import 'album_detail_screen.dart';
import 'friends_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.onProfileTapped,
    this.onRankingTapped,
    this.onAlbumsTapped,
  });

  final VoidCallback? onProfileTapped;
  final VoidCallback? onRankingTapped;
  final VoidCallback? onAlbumsTapped;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Album>> _albumsFuture;

  @override
  void initState() {
    super.initState();
    _albumsFuture = ContentApi.instance.fetchAlbums();
    UserSession.instance.refresh();
  }

  Future<void> _reload() async {
    setState(() {
      _albumsFuture = ContentApi.instance.fetchAlbums();
    });
    await UserSession.instance.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserSession>().user;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Stack(
        children: [
          Positioned(
            top: -140,
            right: -120,
            child: IgnorePointer(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: const BoxDecoration(
                    color: Color(0x44E0F7FA),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _reload,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                      child: _TopBar(
                        user: user,
                        onProfileTapped: widget.onProfileTapped,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _weekday(),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _greeting(user),
                            style: GoogleFonts.inter(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                              color: AppTheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: _PointsHeroCard(user: user),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: _SideTile(
                              icon: Icons.emoji_events_rounded,
                              iconColor: AppTheme.onSecondaryContainer,
                              iconBg: AppTheme.secondaryContainer,
                              title: 'Ranking',
                              subtitle: user != null && user.rank > 0
                                  ? 'Estas en la posicion #${user.rank} global.'
                                  : 'Escala posiciones capturando stickers.',
                              trailingIcon: Icons.north_east_rounded,
                              onTap: widget.onRankingTapped,
                              footer: _AvatarStack(count: 4, extra: 12),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _SideTile(
                              icon: Icons.groups_rounded,
                              iconColor: AppTheme.onTertiaryContainer,
                              iconBg: AppTheme.tertiaryContainer,
                              title: 'Amigos',
                              subtitle: 'Encuentra y chatea con otros cazadores.',
                              trailingIcon: Icons.more_horiz_rounded,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const FriendsScreen()),
                              ),
                              footer: const _MiniBar(progress: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 36, 24, 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Albumes recientes',
                                  style: GoogleFonts.inter(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.6,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Colecciones disponibles en la app',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppTheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: widget.onAlbumsTapped,
                            child: Row(
                              children: [
                                Text(
                                  'Ver todos',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded,
                                    size: 18, color: AppTheme.primary),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 260,
                      child: FutureBuilder<List<Album>>(
                        future: _albumsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'No se pudieron cargar los albumes.',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppTheme.onSurfaceVariant,
                                ),
                              ),
                            );
                          }
                          final albums = snapshot.data ?? const <Album>[];
                          if (albums.isEmpty) {
                            return Center(
                              child: Text(
                                'No hay albumes disponibles aun.',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppTheme.onSurfaceVariant,
                                ),
                              ),
                            );
                          }
                          return ListView.separated(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                            scrollDirection: Axis.horizontal,
                            itemCount: albums.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 16),
                            itemBuilder: (context, i) {
                              final album = albums[i];
                              return _AlbumScrollCard(
                                title: album.title,
                                subtitle: album.theme.isNotEmpty
                                    ? album.theme
                                    : album.description,
                                imageUrl: album.coverUrl,
                                accentIcon: Icons.collections_rounded,
                                accentColor: AppTheme.primary,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AlbumDetailScreen(album: album),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 130)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting(UserProfile? user) {
    final first =
        (user?.displayName ?? 'Cazador').split(' ').firstWhere(
              (s) => s.isNotEmpty,
              orElse: () => 'Cazador',
            );
    return 'Buenos dias, $first';
  }

  String _weekday() {
    const days = ['Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo'];
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    final now = DateTime.now();
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.user, required this.onProfileTapped});
  final UserProfile? user;
  final VoidCallback? onProfileTapped;

  @override
  Widget build(BuildContext context) {
    final initial = (user?.displayName.isNotEmpty ?? false)
        ? user!.displayName[0].toUpperCase()
        : '?';
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppTheme.subtleLift,
          ),
          child: Icon(Icons.menu_rounded, color: AppTheme.onSurface, size: 22),
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
        GestureDetector(
          onTap: onProfileTapped,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppTheme.secondaryContainer, AppTheme.pastelPeach],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: AppTheme.subtleLift,
            ),
            child: Center(
              child: Text(
                initial,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PointsHeroCard extends StatelessWidget {
  const _PointsHeroCard({required this.user});
  final UserProfile? user;

  @override
  Widget build(BuildContext context) {
    final points = user?.totalPoints ?? 0;
    final rank = user?.rank ?? 0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE0F7FA),
              Color(0xFFE8F5E9),
              Color(0xFFF1F8E9),
            ],
          ),
          borderRadius: BorderRadius.all(Radius.circular(32)),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -60,
              child: IgnorePointer(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppTheme.tertiaryContainer.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.stars_rounded,
                          size: 18, color: AppTheme.tertiaryDim),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'PUNTOS BADGEUP',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                        color: AppTheme.tertiaryDim,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  _formatPoints(points),
                  style: GoogleFonts.inter(
                    fontSize: 56,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -2.4,
                    color: AppTheme.onSurface,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.trending_up_rounded,
                        size: 18, color: AppTheme.tertiaryDim),
                    const SizedBox(width: 6),
                    Text(
                      '${user?.totalStickers ?? 0} stickers capturados',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.tertiaryDim,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'STICKERS',
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.4,
                                    color: AppTheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${user?.totalStickers ?? 0}',
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 36,
                            color: AppTheme.onSurfaceVariant.withValues(alpha: 0.15),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'RANK',
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.4,
                                    color: AppTheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  rank > 0 ? '#$rank Global' : '—',
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.onSurface,
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatPoints(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _SideTile extends StatelessWidget {
  const _SideTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.trailingIcon,
    required this.footer,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final IconData trailingIcon;
  final Widget footer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const Spacer(),
                Icon(trailingIcon, size: 18, color: AppTheme.onSurfaceVariant),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.onSurfaceVariant,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            footer,
          ],
        ),
      ),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.count, required this.extra});
  final int count;
  final int extra;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Stack(
        children: [
          for (int i = 0; i < count; i++)
            Positioned(
              left: i * 18.0,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: [
                    AppTheme.secondaryContainer,
                    AppTheme.tertiaryContainer,
                    AppTheme.pastelPeach,
                    AppTheme.surfaceContainerHigh,
                  ][i % 4],
                  border: Border.all(color: AppTheme.surfaceContainerLow, width: 2.5),
                ),
              ),
            ),
          Positioned(
            left: count * 18.0,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.surfaceContainerLowest,
                border: Border.all(color: AppTheme.surfaceContainerLow, width: 2.5),
              ),
              child: Center(
                child: Text(
                  '+$extra',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.onSurface,
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

class _MiniBar extends StatelessWidget {
  const _MiniBar({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: AppTheme.onSurfaceVariant.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.tertiary,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

class _AlbumScrollCard extends StatelessWidget {
  const _AlbumScrollCard({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.accentIcon,
    required this.accentColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String imageUrl;
  final IconData accentIcon;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: AppTheme.surfaceContainerHigh,
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: AppTheme.surfaceContainerHigh,
                      child: Icon(Icons.collections_rounded,
                          color: AppTheme.onSurfaceVariant, size: 40),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(accentIcon, size: 14, color: accentColor),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
