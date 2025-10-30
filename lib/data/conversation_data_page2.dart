import 'conversation_data.dart';

/// page2 전용 대화 데이터. 자유롭게 수정하세요.
class ConversationDataPage2 {
  static const List<Message> messages = [
    Message(
      sender: 'ohtani',
      senderName: 'Ohtani',
      avatarAsset: 'assets/images/profile_ohtani.webp',
      content: '''
North Star Metric이 뭔지 알 듯 말 듯해
''',
    ),
    Message(
      sender: 'ai_tutor',
      senderName: 'AI Tutor',
      avatarAsset: null, // AI Tutor는 아이콘 사용
      content: '''
North Star Metric, 일명 북극성 지표는 기업의 성공을 가장 잘 예측하는 단 하나의 핵심 지표야.
린 스타트업의 핵심은 선택과 집중에 있기에, 가장 중요한 지표 하나에 집중하라는 거지.
''',
    ),
    Message(
      sender: 'ohtani',
      senderName: 'Ohtani',
      avatarAsset: 'assets/images/profile_ohtani.webp',
      content: '''
그런데 북극성 지표는 어떻게 알 수 있어?
스타트업을 시작하는 시점에 이런 지표가 나와 있어야 해?
''',
    ),
    Message(
      sender: 'ai_tutor',
      senderName: 'AI Tutor',
      avatarAsset: null, // AI Tutor는 아이콘 사용
      content: '''
스타트업 초기에는 어떤 지표를 찾아야 할지 막막할 수 있어.
먼저 고객이 제품을 통해 얻는 핵심 가치와, 제품이 수익을 창출하는 비즈니스 모델에 집중해야 해.
북극성 지표는 핵심적일 뿐 아니라 측정 가능성도 고려해야 하므로 차근차근 찾을 필요가 있어.

초기에 이러한 지표를 찾아나가는 과정 자체도 린 스타트업 방법론의 일부로 받아들이는 편이 바람직해.
''',
    ),
  ];
}
