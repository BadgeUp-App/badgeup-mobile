import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';

class ScanLogsScreen extends StatefulWidget {
  const ScanLogsScreen({super.key});

  @override
  State<ScanLogsScreen> createState() => _ScanLogsScreenState();
}

class _ScanLogsScreenState extends State<ScanLogsScreen> {
  List<Map<String, dynamic>> _logs = [];
  bool _loading = true;
  String? _error;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      String path = '/albums/scan-logs/';
      if (_filter == 'matched') path += '?matched=true';
      if (_filter == 'unmatched') path += '?matched=false';
      final data = await ApiClient.instance.get(path);
      final results = data is List ? data : (data['results'] as List?) ?? [];
      if (!mounted) return;
      setState(() {
        _logs = results.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterChips(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
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
          Expanded(
            child: Text(
              'Scan Logs',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: AppTheme.onSurface,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${_logs.length}',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          _chip('Todos', 'all'),
          const SizedBox(width: 8),
          _chip('Con match', 'matched'),
          const SizedBox(width: 8),
          _chip('Sin match', 'unmatched'),
        ],
      ),
    );
  }

  Widget _chip(String label, String value) {
    final selected = _filter == value;
    return GestureDetector(
      onTap: () {
        setState(() => _filter = value);
        _fetchLogs();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppTheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppTheme.error),
              const SizedBox(height: 12),
              Text(
                'Error al cargar logs',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(onPressed: _fetchLogs, child: const Text('Reintentar')),
            ],
          ),
        ),
      );
    }
    if (_logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.document_scanner_outlined,
                size: 56, color: AppTheme.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text(
              'Sin registros',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Los scans apareceran aqui',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchLogs,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
        itemCount: _logs.length,
        itemBuilder: (ctx, i) => _LogTile(
          log: _logs[i],
          onTap: () => _openDetail(_logs[i]),
        ),
      ),
    );
  }

  void _openDetail(Map<String, dynamic> log) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _ScanLogDetail(log: log)),
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.log, required this.onTap});
  final Map<String, dynamic> log;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final matched = log['matched'] == true;
    final detected = (log['detected_items'] as String?) ?? '';
    final stickerName = log['sticker_name'] as String?;
    final albumTitle = log['album_title'] as String?;
    final confidence = (log['confidence'] as num?)?.toDouble() ?? 0.0;
    final createdAt = log['created_at'] as String? ?? '';
    final photoUrl = (log['photo_url'] as String?) ?? (log['photo'] as String?);
    final username = log['username'] as String? ?? '';

    String timeAgo = '';
    if (createdAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(createdAt);
        final diff = DateTime.now().difference(dt);
        if (diff.inMinutes < 60) {
          timeAgo = 'hace ${diff.inMinutes}m';
        } else if (diff.inHours < 24) {
          timeAgo = 'hace ${diff.inHours}h';
        } else {
          timeAgo = 'hace ${diff.inDays}d';
        }
      } catch (_) {}
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: matched
                ? AppTheme.primary.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: photoUrl != null && photoUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: photoUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Icon(
                        Icons.image_not_supported_outlined,
                        size: 22,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    )
                  : Icon(
                      Icons.camera_alt_outlined,
                      size: 22,
                      color: AppTheme.onSurfaceVariant,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detected.isNotEmpty ? detected : 'No detectado',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (matched && stickerName != null)
                    Text(
                      '${albumTitle ?? ''} - $stickerName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    )
                  else
                    Text(
                      'Sin sticker disponible',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (username.isNotEmpty) ...[
                        Text(
                          username,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        timeAgo,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: matched
                        ? AppTheme.primary.withValues(alpha: 0.12)
                        : AppTheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    matched ? 'Match' : 'Miss',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: matched ? AppTheme.primary : AppTheme.error,
                    ),
                  ),
                ),
                if (confidence > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${(confidence * 100).toInt()}%',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: AppTheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _ScanLogDetail extends StatelessWidget {
  const _ScanLogDetail({required this.log});
  final Map<String, dynamic> log;

  @override
  Widget build(BuildContext context) {
    final photoUrl = (log['photo_url'] as String?) ?? (log['photo'] as String?);
    final matched = log['matched'] == true;
    final detected = (log['detected_items'] as String?) ?? 'No detectado';
    final stickerName = log['sticker_name'] as String?;
    final albumTitle = log['album_title'] as String?;
    final confidence = (log['confidence'] as num?)?.toDouble() ?? 0.0;
    final username = log['username'] as String? ?? '';
    final createdAt = log['created_at'] as String? ?? '';
    final aiResponse = log['ai_response'] as Map<String, dynamic>? ?? {};

    final matches = (aiResponse['matches'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final funFact = aiResponse['fun_fact'] as String? ?? '';

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
                    'Detalle del Scan',
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: matched
                          ? AppTheme.primary.withValues(alpha: 0.12)
                          : AppTheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      matched ? 'Match' : 'Miss',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: matched ? AppTheme.primary : AppTheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 60),
                children: [
                  if (photoUrl != null && photoUrl.isNotEmpty)
                    Container(
                      height: 260,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: AppTheme.surfaceContainerLowest,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CachedNetworkImage(
                        imageUrl: photoUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorWidget: (_, __, ___) => Center(
                          child: Icon(Icons.broken_image_outlined,
                              size: 48, color: AppTheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  _infoRow('Detectado', detected),
                  if (matched && stickerName != null)
                    _infoRow('Sticker', stickerName),
                  if (albumTitle != null)
                    _infoRow('Album', albumTitle),
                  if (confidence > 0)
                    _infoRow('Confianza', '${(confidence * 100).toInt()}%'),
                  if (username.isNotEmpty)
                    _infoRow('Usuario', username),
                  if (createdAt.isNotEmpty)
                    _infoRow('Fecha', _formatDate(createdAt)),
                  if (funFact.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryContainer.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fun Fact',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            funFact,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppTheme.onSurface,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (matches.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'DETALLE IA',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...matches.map((m) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  (m['detected_item'] as String?) ?? '',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.onSurface,
                                  ),
                                ),
                              ),
                              Text(
                                '${((m['confidence'] as num?)?.toDouble() ?? 0) * 100 ~/ 1}%',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                          if ((m['reason'] as String?)?.isNotEmpty == true) ...[
                            const SizedBox(height: 6),
                            Text(
                              m['reason'] as String,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppTheme.onSurfaceVariant,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    )),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}
