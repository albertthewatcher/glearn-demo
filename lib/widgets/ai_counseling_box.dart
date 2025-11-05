import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../data/conversation_data.dart';
import '../theme.dart';
import '../config/api_config.dart';

class AICounselingBox extends StatefulWidget {
  const AICounselingBox({
    super.key,
    this.messages,
    this.onVideoSelected,
    this.selectedVideoUrl,
    this.selectedVideoTitle,
    this.selectedVideoDescription,
  });

  final List<Message>? messages;
  final Function(String videoUrl)? onVideoSelected;
  final String? selectedVideoUrl;
  final String? selectedVideoTitle;
  final String? selectedVideoDescription;

  @override
  State<AICounselingBox> createState() => _AICounselingBoxState();
}

class _AICounselingBoxState extends State<AICounselingBox> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = [];
  bool _isLoading = false;
  List<Map<String, String>> _chatHistory = [];
  bool _modelInitialized = false;
  String? _modelError;

  @override
  void initState() {
    super.initState();
    _messages = [];
    _initializeModel();
  }

  @override
  void didUpdateWidget(AICounselingBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 영상이 선택되거나 변경되었을 때 시스템 프롬프트 업데이트
    final videoUrlChanged = widget.selectedVideoUrl != oldWidget.selectedVideoUrl;
    final videoTitleChanged = widget.selectedVideoTitle != oldWidget.selectedVideoTitle;
    final videoDescriptionChanged = widget.selectedVideoDescription != oldWidget.selectedVideoDescription;
    
    // 영상 URL이 변경되거나 영상 정보가 로드되면 프롬프트 업데이트
    if (videoUrlChanged || videoTitleChanged || videoDescriptionChanged) {
      _updateSystemPrompt();
      
      // 영상이 새로 선택된 경우 채팅 히스토리 초기화 (시스템 메시지 제외)
      if (widget.selectedVideoUrl != null && oldWidget.selectedVideoUrl == null) {
        // 시스템 메시지만 남기고 나머지 제거
        final systemMessage = _chatHistory.isNotEmpty && _chatHistory[0]['role'] == 'system'
            ? _chatHistory[0]
            : null;
        _chatHistory.clear();
        if (systemMessage != null) {
          _chatHistory.add(systemMessage);
        }
        // 메시지 목록도 초기화
        setState(() {
          _messages = [];
        });
      }
    }
  }

  void _updateSystemPrompt() {
    if (widget.selectedVideoUrl != null) {
      // 영상이 선택된 경우 - 해당 영상에 대한 Tutor로 변경
      final hasVideoInfo = widget.selectedVideoTitle != null && 
                           widget.selectedVideoDescription != null;
      
      String videoInfoSection = '';
      if (hasVideoInfo) {
        videoInfoSection = '''
[현재 시청 중인 영상]
제목: ${widget.selectedVideoTitle ?? ''}
설명: ${widget.selectedVideoDescription != null && widget.selectedVideoDescription!.length > 300 
  ? widget.selectedVideoDescription!.substring(0, 300) + '...' 
  : widget.selectedVideoDescription ?? ''}
''';
      } else {
        videoInfoSection = '''
[현재 시청 중인 영상]
영상 URL: ${widget.selectedVideoUrl}
영상 정보를 로드하는 중입니다...
''';
      }
      
      final videoSpecificPrompt = '''
당신은 현재 시청 중인 YouTube 영상에 대한 전문 AI Tutor입니다.

$videoInfoSection
[역할]
- 학습자가 현재 시청 중인 영상의 내용을 이해하고 학습할 수 있도록 도와줍니다.
- 영상에서 다루는 개념, 내용, 예시에 대해 설명하고 질문에 답변합니다.
- 영상의 핵심 내용을 요약하고, 추가 학습 자료를 제안할 수 있습니다.

[규칙]
1. 반드시 현재 시청 중인 영상의 내용에만 집중합니다.
2. 영상과 관련 없는 질문에는 정중하게 현재 영상에 대한 질문을 요청합니다.
3. 영상의 내용을 바탕으로 명확하고 도움이 되는 답변을 제공합니다.
4. 답변은 한국어로 작성합니다.
5. 간결하고 이해하기 쉽게 설명합니다.
6. 영상 정보가 아직 로드 중인 경우, 사용자에게 잠시 기다려달라고 안내할 수 있습니다.
''';
      
      // 시스템 메시지 업데이트
      if (_chatHistory.isNotEmpty && _chatHistory[0]['role'] == 'system') {
        _chatHistory[0] = {
          'role': 'system',
          'content': videoSpecificPrompt,
        };
      } else {
        _chatHistory.insert(0, {
          'role': 'system',
          'content': videoSpecificPrompt,
        });
      }
    } else {
      // 영상이 선택되지 않은 경우 - 기본 프롬프트로 복원
      if (_chatHistory.isNotEmpty && _chatHistory[0]['role'] == 'system') {
        _chatHistory[0] = {
          'role': 'system',
          'content': ApiConfig.systemPrompt,
        };
      } else {
        _chatHistory.insert(0, {
          'role': 'system',
          'content': ApiConfig.systemPrompt,
        });
      }
    }
  }

  Future<void> _initializeModel() async {
    try {
      print('🔍 OpenAI 클라이언트 초기화 시도');
      print('🔑 API 키 확인: ${ApiConfig.openaiApiKey.substring(0, 10)}...');

      // 시스템 메시지 추가 (ApiConfig에서 가져옴)
      _chatHistory = [
        {
          'role': 'system',
          'content': ApiConfig.systemPrompt,
        },
      ];

      // 영상이 선택된 경우 프롬프트 업데이트
      _updateSystemPrompt();

      _modelInitialized = true;
      _modelError = null;
      print('✅ OpenAI 클라이언트 초기화 성공');

      if (mounted) {
        setState(() {});
      }
    } catch (e, stackTrace) {
      _modelError = e.toString();
      print('❌ OpenAI 클라이언트 초기화 실패: $e');
      print('📍 상세 에러: $stackTrace');
      _modelInitialized = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();

    if (text.isEmpty || _isLoading) return;

    final userMessage = Message(
      sender: 'ohtani',
      senderName: 'Ohtani',
      avatarAsset: 'assets/images/profile_ohtani.webp',
      content: text,
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _textController.clear();
    _scrollToBottom();

    try {
      if (!_modelInitialized) {
        throw Exception('모델이 초기화되지 않았습니다. 페이지를 새로고침해주세요.');
      }

      print('📤 메시지 전송: $text');

      // 사용자 메시지를 채팅 히스토리에 추가
      _chatHistory.add({
        'role': 'user',
        'content': text,
      });

      // OpenAI API 호출
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConfig.openaiApiKey}',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': _chatHistory,
          'temperature': 0.7,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('⏱️ 타임아웃 발생');
          throw TimeoutException(
            '요청 시간이 초과되었습니다. 네트워크 연결을 확인해주세요.',
            const Duration(seconds: 30),
          );
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        var assistantMessage =
            responseData['choices'][0]['message']['content'] as String;
        print(
          '✅ 응답 받음: ${assistantMessage.substring(0, assistantMessage.length > 50 ? 50 : assistantMessage.length)}...',
        );

        // 유튜브 검색어를 실제 링크로 대체
        assistantMessage = await _replaceSearchKeywordsWithLinks(assistantMessage);

        // AI 응답을 채팅 히스토리에 추가
        _chatHistory.add({
          'role': 'assistant',
          'content': assistantMessage,
        });

        // AI 응답 추가
        final aiMessage = Message(
          sender: 'ai_tutor',
          senderName: 'AI Tutor',
          avatarAsset: null,
          content: assistantMessage,
        );

        setState(() {
          _messages.add(aiMessage);
          _isLoading = false;
        });

        _scrollToBottom();
      } else {
        throw Exception(
          'API 오류: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e, stackTrace) {
      print('❌ 에러 발생: $e');
      print('📍 스택 트레이스: $stackTrace');

      // 마지막 사용자 메시지를 히스토리에서 제거 (실패한 요청이므로)
      if (_chatHistory.isNotEmpty &&
          _chatHistory.last['role'] == 'user') {
        _chatHistory.removeLast();
      }

      setState(() {
        _isLoading = false;
        final errorMessage = e is TimeoutException
            ? '요청 시간이 초과되었습니다. 네트워크 연결을 확인해주세요.'
            : '''오류가 발생했습니다: ${e.toString()}

🔍 문제 해결 방법:
1. OpenAI Platform (https://platform.openai.com/api-keys)에서 API 키 확인
2. API 키가 유효한지 확인 (새로 발급받아보세요)
3. API 키에 충분한 크레딧이 있는지 확인
4. 네트워크 연결을 확인해주세요''';

        _messages.add(
          Message(
            sender: 'ai_tutor',
            senderName: 'AI Tutor',
            avatarAsset: null,
            content: errorMessage,
          ),
        );
      });
      _scrollToBottom();
    }
  }

  Future<String> _searchYouTubeVideo(String query) async {
    if (ApiConfig.youtubeApiKey.isEmpty) {
      // API 키가 없으면 검색 URL 반환
      return 'https://www.youtube.com/results?search_query=${Uri.encodeComponent(query)}';
    }

    try {
      final url = Uri.parse(
        'https://www.googleapis.com/youtube/v3/search'
        '?part=snippet&type=video&maxResults=1&q=${Uri.encodeComponent(query)}'
        '&key=${ApiConfig.youtubeApiKey}',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>?;
        
        if (items != null && items.isNotEmpty) {
          final videoId = items[0]['id']['videoId'] as String;
          return 'https://www.youtube.com/watch?v=$videoId';
        }
      }
    } catch (e) {
      print('❌ 유튜브 검색 실패: $e');
    }
    // 검색 실패 시 검색 URL 반환
    return 'https://www.youtube.com/results?search_query=${Uri.encodeComponent(query)}';
  }

  Future<String> _replaceSearchKeywordsWithLinks(String text) async {
    // [검색어] 패턴을 찾아서 실제 유튜브 링크로 대체
    final searchPattern = RegExp(r'\[검색어\]\s*(.+?)(?=\n|$)');
    final matches = searchPattern.allMatches(text);
    
    String result = text;
    int offset = 0;
    
    for (final match in matches) {
      final searchQuery = match.group(1)?.trim() ?? '';
      if (searchQuery.isNotEmpty) {
        print('🔍 유튜브 검색: $searchQuery');
        final videoUrl = await _searchYouTubeVideo(searchQuery);
        
        // [검색어] 키워드를 실제 링크로 대체
        final before = result.substring(0, match.start + offset);
        final after = result.substring(match.end + offset);
        result = '$before$videoUrl$after';
        offset += videoUrl.length - match.group(0)!.length;
        print('✅ 링크 생성: $videoUrl');
      }
    }
    
    return result;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onExampleQuestionTap(String question) {
    _textController.text = question;
    _sendMessage();
  }

  Widget _buildExampleQuestions(BuildContext context) {
    final isVideoSelected = widget.selectedVideoUrl != null;
    
    final exampleQuestions = isVideoSelected
        ? [
            '중요한 포인트를 요약 정리해줘',
            '내가 이 강의에서 무엇을 얻을 수 있는가?',
            '핵심 개념을 이해하기 어려운데 쉽게 설명해줘',
          ]
        : [
            'Lean Startup에 대해 알아보고 싶어',
            '스포츠 산업의 전망은 어떨까?',
            'LLM에 대한 이해를 넓히고 싶다면?',
          ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: SelectableText(
              'AI Tutor와 대화를 시작해보세요!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SelectableText(
              '예시 질문',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...exampleQuestions.map((question) => Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
                child: InkWell(
                  onTap: () => _onExampleQuestionTap(question),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 18,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SelectableText(
                            question,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!ApiConfig.isApiKeySet) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          SelectableText(
            'AI Tutor',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    SelectableText(
                      'API 키가 설정되지 않았습니다',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SelectableText(
                  'lib/config/api_config.dart 파일에 OpenAI API 키를 설정해주세요.\n'
                  'API 키는 https://platform.openai.com/api-keys 에서 발급받을 수 있습니다.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        SelectableText(
          'AI Tutor',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        if (!_modelInitialized && _modelError != null)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    SelectableText(
                      '모델 초기화 실패',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SelectableText(
                  '모델 초기화에 실패했습니다.\n에러: $_modelError\n\nAPI 키를 확인해주세요.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        SizedBox(
          height: 400, // 고정 높이 설정 (필요에 따라 조정 가능)
          child: _messages.isEmpty && !_isLoading
              ? _buildExampleQuestions(context)
              : ListView.separated(
                  controller: _scrollController,
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isLoading) {
                      return const _LoadingIndicator();
                    }
                    final message = _messages[index];
                    return _ChatMessage(
                      message: message,
                      onVideoSelected: widget.onVideoSelected,
                    );
                  },
                ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                enabled: !_isLoading && _modelInitialized,
                decoration: InputDecoration(
                  hintText: 'Ask Anything…',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: (_isLoading || !_modelInitialized) ? null : _sendMessage,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white70,
                        ),
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white70),
            ),
          ],
        ),
      ],
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.secondary.withOpacity(0.3),
          child: const Icon(Icons.smart_toy, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                ),
              ),
              const SizedBox(width: 8),
              SelectableText(
                'AI가 생각 중...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChatMessage extends StatelessWidget {
  const _ChatMessage({
    required this.message,
    this.onVideoSelected,
  });
  final Message message;
  final Function(String)? onVideoSelected;

  @override
  Widget build(BuildContext context) {
    final isOhtani = message.sender == 'ohtani';
    final scheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: isOhtani
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (!isOhtani) ...[_buildAvatar(context), const SizedBox(width: 8)],
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isOhtani
                  ? scheme.primary.withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  message.senderName,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                _MessageBody(
                  content: message.content,
                  onVideoSelected: onVideoSelected,
                ),
              ],
            ),
          ),
        ),
        if (isOhtani) ...[const SizedBox(width: 8), _buildAvatar(context)],
      ],
    );
  }

  Widget _buildAvatar(BuildContext context) {
    if (message.avatarAsset != null) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: AssetImage(message.avatarAsset!),
      );
    } else {
      return CircleAvatar(
        radius: 24,
        backgroundColor: Theme.of(
          context,
        ).colorScheme.secondary.withOpacity(0.3),
        child: const Icon(Icons.smart_toy, color: Colors.white, size: 48),
      );
    }
  }
}

class _MessageBody extends StatelessWidget {
  const _MessageBody({
    required this.content,
    this.onVideoSelected,
  });
  final String content;
  final Function(String)? onVideoSelected;

  bool _isYouTubeUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.contains('youtube.com') || uri.host.contains('youtu.be');
    } catch (e) {
      return false;
    }
  }

  Future<void> _handleUrlTap(String url) async {
    final fullUrl = url.startsWith('www.') ? 'https://$url' : url;
    
    // YouTube URL인 경우 콜백 호출
    if (_isYouTubeUrl(fullUrl) && onVideoSelected != null) {
      onVideoSelected!(fullUrl);
    } else {
      // 다른 URL은 외부 브라우저로 열기
      final uri = Uri.parse(fullUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  List<TextSpan> _parseTextWithUrls(String text, TextStyle? baseStyle) {
    final textSpans = <TextSpan>[];
    // URL 패턴: http://, https://, www.로 시작하는 URL 또는 youtube.com/watch 등의 패턴
    final urlPattern = RegExp(
      r'(https?://[^\s]+|www\.[^\s]+|youtube\.com/[^\s]+|youtu\.be/[^\s]+)',
      caseSensitive: false,
    );

    int lastIndex = 0;
    final matches = urlPattern.allMatches(text);

    for (final match in matches) {
      // URL 이전 텍스트
      if (match.start > lastIndex) {
        textSpans.add(
          TextSpan(
            text: text.substring(lastIndex, match.start),
            style: baseStyle,
          ),
        );
      }

      // URL 부분
      final url = match.group(0)!;
      // www.로 시작하는 경우 http://를 추가
      final fullUrl = url.startsWith('www.') ? 'https://$url' : url;
      
      textSpans.add(
        TextSpan(
          text: url,
          style: baseStyle?.copyWith(
            color: Colors.blueAccent,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => _handleUrlTap(fullUrl),
        ),
      );

      lastIndex = match.end;
    }

    // 남은 텍스트
    if (lastIndex < text.length) {
      textSpans.add(
        TextSpan(
          text: text.substring(lastIndex),
          style: baseStyle,
        ),
      );
    }

    return textSpans.isEmpty ? [TextSpan(text: text, style: baseStyle)] : textSpans;
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Colors.white,
      fontSize: 14,
      height: 1.4,
    );
    final timeIndex = RegExp(r"\(\d{2}:\d{2}-\d{2}:\d{2}\)");

    // 전체 텍스트를 하나의 SelectableText로 처리하여 한 번에 선택 가능하도록
    final textSpans = <TextSpan>[];
    final lines = content.split('\n');
    final numberHeading = RegExp(r'^\d+\.');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final isLastLine = i == lines.length - 1;

      if (numberHeading.hasMatch(line)) {
        // 번호가 있는 헤딩
        textSpans.add(
          TextSpan(
            text: line + (isLastLine ? '' : '\n'),
            style: base?.copyWith(
              fontWeight: FontWeight.w800,
              color: GalaxyColors.yellow,
            ),
          ),
        );
      } else {
        // 일반 텍스트 또는 시간 정보가 있는 텍스트
        final match = timeIndex.firstMatch(line);
        if (match == null) {
          // URL이 포함된 텍스트 파싱
          final parsedSpans = _parseTextWithUrls(
            line + (isLastLine ? '' : '\n'),
            base,
          );
          textSpans.addAll(parsedSpans);
        } else {
          final before = line.substring(0, match.start);
          final mid = line.substring(match.start, match.end);
          final after = line.substring(match.end);
          
          // before와 after에도 URL이 있을 수 있으므로 파싱
          textSpans.addAll(_parseTextWithUrls(before, base));
          textSpans.add(
            TextSpan(
              text: mid,
              style: base?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.redAccent,
              ),
            ),
          );
          textSpans.addAll(
            _parseTextWithUrls(after + (isLastLine ? '' : '\n'), base),
          );
        }
      }
    }

    return SelectableText.rich(TextSpan(children: textSpans));
  }
}
