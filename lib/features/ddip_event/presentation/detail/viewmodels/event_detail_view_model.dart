// lib/features/ddip_event/presentation/detail/viewmodels/event_detail_view_model.dart

import 'package:ddip/features/auth/providers/auth_provider.dart';
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

// 1. View가 사용할 상태(State)를 정의합니다.
// EventActionButton을 그리는 데 필요한 모든 정보를 담습니다.
@freezed
class EventDetailState with _$EventDetailState {
  const factory EventDetailState({
    @Default(false) bool isProcessing, // 로딩 중 여부
    String? buttonText, // 버튼에 표시될 텍스트 (nullable)
    @Default(false) bool buttonIsEnabled, // 버튼 활성화 여부
    Color? buttonColor, // 버튼 색상 (nullable)
  }) = _EventDetailState;
}

// 2. 상태를 관리하고 비즈니스 로직을 수행할 ViewModel(Notifier)을 정의합니다.
class EventDetailViewModel extends StateNotifier<EventDetailState> {
  final Ref _ref;
  final String _eventId;

  EventDetailViewModel(this._ref, this._eventId)
    : super(const EventDetailState()) {
    // ViewModel이 처음 생성될 때, 이벤트 상태를 기반으로 버튼의 초기 상태를 설정합니다.
    _initialize();
  }

  void _initialize() {
    // eventStreamProvider를 사용하여 현재 이벤트 데이터를 가져옵니다.
    final eventAsyncValue = _ref.read(eventStreamProvider(_eventId));
    final currentUser = _ref.read(authProvider);

    eventAsyncValue.whenData((event) {
      if (currentUser == null) {
        state = state.copyWith(
          buttonIsEnabled: false,
          buttonText: '로그인이 필요합니다.',
        );
        return;
      }

      // 기존 EventActionButton에 있던 복잡한 UI 결정 로직을 이곳으로 이전합니다.
      String? text;
      bool isEnabled = false;
      Color? color;

      final bool isRequester = event.requesterId == currentUser.id;
      final bool isSelectedResponder =
          event.selectedResponderId == currentUser.id;
      final bool hasApplied = event.applicants.contains(currentUser.id);
      final hasPendingPhoto = event.photos.any(
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

      state = state.copyWith(
        buttonText: text,
        buttonIsEnabled: isEnabled,
        buttonColor: color,
      );
    });
  }

  /// '지원하기' 비즈니스 로직을 수행하는 메서드
  Future<void> applyToEvent() async {
    // 1. 로딩 상태 시작: UI에 로딩 인디케이터를 표시하도록 알림
    state = state.copyWith(isProcessing: true);

    try {
      // 2. 실제 로직 수행: DdipEventsNotifier를 호출하여 '지원하기' 기능을 실행
      //    이 ViewModel은 UI와 핵심 비즈니스 로직(Notifier) 사이의 '다리' 역할을 합니다.
      await _ref
          .read(ddipEventsNotifierProvider.notifier)
          .applyToEvent(_eventId);

      // 3. 성공 시 UI 상태 갱신: 지원 후에는 버튼이 비활성화되어야 합니다.
      //    (더 이상 지원할 수 없으므로)
      state = state.copyWith(
        buttonIsEnabled: false,
        buttonText: '지원이 완료되었습니다.',
      );
    } catch (e) {
      // 4. 에러 처리: 에러가 발생하면 UI에 알려줄 수 있습니다. (추후 구현)
      //    예: state = state.copyWith(errorText: e.toString());
      rethrow; // 에러를 다시 던져서 UI 계층에서 스낵바 등으로 표시할 수 있게 함
    } finally {
      // 5. 로딩 상태 종료: 성공하든 실패하든, 로딩 상태를 해제합니다.
      state = state.copyWith(isProcessing: false);
    }
  }

  /// 사진 제출 비즈니스 로직의 '후반부'를 담당하는 메서드
  Future<void> submitPhoto({
    required String imagePath,
    required Map<String, dynamic> submissionResult,
  }) async {
    state = state.copyWith(isProcessing: true);

    try {
      // 1. Geolocator 호출, Photo 객체 생성 등 핵심 비즈니스 로직을 수행합니다.
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final newPhoto = Photo(
        id: const Uuid().v4(),
        url: imagePath,
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
      );

      // 2. DdipEventsNotifier에 최종 데이터를 전달하여 상태 업데이트를 요청합니다.
      await _ref
          .read(ddipEventsNotifierProvider.notifier)
          .addPhoto(
            _eventId,
            newPhoto,
            action: submissionResult['action'] as ActionType,
            messageCode: submissionResult['message'] as MessageCode?,
          );

      // 3. 성공 후 UI 상태를 갱신합니다. (예: 피드백 대기 중 메시지 표시)
      state = state.copyWith(
        buttonIsEnabled: false,
        buttonText: '요청자 피드백 대기 중',
      );
    } catch (e) {
      // 에러 처리
      rethrow;
    } finally {
      state = state.copyWith(isProcessing: false);
    }
  }
}
