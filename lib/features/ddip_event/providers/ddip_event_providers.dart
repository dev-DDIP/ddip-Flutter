// lib/features/ddip_event/providers/ddip_event_providers.dart

import 'package:collection/collection.dart';
import 'package:ddip/core/providers/core_providers.dart';
import 'package:ddip/features/ddip_event/data/datasources/ddip_event_remote_data_source.dart';
import 'package:ddip/features/ddip_event/data/datasources/web_socket_data_source.dart';
import 'package:ddip/features/ddip_event/data/repositories/fake_ddip_event_repository_impl.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/repositories/ddip_event_repository.dart';
import 'package:ddip/features/ddip_event/domain/usecases/create_ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/usecases/get_ddip_events.dart';
import 'package:ddip/features/ddip_event/presentation/detail/viewmodels/event_detail_view_model.dart';
import 'package:ddip/features/ddip_event/presentation/notifiers/ddip_events_notifier.dart';
import 'package:ddip/features/ddip_event/presentation/strategy/detail_sheet_strategy.dart';
import 'package:ddip/features/map/providers/map_providers.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
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

final getDdipEventsUseCaseProvider = Provider<GetDdipEvents>((ref) {
  final repository = ref.watch(ddipEventRepositoryProvider);
  return GetDdipEvents(repository: repository);
});

// --- 3. Presentation 계층 프로바이더 (State Notifier & View Model) ---

/// '띱' 이벤트 데이터의 원본을 관리하고 비즈니스 로직을 처리하는 Notifier
final ddipEventsNotifierProvider =
    StateNotifierProvider<DdipEventsNotifier, AsyncValue<DdipFeedState>>((ref) {
      return DdipEventsNotifier(ref);
    });

/// 피드 화면에 필요한 '띱' 목록 전체를 제공하는 Provider
final ddipFeedProvider = Provider<List<DdipEvent>>((ref) {
  // '띱' 이벤트 데이터의 원본을 관리하는 Notifier를 감시
  final eventsState = ref.watch(ddipEventsNotifierProvider);

  // 로드된 데이터(feedState)에서 .events 속성을 통해 실제 목록을 반환합니다.
  // maybeWhen을 사용하면 data 상태일 때만 처리하고, loading/error일 때는 orElse로 기본값을 반환하여 코드가 간결해집니다.
  return eventsState.maybeWhen(
    data: (feedState) => feedState.events,
    orElse: () => [], // 로딩 중이거나 에러일 때는 빈 목록 반환
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

  // 데이터가 성공적으로 로드된 경우(feedState), 그 안의 events 목록에서 검색합니다.
  return eventsState.maybeWhen(
    data:
        (feedState) =>
            feedState.events.firstWhereOrNull((event) => event.id == eventId),
    orElse: () => null, // 로딩 중이거나 에러일 때는 null 반환
  );
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

/// 지도에 현재 보이는 영역 내의 '띱' 이벤트 목록만 필터링하여 제공하는 Provider
final visibleEventsProvider = Provider.autoDispose<List<DdipEvent>>((ref) {
  // 1. 전체 이벤트 목록의 '상태'를 감시
  final eventsState = ref.watch(ddipEventsNotifierProvider);
  // 2. 지도의 현재 '영역'을 감시
  final currentBounds = ref.watch(mapBoundsProvider);

  // 이벤트 목록이 로딩 중이거나, 지도 영역이 아직 설정되지 않았다면 빈 목록 반환
  return eventsState.maybeWhen(
    data: (feedState) {
      if (currentBounds == null) {
        return []; // 지도 준비 전에는 아무것도 보여주지 않음
      }

      // '지도 영역(currentBounds)'에 포함되는 이벤트만 필터링하여 반환
      return feedState.events.where((event) {
        final eventPosition = NLatLng(event.latitude, event.longitude);
        return currentBounds.containsPoint(eventPosition);
      }).toList();
    },
    orElse: () => [], // 로딩 또는 에러 시 빈 목록 반환
  );
});

// 2개의 파라미터(userId, type)를 받기 위해 Record 타입을 사용합니다.
final userActivityProvider = FutureProvider.autoDispose
    .family<List<DdipEvent>, ({String userId, UserActivityType type})>((
      ref,
      params,
    ) {
      final repository = ref.watch(ddipEventRepositoryProvider);
      return repository.getEventsByUserId(params.userId, params.type);
    });
