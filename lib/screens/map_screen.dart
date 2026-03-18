import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Mapa de Capturas'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explora donde se han capturado stickers',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
            const SizedBox(height: 16),
            Container(
              height: 360,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFFDBEAFE), Color(0xFFE0E7FF), Color(0xFFD1FAE5)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                children: [
                  _mapPin(left: 60, top: 80, label: 'LA'),
                  _mapPin(left: 110, top: 130, label: 'MX'),
                  _mapPin(left: 210, top: 70, label: 'EU'),
                  _mapPin(left: 280, top: 110, label: 'IN'),
                  _mapPin(left: 190, top: 170, label: 'AF'),
                  _mapPin(left: 170, top: 240, label: 'BR'),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.map, size: 32, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              const Text(
                                'Mapa interactivo',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF374151),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Se integrara Google Maps.\nFuncionalidad pendiente.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Capturas recientes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            _captureItem(context, 'Porsche 911 GT3', 'Tonala, Jalisco', '30/11/2025'),
            _captureItem(context, 'Audi R8 2020', 'Tlaquepaque, Jalisco', '03/12/2025'),
            _captureItem(context, 'Charger SRT Hellcat', 'Zapopan, Jalisco', '01/12/2025'),
            _captureItem(context, 'Ford Mustang GT', 'Zapopan, Jalisco', '28/11/2025'),
          ],
        ),
      ),
    );
  }

  Widget _mapPin({required double left, required double top, required String label}) {
    return Positioned(
      left: left,
      top: top,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.errorRed,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.errorRed.withValues(alpha: 0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.directions_car, size: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _captureItem(BuildContext context, String name, String location, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, size: 18, color: AppTheme.errorRed),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Text(location, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
          Text(date, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
        ],
      ),
    );
  }
}
