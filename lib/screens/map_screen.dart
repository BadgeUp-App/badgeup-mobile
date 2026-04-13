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

  static const _defaultCenter = LatLng(20.6597, -103.3496);
  static const double _defaultZoom = 12.0;

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

  void _fitBounds(List<StickerLocationEntry> locations) {
    if (locations.isEmpty) return;
    final points = locations.map((l) => LatLng(l.lat, l.lng)).toList();
    if (points.length == 1) {
      _mapController.move(points.first, 14.0);
      return;
    }
    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
        maxZoom: 16,
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

  List<Marker> _buildMarkers(List<StickerLocationEntry> locations) {
    return locations.map((loc) {
      final color = _rarityColor(loc.rarity);
      return Marker(
        point: LatLng(loc.lat, loc.lng),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _showLocationDetail(loc),
          child: Container(
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
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
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
                  final loading = snapshot.connectionState == ConnectionState.waiting;

                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _defaultCenter,
                            initialZoom: _defaultZoom,
                            minZoom: 3,
                            maxZoom: 18,
                            onMapReady: () {
                              if (locations.isNotEmpty) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _fitBounds(locations);
                                });
                              }
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.badgeup.mobile',
                            ),
                            MarkerLayer(markers: _buildMarkers(locations)),
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
                                    : '${locations.length} capturas con ubicacion',
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
                            if (locations.isNotEmpty)
                              _mapActionButton(
                                Icons.fit_screen_rounded,
                                () => _fitBounds(locations),
                              ),
                            const SizedBox(height: 10),
                            _mapActionButton(
                              Icons.my_location_rounded,
                              () => _mapController.move(_defaultCenter, _defaultZoom),
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
