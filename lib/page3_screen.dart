import 'package:flutter/material.dart';

import 'widgets/sidebar.dart';
import 'widgets/top_hero_banner.dart';
import 'widgets/recommended_card.dart';
import 'widgets/ai_counseling_box.dart';
import 'widgets/profile_panel.dart';
import 'data/conversation_data_page3.dart';

class Page3Screen extends StatelessWidget {
  const Page3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E5E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Sidebar(),
              const SizedBox(width: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TopHeroBanner(),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SelectableText(
                            'Recommended Courses',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
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
                          children: const [
                            RecommendedCard(
                              category: 'Business',
                              title:
                                  '5 Takeaways For The Lean Startup\nBusiness Principles For Success',
                              subtitle: 'Eric Ries, Author Of The Lean Startup',
                              progress: 0.3,
                              progressColor: Colors.blue,
                              thumbnail: AssetImage(
                                'assets/images/thumbnail-lean.jpg',
                              ),
                            ),
                            SizedBox(width: 14),
                            RecommendedCard(
                              category: 'Technology',
                              title:
                                  'Sound On For Sora 2\nIntroducing The Sora App',
                              subtitle:
                                  'OpenAI, AI Research & Deployment Company',
                              progress: 0.6,
                              progressColor: Colors.green,
                              thumbnail: AssetImage(
                                'assets/images/thumbnail-sora.jpg',
                              ),
                            ),
                            SizedBox(width: 14),
                            RecommendedCard(
                              category: 'Communications',
                              title:
                                  "Secret To Great Public Speaking\nby TED Founder",
                              subtitle: 'Chris Anderson, Head Of TED',
                              progress: 0.8,
                              progressColor: Colors.orange,
                              thumbnail: AssetImage(
                                'assets/images/thumbnail-ted.jpg',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      AICounselingBox(messages: ConversationDataPage3.messages),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const ProfilePanel(),
            ],
          ),
        ),
      ),
    );
  }
}
