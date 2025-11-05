import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../theme.dart';
import '../config/api_config.dart';

// Web 전용 import
import 'dart:html' as html show IFrameElement;
import 'dart:ui_web' as ui_web;

class YouTubeVideoInfo {
  final String title;
  final String description;
  final String channelTitle;

  YouTubeVideoInfo({
    required this.title,
    required this.description,
    required this.channelTitle,
  });
}

class YouTubePlayer extends StatefulWidget {
  const YouTubePlayer({
    super.key,
    required this.videoUrl,
    this.onClose,
    this.onVideoInfoLoaded,
  });

  final String videoUrl;
  final VoidCallback? onClose;
  final Function(String title, String description)? onVideoInfoLoaded;

  @override
  State<YouTubePlayer> createState() => _YouTubePlayerState();
}

class _YouTubePlayerState extends State<YouTubePlayer> {
  String? _videoId;
  String? _platformViewId;
  YouTubeVideoInfo? _videoInfo;
  bool _isLoadingInfo = true;

  @override
  void initState() {
    super.initState();
    _videoId = _extractVideoId(widget.videoUrl);
    if (kIsWeb && _videoId != null && _videoId!.isNotEmpty) {
      _platformViewId = 'youtube-${_videoId}-${DateTime.now().millisecondsSinceEpoch}';
      _registerIframe();
      _loadVideoInfo();
    }
  }

  @override
  void didUpdateWidget(YouTubePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoUrl != oldWidget.videoUrl) {
      _videoId = _extractVideoId(widget.videoUrl);
      if (kIsWeb && _videoId != null && _videoId!.isNotEmpty) {
        _platformViewId = 'youtube-${_videoId}-${DateTime.now().millisecondsSinceEpoch}';
        _registerIframe();
        _loadVideoInfo();
      }
    }
  }

  String _extractVideoId(String url) {
    try {
      final uri = Uri.parse(url);
      
      if (uri.host.contains('youtube.com') && uri.queryParameters.containsKey('v')) {
        return uri.queryParameters['v']!;
      }
      
      if (uri.host.contains('youtu.be')) {
        return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
      }
      
      return '';
    } catch (e) {
      return '';
    }
  }

  Future<void> _loadVideoInfo() async {
    if (_videoId == null || _videoId!.isEmpty || ApiConfig.youtubeApiKey.isEmpty) {
      setState(() {
        _isLoadingInfo = false;
      });
      return;
    }

    try {
      final url = Uri.parse(
        'https://www.googleapis.com/youtube/v3/videos'
        '?part=snippet&id=$_videoId&key=${ApiConfig.youtubeApiKey}',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>?;
        
        if (items != null && items.isNotEmpty) {
          final snippet = items[0]['snippet'] as Map<String, dynamic>;
          setState(() {
            _videoInfo = YouTubeVideoInfo(
              title: snippet['title'] as String? ?? '',
              description: snippet['description'] as String? ?? '',
              channelTitle: snippet['channelTitle'] as String? ?? '',
            );
            _isLoadingInfo = false;
          });
          
          // 콜백 호출
          if (widget.onVideoInfoLoaded != null) {
            widget.onVideoInfoLoaded!(
              _videoInfo!.title,
              _videoInfo!.description,
            );
          }
          return;
        }
      }
    } catch (e) {
      print('❌ 영상 정보 로드 실패: $e');
    }
    
    setState(() {
      _isLoadingInfo = false;
    });
  }

  void _registerIframe() {
    if (!kIsWeb || _platformViewId == null || _videoId == null) return;

    ui_web.platformViewRegistry.registerViewFactory(
      _platformViewId!,
      (int viewId) {
        final iframe = html.IFrameElement()
          ..src = 'https://www.youtube.com/embed/$_videoId?autoplay=1'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allowFullscreen = true;
        return iframe;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_videoId == null || _videoId!.isEmpty) {
      return Container(
        height: 420,
        decoration: BoxDecoration(
          color: GalaxyColors.panel.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text('유효하지 않은 YouTube URL입니다'),
        ),
      );
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 1000),
      decoration: BoxDecoration(
        color: GalaxyColors.panel.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 닫기 버튼만 (우측 상단)
          if (widget.onClose != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: widget.onClose,
                    tooltip: '닫기',
                  ),
                ],
              ),
            ),
          // YouTube 플레이어 iframe (크게 표시)
          if (kIsWeb && _platformViewId != null)
            SizedBox(
              height: 420,
              width: double.infinity,
              child: HtmlElementView(viewType: _platformViewId!),
            )
          else
            Container(
              height: 420,
              decoration: const BoxDecoration(color: Colors.black),
              child: const Center(
                child: Text('YouTube 플레이어는 Web에서만 지원됩니다'),
              ),
            ),
          // 영상 제목과 설명
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isLoadingInfo)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_videoInfo != null) ...[
                  SelectableText(
                    _videoInfo!.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    _videoInfo!.channelTitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    _videoInfo!.description.length > 200
                        ? '${_videoInfo!.description.substring(0, 200)}...'
                        : _videoInfo!.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white60,
                      height: 1.4,
                    ),
                    maxLines: 3,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

