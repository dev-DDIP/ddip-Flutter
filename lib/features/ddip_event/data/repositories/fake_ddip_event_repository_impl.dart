import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/repositories/ddip_event_repository.dart';

class FakeDdipEventRepositoryImpl implements DdipEventRepository {
  // 1. [추가] 앱이 실행되는 동안 '띱' 목록을 저장할 메모리 내 리스트
  final List<DdipEvent> _ddipEvents = [
    // 기존에 있던 초기 가짜 데이터는 여기에 보관합니다.
    DdipEvent(
      id: '1', title: '북문 타코야끼 트럭 왔나요?', content: '지금 가면 먹을 수 있는지 궁금해요',
      requesterId: 'user123', reward: 1000, latitude: 35.8925, longitude: 128.614,
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
}
