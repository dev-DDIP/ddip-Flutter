// lib/features/ddip_event/data/repositories/mock_ddip_event_data.dart

import 'dart:math';

import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/interaction.dart';
import 'package:uuid/uuid.dart';

/// 클러스터링 테스트를 위해 의도적으로 그룹화된 가짜 '띱' 이벤트 데이터 목록입니다.
/// 각 클러스터 내의 마커들은 중심 좌표에서 약간의 무작위 오프셋을 가집니다.
final mockDdipEvents = _generateMockEvents();

// --- 데이터 생성 로직 ---

const _uuid = Uuid();
final _random = Random();

// ✨ [수정] 각 Map 상수에 타입을 명시적으로 선언하여 타입 추론 오류를 방지합니다.
const Map<String, double> _centerNorthGate = {
  'lat': 35.8925,
  'lon': 128.6095,
}; // 북문
const Map<String, double> _centerCentralPark = {
  'lat': 35.8900,
  'lon': 128.6120,
}; // 센트럴파크
const Map<String, double> _centerLibrary = {
  'lat': 35.8885,
  'lon': 128.6105,
}; // 중앙도서관
const Map<String, double> _centerIT1 = {
  'lat': 35.8860,
  'lon': 128.6090,
}; // IT-1호관
const Map<String, double> _centerDorm = {
  'lat': 35.8850,
  'lon': 128.6130,
}; // 기숙사

// 샘플 텍스트 데이터
const _sampleTitles = [
  '지금 OO 트럭 왔나요?',
  '여기 자리 있나요?',
  '오늘 OO 메뉴 뭔가요?',
  '줄 긴가요?',
  '분실물 확인 좀 부탁드려요',
  'OO 재고 있는지 봐주세요',
  '지금 사람 많은가요?',
  '고양이들 어디있나요?',
  '주차 자리 있나요?',
  '프린터 용지 있는지 확인좀',
];
const _sampleContents = [
  '사진 한 장만 부탁드려요!',
  '헛걸음하기 싫어서요 ㅠㅠ',
  '지금 가면 바로 먹을 수 있을까요?',
  '사람 많으면 다른데 가려구요.',
  '친구가 기다리고 있어서 급해요!',
  'A4용지 없으면 사가려구요.',
  '깜빡하고 안 끈 것 같아요 ㅠㅠ',
];
const _requesterIds = ['requester_1', 'requester_2', 'requester_3'];

// 좌표에 무작위성을 더하는 함수
double _jitter(double value, double amount) {
  return value + (_random.nextDouble() - 0.5) * amount;
}

// 전체 목 데이터를 생성하는 메인 함수
List<DdipEvent> _generateMockEvents() {
  final events = <DdipEvent>[];

  events.add(
    DdipEvent(
      id: 'test-event-in-progress',
      // 테스트를 위해 고정 ID 사용
      title: '[테스트] 북문 앞 푸드트럭 지금 줄 긴가요?',
      content: '오늘 온 푸드트럭 가보려고 하는데, 지금 바로 가도 될지 궁금합니다. 사진 한 장만 부탁드려요!',
      requesterId: 'requester_1',
      // 김요청
      reward: 1500,
      latitude: _jitter(_centerNorthGate['lat']!, 0.0001),
      longitude: _jitter(_centerNorthGate['lon']!, 0.0001),
      status: DdipEventStatus.in_progress,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      applicants: ['responder_1', 'responder_2'],
      // 이수행, 박지원 지원
      selectedResponderId: 'responder_1',
      // 이수행 선택됨
      interactions: [],
    ),
  );

  // --- 클러스터 A: 북문 근처 (3개) ---
  for (int i = 0; i < 3; i++) {
    events.add(
      _createRandomEvent(
        center: _centerNorthGate,
        jitterAmount: 0.0008,
        status: DdipEventStatus.open,
      ),
    );
  }

  // --- 클러스터 B: 센트럴파크 (3개) ---
  for (int i = 0; i < 3; i++) {
    events.add(
      _createRandomEvent(
        center: _centerCentralPark,
        jitterAmount: 0.0012,
        status: i < 1 ? DdipEventStatus.in_progress : DdipEventStatus.open,
      ),
    );
  }

  // --- 클러스터 C: 중앙도서관 (2개) ---
  for (int i = 0; i < 2; i++) {
    events.add(
      _createRandomEvent(
        center: _centerLibrary,
        jitterAmount: 0.0010,
        status: i < 1 ? DdipEventStatus.completed : DdipEventStatus.failed,
      ),
    );
  }

  // --- 클러스터 D: IT-1호관 (2개) ---
  for (int i = 0; i < 2; i++) {
    events.add(
      _createRandomEvent(
        center: _centerIT1,
        jitterAmount: 0.0025,
        status: DdipEventStatus.open,
      ),
    );
  }

  // 생성 시간 기준으로 내림차순 정렬
  events.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return events;
}

// 단일 랜덤 이벤트를 생성하는 헬퍼 함수
DdipEvent _createRandomEvent({
  required Map<String, double> center,
  required double jitterAmount,
  DdipEventStatus status = DdipEventStatus.open,
}) {
  return DdipEvent(
    id: _uuid.v4(),
    title: _sampleTitles[_random.nextInt(_sampleTitles.length)],
    content: _sampleContents[_random.nextInt(_sampleContents.length)],
    requesterId: _requesterIds[_random.nextInt(_requesterIds.length)],
    reward: (_random.nextInt(30) + 5) * 100,
    // 500 ~ 3400원
    // ✨ [수정] 이제 상위에서 타입을 명시해주었기 때문에, 불필요한 'as double' 캐스팅을 제거하여 코드를 더 깔끔하게 만듭니다.
    latitude: _jitter(center['lat']!, jitterAmount),
    longitude: _jitter(center['lon']!, jitterAmount),

    status: status,
    createdAt: DateTime.now().subtract(
      Duration(minutes: _random.nextInt(24 * 60)),
    ),
    // 최근 24시간 내
    applicants:
        status == DdipEventStatus.in_progress
            ? ['responder_1', 'responder_2']
            : [],
    selectedResponderId:
        status == DdipEventStatus.in_progress ? 'responder_1' : null,
  );
}
