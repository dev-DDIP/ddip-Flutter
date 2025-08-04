// lib/features/ddip_event/providers/ddip_event_providers.dart

import 'package:collection/collection.dart';
import 'package:ddip/core/providers/core_providers.dart';
import 'package:ddip/features/ddip_event/data/datasources/ddip_event_remote_data_source.dart';
import 'package:ddip/features/ddip_event/data/datasources/web_socket_data_source.dart';
import 'package:ddip/features/ddip_event/data/repositories/fake_ddip_event_repository_impl.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/repositories/ddip_event_repository.dart';
import 'package:ddip/features/ddip_event/domain/usecases/create_ddip_event.dart';
import 'package:ddip/features/ddip_event/presentation/detail/viewmodels/event_detail_view_model.dart';
import 'package:ddip/features/ddip_event/presentation/notifiers/ddip_events_notifier.dart';
import 'package:ddip/features/ddip_event/presentation/strategy/detail_sheet_strategy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- 1. Data 계층 프로바이더 ---
final ddipEventDataSourceProvider = Provider<DdipEventRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return DdipEventRemoteDataSourceImpl(dio: dio);
});

final ddipEventRepositoryProvider = Provider<DdipEventRepository>((ref) {
  // 1. 어떤 WebSocketDataSource를 사용할지 webSocketDataSourceProvider에게 물어봅니다.
  final webSocketDataSource = ref.watch(webSocketDataSourceProvider);

  // 2. 주입받은 DataSource를 사용하여 Repository 구현체를 생성합니다.
  //    (이 코드는 main.dart에서 override될 때만 실제로 실행됩니다.)
  return FakeDdipEventRepositoryImpl(
    ref,
    webSocketDataSource: webSocketDataSource,
  );
});

// --- 2. Domain 계층 프로바이더 (UseCase) ---
final createDdipEventUseCaseProvider = Provider<CreateDdipEvent>((ref) {
  final repository = ref.watch(ddipEventRepositoryProvider);
  return CreateDdipEvent(repository: repository);
});

// --- 3. Presentation 계층 프로바이더 (State Notifier & View Model) ---

/// '띱' 이벤트 데이터의 원본을 관리하고 비즈니스 로직을 처리하는 Notifier
final ddipEventsNotifierProvider =
    StateNotifierProvider<DdipEventsNotifier, AsyncValue<List<DdipEvent>>>((
      ref,
    ) {
      return DdipEventsNotifier(ref);
    });

/// 피드 화면에 필요한 '띱' 목록 전체를 제공하는 Provider
final ddipFeedProvider = Provider<List<DdipEvent>>((ref) {
  // '띱' 이벤트 데이터의 원본을 관리하는 Notifier를 감시
  final eventsState = ref.watch(ddipEventsNotifierProvider);

  // 로드된 데이터를 그대로 반환 (이제 필터링하지 않음)
  return eventsState.when(
    data: (events) => events,
    loading: () => [],
    error: (e, s) => [],
  );
});

// --- 4. Presentation 계층 프로바이더 (상세 화면용) ---

/// 전체 '띱' 목록 상태가 변경될 때마다,
/// 특정 ID의 '띱' 하나만 찾아서 상세 화면 UI에 제공하는 프로바이더입니다.
final eventDetailProvider = Provider.autoDispose.family<DdipEvent?, String>((
  ref,
  eventId,
) {
  // 데이터의 원천인 ddipEventsNotifierProvider를 감시
  final eventsState = ref.watch(ddipEventsNotifierProvider);

  // 데이터가 성공적으로 로드된 경우에만 목록에서 찾기를 시도
  return eventsState.whenData((events) {
    // collection 패키지의 firstWhereOrNull을 사용해 안전하게 검색
    return events.firstWhereOrNull((event) => event.id == eventId);
  }).value; // whenData의 결과에서 실제 값(DdipEvent? 또는 null)을 추출
});

final detailSheetStrategyProvider =
    StateNotifierProvider.autoDispose<DetailSheetStrategy, double>(
      (ref) => DetailSheetStrategy(),
    );

/// UI 위젯은 이 프로바이더를 watch하여 데이터 변경 시 자동으로 리빌드됩니다.
final eventStreamProvider = StreamProvider.autoDispose
    .family<DdipEvent, String>((ref, eventId) {
      final repository = ref.watch(ddipEventRepositoryProvider);
      return repository.getEventStreamById(eventId);
    });

/// 상세 화면의 상태와 비즈니스 로직을 관리하는 ViewModel을 위한 Provider입니다.
/// .family를 사용하여 각 상세 화면마다 독립적인 ViewModel 인턴스를 갖도록 합니다.
final eventDetailViewModelProvider = StateNotifierProvider.autoDispose
    .family<EventDetailViewModel, EventDetailState, String>((ref, eventId) {
      return EventDetailViewModel(ref, eventId);
    });
