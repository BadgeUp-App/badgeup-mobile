import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ranking = MockData.ranking;
    final top3 = ranking.take(3).toList();
    final rest = ranking.skip(3).toList();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          backgroundColor: const Color(0xFFF59E0B),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    children: [
                      const Text(
                        'Ranking Global',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      if (top3.length >= 3) _buildPodium(top3),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final entry = rest[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 28,
                        child: Text(
                          '#${entry.rank}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      CircleAvatar(
                        radius: 19,
                        backgroundColor: const Color(0xFFEFF6FF),
                        child: Icon(Icons.person, size: 20, color: Colors.grey[400]),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.displayName,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '@${entry.username}',
                              style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${entry.points}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: rest.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPodium(List top3) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _podiumColumn(top3[1], 100, const Color(0xFFC0C0C0)),
        const SizedBox(width: 8),
        _podiumColumn(top3[0], 140, const Color(0xFFFFD700)),
        const SizedBox(width: 8),
        _podiumColumn(top3[2], 70, const Color(0xFFCD7F32)),
      ],
    );
  }

  Widget _podiumColumn(entry, double height, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white.withValues(alpha: 0.3),
          child: Icon(Icons.person, color: Colors.white.withValues(alpha: 0.8)),
        ),
        const SizedBox(height: 6),
        Text(
          entry.displayName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${entry.points} pts',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              '#${entry.rank}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
