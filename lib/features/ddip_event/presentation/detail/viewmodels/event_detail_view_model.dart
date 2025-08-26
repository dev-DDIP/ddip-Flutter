// lib/features/ddip_event/presentation/detail/viewmodels/event_detail_view_model.dart

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:ddip/features/auth/domain/entities/user.dart';
import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/camera/photo_preview_screen.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/interaction.dart';
import 'package:ddip/features/ddip_event/domain/entities/mission_stage.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/communication_log_sliver.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/detailed_request_card.dart';
import 'package:ddip/features/ddip_event/presentation/models/progress_step.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:ddip/features/evaluation/providers/evaluation_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

part 'event_detail_view_model.freezed.dart';

// 이제 버튼 상태 뿐만 아닌, 상세 페이지에 필요한 핵심 데이터 'DdipEvent'의 상태를 관리합니다.
@freezed
class EventDetailState with _$EventDetailState {
  const factory EventDetailState({
    // AsyncValue를 사용해 로딩, 데이터, 에러 상태를 모두 표현합니다.
    @Default(AsyncValue.loading()) AsyncValue<DdipEvent> event,
    @Default(false) bool isProcessing, // 버튼 동작 등 개별 액션의 로딩 상태
    String? buttonText,
    @Default(false) bool buttonIsEnabled,
    Color? buttonColor,
    required MissionStage missionStage,
    required List<ProgressStep> progressSteps, // [수정] required로 변경
    @Default(true) bool showProgressBar,
    @Default(false) bool showMissionControl,
    @Default(false) bool hasCurrentUserEvaluated,
  }) = _EventDetailState;
}

class EventDetailViewModel extends StateNotifier<EventDetailState> {
  final Ref _ref;
  final String _eventId;

  // Stream의 구독을 관리하기 위한 변수
  StreamSubscription<DdipEvent>? _eventSubscription;

  EventDetailViewModel(this._ref, this._eventId)
    : super(
        EventDetailState(
          // 'required'로 지정된 필드에 대한 초기값을 여기서 제공합니다.
          missionStage: MissionStage.inactive(), // 초기에는 비활성 상태로 시작
          progressSteps: const [], // 초기에는 빈 리스트로 시작
        ),
      ) {
    _initialize();
  }

  Future<void> _initialize() async {
    final repository = _ref.read(ddipEventRepositoryProvider);
    try {
      final initialEvent = await repository.getDdipEventById(_eventId);
      // 2. 데이터를 받으면, 중앙 관리 메서드를 호출하여 상태를 갱신합니다.
      _updateStateFromEvent(initialEvent);

      _eventSubscription = repository
          .getEventStreamById(_eventId)
          .listen(
            (updatedEvent) {
              // 3. 실시간 업데이트가 올 때도, 중앙 관리 메서드를 호출합니다.
              _updateStateFromEvent(updatedEvent);
            },
            // 4. 타입 오류를 해결하기 위해 error와 stackTrace의 타입을 명시합니다.
            onError: (Object error, StackTrace stackTrace) {
              state = state.copyWith(
                event: AsyncValue.error(error, stackTrace),
              );
            },
          );
    } catch (e, s) {
      state = state.copyWith(event: AsyncValue.error(e, s));
    }
  }

  void _updateStateFromEvent(DdipEvent event) async {
    final currentUser = _ref.read(authProvider);

    bool hasEvaluated = false;
    // 미션이 종료되었고, 사용자가 로그인한 상태일 때만 평가 여부를 확인합니다.
    if (currentUser != null &&
        (event.status == DdipEventStatus.completed ||
            event.status == DdipEventStatus.failed)) {
      final evaluationRepository = _ref.read(evaluationRepositoryProvider);
      hasEvaluated = await evaluationRepository.hasUserEvaluatedMission(
        userId: currentUser.id,
        missionId: event.id,
      );
    }

    // --- 버튼 상태 결정 로직 (생략) ---
    String? text;
    bool isEnabled = false;
    Color? color;
    if (currentUser != null) {
      final bool isRequester = event.requesterId == currentUser.id;
      final bool isSelectedResponder =
          event.selectedResponderId == currentUser.id;
      final bool hasApplied = event.applicants.contains(currentUser.id);
      final bool hasPendingPhoto = event.photos.any(
        (p) => p.status == PhotoStatus.pending,
      );
      switch (event.status) {
        case DdipEventStatus.open:
          if (!isRequester && !hasApplied) {
            text = '지원하기';
            isEnabled = true;
          }
          break;
        case DdipEventStatus.in_progress:
          if (isSelectedResponder && !hasPendingPhoto) {
            text = '사진 찍고 제출하기';
            isEnabled = true;
            color = Colors.green;
          }
          break;
        case DdipEventStatus.completed:
          text = '완료된 요청';
          break;
        case DdipEventStatus.failed:
          text = '실패한 요청';
          color = Colors.red[700];
          break;
      }
    } else {
      isEnabled = false;
      text = '로그인이 필요합니다.';
    }

    // [핵심 수정] buildProgressSteps에 평가 완료 여부를 전달합니다.
    final progressSteps = _buildProgressSteps(event, hasEvaluated);
    final missionStage = _determineMissionStage(event, currentUser?.id);

    final bool shouldShowProgressBar = progressSteps.isNotEmpty;
    final bool shouldShowMissionControl = missionStage.isActive;

    // --- 최종 상태 업데이트 ---
    state = state.copyWith(
      event: AsyncValue.data(event),
      buttonText: text,
      buttonIsEnabled: isEnabled,
      buttonColor: color,
      missionStage: missionStage,
      progressSteps: progressSteps,
      showProgressBar: shouldShowProgressBar,
      showMissionControl: shouldShowMissionControl,
      hasCurrentUserEvaluated: hasEvaluated,

      // 계산된 높이 저장
      isProcessing: false,
    );
  }

  @override
  void dispose() {
    // ViewModel이 파괴될 때, Stream 구독을 반드시 취소하여 메모리 누수를 방지합니다.
    _eventSubscription?.cancel();
    super.dispose();
  }

  MissionStage _determineMissionStage(DdipEvent event, String? currentUserId) {
    if (currentUserId == null ||
        event.status == DdipEventStatus.completed ||
        event.status == DdipEventStatus.failed) {
      return MissionStage.inactive();
    }

    final isRequester = event.requesterId == currentUserId;
    final photos = List.from(event.photos);
    final lastPhoto = photos.isNotEmpty ? photos.lastOrNull : null;

    // --- 1단계: 매칭 후 첫 사진 제출 대기 ---
    if (event.status == DdipEventStatus.in_progress && photos.isEmpty) {
      final Interaction? matchInteraction = event.interactions.firstWhereOrNull(
        (i) => i.actionType == ActionType.selectResponder,
      );
      if (matchInteraction == null) return MissionStage.inactive();
      final matchTime = matchInteraction.timestamp;

      return MissionStage(
        isActive: true,
        totalDuration: const Duration(minutes: 3),
        endTime: matchTime.add(const Duration(minutes: 3)),
        guideText:
            isRequester ? '⏳ 수행자의 첫 사진을 기다리고 있습니다.' : '📸 3분 내에 현장 사진을 제출해주세요!',
        guideIcon:
            isRequester
                ? Icons.hourglass_empty_rounded
                : Icons.camera_alt_outlined,
        guideColor: isRequester ? Colors.blue.shade600 : Colors.green.shade600,
      );
    }

    // --- 사진이 제출된 이후의 복잡한 분기 처리 ---
    if (lastPhoto != null) {
      // 마지막 사진이 '반려' 상태일 때 -> 다음 사진 제출 대기
      if (lastPhoto.status == PhotoStatus.rejected) {
        final rejectInteraction = event.interactions.lastWhereOrNull(
          (i) =>
              i.actionType == ActionType.requestRevision &&
              i.relatedPhotoId == lastPhoto.id,
        );
        if (rejectInteraction == null) return MissionStage.inactive();

        return MissionStage(
          isActive: true,
          totalDuration: const Duration(minutes: 3),
          endTime: rejectInteraction.timestamp.add(const Duration(minutes: 3)),
          guideText:
              isRequester
                  ? '⏳ 수행자의 다음 사진을 기다리고 있습니다.'
                  : '⚠️ 사진이 반려되었습니다. 3분 내에 다시 제출해주세요.',
          guideIcon:
              isRequester
                  ? Icons.hourglass_empty_rounded
                  : Icons.sync_problem_outlined,
          guideColor: isRequester ? Colors.blue.shade600 : Colors.red.shade600,
        );
      }

      // 마지막 사진이 '제출 대기' 상태일 때 -> Q&A 또는 의사결정 단계
      if (lastPhoto.status == PhotoStatus.pending) {
        // 마지막 사진이 제출된 시점을 찾습니다.
        final submitInteraction = event.interactions.lastWhereOrNull(
          (i) =>
              i.actionType == ActionType.submitPhoto &&
              i.relatedPhotoId == lastPhoto.id,
        );
        if (submitInteraction == null) return MissionStage.inactive();

        // 사진 제출 이후에 발생한 활동들만 필터링합니다.
        final interactionsAfterPhoto =
            event.interactions
                .where((i) => i.timestamp.isAfter(submitInteraction.timestamp))
                .toList();

        final lastActionAfterPhoto =
            interactionsAfterPhoto.isNotEmpty
                ? interactionsAfterPhoto.last
                : null;

        // 시나리오 1: 사진 제출 후 아무 활동도 없었음 -> 요청자의 1차 의사결정
        if (lastActionAfterPhoto == null) {
          return MissionStage(
            isActive: true,
            totalDuration: const Duration(minutes: 1, seconds: 30),
            endTime: submitInteraction.timestamp.add(
              const Duration(minutes: 1, seconds: 30),
            ),
            guideText:
                isRequester
                    ? '👍 1분 30초 내에 사진을 확인하고 질문 또는 반려해주세요!'
                    : '⏳ 요청자 확인 중...',
            guideIcon:
                isRequester
                    ? Icons.rate_review_outlined
                    : Icons.hourglass_top_rounded,
            guideColor:
                isRequester ? Colors.orange.shade700 : Colors.grey.shade600,
          );
        }

        // 시나리오 2: 사진 제출 후 마지막 활동이 '질문하기'였음 -> 수행자의 답변 시간
        if (lastActionAfterPhoto.actionType == ActionType.askQuestion) {
          return MissionStage(
            isActive: true,
            totalDuration: const Duration(minutes: 1, seconds: 30),
            endTime: lastActionAfterPhoto.timestamp.add(
              const Duration(minutes: 1, seconds: 30),
            ),
            guideText:
                isRequester
                    ? '⏳ 수행자의 답변을 기다리고 있습니다.'
                    : '💬 1분 30초 내에 질문에 답변해주세요.',
            guideIcon:
                isRequester
                    ? Icons.hourglass_bottom_rounded
                    : Icons.question_answer,
            guideColor:
                isRequester ? Colors.grey.shade600 : Colors.purple.shade600,
          );
        }

        // 시나리오 3: 사진 제출 후 마지막 활동이 '답변하기'였음 -> 요청자의 최종 의사결정
        if (lastActionAfterPhoto.actionType == ActionType.answerQuestion) {
          return MissionStage(
            isActive: true,
            totalDuration: const Duration(minutes: 1, seconds: 30),
            endTime: lastActionAfterPhoto.timestamp.add(
              const Duration(minutes: 1, seconds: 30),
            ),
            guideText:
                isRequester
                    ? '👍 답변을 확인했습니다. 1분 30초 내에 최종 승인 또는 반려해주세요.'
                    : '⏳ 요청자의 최종 결정을 기다리고 있습니다.',
            guideIcon:
                isRequester ? Icons.gavel_rounded : Icons.hourglass_top_rounded,
            guideColor:
                isRequester ? Colors.orange.shade700 : Colors.grey.shade600,
          );
        }
      }
    }

    return MissionStage.inactive();
  }

  /// DdipEvent 상태를 기반으로 '예측적 슬라이딩 윈도우'에 표시될 4개의 Step 리스트를 생성합니다.
  List<ProgressStep> _buildProgressSteps(
    DdipEvent event,
    bool hasCurrentUserEvaluated,
  ) {
    // 미션 성공/실패 시
    if (event.status == DdipEventStatus.completed ||
        event.status == DdipEventStatus.failed) {
      final isSuccess = event.status == DdipEventStatus.completed;

      // 평가를 아직 안했다면 '상호 평가'가 현재 단계 (기존 로직 유지)
      if (!hasCurrentUserEvaluated) {
        return [
          ProgressStep(
            label: isSuccess ? '미션 성공!' : '미션 실패',
            status: isSuccess ? StepStatus.success : StepStatus.stopped,
            icon:
                isSuccess ? Icons.celebration_outlined : Icons.cancel_outlined,
          ),
          const ProgressStep(
            label: '상호 평가',
            status: StepStatus.current,
            icon: Icons.reviews_outlined,
          ),
          const ProgressStep(
            label: '완료',
            status: StepStatus.future,
            icon: Icons.check_circle_outline,
          ),
          const ProgressStep(
            label: '',
            status: StepStatus.future,
            icon: Icons.more_horiz,
          ),
        ];
      }
      // ★★★ [핵심 수정] 평가를 완료했다면, '상호 평가'는 완료되고 '완료'가 현재 단계가 됩니다. ★★★
      else {
        return [
          // '미션 성공/실패' 단계는 왼쪽으로 사라지고, '상호 평가'가 첫 번째 칸으로 옵니다.
          const ProgressStep(
            label: '상호 평가',
            status: StepStatus.success, // 완료된 상태로 변경
            icon: Icons.reviews_outlined,
          ),
          const ProgressStep(
            label: '완료',
            status: StepStatus.current, // 현재 단계로 변경
            icon: Icons.check_circle_outline,
          ),
          // 뒤따라오는 미래 단계들은 빈 공간으로 채웁니다.
          const ProgressStep(
            label: '',
            status: StepStatus.future,
            icon: Icons.more_horiz,
          ),
          const ProgressStep(
            label: '',
            status: StepStatus.future,
            icon: Icons.more_horiz,
          ),
        ];
      }
    }

    // 공통 사용될 Step 정의 (코드 가독성 향상)
    const stepMatchingSuccess = ProgressStep(
      label: '수행자 모집',
      status: StepStatus.success,
      icon: Icons.people_outline,
    );
    const stepSubmitSuccess = ProgressStep(
      label: '사진 제출',
      status: StepStatus.success,
      icon: Icons.camera_alt_outlined,
    );
    const stepAnswerSuccess = ProgressStep(
      label: '답변 완료',
      status: StepStatus.success,
      icon: Icons.question_answer_outlined,
    );
    const stepFutureEllipsis = ProgressStep(
      label: '...',
      status: StepStatus.future,
      isPredictive: true,
      icon: Icons.more_horiz,
    );
    const stepFutureMissionEnd = ProgressStep(
      label: '미션 종료',
      status: StepStatus.future,
      icon: Icons.flag_outlined,
    );

    final bool isAnyPhotoRejected = event.photos.any(
      (p) => p.status == PhotoStatus.rejected,
    );

    // ID 0: 수행자 모집
    if (event.status == DdipEventStatus.open) {
      return [
        const ProgressStep(
          label: '요청 등록',
          status: StepStatus.success,
          icon: Icons.edit_note_outlined,
        ),
        const ProgressStep(
          label: '수행자 모집',
          status: StepStatus.current,
          icon: Icons.people_outline,
        ),
        const ProgressStep(
          label: '사진 제출',
          status: StepStatus.future,
          icon: Icons.camera_alt_outlined,
        ),
        const ProgressStep(
          label: '사진 검증',
          status: StepStatus.future,
          icon: Icons.rate_review_outlined,
        ),
      ];
    }

    // 미션 진행 중 상태 (in_progress)
    if (event.status == DdipEventStatus.in_progress) {
      final lastPhoto = event.photos.lastOrNull;

      // ID 1A: 1차 사진 제출
      if (lastPhoto == null) {
        return [
          stepMatchingSuccess,
          const ProgressStep(
            label: '사진 제출',
            status: StepStatus.current,
            icon: Icons.camera_alt_outlined,
          ),
          const ProgressStep(
            label: '사진 검증',
            status: StepStatus.future,
            icon: Icons.rate_review_outlined,
          ),
          stepFutureEllipsis,
        ];
      }

      // 1차 또는 2차 시도의 검증 단계
      if (lastPhoto.status == PhotoStatus.pending) {
        // ID 1B, 1C, 1D: 1차 시도 검증 루프
        if (!isAnyPhotoRejected) {
          if (lastPhoto.requesterQuestion != null &&
              lastPhoto.responderAnswer != null) {
            // 1D
            return [
              stepAnswerSuccess,
              const ProgressStep(
                label: '1차 최종 결정',
                status: StepStatus.current,
                icon: Icons.gavel_outlined,
              ),
              stepFutureEllipsis,
              stepFutureMissionEnd,
            ];
          }
          if (lastPhoto.requesterQuestion != null) {
            // 1C
            return [
              const ProgressStep(
                label: '사진 검증(질문)',
                status: StepStatus.question,
                icon: Icons.rate_review_outlined,
              ),
              const ProgressStep(
                label: '답변 작성',
                status: StepStatus.current,
                icon: Icons.question_answer_outlined,
              ),
              const ProgressStep(
                label: '1차 최종 결정',
                status: StepStatus.future,
                icon: Icons.gavel_outlined,
              ),
              stepFutureEllipsis,
            ];
          }
          return [
            stepSubmitSuccess,
            const ProgressStep(
              label: '사진 검증',
              status: StepStatus.current,
              icon: Icons.rate_review_outlined,
            ),
            stepFutureEllipsis,
            stepFutureMissionEnd,
          ]; // 1B
        }
        // ★★★ [버그 수정] ID 2B, 2C, 2D: 2차 시도 검증 루프 ★★★
        else {
          const stepResubmitSuccess = ProgressStep(
            label: '사진 재제출',
            status: StepStatus.success,
            icon: Icons.camera_alt_outlined,
          );
          if (lastPhoto.requesterQuestion != null &&
              lastPhoto.responderAnswer != null) {
            // 2D
            return [
              stepAnswerSuccess,
              const ProgressStep(
                label: '2차 최종 결정',
                status: StepStatus.current,
                icon: Icons.gavel_outlined,
              ),
              stepFutureEllipsis,
              stepFutureMissionEnd,
            ];
          }
          if (lastPhoto.requesterQuestion != null) {
            // 2C
            return [
              const ProgressStep(
                label: '사진 검증(질문)',
                status: StepStatus.question,
                icon: Icons.rate_review_outlined,
              ),
              const ProgressStep(
                label: '답변 작성',
                status: StepStatus.current,
                icon: Icons.question_answer_outlined,
              ),
              const ProgressStep(
                label: '2차 최종 결정',
                status: StepStatus.future,
                icon: Icons.gavel_outlined,
              ),
              stepFutureEllipsis,
            ];
          }
          return [
            stepResubmitSuccess,
            const ProgressStep(
              label: '2차 사진 검증',
              status: StepStatus.current,
              icon: Icons.rate_review_outlined,
            ),
            stepFutureEllipsis,
            stepFutureMissionEnd,
          ]; // 2B
        }
      }

      // ID 2A: 2차 사진 제출 (1차 반려 직후)
      if (lastPhoto.status == PhotoStatus.rejected) {
        return [
          const ProgressStep(
            label: '1차 최종 결정',
            status: StepStatus.rejected,
            icon: Icons.gavel_outlined,
          ),
          const ProgressStep(
            label: '사진 재제출',
            status: StepStatus.current,
            icon: Icons.camera_alt_outlined,
          ),
          const ProgressStep(
            label: '사진 검증',
            status: StepStatus.future,
            icon: Icons.rate_review_outlined,
          ),
          stepFutureEllipsis,
        ];
      }
    }

    // END-C: 미션 성공
    if (event.status == DdipEventStatus.completed) {
      return [
        const ProgressStep(
          label: '미션 성공!',
          status: StepStatus.success,
          icon: Icons.celebration_outlined,
        ),
        const ProgressStep(
          label: '상호 평가',
          status: StepStatus.current,
          icon: Icons.reviews_outlined,
        ),
        const ProgressStep(
          label: '완료',
          status: StepStatus.future,
          icon: Icons.check_circle_outline,
        ),
        const ProgressStep(
          label: '',
          status: StepStatus.future,
          icon: Icons.more_horiz,
        ),
      ];
    }

    // ★★★ [버그 수정] END-I: 미션 실패 ★★★
    if (event.status == DdipEventStatus.failed) {
      return [
        const ProgressStep(
          label: '미션 실패',
          status: StepStatus.stopped,
          icon: Icons.cancel_outlined,
        ),
        const ProgressStep(
          label: '상호 평가',
          status: StepStatus.current,
          icon: Icons.reviews_outlined,
        ),
        const ProgressStep(
          label: '완료',
          status: StepStatus.future,
          icon: Icons.check_circle_outline,
        ),
        const ProgressStep(
          label: '',
          status: StepStatus.future,
          icon: Icons.more_horiz,
        ),
      ];
    }

    // 어떤 조건에도 해당하지 않을 경우의 기본값 (ID 0과 동일)
    return [
      const ProgressStep(
        label: '요청 등록',
        status: StepStatus.success,
        icon: Icons.edit_note_outlined,
      ),
      const ProgressStep(
        label: '수행자 모집',
        status: StepStatus.current,
        icon: Icons.people_outline,
      ),
      const ProgressStep(
        label: '사진 제출',
        status: StepStatus.future,
        icon: Icons.camera_alt_outlined,
      ),
      const ProgressStep(
        label: '사진 검증',
        status: StepStatus.future,
        icon: Icons.rate_review_outlined,
      ),
    ];
  }

  // 버튼 클릭을 처리하는 유일한 진입점 메서드
  Future<void> handleButtonPress(BuildContext context) async {
    // ViewModel이 현재 가지고 있는 최신 이벤트 데이터를 가져옵니다.
    final event = state.event.value;
    if (event == null || state.isProcessing) return; // 이미 처리 중이면 중복 실행 방지

    state = state.copyWith(isProcessing: true); // 로딩 시작

    try {
      // 이벤트 상태에 따라 적절한 로직 호출
      if (event.status == DdipEventStatus.open) {
        await _ref
            .read(ddipEventsNotifierProvider.notifier)
            .applyToEvent(_eventId);
      } else if (event.status == DdipEventStatus.in_progress) {
        await _processPhotoSubmission(context);
      }
      // 성공 시에는 isProcessing을 여기서 false로 바꾸지 않습니다.
      // 스트림 리스너가 새로운 데이터를 받아 _updateStateFromEvent를 호출하며
      // isProcessing을 false로 바꿔줄 것이기 때문입니다.
    } catch (e) {
      // 에러 발생 시에는 로딩 상태를 직접 해제해줘야 합니다.
      if (mounted) {
        state = state.copyWith(isProcessing: false);
      }
      print("handleButtonPress Error: $e");
    }
  }

  /// 텍스트 입력을 위한 공용 다이얼로그를 표시하는 헬퍼 메서드.
  /// [isRequired]가 true이면 빈 문자열을 제출할 수 없습니다.
  Future<String?> _showTextInputDialog(
    BuildContext context, {
    required String title,
    String hintText = '내용을 입력하세요...',
    bool isRequired = true,
  }) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(hintText: hintText),
              autofocus: true,
              validator:
                  isRequired
                      ? (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '내용을 입력해주세요.';
                        }
                        return null;
                      }
                      : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                if (isRequired && !formKey.currentState!.validate()) {
                  return;
                }
                Navigator.pop(context, controller.text);
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  // 사진 제출과 관련된 전체 흐름을 담당하는 내부 메서드
  Future<void> _processPhotoSubmission(BuildContext context) async {
    try {
      // 1. ImagePicker 인스턴스를 생성합니다.
      final picker = ImagePicker();

      // 2. picker.pickImage를 호출하여 기본 카메라 앱을 실행하고 결과를 기다립니다.
      final photo = await picker.pickImage(source: ImageSource.camera);

      // 3. 사용자가 사진을 찍지 않고 취소했다면, 로딩을 멈추고 함수를 종료합니다.
      if (photo == null || !context.mounted) {
        state = state.copyWith(isProcessing: false);
        return;
      }

      // 4. 촬영된 사진(photo)을 가지고, 기존에 사용하던 미리보기 및 코멘트 작성 화면으로 이동합니다.
      //    이를 통해 코드 재사용성을 높이고 UI 일관성을 유지합니다.
      final result = await Navigator.of(context).push<PhotoSubmissionResult?>(
        MaterialPageRoute(
          // XFile 객체를 PhotoPreviewScreen에 넘겨줍니다.
          builder: (context) => PhotoPreviewScreen(image: photo),
        ),
      );

      // 5. 사용자가 미리보기 화면에서 '전송하기'를 누르지 않고 뒤로가기 했다면 함수를 종료합니다.
      if (result == null || !context.mounted) {
        state = state.copyWith(isProcessing: false);
        return;
      }

      // 6. 최종 결과물(이미지 경로 + 코멘트)을 사용하여 서버에 사진을 제출합니다.
      await submitPhoto(imagePath: result.imagePath, comment: result.comment);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('사진을 처리하는 중 오류가 발생했습니다: $e')));
      }
      rethrow;
    }
  }

  /// 현재 이벤트 상태에 따라 올바른 Sliver 위젯 목록을 조립하여 반환합니다.
  List<Widget> buildMissionLogSlivers(DdipEvent event) {
    final List<Widget> slivers = [];

    // 1. 공통 영역: 요청 상세 내용 카드를 먼저 추가합니다.
    slivers.add(
      SliverToBoxAdapter(child: DetailedRequestCard(content: event.content)),
    );

    // 2. 상태별 분기: 미션 상태에 따라 다른 Sliver를 추가합니다.
    switch (event.status) {
      // '지원 가능' 상태일 때는 '수행자 목록' Sliver를 추가합니다.
      case DdipEventStatus.open:
        slivers.add(_buildApplicantListSliver(event));
        break;
      // 그 외의 상태(진행중, 완료, 실패)일 때는 '활동 타임라인' Sliver를 추가합니다.
      case DdipEventStatus.in_progress:
      case DdipEventStatus.completed:
      case DdipEventStatus.failed:
        slivers.add(CommunicationLogSliver(event: event));
        break;
    }
    return slivers;
  }

  /// '수행자 목록'을 표시하는 SliverList를 생성하는 헬퍼 메서드입니다.
  Widget _buildApplicantListSliver(DdipEvent event) {
    // Sliver 위젯의 헤더 부분
    final header = SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 16.0, 16.0, 8.0),
        child: Text(
          '수행자 목록 (${event.applicants.length}명)',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );

    // 수행자가 없으면 헤더와 안내 메시지만 표시
    if (event.applicants.isEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate([
          header.child!,
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40.0),
            child: Center(
              child: Text(
                '아직 수행자가 없습니다.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ]),
      );
    }

    // 수행자 목록을 렌더링하는 SliverList 본문
    final body = SliverList.builder(
      itemCount: event.applicants.length,
      itemBuilder: (context, index) {
        final applicantId = event.applicants[index];
        final User applicant = _ref
            .watch(mockUsersProvider)
            .firstWhere(
              (user) => user.id == applicantId,
              orElse: () => User(id: applicantId, name: '알 수 없는 사용자'),
            );

        final isRequester = event.requesterId == _ref.read(authProvider)?.id;

        // v2.0 디자인에 맞춘 ListTile
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person_outline)),
            title: Text(
              applicant.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 14),
                Text(' 4.5 / 8회 완료'), // TODO: 실제 평판 데이터 연동
              ],
            ),
            trailing:
                isRequester
                    ? FilledButton(
                      onPressed: () {
                        _ref
                            .read(ddipEventsNotifierProvider.notifier)
                            .selectResponder(event.id, applicantId);
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: const Text('선택'),
                    )
                    : null,
            onTap: () {
              // go_router를 사용해 프로필 화면으로 이동합니다.
              context.push('/profile/${applicant.id}');
            },
          ),
        );
      },
    );

    return SliverMainAxisGroup(slivers: [header, body]);
  }

  /// 사진 제출 비즈니스 로직의 '후반부'를 담당하는 메서드
  Future<void> submitPhoto({required String imagePath, String? comment}) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // PhotoPreviewScreen에서 받은 코멘트를 Photo 객체에 담습니다.
      final newPhoto = Photo(
        id: const Uuid().v4(),
        url: imagePath,
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
        responderComment: comment, // 여기에 코멘트가 담깁니다.
      );

      // Notifier의 addPhoto는 Photo 객체를 통째로 받으므로 수정 없이 그대로 사용 가능합니다.
      final updatedEvent = await _ref
          .read(ddipEventsNotifierProvider.notifier)
          .addPhoto(_eventId, newPhoto, action: ActionType.submitPhoto);

      // 상태 업데이트
      _updateStateFromEvent(updatedEvent);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addCommentToPhoto(String photoId, String comment) async {
    // TODO: Notifier에 사진 코멘트를 업데이트하는 로직을 호출하도록 구현해야 합니다.
    print('코멘트 추가: [사진 ID: $photoId] $comment');
    // 예: await _ref.read(ddipEventsNotifierProvider.notifier).addComment(photoId, comment);
  }

  Future<void> askQuestion(
    BuildContext context,
    String photoId,
    String question, // ✅ [수정] 3번째 인자로 질문 텍스트를 직접 받습니다.
  ) async {
    // 1. 다이얼로그를 띄우는 로직을 삭제합니다.
    state = state.copyWith(isProcessing: true);
    try {
      // 2. Notifier에게 바로 작업을 위임합니다.
      await _ref
          .read(ddipEventsNotifierProvider.notifier)
          .askQuestionOnPhoto(_eventId, photoId, question);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류: $e')));
        state = state.copyWith(isProcessing: false);
      }
    }
    // 상태 업데이트는 Notifier의 스트림을 통해 자동으로 반영됩니다.
  }

  Future<void> requestRevision(String photoId, String reason) async {
    // TODO: Repository를 호출하여 재요청을 서버에 전송하는 로직 구현
    print('재요청: [사진 ID: $photoId] $reason');
    // 로직 처리 후 상태 업데이트를 위해 Notifier를 통해 상태 변경 요청
  }

  /// 수행자가 요청자의 질문에 답변하는 메서드
  Future<void> answerQuestion(
    BuildContext context,
    String photoId,
    String answer, // ✨ [핵심 수정] 이제 답변 텍스트를 파라미터로 직접 받습니다.
  ) async {
    // 1. 다이얼로그를 띄우는 로직을 삭제합니다.
    state = state.copyWith(isProcessing: true);
    try {
      // 2. Notifier에게 바로 작업을 위임합니다.
      await _ref
          .read(ddipEventsNotifierProvider.notifier)
          .answerQuestionOnPhoto(_eventId, photoId, answer);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류: $e')));
        state = state.copyWith(isProcessing: false);
      }
    }
    // 성공 시 상태 업데이트는 스트림을 통해 자동으로 반영됩니다.
  }

  /// 요청자가 사진을 반려하는 메서드
  Future<void> rejectPhotoWithReason(
    BuildContext context,
    String photoId,
    String reason, // ✅ [수정] 3번째 인자로 반려 사유를 직접 받습니다.
  ) async {
    // 1. 다이얼로그를 띄우는 로직을 삭제합니다.
    state = state.copyWith(isProcessing: true);
    try {
      // 2. Notifier에게 바로 작업을 위임합니다.
      await _ref
          .read(ddipEventsNotifierProvider.notifier)
          .updatePhotoStatus(
            _eventId,
            photoId,
            PhotoStatus.rejected,
            comment: reason, // 반려 사유를 comment 파라미터로 전달
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류: $e')));
        state = state.copyWith(isProcessing: false);
      }
    }
  }

  // EventDetailViewModel 클래스 내부에 아래 메소드를 추가
  Future<void> completeMission(BuildContext context) async {
    state = state.copyWith(isProcessing: true);
    try {
      await _ref
          .read(ddipEventsNotifierProvider.notifier)
          .completeMission(_eventId);
      // 성공 시 스트림을 통해 자동으로 상태가 갱신됨
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류: $e')));
        state = state.copyWith(isProcessing: false);
      }
    }
  }

  /// UI에서 미션 중단(강제 종료)을 요청할 때 호출되는 메서드
  Future<void> cancelMission(BuildContext context) async {
    if (state.isProcessing) return;
    state = state.copyWith(isProcessing: true);

    try {
      // Notifier에게 실제 로직 처리를 위임
      await _ref
          .read(ddipEventsNotifierProvider.notifier)
          .cancelMission(_eventId);
      // 성공 시에는 스트림을 통해 상태가 자동으로 갱신되므로 isProcessing을 false로 바꿀 필요 없음
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isProcessing: false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: $e')));
      }
    }
  }

  /// 평가 화면으로 이동하고, 돌아온 후 상태를 갱신합니다.
  void navigateToEvaluation(BuildContext context) async {
    // async 키워드 추가
    // 1. 로딩 상태를 true로 설정합니다.
    state = state.copyWith(isProcessing: true);

    final event = state.event.value;
    if (event == null) {
      state = state.copyWith(isProcessing: false); // 이벤트 없으면 로딩 해제
      return;
    }

    // 2. 평가 화면으로 이동하고, 해당 화면이 닫힐 때까지 'await'로 기다립니다.
    await context.push('/feed/${event.id}/evaluate', extra: event);

    // 3. [핵심 수정] 평가 화면에서 돌아온 직후, ViewModel의 상태를 강제로 새로고침합니다.
    //    _updateStateFromEvent 메소드를 다시 호출하여 평가 완료 여부를 재확인하고,
    //    isProcessing 상태를 false로 되돌립니다.
    if (mounted) {
      // 위젯이 여전히 화면에 있는지 확인
      _updateStateFromEvent(event);
    }
  }
}
