import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/sticker.dart';
import 'rarity_badge.dart';

class StickerCard extends StatelessWidget {
  final Sticker sticker;
  final VoidCallback? onTap;

  const StickerCard({super.key, required this.sticker, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: sticker.unlocked ? onTap : null,
      child: AnimatedOpacity(
        opacity: sticker.unlocked ? 1.0 : 0.45,
        duration: const Duration(milliseconds: 300),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (sticker.unlocked)
                      Hero(
                        tag: 'sticker_${sticker.id}',
                        child: CachedNetworkImage(
                          imageUrl: sticker.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.emoji_events_rounded, size: 40, color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      Container(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.lock_rounded, size: 36, color: Colors.grey),
                        ),
                      ),
                    if (sticker.unlocked)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: RarityBadge(rarity: sticker.rarity),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sticker.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${sticker.points} pts',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                        if (sticker.unlocked)
                          const Icon(Icons.check_circle, size: 14, color: Color(0xFF10B981)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
