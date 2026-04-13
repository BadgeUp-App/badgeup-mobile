import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/friend_request.dart';
import '../models/user_profile.dart';
import '../services/content_api.dart';
import '../services/social_api.dart';
import '../theme/app_theme.dart';
import 'chat_screen.dart';

class PublicProfileScreen extends StatefulWidget {
  final int userId;
  final String? username;

  const PublicProfileScreen({
    super.key,
    required this.userId,
    this.username,
  });

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  late Future<UserProfile> _profileFuture;
  late Future<List<Member>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ContentApi.instance.fetchPublicProfile(widget.userId);
    _membersFuture = SocialApi.instance.fetchMembers();
  }

  void _reload() {
    setState(() {
      _profileFuture = ContentApi.instance.fetchPublicProfile(widget.userId);
      _membersFuture = SocialApi.instance.fetchMembers();
    });
  }

  Member? _findMember(List<Member> members) {
    try {
      return members.firstWhere((m) => m.id == widget.userId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _sendFriendRequest() async {
    try {
      await SocialApi.instance.sendFriendRequest(widget.userId);
      _snack('Solicitud enviada');
      _reload();
    } catch (e) {
      _snack('Error: $e');
    }
  }

  void _openChat(String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ChatScreen(otherUserId: widget.userId, otherName: name),
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

  @override
  Widget build(BuildContext context) {
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
                    color: AppTheme.secondaryContainer.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: FutureBuilder<UserProfile>(
              future: _profileFuture,
              builder: (context, profileSnap) {
                return FutureBuilder<List<Member>>(
                  future: _membersFuture,
                  builder: (context, membersSnap) {
                    final loading =
                        profileSnap.connectionState == ConnectionState.waiting;
                    final hasError = profileSnap.hasError;
                    final user = profileSnap.data;
                    final members = membersSnap.data ?? const <Member>[];
                    final member = user != null ? _findMember(members) : null;

                    return Column(
                      children: [
                        _buildAppBar(),
                        Expanded(
                          child: loading
                              ? const Center(child: CircularProgressIndicator())
                              : hasError
                                  ? _buildError()
                                  : _buildContent(user!, member),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
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
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: AppTheme.onSurface),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            widget.username != null ? '@${widget.username}' : 'Perfil',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'No se pudo cargar el perfil.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          TextButton(onPressed: _reload, child: const Text('Reintentar')),
        ],
      ),
    );
  }

  Widget _buildContent(UserProfile user, Member? member) {
    final isFriend = member?.isFriend == true;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(
        children: [
          const SizedBox(height: 12),
          _buildAvatar(user),
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
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    value: '${user.totalStickers}',
                    label: 'STICKERS',
                    accent: AppTheme.tertiaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    value: user.rank > 0 ? '#${user.rank}' : '--',
                    label: 'RANKING',
                    accent: AppTheme.secondaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
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
                      ? 'Este usuario no tiene biografia.'
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
          if (user.totalAlbums > 0) ...[
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.collections_rounded,
                          size: 20, color: AppTheme.onTertiaryContainer),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user.totalAlbums} albumes',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${user.totalStickers} stickers desbloqueados',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: isFriend
                ? Row(
                    children: [
                      Expanded(
                        child: _actionButton(
                          label: 'Amigos',
                          icon: Icons.check_circle_rounded,
                          filled: false,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _actionButton(
                          label: 'Enviar mensaje',
                          icon: Icons.chat_rounded,
                          filled: true,
                          onTap: () => _openChat(user.displayName),
                        ),
                      ),
                    ],
                  )
                : SizedBox(
                    width: double.infinity,
                    child: _actionButton(
                      label: 'Agregar amigo',
                      icon: Icons.person_add_rounded,
                      filled: true,
                      onTap: _sendFriendRequest,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(UserProfile user) {
    final initial =
        user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?';
    final hasAvatar = user.avatarUrl != null && user.avatarUrl!.isNotEmpty;
    return Column(
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
                          child: CircularProgressIndicator(strokeWidth: 2),
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
          '@${user.username}',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: filled ? AppTheme.pastelPeach : AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18,
                color: filled
                    ? AppTheme.onPastelPeach
                    : AppTheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: filled
                    ? AppTheme.onPastelPeach
                    : AppTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.accent,
  });

  final String value;
  final String label;
  final Color accent;

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
