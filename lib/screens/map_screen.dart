import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/capture_entry.dart';
import '../services/content_api.dart';
import '../theme/app_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late Future<List<StickerLocationEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = ContentApi.instance.fetchStickerLocations();
  }

  Future<void> _reload() async {
    setState(() {
      _future = ContentApi.instance.fetchStickerLocations();
    });
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day/$month/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _reload,
          child: FutureBuilder<List<StickerLocationEntry>>(
            future: _future,
            builder: (context, snapshot) {
              final locations = snapshot.data ?? const <StickerLocationEntry>[];
              final loading =
                  snapshot.connectionState == ConnectionState.waiting;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                          'Mapa de capturas',
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: AppTheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'EXPLORA',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Donde capturaste',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.9,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${locations.length} capturas con ubicacion registrada.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Container(
                        height: 300,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFE0F7FA),
                              Color(0xFFF6D9FF),
                              Color(0xFFFFD8C4),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Stack(
                          children: [
                            ..._buildPins(locations),
                            if (loading)
                              const Center(child: CircularProgressIndicator())
                            else if (locations.isEmpty)
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceContainerLowest
                                        .withValues(alpha: 0.88),
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.map_rounded,
                                          size: 32,
                                          color: AppTheme.onSurfaceVariant),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Sin capturas aun',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.onSurface,
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
                    const SizedBox(height: 28),
                    Text(
                      'Capturas recientes',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (loading && locations.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (locations.isEmpty)
                      Text(
                        'Nadie ha registrado capturas con GPS todavia.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      )
                    else
                      ...locations.take(12).map(
                            (loc) => _captureItem(
                              context,
                              loc.stickerName,
                              '${loc.albumTitle} - @${loc.username}',
                              _formatDate(loc.unlockedAt),
                            ),
                          ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPins(List<StickerLocationEntry> locations) {
    if (locations.isEmpty) return const [];
    double minLat = double.infinity, maxLat = -double.infinity;
    double minLng = double.infinity, maxLng = -double.infinity;
    for (final l in locations) {
      if (l.lat < minLat) minLat = l.lat;
      if (l.lat > maxLat) maxLat = l.lat;
      if (l.lng < minLng) minLng = l.lng;
      if (l.lng > maxLng) maxLng = l.lng;
    }
    final latRange = (maxLat - minLat).abs() < 0.0001 ? 1 : (maxLat - minLat);
    final lngRange = (maxLng - minLng).abs() < 0.0001 ? 1 : (maxLng - minLng);

    final pins = <Widget>[];
    for (int i = 0; i < locations.length && i < 20; i++) {
      final loc = locations[i];
      final left = ((loc.lng - minLng) / lngRange) * 280 + 20;
      final top = (1 - (loc.lat - minLat) / latRange) * 220 + 30;
      pins.add(Positioned(
        left: left,
        top: top,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                loc.stickerName.length > 10
                    ? '${loc.stickerName.substring(0, 9)}.'
                    : loc.stickerName,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.pastelPeach,
                boxShadow: AppTheme.subtleLift,
              ),
              child: const Icon(Icons.directions_car_rounded,
                  size: 14, color: AppTheme.onPastelPeach),
            ),
          ],
        ),
      ));
    }
    return pins;
  }

  Widget _captureItem(
      BuildContext context, String name, String subtitle, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.secondaryContainer,
            ),
            child: const Icon(Icons.location_on_rounded,
                size: 18, color: AppTheme.onSecondaryContainer),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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
          Text(
            date,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppTheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
