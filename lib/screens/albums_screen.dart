import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../data/mock_data.dart';
import '../models/album.dart';
import '../theme/app_theme.dart';
import 'album_detail_screen.dart';
import 'create_sticker_screen.dart';

class AlbumsScreen extends StatelessWidget {
  const AlbumsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final albums = MockData.albums;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Albumes'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateStickerScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('+ Crear', style: TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: albums.length,
        itemBuilder: (context, index) {
          return _AlbumListCard(album: albums[index]);
        },
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
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AlbumDetailScreen(album: album)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
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
              height: 140,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF60A5FA), Color(0xFF818CF8)],
                ),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(Icons.directions_car, size: 60, color: Colors.white),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${album.totalCount} stickers',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
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
                      Text(
                        album.title,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                      ),
                      if (album.isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Premium',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFD97706),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(album.theme, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      '${album.unlockedCount}/${album.totalCount} desbloqueados',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
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
