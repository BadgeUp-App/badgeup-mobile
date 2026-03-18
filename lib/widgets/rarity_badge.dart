import 'package:flutter/material.dart';
import '../models/sticker.dart';
import '../theme/app_theme.dart';

class RarityBadge extends StatelessWidget {
  final Rarity rarity;

  const RarityBadge({super.key, required this.rarity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _textColor,
        ),
      ),
    );
  }

  String get _label {
    switch (rarity) {
      case Rarity.comun:
        return 'Comun';
      case Rarity.raro:
        return 'Raro';
      case Rarity.epico:
        return 'Epico';
      case Rarity.legendario:
        return 'Legendario';
    }
  }

  Color get _backgroundColor {
    switch (rarity) {
      case Rarity.comun:
        return const Color(0xFFE5E7EB);
      case Rarity.raro:
        return const Color(0xFFDBEAFE);
      case Rarity.epico:
        return const Color(0xFFEDE9FE);
      case Rarity.legendario:
        return const Color(0xFFFEF3C7);
    }
  }

  Color get _textColor {
    switch (rarity) {
      case Rarity.comun:
        return AppTheme.rarityCommon;
      case Rarity.raro:
        return AppTheme.rarityRare;
      case Rarity.epico:
        return AppTheme.rarityEpic;
      case Rarity.legendario:
        return AppTheme.rarityLegendary;
    }
  }
}
