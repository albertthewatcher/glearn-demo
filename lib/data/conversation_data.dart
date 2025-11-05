/// 대화 데이터 모델 및 샘플 데이터
/// 이 파일을 수정하여 대화 내용을 변경할 수 있습니다.
library;

class Message {
  const Message({
    required this.sender,
    required this.senderName,
    required this.avatarAsset,
    required this.content,
  });

  final String sender; // 'ohtani' or 'ai_tutor'
  final String senderName; // 'Ohtani' or 'AI Tutor'
  final String? avatarAsset; // 이미지 경로 (null이면 아이콘 사용)
  final String content;
}

class ConversationData {
  static const List<Message> messages = [
    Message(
      sender: 'ohtani',
      senderName: 'Ohtani',
      avatarAsset: 'assets/images/profile_ohtani.webp',
      content: '''
린 스타트업이 뭐야?
이 컨셉에 대해 자세히 알고 싶은데
''',
    ),
    Message(
      sender: 'ai_tutor',
      senderName: 'AI Tutor',
      avatarAsset: null, // AI Tutor는 아이콘 사용
      content: '''
린 스타트업은 2010년대 들어 IT 산업을 중심으로 유행하기 시작한 창업 방법론이야.
이 개념을 창안한 Eric Ries의 강의를 비롯해, 실제 창업에 방법론을 적용한 다양한 사례를 소개해줄게.

아래 3개의 강의를 차례대로 보면 개념 → 실천 → 검증까지 흐름을 빠르게 잡을 수 있어.

1. [12:33] 린 스타트업 핵심 개념 정리 (문제-해결 적합성 → 제품-시장 적합성)
   - 이 강의의 핵심은 가설을 세우고 가장 위험한 가정을 먼저 검증해. MVP로 빠르게 학습하는 것이 관건이야.
   - 🔗 youtu.be/G-wwOK4X0lc?si=roOoxJ3drnajN5yN

2. [01:02:51] MVP와 반복(Iteration) 전략, 실전 적용 사례
   - 이 강의의 핵심은 최소 기능 제품(MVP)을 작게 정의하고, 정성/정량 데이터로 개선 사이클을 돌리는 것이야.
   - 🔗 youtu.be/fEvKo90qBns?si=iGpSPpe4jO6GGwCa

3. [52:13] 계량 지표와 피벗(Pivot) 의사결정
   - 이 강의의 핵심은 허영 지표가 아닌 행동 지표로 학습을 측정하고, 유의미한 신호가 없으면 과감히 피벗한다는 컨셉이야.
   - 🔗 youtu.be/RSaIOCHbuYw?si=q99dQzvdypYjGWkp
''',
    ),
  ];
}
