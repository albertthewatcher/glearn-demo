import 'conversation_data.dart';

/// page3 전용 대화 데이터. 자유롭게 수정하세요.
class ConversationDataPage3 {
  static const List<Message> messages = [
    Message(
      sender: 'ohtani',
      senderName: 'Ohtani',
      avatarAsset: 'assets/images/profile_ohtani.webp',
      content: '''
나는 스포츠 선수라 경영학적인 개념을 자세히 알고 싶지는 않아
짧은 시간 내에 핵심만 이해할 수 있는 방법이 없을까?
''',
    ),
    Message(
      sender: 'ai_tutor',
      senderName: 'AI Tutor',
      avatarAsset: null, // AI Tutor는 아이콘 사용
      content: '''
그렇다면 기존의 코스에서 Best Practice로 소개할 만한 내용들을 잘라내서 소개해줄게.

1. [02:33] Lean Startup 핵심 개념 요약
   - 🔗 youtu.be/G-wwOK4X0lc?si=roOoxJ3drnajN5yN (03:01-05:34)

2. [01:35] Lean Startup in Practice - Spotify는 어떻게 Rdio를 꺾었는가
   - 🔗 youtu.be/fEvKo90qBns?si=iGpSPpe4jO6GGwCa (52:12-52:47)

3. [02:55] Lean Startup 대표사례 - Airbnb의 초창기부터 확장기까지
   - 🔗 youtu.be/RSaIOCHbuYw?si=q99dQzvdypYjGWkp (40:09-44:04)

4. [03:50] Inside the Lean Startup - MaRS Best Practices
   - 🔗 youtu.be/fEvKo90qBns?si=iGpSPpe4jO6GGwCa (14:51-18:41)

5. [06:03] Lean Startup에 대한 오해와 진실
   - 🔗 youtu.be/G-wwOK4X0lc?si=roOoxJ3drnajN5yN (11:00-17:03)
''',
    ),
  ];
}
