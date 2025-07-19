import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/repositories/ddip_event_repository.dart';

// 실제 서버 API 대신, 앱의 메모리에서 가짜 데이터를 관리하는 클래스입니다.
// 클린 아키텍처 덕분에, 나중에 이 파일만 실제 API를 호출하는 파일로 교체하면
// 앱의 다른 부분은 전혀 수정할 필요가 없습니다.
class FakeDdipEventRepositoryImpl implements DdipEventRepository {
  // 1. [추가] 앱이 실행되는 동안 '띱' 목록을 저장할 메모리 내 리스트
  final List<DdipEvent> _ddipEvents = [
    // 기존에 있던 초기 가짜 데이터는 여기에 보관합니다.
    DdipEvent(
      id: '1', title: '북문 타코야끼 트럭 왔나요?', content: '지금 가면 먹을 수 있는지 궁금해요',
      requesterId: 'user123', reward: 1000, latitude: 36.8925, longitude: 128.614,
      status: 'open', createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    DdipEvent(
      id: '2', title: '센팍에 자리 있나요?', content: '친구랑 치킨 먹으려는데 빈 테이블 있는지 봐주세요!',
      requesterId: 'user456', reward: 500, latitude: 35.890, longitude: 128.612,
      status: 'open', createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  @override
  Future<void> createDdipEvent(DdipEvent event) async {
    print('Fake createDdipEvent success: ${event.title}');
    _ddipEvents.insert(0, event); // 최신 글이 맨 위로 오도록 insert 사용
    await Future.delayed(const Duration(milliseconds: 500)); // 실제 네트워크처럼 약간의 딜레이
    return;
  }

  @override
  Future<List<DdipEvent>> getDdipEvents() async {
    // 2초 딜레이를 주어 실제 네트워크 통신처럼 보이게 함
    await Future.delayed(const Duration(seconds: 2));
    return _ddipEvents;
  }

  @override
  Future<DdipEvent> getDdipEventById(String id) async {
    // 실제 앱에서는 id를 사용해 _ddipEvents 리스트에서 해당 이벤트를 찾아 반환해야 하지만,
    // 지금은 테스트용으로 항상 동일한 상세 데이터를 반환하도록 구현합니다.
    await Future.delayed(const Duration(milliseconds: 300));
    // 1. _ddipEvents 리스트에서 전달받은 id와 일치하는 첫 번째 이벤트를 찾습니다.
    try {
      final event = _ddipEvents.firstWhere((event) => event.id == id);
      return event;
    } catch (e) {
      // 2. 만약 일치하는 이벤트가 없으면 에러를 발생시킵니다.
      //    (firstWhere는 일치하는 항목이 없으면 StateError를 던집니다)
      throw Exception('ID($id)에 해당하는 띱 이벤트를 찾을 수 없습니다.');
    }
  }

  @override
  Future<void> acceptDdipEvent(String eventId, String responderId) async {
    // 1. 실제 네트워크 통신처럼 보이도록 일부러 약간의 딜레이를 줍니다.
    await Future.delayed(const Duration(milliseconds: 200));

    // 2. 리스트에서 수정할 이벤트의 인덱스를 찾습니다.
    final index = _ddipEvents.indexWhere((event) => event.id == eventId);

    // 3. 만약 해당 ID의 이벤트가 리스트에 존재한다면,
    if (index != -1) {
      // 4. 기존 이벤트를 가져옵니다.
      final originalEvent = _ddipEvents[index];

      // 5. 기존 이벤트 정보에, 변경할 내용(status, responderId)을 덮어쓴 '새로운' 객체를 만듭니다.
      //    (상태 관리를 위해 기존 객체를 직접 수정하지 않고, 복사하여 새 객체를 만드는 것이 좋습니다.)
      final updatedEvent = DdipEvent(
        id: originalEvent.id,
        title: originalEvent.title,
        content: originalEvent.content,
        requesterId: originalEvent.requesterId,
        reward: originalEvent.reward,
        latitude: originalEvent.latitude,
        longitude: originalEvent.longitude,
        createdAt: originalEvent.createdAt,
        responsePhotoUrl: originalEvent.responsePhotoUrl,
        // ▼▼▼ 상태와 응답자 ID를 여기서 업데이트합니다.
        status: 'in_progress',
        responderId: responderId,
      );

      // 6. 리스트의 해당 인덱스 위치에, 방금 만든 새로운 객체로 교체합니다.
      _ddipEvents[index] = updatedEvent;

      print('Fake acceptDdipEvent success: ID($eventId)의 상태가 in_progress로 변경되었습니다.');
    } else {
      // 7. 만약 해당 ID의 이벤트가 없다면, 에러를 발생시킵니다.
      throw Exception('ID($eventId)에 해당하는 띱 이벤트를 찾을 수 없어 수락에 실패했습니다.');
    }
  }

  @override
  Future<void> completeDdipEvent(String eventId, String imagePath) async {
    // 1. 실제 네트워크처럼 딜레이를 줍니다.
    await Future.delayed(const Duration(milliseconds: 500));

    // 2. 리스트에서 수정할 이벤트의 인덱스를 찾습니다.
    final index = _ddipEvents.indexWhere((event) => event.id == eventId);

    // 3. 만약 해당 이벤트를 찾았다면,
    if (index != -1) {
      // 4. 기존 이벤트를 가져옵니다.
      final originalEvent = _ddipEvents[index];

      // 5. 상태(status)만 'completed'로 변경한 새로운 객체를 만듭니다.
      final updatedEvent = DdipEvent(
        id: originalEvent.id,
        title: originalEvent.title,
        content: originalEvent.content,
        requesterId: originalEvent.requesterId,
        responderId: originalEvent.responderId,
        reward: originalEvent.reward,
        latitude: originalEvent.latitude,
        longitude: originalEvent.longitude,
        status: 'completed', // status를 'completed'로 변경
        createdAt: originalEvent.createdAt,
        responsePhotoUrl: imagePath,
      );

      // 6. 리스트의 기존 이벤트를 새로운 객체로 교체합니다.
      _ddipEvents[index] = updatedEvent;

      print('Fake completeDdipEvent success: ID($eventId)의 상태가 completed로 변경되었습니다.');
    } else {
      // 7. 만약 이벤트를 찾지 못하면 에러를 발생시킵니다.
      throw Exception('ID($eventId)에 해당하는 띱 이벤트를 찾을 수 없어 완료에 실패했습니다.');
    }
  }
}
