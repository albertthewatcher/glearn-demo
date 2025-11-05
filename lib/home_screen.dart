import 'package:flutter/material.dart';

import 'widgets/sidebar.dart';
import 'widgets/top_hero_banner.dart';
import 'widgets/recommended_courses_section.dart';
import 'widgets/ai_counseling_box.dart';
import 'widgets/profile_panel.dart';
import 'widgets/youtube_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedVideoUrl;
  String? _selectedVideoTitle;
  String? _selectedVideoDescription;

  void _handleVideoSelected(String videoUrl) {
    setState(() {
      _selectedVideoUrl = videoUrl;
      // 영상 정보는 YouTubePlayer에서 로드되므로 여기서는 URL만 저장
      _selectedVideoTitle = null;
      _selectedVideoDescription = null;
    });
  }

  void _closeVideoPlayer() {
    setState(() {
      _selectedVideoUrl = null;
      _selectedVideoTitle = null;
      _selectedVideoDescription = null;
    });
  }

  void _onVideoInfoLoaded(String title, String description) {
    setState(() {
      _selectedVideoTitle = title;
      _selectedVideoDescription = description;
    });
  }

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
              Sidebar(
                onReset: _closeVideoPlayer,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 유튜브 플레이어가 구동 중일 때는 배너 숨김
                      if (_selectedVideoUrl == null) ...[
                        const TopHeroBanner(),
                        const SizedBox(height: 30),
                      ],
                      // 조건부 렌더링: 영상이 선택되었으면 플레이어, 아니면 RecommendedCoursesSection
                      _selectedVideoUrl != null
                          ? YouTubePlayer(
                              videoUrl: _selectedVideoUrl!,
                              onClose: _closeVideoPlayer,
                              onVideoInfoLoaded: _onVideoInfoLoaded,
                            )
                          : RecommendedCoursesSection(
                              onVideoSelected: _handleVideoSelected,
                            ),
                      const SizedBox(height: 24),
                      AICounselingBox(
                        key: ValueKey(_selectedVideoUrl ?? 'default'),
                        onVideoSelected: _handleVideoSelected,
                        selectedVideoUrl: _selectedVideoUrl,
                        selectedVideoTitle: _selectedVideoTitle,
                        selectedVideoDescription: _selectedVideoDescription,
                      ),
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
