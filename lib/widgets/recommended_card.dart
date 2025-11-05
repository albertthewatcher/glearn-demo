import 'package:flutter/material.dart';
import '../theme.dart';

class RecommendedCard extends StatelessWidget {
  const RecommendedCard({
    super.key,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.progressColor,
    required this.thumbnail,
    this.onTap,
  });

  final String category;
  final String title;
  final String subtitle;
  final double progress;
  final Color progressColor;
  final ImageProvider thumbnail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          color: GalaxyColors.panel.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: GalaxyColors.slate,
                image: DecorationImage(image: thumbnail, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: SelectableText(
                      category.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        letterSpacing: 0.6,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Icon(Icons.more_horiz, color: Colors.white70, size: 18),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SelectableText(
                title,
                maxLines: 3,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SelectableText(
                subtitle,
                maxLines: 1,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium!.copyWith(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  color: progressColor,
                  backgroundColor: Colors.white24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
