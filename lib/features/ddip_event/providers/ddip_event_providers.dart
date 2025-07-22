// lib/features/ddip_event/providers/ddip_event_providers.dart

import 'package:ddip/core/providers/core_providers.dart';
import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/data/datasources/ddip_event_remote_data_source.dart';
import 'package:ddip/features/ddip_event/data/repositories/fake_ddip_event_repository_impl.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/repositories/ddip_event_repository.dart';
import 'package:ddip/features/ddip_event/domain/usecases/create_ddip_event.dart';
import 'package:ddip/features/ddip_event/presentation/notifiers/ddip_events_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- 1. Data 계층 프로바이더 ---
final ddipEventDataSourceProvider = Provider<DdipEventRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return DdipEventRemoteDataSourceImpl(dio: dio);
});

// [리팩토링] DdipEvent 기능 전반에서 사용될 Repository Provider
final ddipEventRepositoryProvider = Provider<DdipEventRepository>((ref) {
  final remoteDataSource = ref.watch(ddipEventDataSourceProvider);
  return FakeDdipEventRepositoryImpl(); // 실제 백엔드 도입 전까지는 Fake Repository 사용
  // return DdipEventRepositoryImpl(remoteDataSource: remoteDataSource);
});

// --- 2. Domain 계층 프로바이더 (UseCase) ---
// 아직 '띱 생성'은 단순한 작업이므로 UseCase를 그대로 사용합니다.
final createDdipEventUseCaseProvider = Provider<CreateDdipEvent>((ref) {
  final repository = ref.watch(ddipEventRepositoryProvider);
  return CreateDdipEvent(repository: repository);
});

// --- 3. Presentation 계층 프로바이더 (State Notifier & Filtered View) ---

/// '띱' 이벤트 데이터의 원본을 관리하고 비즈니스 로직을 처리하는 Notifier
final ddipEventsNotifierProvider =
    StateNotifierProvider<DdipEventsNotifier, AsyncValue<List<DdipEvent>>>((
      ref,
    ) {
      return DdipEventsNotifier(ref);
    });

/// 로그인한 사용자에 따라 '띱' 목록을 필터링하여 UI에 제공하는 Provider
final filteredDdipFeedProvider = Provider<List<DdipEvent>>((ref) {
  final eventsState = ref.watch(ddipEventsNotifierProvider);
  final currentUser = ref.watch(authProvider);

  return eventsState.when(
    data: (events) {
      if (currentUser == null) {
        return events
            .where((event) => event.status == DdipEventStatus.open)
            .toList();
      } else {
        return events.where((event) {
          final isMyEvent = event.requesterId == currentUser.id;
          final isIAmApplicant = event.applicants.contains(currentUser.id);
          final isOpenForApply = event.status == DdipEventStatus.open;
          return isMyEvent || isIAmApplicant || isOpenForApply;
        }).toList();
      }
    },
    loading: () => [],
    error: (e, s) => [],
  );
});

// --- 4. Presentation 계층 프로바이더 (상세 화면용) ---

/// 전체 '띱' 목록 상태가 변경될 때마다,
/// 특정 ID의 '띱' 하나만 찾아서 상세 화면 UI에 제공하는 프로바이더입니다.
/// .family를 사용하여 eventId를 파라미터로 받을 수 있습니다.
final eventDetailProvider = Provider.autoDispose.family<DdipEvent?, String>((
  ref,
  eventId,
) {
  // 1. 원본 데이터가 있는 notifier를 감시(watch)합니다.
  final eventsState = ref.watch(ddipEventsNotifierProvider);

  // 2. 데이터가 성공적으로 로드된 경우에만 목록에서 찾기를 시도합니다.
  return eventsState.whenData((events) {
    try {
      // 3. 전체 events 리스트에서 eventId와 일치하는 첫 번째 항목을 찾습니다.
      return events.firstWhere((event) => event.id == eventId);
    } catch (e) {
      // 4. 일치하는 항목이 없으면 null을 반환합니다.
      return null;
    }
  }).value; // whenData의 결과에서 실제 값(DdipEvent? 또는 null)을 추출합니다.
});
