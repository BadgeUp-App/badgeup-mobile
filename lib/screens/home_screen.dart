import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import 'album_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = MockData.currentUser;
    final album = MockData.albums.first;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color ?? (isDark ? AppTheme.darkCard : Colors.white);
    final subtextColor = isDark ? Colors.grey[400] : Colors.grey[500];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreeting(context, user, isDark),
            const SizedBox(height: 20),
            _buildPointsCard(context, user, album, cardColor, subtextColor),
            const SizedBox(height: 14),
            _buildStatRow(context, user, cardColor, subtextColor),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mis Albumes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Ver todos ->',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.primaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildAlbumCard(context, album, cardColor, subtextColor),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context, user, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola de nuevo',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                user.displayName,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Text('Notificaciones'),
                content: const Text(
                  'Aqui se mostraran las notificaciones del usuario. Funcionalidad pendiente.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Entendido'),
                  ),
                ],
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Badge(
              smallSize: 8,
              child: Icon(Icons.notifications_none, size: 22, color: AppTheme.primaryOrange),
            ),
          ),
        ),
        const SizedBox(width: 10),
        CircleAvatar(
          radius: 20,
          backgroundColor: AppTheme.primaryOrange.withValues(alpha: 0.15),
          child: Text(
            user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryOrange,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPointsCard(BuildContext context, user, album, Color cardColor, Color? subtextColor) {
    final totalStickers = album.totalCount;
    final unlockedStickers = album.unlockedCount;
    final progress = totalStickers > 0 ? unlockedStickers / totalStickers : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFEA580C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryOrange.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PUNTOS TOTALES',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.75),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${user.totalPoints}',
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.star_rounded, color: Colors.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso global',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$unlockedStickers/$totalStickers stickers',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearPercentIndicator(
            padding: EdgeInsets.zero,
            lineHeight: 8,
            percent: progress,
            barRadius: const Radius.circular(4),
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            progressColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, user, Color cardColor, Color? subtextColor) {
    return Row(
      children: [
        Expanded(
          child: _miniStatCard(
            context,
            icon: Icons.emoji_events,
            iconColor: const Color(0xFFF59E0B),
            iconBg: const Color(0xFFFEF3C7),
            value: '#${user.rank}',
            label: 'Ranking',
            cardColor: cardColor,
            subtextColor: subtextColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _miniStatCard(
            context,
            icon: Icons.people,
            iconColor: AppTheme.primaryBlue,
            iconBg: const Color(0xFFDBEAFE),
            value: '${MockData.friends.length}',
            label: 'Amigos',
            cardColor: cardColor,
            subtextColor: subtextColor,
          ),
        ),
      ],
    );
  }

  Widget _miniStatCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String value,
    required String label,
    required Color cardColor,
    Color? subtextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: subtextColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumCard(BuildContext context, album, Color cardColor, Color? subtextColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AlbumDetailScreen(album: album)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF60A5FA), Color(0xFF818CF8)],
                ),
              ),
              child: const Center(
                child: Icon(Icons.collections_bookmark, size: 48, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            album.title,
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            album.theme,
                            style: TextStyle(fontSize: 12, color: subtextColor),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${album.unlockedCount}/${album.totalCount}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  LinearPercentIndicator(
                    padding: EdgeInsets.zero,
                    lineHeight: 8,
                    percent: album.progress,
                    barRadius: const Radius.circular(4),
                    backgroundColor: const Color(0xFFE5E7EB),
                    linearGradient: const LinearGradient(
                      colors: [AppTheme.accentGreen, Color(0xFF34D399)],
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
