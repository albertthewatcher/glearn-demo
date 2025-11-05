import 'package:flutter/material.dart';
import 'recommended_card.dart';

class RecommendedCoursesSection extends StatelessWidget {
  const RecommendedCoursesSection({
    super.key,
    this.onVideoSelected,
  });

  final Function(String videoUrl)? onVideoSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SelectableText(
              'Recommended Courses',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      size: 12,
                    ),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                    ),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              RecommendedCard(
                category: 'Business',
                title:
                    '5 Takeaways For The Lean Startup\nBusiness Principles For Success',
                subtitle: 'Eric Ries, Author Of The Lean Startup',
                progress: 0.3,
                progressColor: Colors.blue,
                thumbnail: const AssetImage(
                  'assets/images/thumbnail-lean.jpg',
                ),
                onTap: () {
                  onVideoSelected?.call('https://youtu.be/RSaIOCHbuYw?si=6P1QZ4l9FsKw768s');
                },
              ),
              const SizedBox(width: 14),
              RecommendedCard(
                category: 'Technology',
                title:
                    'Sound On For Sora 2\nIntroducing The Sora App',
                subtitle:
                    'OpenAI, AI Research & Deployment Company',
                progress: 0.6,
                progressColor: Colors.green,
                thumbnail: const AssetImage(
                  'assets/images/thumbnail-sora.jpg',
                ),
                onTap: () {
                  onVideoSelected?.call('https://youtu.be/1PaoWKvcJP0?si=mCELNYi_FYl98MvI');
                },
              ),
              const SizedBox(width: 14),
              RecommendedCard(
                category: 'Communications',
                title:
                    "Secret To Great Public Speaking\nby TED Founder",
                subtitle: 'Chris Anderson, Head Of TED',
                progress: 0.8,
                progressColor: Colors.orange,
                thumbnail: const AssetImage(
                  'assets/images/thumbnail-ted.jpg',
                ),
                onTap: () {
                  onVideoSelected?.call('https://youtu.be/-FOCpMAww28?si=oVJhZax21eDodKjP');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

