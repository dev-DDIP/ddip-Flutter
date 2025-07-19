import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/usecases/get_ddip_events.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. '목록 조회' 유스케이스를 제공하는 프로바이더
//    (ddip_creation_providers.dart에 이미 만들어둔 ddipEventRepositoryProvider를 재활용합니다)
final getDdipEventsUseCaseProvider = Provider<GetDdipEvents>((ref) {
  final repository = ref.watch(ddipEventRepositoryProvider);
  return GetDdipEvents(repository: repository);
});

// 2. '목록 조회' 상태를 관리하고, UI에 데이터를 제공할 최종 프로바이더
final ddipFeedProvider =
AsyncNotifierProvider<DdipFeedNotifier, List<DdipEvent>>(() {
  return DdipFeedNotifier();
});

// 3. '목록 조회' 상태 관리자 클래스 (실제 로직)
class DdipFeedNotifier extends AsyncNotifier<List<DdipEvent>> {
  // build 메서드는 이 프로바이더가 처음 실행될 때 호출됩니다.
  // 여기서 초기 데이터 로딩을 수행합니다.
  @override
  Future<List<DdipEvent>> build() async {
    // getDdipEventsUseCaseProvider를 읽어와서 실행합니다.
    final useCase = ref.read(getDdipEventsUseCaseProvider);
    return useCase(); // useCase()는 Future<List<DdipEvent>>를 반환합니다.
  }
}