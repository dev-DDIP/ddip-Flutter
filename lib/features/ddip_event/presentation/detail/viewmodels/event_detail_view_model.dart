// lib/features/ddip_event/presentation/detail/viewmodels/event_detail_view_model.dart

import 'dart:async';

import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/camera/camera_screen.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/interaction.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';
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
  }) = _EventDetailState;
}

class EventDetailViewModel extends StateNotifier<EventDetailState> {
  final Ref _ref;
  final String _eventId;

  // Stream의 구독을 관리하기 위한 변수
  StreamSubscription<DdipEvent>? _eventSubscription;

  EventDetailViewModel(this._ref, this._eventId)
    : super(const EventDetailState()) {
    // ViewModel이 생성되자마자 데이터 로딩 및 실시간 업데이트 수신을 시작합니다.
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

  void _updateStateFromEvent(DdipEvent event) {
    final currentUser = _ref.read(authProvider);

    if (currentUser == null) {
      state = state.copyWith(
        event: AsyncValue.data(event),
        buttonIsEnabled: false,
        buttonText: '로그인이 필요합니다.',
      );
      return;
    }

    // --- 기존의 버튼 상태 결정 로직을 이곳으로 가져옵니다 ---
    String? text;
    bool isEnabled = false;
    Color? color;

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

    // 데이터와 파생된 UI 상태를 '원자적'으로 한 번에 업데이트합니다.
    state = state.copyWith(
      event: AsyncValue.data(event),
      buttonText: text,
      buttonIsEnabled: isEnabled,
      buttonColor: color,
      isProcessing: false,
    );
  }

  @override
  void dispose() {
    // ViewModel이 파괴될 때, Stream 구독을 반드시 취소하여 메모리 누수를 방지합니다.
    _eventSubscription?.cancel();
    super.dispose();
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

  // 사진 제출과 관련된 전체 흐름을 담당하는 내부 메서드
  Future<void> _processPhotoSubmission(BuildContext context) async {
    state = state.copyWith(isProcessing: true);
    try {
      // 1. 카메라 화면으로 이동하여 사진 경로를 받아옵니다.
      final imagePath = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (context) => const CameraScreen()),
      );
      // 사용자가 사진을 찍지 않고 뒤로가기 한 경우
      if (imagePath == null || !context.mounted) {
        state = state.copyWith(isProcessing: false);
        return;
      }

      // 2. 제출 옵션 다이얼로그를 띄워 추가 정보를 받습니다.
      final submissionResult = await _showSubmissionOptionsDialog(context);
      // 사용자가 다이얼로그에서 '취소'를 누른 경우
      if (submissionResult == null) {
        state = state.copyWith(isProcessing: false);
        return;
      }

      // 3. 최종적으로 사진과 추가 정보를 제출하는 로직을 호출합니다.
      await submitPhoto(
        imagePath: imagePath,
        submissionResult: submissionResult,
      );
    } catch (e) {
      // 에러 처리
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: $e')));
      }
      rethrow;
    } finally {
      if (mounted) {
        state = state.copyWith(isProcessing: false);
      }
    }
  }

  // 사진 제출 시 옵션을 선택하는 다이얼로그를 보여주는 메서드
  Future<Map<String, dynamic>?> _showSubmissionOptionsDialog(
    BuildContext context,
  ) async {
    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('수행 옵션 선택'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('현장 상황을 선택해주세요.'),
                const SizedBox(height: 16),
                // --- 단순 사진 제출 ---
                ElevatedButton(
                  child: const Text('단순 사진 제출'),
                  onPressed:
                      () => Navigator.pop(context, {
                        'action': ActionType.submitPhoto,
                        'message': null,
                      }),
                ),
                const Divider(height: 24),
                // --- 특별 상황 보고 ---
                const Text('또는, 특별한 상황 보고:'),
                ListTile(
                  title: const Text('재료가 소진되어 마감됐어요.'),
                  onTap:
                      () => Navigator.pop(context, {
                        'action': ActionType.reportSituation,
                        'message': MessageCode.soldOut,
                      }),
                ),
                ListTile(
                  title: const Text('대기 줄이 너무 길어요.'),
                  onTap:
                      () => Navigator.pop(context, {
                        'action': ActionType.reportSituation,
                        'message': MessageCode.longQueue,
                      }),
                ),
                ListTile(
                  title: const Text('요청 장소가 현재 닫혀있어요.'),
                  onTap:
                      () => Navigator.pop(context, {
                        'action': ActionType.reportSituation,
                        'message': MessageCode.placeClosed,
                      }),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () => Navigator.pop(context, null),
            ),
          ],
        );
      },
    );
  }

  /// 사진 제출 비즈니스 로직의 '후반부'를 담당하는 메서드
  Future<void> submitPhoto({
    required String imagePath,
    required Map<String, dynamic> submissionResult,
  }) async {
    try {
      // 1. geolocator로 현재 위치를 정확하게 가져옵니다.
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      // 2. 제출할 Photo 객체를 생성합니다.
      final newPhoto = Photo(
        id: const Uuid().v4(),
        url: imagePath,
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
      );
      // 3. DdipEventsNotifier에 최종 데이터를 전달하여 상태 업데이트를 요청합니다.
      await _ref
          .read(ddipEventsNotifierProvider.notifier)
          .addPhoto(
            _eventId,
            newPhoto,
            action: submissionResult['action'] as ActionType,
            messageCode: submissionResult['message'] as MessageCode?,
          );
    } catch (e) {
      rethrow;
    }
  }
}
