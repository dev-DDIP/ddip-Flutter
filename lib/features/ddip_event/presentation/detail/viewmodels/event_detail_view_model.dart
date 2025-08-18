// lib/features/ddip_event/presentation/detail/viewmodels/event_detail_view_model.dart

import 'dart:async';

import 'package:ddip/features/auth/domain/entities/user.dart';
import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/camera/camera_screen.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/interaction.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/CommunicationLogSliver.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
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
    Stream<Duration>? countdownStream,
  }) = _EventDetailState;
}

class EventDetailViewModel extends StateNotifier<EventDetailState> {
  final Ref _ref;
  final String _eventId;

  // Stream의 구독을 관리하기 위한 변수
  StreamSubscription<DdipEvent>? _eventSubscription;

  Timer? _countdownTimer;
  StreamController<Duration>? _countdownController;

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

    // --- 버튼 상태 결정 로직 (기존과 동일) ---
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

    // --- 타이머 로직 ---
    Stream<Duration>? newCountdownStream = state.countdownStream;
    if (event.status == DdipEventStatus.in_progress &&
        _countdownTimer == null) {
      final matchedInteraction = event.interactions.lastWhere(
        (i) => i.actionType == ActionType.selectResponder,
        orElse:
            () => Interaction(
              id: '',
              actorId: '',
              actorRole: ActorRole.system,
              actionType: ActionType.create,
              timestamp: DateTime.now(),
            ),
      );
      final matchedTime = matchedInteraction.timestamp;
      final endTime = matchedTime.add(const Duration(minutes: 3));

      _countdownController = StreamController<Duration>.broadcast();
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final remaining = endTime.difference(DateTime.now());
        if (remaining.isNegative) {
          _countdownController?.add(Duration.zero);
          timer.cancel();
        } else {
          _countdownController?.add(remaining);
        }
      });
      newCountdownStream = _countdownController?.stream;
    }

    // --- 최종 상태 업데이트 ---
    // if 블록 밖으로 이동하여 항상 상태가 업데이트되도록 수정했습니다.
    state = state.copyWith(
      event: AsyncValue.data(event),
      buttonText: text,
      buttonIsEnabled: isEnabled,
      buttonColor: color,
      isProcessing: false,
      countdownStream: newCountdownStream, // 타이머 스트림도 함께 업데이트
    );
  }

  @override
  void dispose() {
    // ViewModel이 파괴될 때, Stream 구독을 반드시 취소하여 메모리 누수를 방지합니다.
    _eventSubscription?.cancel();
    _countdownTimer?.cancel();
    _countdownController?.close();
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
    state = state.copyWith(isProcessing: true);
    try {
      // 1. 카메라 화면으로 이동하여 사진 경로를 받아옵니다.
      final imagePath = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (context) => const CameraScreen()),
      );
      if (imagePath == null || !context.mounted) {
        state = state.copyWith(isProcessing: false);
        return;
      }

      // 2. [수정] 수행자 코멘트를 (선택적으로) 입력받는 다이얼로그를 띄웁니다.
      final responderComment = await _showTextInputDialog(
        context,
        title: '코멘트 추가 (선택)',
        hintText: '사진에 대한 부연 설명을 남길 수 있습니다.',
        isRequired: false, // 코멘트는 선택 사항
      );

      // 사용자가 다이얼로그를 그냥 닫은 경우에도 진행은 계속됩니다 (코멘트만 null).
      // 3. 최종적으로 사진과 추가 정보를 제출하는 로직을 호출합니다.
      await submitPhoto(
        imagePath: imagePath,
        responderComment: responderComment, // 입력받은 코멘트 전달
      );
    } catch (e) {
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

  /// 현재 이벤트 상태에 따라 올바른 Sliver 위젯 목록을 조립하여 반환합니다.
  List<Widget> buildMissionLogSlivers(DdipEvent event) {
    final List<Widget> slivers = [];

    // 공통 영역: 미션 상세 내용
    slivers.add(
      SliverToBoxAdapter(
        child: Card(
          elevation: 0,
          color: Colors.grey.shade50,
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              event.content,
              style: const TextStyle(fontSize: 15, height: 1.6),
            ),
          ),
        ),
      ),
    );

    // 상태별 분기
    switch (event.status) {
      case DdipEventStatus.open:
        slivers.add(_buildApplicantListSliver(event));
        break;
      case DdipEventStatus.in_progress:
      case DdipEventStatus.completed:
      case DdipEventStatus.failed:
        // 방금 만든 CommunicationLogSliver 위젯을 여기에 추가합니다.
        slivers.add(CommunicationLogSliver(event: event));
        break;
    }
    return slivers;
  }

  /// '지원자 목록'을 표시하는 SliverList를 생성하는 헬퍼 메서드입니다.
  Widget _buildApplicantListSliver(DdipEvent event) {
    // Sliver 위젯의 헤더 부분
    final header = SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 16.0, 16.0, 8.0),
        child: Text(
          '지원자 목록 (${event.applicants.length}명)',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );

    // 지원자가 없으면 헤더와 안내 메시지만 표시
    if (event.applicants.isEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate([
          header.child!,
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40.0),
            child: Center(
              child: Text(
                '아직 지원자가 없습니다.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ]),
      );
    }

    // 지원자 목록을 렌더링하는 SliverList 본문
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
  Future<void> submitPhoto({
    required String imagePath,
    String? responderComment,
  }) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final newPhoto = Photo(
        id: const Uuid().v4(),
        url: imagePath,
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
        // responderComment: responderComment, // Photo 엔티티에 이 필드가 있어야 합니다.
      );

      // Notifier에는 Photo 객체 하나만 전달하도록 간소화합니다.
      await _ref
          .read(ddipEventsNotifierProvider.notifier)
          .addPhoto(
            _eventId,
            newPhoto,
            action: ActionType.submitPhoto,
            // comment 파라미터는 제거합니다. Notifier가 Photo 객체에서 직접 꺼내 쓰도록 합니다.
          );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> askQuestion(String photoId, String question) async {
    // TODO: Repository를 호출하여 질문을 서버에 전송하는 로직 구현
    print('질문 제출: [사진 ID: $photoId] $question');
    // 로직 처리 후 상태 업데이트를 위해 Notifier를 통해 상태 변경 요청
  }

  Future<void> requestRevision(String photoId, String reason) async {
    // TODO: Repository를 호출하여 재요청을 서버에 전송하는 로직 구현
    print('재요청: [사진 ID: $photoId] $reason');
    // 로직 처리 후 상태 업데이트를 위해 Notifier를 통해 상태 변경 요청
  }

  /// 수행자가 요청자의 질문에 답변하는 메서드
  Future<void> answerQuestion(BuildContext context, String photoId) async {
    final answer = await _showTextInputDialog(
      context,
      title: '답변하기',
      hintText: '요청자의 질문에 대해 답변해주세요.',
      isRequired: true,
    );

    if (answer != null && answer.trim().isNotEmpty) {
      state = state.copyWith(isProcessing: true);
      try {
        // TODO: Notifier에 answerQuestion 로직 구현 후 호출
        print('답변 제출: $answer');
      } finally {
        if (mounted) state = state.copyWith(isProcessing: false);
      }
    }
  }

  /// 요청자가 사진을 반려하는 메서드
  Future<void> rejectPhotoWithReason(
    BuildContext context,
    String photoId,
  ) async {
    final reason = await _showTextInputDialog(
      context,
      title: '사진 반려 사유 입력',
      hintText: '최초 요청사항과 어떻게 다른지 구체적으로 작성해주세요.',
      isRequired: true,
    );

    if (reason != null && reason.trim().isNotEmpty) {
      await _ref
          .read(ddipEventsNotifierProvider.notifier)
          .updatePhotoStatus(
            _eventId,
            photoId,
            PhotoStatus.rejected,
            comment: reason,
          );
    }
  }
}
