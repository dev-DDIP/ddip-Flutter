// lib/features/ddip_event/providers/ddip_event_providers.dart

import 'package:ddip/core/providers/core_providers.dart';
import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/data/datasources/ddip_event_remote_data_source.dart';
import 'package:ddip/features/ddip_event/data/repositories/ddip_event_repository_impl.dart';
import 'package:ddip/features/ddip_event/data/repositories/fake_ddip_event_repository_impl.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/repositories/ddip_event_repository.dart';
import 'package:ddip/features/ddip_event/domain/usecases/create_ddip_event.dart';
import 'package:ddip/features/ddip_event/presentation/notifiers/ddip_events_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

// --- 1. Data 계층 프로바이더 ---
final ddipEventDataSourceProvider = Provider<DdipEventRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return DdipEventRemoteDataSourceImpl(dio: dio);
});

final ddipEventRepositoryProvider = Provider<DdipEventRepository>((ref) {
  // final remoteDataSource = ref.watch(ddipEventDataSourceProvider);
  return FakeDdipEventRepositoryImpl(); // 실제 백엔드 도입 전까지는 Fake Repository 사용
  // return DdipEventRepositoryImpl(remoteDataSource: remoteDataSource);
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
