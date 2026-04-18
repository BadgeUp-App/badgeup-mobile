import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/album.dart';
import '../models/capture_entry.dart';
import '../models/sticker.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/content_api.dart';
import '../services/user_session.dart';
import '../theme/app_theme.dart';
import 'edit_profile_screen.dart';
import 'map_screen.dart';
import 'settings_screen.dart';
import 'friends_screen.dart';
import 'ranking_screen.dart';
import 'calendar_screen.dart';
import 'chat_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<List<Album>> _albumsFuture;
  late Future<List<StickerLocationEntry>> _locationsFuture;

  @override
  void initState() {
    super.initState();
    _albumsFuture = ContentApi.instance.fetchAlbums();
    _locationsFuture = ContentApi.instance.fetchStickerLocations();
    UserSession.instance.refresh();
  }

  Future<void> _reload() async {
    setState(() {
      _albumsFuture = ContentApi.instance.fetchAlbums();
      _locationsFuture = ContentApi.instance.fetchStickerLocations();
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
            top: -160,
            right: -120,
            child: IgnorePointer(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    color: AppTheme.pastelPeach.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _reload,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 150),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
                      child: Row(
                        children: [
                          Text(
                            'Perfil',
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () async {
                              final updated = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const EditProfileScreen(),
                                ),
                              );
                              if (updated == true) _reload();
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: AppTheme.subtleLift,
                              ),
                              child: Icon(Icons.edit_outlined,
                                  size: 20, color: AppTheme.onSurface),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SettingsScreen()),
                            ),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: AppTheme.subtleLift,
                              ),
                              child: Icon(Icons.settings_rounded,
                                  size: 20, color: AppTheme.onSurface),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (user == null)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 60),
                        child: CircularProgressIndicator(),
                      )
                    else ...[
                      _AvatarBlock(
                        user: user,
                        onTap: () async {
                          final updated = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfileScreen(),
                            ),
                          );
                          if (updated == true) _reload();
                        },
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: _StatTile(
                                value: _formatPoints(user.totalPoints),
                                label: 'PUNTOS',
                                accent: AppTheme.pastelPeach,
                                accentText: AppTheme.onPastelPeach,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatTile(
                                value: '${user.totalStickers}',
                                label: 'STICKERS',
                                accent: AppTheme.tertiaryContainer,
                                accentText: AppTheme.onTertiaryContainer,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatTile(
                                value: user.rank > 0 ? '#${user.rank}' : '—',
                                label: 'RANKING',
                                accent: AppTheme.secondaryContainer,
                                accentText: AppTheme.onSecondaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Biografia',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              (user.bio == null || user.bio!.trim().isEmpty)
                                  ? 'Aun no escribes una biografia.'
                                  : user.bio!,
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
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Albumes recientes',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 160,
                      child: FutureBuilder<List<Album>>(
                        future: _albumsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final albums = snapshot.data ?? const <Album>[];
                          if (albums.isEmpty) {
                            return Center(
                              child: Text(
                                'No hay albumes disponibles.',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppTheme.onSurfaceVariant,
                                ),
                              ),
                            );
                          }
                          return ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: albums.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 14),
                            itemBuilder: (context, i) {
                              final album = albums[i];
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: SizedBox(
                                  width: 220,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: album.coverUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) => Container(
                                          color: AppTheme.surfaceContainerHigh,
                                        ),
                                        errorWidget: (_, __, ___) => Container(
                                          color: AppTheme.surfaceContainerHigh,
                                          child: Icon(Icons.collections_rounded,
                                              color: AppTheme.onSurfaceVariant),
                                        ),
                                      ),
                                      Container(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Color(0xCC0C0E12),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              album.title,
                                              style: GoogleFonts.inter(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${album.unlockedCount}/${album.totalCount} figuritas',
                                              style: GoogleFonts.inter(
                                                fontSize: 11,
                                                color: Colors.white.withValues(alpha: 0.85),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _QuickAction(
                            icon: Icons.people_rounded,
                            label: 'Amigos',
                            bg: AppTheme.secondaryContainer,
                            iconColor: AppTheme.secondary,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const FriendsScreen()),
                            ),
                          ),
                          _QuickAction(
                            icon: Icons.emoji_events_rounded,
                            label: 'Ranking',
                            bg: AppTheme.tertiaryContainer,
                            iconColor: AppTheme.tertiary,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RankingScreen()),
                            ),
                          ),
                          _QuickAction(
                            icon: Icons.calendar_today_rounded,
                            label: 'Agenda',
                            bg: AppTheme.pastelPeach,
                            iconColor: AppTheme.onPastelPeach,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CalendarScreen()),
                            ),
                          ),
                          _QuickAction(
                            icon: Icons.chat_rounded,
                            label: 'Chat',
                            bg: AppTheme.surfaceContainerHigh,
                            iconColor: AppTheme.primary,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ChatScreen()),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    _MapPreview(locationsFuture: _locationsFuture),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GestureDetector(
                        onTap: () => _showLogoutDialog(context),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.logout_rounded,
                                  size: 18, color: AppTheme.error),
                              const SizedBox(width: 8),
                              Text(
                                'Cerrar sesion',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  String _formatPoints(dynamic nd) {
    final n = nd is int ? nd : int.tryParse('$nd') ?? 0;
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text('Cerrar sesion',
            style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        content: Text('Seguro que quieres salir?',
            style: GoogleFonts.inter(color: AppTheme.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.instance.logout();
              // AuthGate will swap back to LoginScreen automatically.
            },
            child: Text('Salir',
                style: GoogleFonts.inter(
                    color: AppTheme.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _AvatarBlock extends StatelessWidget {
  const _AvatarBlock({required this.user, required this.onTap});
  final UserProfile user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initial = user.displayName.isNotEmpty
        ? user.displayName[0].toUpperCase()
        : '?';
    final hasAvatar =
        user.avatarUrl != null && user.avatarUrl!.isNotEmpty;
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 116,
                height: 116,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.pastelPeach,
                      AppTheme.secondaryContainer,
                    ],
                  ),
                  boxShadow: AppTheme.softShadow,
                ),
                padding: const EdgeInsets.all(6),
                child: ClipOval(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLowest,
                      shape: BoxShape.circle,
                    ),
                    child: hasAvatar
                        ? CachedNetworkImage(
                            imageUrl: user.avatarUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Center(
                              child: Text(
                                initial,
                                style: GoogleFonts.inter(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.onSurface,
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              initial,
                              style: GoogleFonts.inter(
                                fontSize: 44,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.onSurface,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.pastelPeach,
                    boxShadow: AppTheme.subtleLift,
                    border: Border.all(
                      color: AppTheme.surface,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 16,
                    color: AppTheme.onPastelPeach,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user.displayName,
          style: GoogleFonts.inter(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.accent,
    required this.accentText,
  });

  final String value;
  final String label;
  final Color accent;
  final Color accentText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.bg,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color bg;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPreview extends StatelessWidget {
  const _MapPreview({required this.locationsFuture});
  final Future<List<StickerLocationEntry>> locationsFuture;

  Color _rarityColor(String? rarity) {
    switch (rarityFromString(rarity)) {
      case Rarity.legendario:
        return const Color(0xFFF59E0B);
      case Rarity.epico:
        return const Color(0xFF8B5CF6);
      case Rarity.raro:
        return const Color(0xFF3B82F6);
      case Rarity.comun:
        return const Color(0xFF9CA3AF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mapa de capturas',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MapScreen()),
            ),
            child: FutureBuilder<List<StickerLocationEntry>>(
              future: locationsFuture,
              builder: (context, snapshot) {
                final locs = snapshot.data ?? const <StickerLocationEntry>[];
                final loading =
                    snapshot.connectionState == ConnectionState.waiting;

                return Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1A1D23),
                        Color(0xFF2A2D35),
                      ],
                    ),
                    boxShadow: AppTheme.subtleLift,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        top: -20,
                        child: Icon(
                          Icons.map_rounded,
                          size: 140,
                          color: Colors.white.withValues(alpha: 0.04),
                        ),
                      ),
                      if (locs.isNotEmpty)
                        Positioned(
                          top: 16,
                          left: 16,
                          right: 80,
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: locs.take(12).map((loc) {
                              return Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _rarityColor(loc.rarity),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      Positioned(
                        top: 14,
                        right: 16,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.open_in_full_rounded,
                            size: 18,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: locs.isNotEmpty
                                            ? const Color(0xFF22C55E)
                                            : Colors.white38,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      loading
                                          ? 'Cargando...'
                                          : '${locs.length} capturas con GPS',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Toca para ver el mapa completo',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: Colors.white54,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.pastelPeach,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Ver mapa',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.onPastelPeach,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
