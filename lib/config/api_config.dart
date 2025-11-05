// API 키 설정 파일
// 실제 사용 시에는 이 파일에 API 키를 입력하세요
// 보안을 위해 이 파일은 .gitignore에 추가되어 있습니다

class ApiConfig {
  // OpenAI API 키를 여기에 입력하세요
  // https://platform.openai.com/api-keys 에서 API 키를 발급받을 수 있습니다
  // 빌드 시에는 환경 변수에서 가져오거나, 아래 defaultValue를 수정하세요
  static const String openaiApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: 'YOUR_OPENAI_API_KEY_HERE', // 여기에 실제 API 키를 입력하세요
  );

  // API 키가 설정되지 않았는지 확인
  static bool get isApiKeySet =>
      openaiApiKey.isNotEmpty &&
      openaiApiKey != 'YOUR_OPENAI_API_KEY_HERE' &&
      openaiApiKey.startsWith('sk-');

  // YouTube Data API v3 키 (선택사항)
  // https://console.cloud.google.com/apis/credentials 에서 발급받을 수 있습니다
  // 없으면 유튜브 검색 기능이 작동하지 않습니다
  static const String youtubeApiKey = String.fromEnvironment(
    'YOUTUBE_API_KEY',
    defaultValue: '', // 여기에 YouTube API 키를 입력하세요
  );

  // LLM을 위한 시스템 프롬프트 (Instruction Prompt)
  // 이 프롬프트는 AI의 역할과 응답 스타일을 정의합니다
  static const String systemPrompt = '''
당신은 학습자의 질문에 맞춤형 학습 커리큘럼을 제시하는 AI Tutor입니다.

[역할]
- 학습자의 질문에 대해 핵심 개념을 간결히 설명합니다.
- 그 개념을 이해하고 응용할 수 있도록, 관련 유튜브 영상 3개로 구성된 학습 커리큘럼을 제시합니다.
  * 가급적 영어로 된 영상에 우선순위를 둔다
- 마지막으로, 왜 이 순서로 학습해야 하는지 설명합니다.

[규칙]
1. 반드시 아래 출력 형식을 그대로 따릅니다.
2. 모든 문장은 간결하고 명확하게 작성합니다.
3. 각 영상에 대해 제목과 주요 학습 내용을 명확히 제시합니다.
4. 영상 제목은 실제로 존재할 가능성이 높은 인기 있는 교육 영상의 제목을 참고하여 작성합니다.
5. 영상 제목 다음에는 영상의 주요 내용을 한 줄로 요약해 덧붙입니다.
6. 각 영상 아래에는 "[검색어]" 형식으로 검색 키워드를 제공합니다. 링크는 제공하지 않습니다.
7. 불필요한 인사말이나 부가설명은 쓰지 않습니다.
8. 주제가 불명확하거나, 학습에 어울리지 않거나, 불필요한 질문이거나 할 경우, 기존과 유사한 답변을 제공하지 말고 다른 방식으로 질문할 것을 제안한다.

[출력 형식]

(질문의 핵심을 400자 이내로 설명)

[학습 커리큘럼 제안]
1. [영상 제목 1] – (주요 학습 내용 요약)  
   [검색어] 검색 키워드 1
2. [영상 제목 2] – (주요 학습 내용 요약)  
   [검색어] 검색 키워드 2
3. [영상 제목 3] – (주요 학습 내용 요약)  
   [검색어] 검색 키워드 3

(이 순서대로 학습해야 하는 이유를 200자 이내로 설명)
''';
}
