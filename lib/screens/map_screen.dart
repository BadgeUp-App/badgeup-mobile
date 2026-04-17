import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../models/capture_entry.dart';
import '../models/sticker.dart';
import '../services/content_api.dart';
import '../theme/app_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  late Future<List<StickerLocationEntry>> _future;

  static const _worldCenter = LatLng(20.0, 0.0);
  static const double _worldZoom = 2.2;

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

  String _rarityLabel(String? rarity) {
    switch (rarityFromString(rarity)) {
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

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day/$month/${d.year}';
  }

  List<_LocationCluster> _buildClusters(List<StickerLocationEntry> locations) {
    final buckets = <String, List<StickerLocationEntry>>{};
    for (final loc in locations) {
      final key =
          '${loc.lat.toStringAsFixed(4)}_${loc.lng.toStringAsFixed(4)}';
      buckets.putIfAbsent(key, () => []).add(loc);
    }
    return buckets.values.map((items) {
      final avgLat =
          items.map((e) => e.lat).reduce((a, b) => a + b) / items.length;
      final avgLng =
          items.map((e) => e.lng).reduce((a, b) => a + b) / items.length;
      return _LocationCluster(
        center: LatLng(avgLat, avgLng),
        items: items,
      );
    }).toList();
  }

  void _fitBoundsFromClusters(List<_LocationCluster> clusters) {
    if (clusters.isEmpty) return;
    if (clusters.length == 1) {
      _mapController.move(clusters.first.center, 12.0);
      return;
    }
    final points = clusters.map((c) => c.center).toList();
    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(60),
        maxZoom: 14,
      ),
    );
  }

  void _showLocationDetail(StickerLocationEntry loc) {
    final color = _rarityColor(loc.rarity);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: AppTheme.softShadow,
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.15),
                  ),
                  child: Icon(Icons.location_on_rounded, color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.stickerName,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        loc.albumTitle,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _detailChip('Rareza', _rarityLabel(loc.rarity), color),
                  const SizedBox(width: 16),
                  _detailChip('Usuario', '@${loc.username}', AppTheme.primaryContainer),
                  if (loc.unlockedAt != null) ...[
                    const SizedBox(width: 16),
                    _detailChip('Fecha', _formatDate(loc.unlockedAt), AppTheme.onSurfaceVariant),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.pin_drop_rounded, size: 14, color: AppTheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  '${loc.lat.toStringAsFixed(5)}, ${loc.lng.toStringAsFixed(5)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showClusterList(_LocationCluster cluster) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLowest,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primary.withValues(alpha: 0.12),
                      ),
                      child: Icon(Icons.place_rounded,
                          color: AppTheme.primary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${cluster.items.length} capturas aqui',
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${cluster.center.latitude.toStringAsFixed(5)}, ${cluster.center.longitude.toStringAsFixed(5)}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 24),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding:
                      const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: cluster.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final loc = cluster.items[i];
                    final c = _rarityColor(loc.rarity);
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _showLocationDetail(loc);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: c,
                              ),
                              child: const Icon(
                                Icons.emoji_events_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    loc.stickerName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '@${loc.username} - ${_rarityLabel(loc.rarity)}',
                                    style: GoogleFonts.poppins(
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
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailChip(String label, String value, Color accent) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers(List<_LocationCluster> clusters) {
    return clusters.map((cluster) {
      final first = cluster.items.first;
      final color = _rarityColor(first.rarity);
      final count = cluster.items.length;
      return Marker(
        point: cluster.center,
        width: 48,
        height: 48,
        child: GestureDetector(
          onTap: () {
            if (count > 1) {
              _showClusterList(cluster);
            } else {
              _showLocationDetail(first);
            }
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.emoji_events_rounded,
                    color: Colors.white, size: 18),
              ),
              if (count > 1)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    constraints:
                        const BoxConstraints(minWidth: 20, minHeight: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLowest,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: color, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        '$count',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: color,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
              child: Row(
                children: [
                  Text(
                    'Mapa de capturas',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _reload,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: AppTheme.subtleLift,
                      ),
                      child: Icon(Icons.refresh_rounded,
                          size: 20, color: AppTheme.onSurface),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: FutureBuilder<List<StickerLocationEntry>>(
                future: _future,
                builder: (context, snapshot) {
                  final locations = snapshot.data ?? const <StickerLocationEntry>[];
                  final clusters = _buildClusters(locations);
                  final loading = snapshot.connectionState == ConnectionState.waiting;

                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: FlutterMap(
                          mapController: _mapController,
                          options: const MapOptions(
                            initialCenter: _worldCenter,
                            initialZoom: _worldZoom,
                            minZoom: 2,
                            maxZoom: 18,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.badgeup.mobile',
                            ),
                            MarkerLayer(markers: _buildMarkers(clusters)),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLowest.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: AppTheme.subtleLift,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: locations.isNotEmpty
                                      ? const Color(0xFF22C55E)
                                      : AppTheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                loading
                                    ? 'Cargando ubicaciones...'
                                    : '${locations.length} capturas en ${clusters.length} lugares',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (loading)
                        const Center(child: CircularProgressIndicator()),
                      if (!loading && locations.isEmpty)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            margin: const EdgeInsets.symmetric(horizontal: 40),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceContainerLowest.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: AppTheme.subtleLift,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.map_rounded,
                                    size: 36, color: AppTheme.onSurfaceVariant),
                                const SizedBox(height: 10),
                                Text(
                                  'Sin capturas aun',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Las capturas con GPS apareceran aqui.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: AppTheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (snapshot.hasError && !loading)
                        Positioned(
                          bottom: 20,
                          left: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.error.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              'Error al cargar ubicaciones',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 24,
                        right: 16,
                        child: Column(
                          children: [
                            if (clusters.isNotEmpty)
                              _mapActionButton(
                                Icons.fit_screen_rounded,
                                () => _fitBoundsFromClusters(clusters),
                              ),
                            const SizedBox(height: 10),
                            _mapActionButton(
                              Icons.public_rounded,
                              () => _mapController.move(_worldCenter, _worldZoom),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mapActionButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppTheme.subtleLift,
        ),
        child: Icon(icon, size: 20, color: AppTheme.onSurface),
      ),
    );
  }
}

class _LocationCluster {
  final LatLng center;
  final List<StickerLocationEntry> items;

  const _LocationCluster({
    required this.center,
    required this.items,
  });
}
