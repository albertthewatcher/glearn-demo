import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../data/conversation_data.dart';
import '../theme.dart';
import '../config/api_config.dart';

class AICounselingBox extends StatefulWidget {
  const AICounselingBox({super.key, this.messages});

  final List<Message>? messages;

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

  Future<void> _initializeModel() async {
    try {
      print('🔍 OpenAI 클라이언트 초기화 시도');
      print('🔑 API 키 확인: ${ApiConfig.openaiApiKey.substring(0, 10)}...');

      // 시스템 메시지 추가
      _chatHistory = [
        {
          'role': 'system',
          'content':
              '당신은 친절하고 전문적인 AI 튜터입니다. 학생의 질문에 대해 명확하고 도움이 되는 답변을 제공해주세요. 학습 관련 질문에 특히 잘 답변하며, 필요시 관련 강의나 자료를 추천할 수 있습니다. 답변은 한국어로 작성해주세요.',
        },
      ];

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
        final assistantMessage =
            responseData['choices'][0]['message']['content'] as String;
        print(
          '✅ 응답 받음: ${assistantMessage.substring(0, assistantMessage.length > 50 ? 50 : assistantMessage.length)}...',
        );

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
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 48,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      SelectableText(
                        'AI Tutor와 대화를 시작해보세요!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                )
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
                    return _ChatMessage(message: message);
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
  const _ChatMessage({required this.message});
  final Message message;

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
                _MessageBody(content: message.content),
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
  const _MessageBody({required this.content});
  final String content;

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
          textSpans.add(
            TextSpan(text: line + (isLastLine ? '' : '\n'), style: base),
          );
        } else {
          final before = line.substring(0, match.start);
          final mid = line.substring(match.start, match.end);
          final after = line.substring(match.end);
          textSpans.addAll([
            TextSpan(text: before, style: base),
            TextSpan(
              text: mid,
              style: base?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.redAccent,
              ),
            ),
            TextSpan(text: after + (isLastLine ? '' : '\n'), style: base),
          ]);
        }
      }
    }

    return SelectableText.rich(TextSpan(children: textSpans));
  }
}
