// API 키 설정 파일
// 실제 사용 시에는 이 파일에 API 키를 입력하세요
// 보안을 위해 이 파일은 .gitignore에 추가되어 있습니다

class ApiConfig {
  // OpenAI API 키를 여기에 입력하세요
  // https://platform.openai.com/api-keys 에서 API 키를 발급받을 수 있습니다
  // 빌드 시에는 환경 변수에서 가져오거나, 플레이스홀더를 사용합니다
  static const String openaiApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: 'YOUR_OPENAI_API_KEY_HERE',
  );

  // API 키가 설정되지 않았는지 확인
  static bool get isApiKeySet =>
      openaiApiKey.isNotEmpty &&
      openaiApiKey != 'YOUR_OPENAI_API_KEY_HERE' &&
      openaiApiKey.startsWith('sk-');
}
