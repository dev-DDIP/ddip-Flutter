import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/repositories/ddip_event_repository.dart';

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
}
