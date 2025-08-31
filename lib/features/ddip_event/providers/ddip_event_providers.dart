// lib/features/ddip_event/providers/ddip_event_providers.dart

import 'package:collection/collection.dart';
import 'package:ddip/core/providers/core_providers.dart';
import 'package:ddip/features/activity/presentation/models/ongoing_mission_summary.dart';
import 'package:ddip/features/auth/domain/entities/user.dart';
import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/data/datasources/ddip_event_remote_data_source.dart';
import 'package:ddip/features/ddip_event/data/datasources/web_socket_data_source.dart';
import 'package:ddip/features/ddip_event/data/repositories/fake_ddip_event_repository_impl.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
import 'package:ddip/features/ddip_event/domain/repositories/ddip_event_repository.dart';
import 'package:ddip/features/ddip_event/domain/services/price_prediction_service.dart';
import 'package:ddip/features/ddip_event/domain/usecases/create_ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/usecases/get_ddip_events.dart';
import 'package:ddip/features/ddip_event/presentation/detail/viewmodels/event_detail_view_model.dart';
import 'package:ddip/features/ddip_event/presentation/notifiers/ddip_events_notifier.dart';
import 'package:ddip/features/ddip_event/presentation/strategy/detail_sheet_strategy.dart';
import 'package:ddip/features/evaluation/providers/evaluation_providers.dart';
import 'package:ddip/features/map/providers/map_providers.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- 1. Data 계층 프로바이더 ---
final ddipEventDataSourceProvider = Provider<DdipEventRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return DdipEventRemoteDataSourceImpl(dio: dio);
});

final ddipEventRepositoryProvider = Provider<DdipEventRepository>((ref) {
  // 1. WebSocketDataSource를 가져옵니다.
  final webSocketDataSource = ref.watch(webSocketDataSourceProvider);
  // 2. [추가] EvaluationRepository를 가져옵니다.
  final evaluationRepository = ref.watch(evaluationRepositoryProvider);

  // 3. [수정] FakeDdipEventRepositoryImpl을 생성할 때,
  //    새로 추가된 evaluationRepository 파라미터에 2번에서 가져온 객체를 전달합니다.
  return FakeDdipEventRepositoryImpl(
    ref,
    webSocketDataSource: webSocketDataSource,
    evaluationRepository: evaluationRepository,
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

/// 상세 화면의 커맨드 바 가시성(visibility)을 관리하는 프로바이더
final commandBarVisibilityProvider = StateProvider.autoDispose<bool>(
  (ref) => true,
);

/// 특정 DdipEvent 객체를 OngoingMissionSummary 데이터로 가공(변환)하는 책임을 가지는 프로바이더입니다.
final ongoingMissionSummaryProvider = Provider.autoDispose.family<
  OngoingMissionSummary,
  DdipEvent
>((ref, event) {
  final detailViewModelState = ref.watch(
    eventDetailViewModelProvider(event.id),
  );
  final currentUser = ref.watch(authProvider)!;
  final allUsers = ref.watch(mockUsersProvider);

  // 파트너(상대방) 정보 계산
  final isRequester = event.requesterId == currentUser.id;
  final partnerId = isRequester ? event.selectedResponderId : event.requesterId;
  final partner = allUsers.firstWhere(
    (user) => user.id == partnerId,
    orElse: () => User(id: partnerId ?? '', name: '상대방'),
  );

  // --- ★★★ 핵심 수정: 4개의 마일스톤 상태를 계산하는 로직 ---
  List<MilestoneState> _calculateMilestoneStates() {
    // 1. 매칭 (Matching)
    final matchingMilestone = MilestoneState(
      label: '매칭',
      status: MilestoneStatus.completed,
    );

    // 2. 제출 (Submission)
    MilestoneState submissionMilestone;
    final isAnyPhotoRejected = event.photos.any(
      (p) => p.status == PhotoStatus.rejected,
    );

    if (event.photos.isEmpty) {
      submissionMilestone = MilestoneState(
        label: '제출',
        status: MilestoneStatus.inProgress,
      );
    } else if (isAnyPhotoRejected &&
        event.photos.last.status == PhotoStatus.rejected) {
      submissionMilestone = MilestoneState(
        label: '2차 제출',
        status: MilestoneStatus.inProgress,
      );
    } else {
      final label = isAnyPhotoRejected ? '2차 제출' : '제출';
      submissionMilestone = MilestoneState(
        label: label,
        status: MilestoneStatus.completed,
      );
    }

    // 3. 검증 (Verification)
    MilestoneState verificationMilestone;
    final lastPhoto = event.photos.lastOrNull;
    if (lastPhoto != null && lastPhoto.status == PhotoStatus.pending) {
      String label = '검증';
      if (lastPhoto.requesterQuestion != null &&
          lastPhoto.responderAnswer == null) {
        label = 'Q&A';
      }
      verificationMilestone = MilestoneState(
        label: label,
        status: MilestoneStatus.inProgress,
      );
    } else if (lastPhoto != null && lastPhoto.status == PhotoStatus.rejected) {
      verificationMilestone = MilestoneState(
        label: '반려됨',
        status: MilestoneStatus.failed,
      );
    } else if (lastPhoto != null && lastPhoto.status == PhotoStatus.approved) {
      verificationMilestone = MilestoneState(
        label: '검증',
        status: MilestoneStatus.completed,
      );
    } else {
      verificationMilestone = MilestoneState(
        label: '검증',
        status: MilestoneStatus.pending,
      );
    }

    // 4. 종료 (End)
    MilestoneState endMilestone;
    if (event.status == DdipEventStatus.completed) {
      endMilestone = MilestoneState(
        label: '성공',
        status: MilestoneStatus.completed,
      );
      // 성공 시 모든 이전 단계는 완료 처리
      submissionMilestone = MilestoneState(
        label: submissionMilestone.label,
        status: MilestoneStatus.completed,
      );
      verificationMilestone = MilestoneState(
        label: verificationMilestone.label,
        status: MilestoneStatus.completed,
      );
    } else if (event.status == DdipEventStatus.failed) {
      endMilestone = MilestoneState(
        label: '실패',
        status: MilestoneStatus.failed,
      );
    } else {
      endMilestone = MilestoneState(
        label: '종료',
        status: MilestoneStatus.pending,
      );
    }

    return [
      matchingMilestone,
      submissionMilestone,
      verificationMilestone,
      endMilestone,
    ];
  }

  // 최종적으로, UI에 필요한 모든 정보를 담은 OngoingMissionSummary 객체를 생성하여 반환합니다.
  return OngoingMissionSummary(
    event: event,
    partnerName: partner.name,
    accentColor: detailViewModelState.missionStage.guideColor,
    guideIcon: detailViewModelState.missionStage.guideIcon,
    guideText: detailViewModelState.missionStage.guideText,
    timerEndTime:
        detailViewModelState.missionStage.isActive
            ? detailViewModelState.missionStage.endTime
            : null,
    timerTotalDuration:
        detailViewModelState.missionStage.isActive
            ? detailViewModelState.missionStage.totalDuration
            : null,
    milestones: _calculateMilestoneStates(),
  );
});

/// AI 가격 예측 서비스를 제공하는 FutureProvider입니다.
/// 앱 전체에서 이 Provider를 통해 안전하게 서비스 인스턴스를 사용할 수 있습니다.
final pricePredictionServiceProvider = FutureProvider<PricePredictionService>((
  ref,
) async {
  // 1. 서비스 객체를 생성합니다.
  final service = PricePredictionService();

  // 2. 서비스의 비동기 초기화 메서드를 호출하고 완료될 때까지 기다립니다.
  await service.initialize();

  // 3. Provider가 소멸될 때 서비스의 dispose 메서드를 호출하여 자원을 정리합니다.
  ref.onDispose(() => service.dispose());

  // 4. 초기화가 완료된 서비스 객체를 반환합니다.
  return service;
});
