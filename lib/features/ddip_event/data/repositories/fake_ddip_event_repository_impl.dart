import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/repositories/ddip_event_repository.dart';

class FakeDdipEventRepositoryImpl implements DdipEventRepository {
  @override
  Future<void> createDdipEvent(DdipEvent event) async {
    print('Fake createDdipEvent success: ${event.title}');
    return;
  }

  @override
  Future<List<DdipEvent>> getDdipEvents() async {
    // 2초 딜레이를 주어 실제 네트워크 통신처럼 보이게 함
    await Future.delayed(const Duration(seconds: 2));

    // 가짜 DdipEvent 객체 3개를 포함한 리스트를 반환
    return [
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
      DdipEvent(
        id: '3', title: 'IT 1호관 404호 불 켜져 있는지 확인 가능하신 분', content: '깜빡하고 불을 안 끈 것 같아요ㅠㅠ',
        requesterId: 'user789', reward: 1500, latitude: 35.887, longitude: 128.609,
        status: 'open', createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}