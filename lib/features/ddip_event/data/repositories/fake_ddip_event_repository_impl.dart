import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo_feedback.dart';
import 'package:ddip/features/ddip_event/domain/repositories/ddip_event_repository.dart';

// 실제 서버 API 대신, 앱의 메모리에서 가짜 데이터를 관리하는 클래스입니다.
// 클린 아키텍처 덕분에, 나중에 이 파일만 실제 API를 호출하는 파일로 교체하면
// 앱의 다른 부분은 전혀 수정할 필요가 없습니다.
class FakeDdipEventRepositoryImpl implements DdipEventRepository {
  // 1. [추가] 앱이 실행되는 동안 '띱' 목록을 저장할 메모리 내 리스트
  final List<DdipEvent> _ddipEvents = [
    DdipEvent(
      id: 'event_1',
      title: '북문 앞 타코야끼 트럭 왔나요?',
      content: '지금 가면 바로 먹을 수 있는지 궁금해요. 사진 한 장만 부탁드립니다!',
      requesterId: 'requester_1', // 김요청
      reward: 1000,
      latitude: 35.8925,
      longitude: 128.60953,
      status: DdipEventStatus.open,
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      applicants: [], // 시나리오 1: 지원자 아직 없음
    ),
    DdipEvent(
      id: 'event_2',
      title: '센트럴파크에 2명 앉을 벤치 있나요?',
      content: '친구랑 치킨 먹으러는데 자리 있는지 봐주세요!',
      requesterId: 'requester_1', // 김요청
      reward: 500,
      latitude: 35.890,
      longitude: 128.612,
      status: DdipEventStatus.open,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      applicants: ['responder_1', 'responder_2'], // 시나리오 2: 여러 명 지원한 상태
    ),
    DdipEvent(
      id: 'event_3',
      title: '공대 9호관 1층 프린터 대기줄 긴가요?',
      content: 'A4 10장 뽑아야 하는데, 지금 가면 얼마나 기다릴지 사진으로 알려주세요.',
      requesterId: 'requester_2', // 박지원
      reward: 1500,
      latitude: 35.888,
      longitude: 128.611,
      status: DdipEventStatus.in_progress,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      applicants: ['responder_1'],
      selectedResponderId: 'responder_1', // 이수행 선택됨
      photos: [], // 시나리오 3: 미션 진행중, 아직 사진 제출 전
    ),
    DdipEvent(
      id: 'event_4',
      title: 'IT 1호관 404호 불 켜져 있나요?',
      content: '과제를 놓고 온 것 같은데, 아직 불이 켜져 있는지 확인 부탁드립니다.',
      requesterId: 'requester_1', // 김요청
      reward: 800,
      latitude: 35.889,
      longitude: 128.610,
      status: DdipEventStatus.in_progress,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      applicants: ['responder_2'],
      selectedResponderId: 'responder_2', // 박지원 선택됨
      photos: [
        // 시나리오 4: 사진 1장 제출 후 피드백 대기중
        PhotoFeedback(
          photoId: 'photo_4_1',
          photoUrl: 'assets/images/sample_light_on.png',
          latitude: 35.889,
          longitude: 128.610,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          status: FeedbackStatus.pending,
        ),
      ],
    ),
    DdipEvent(
      id: 'event_5',
      title: '중앙도서관 1층 카페 자리 있나요?',
      content: '노트북 할 수 있는 콘센트 있는 자리 있는지 궁금해요!',
      requesterId: 'responder_1', // 이수행
      reward: 1200,
      latitude: 35.891,
      longitude: 128.613,
      status: DdipEventStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      applicants: ['requester_1'],
      selectedResponderId: 'requester_1', // 김요청이 수행
      photos: [
        // 시나리오 5: 거래 성공적으로 완료됨
        PhotoFeedback(
          photoId: 'photo_5_1',
          photoUrl: 'assets/images/sample_cafe_seat.png',
          latitude: 35.891,
          longitude: 128.613,
          timestamp: DateTime.now().subtract(
            const Duration(days: 1, minutes: 10),
          ),
          status: FeedbackStatus.approved,
        ),
      ],
    ),
  ];

  @override
  Future<void> applyToEvent(String eventId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _ddipEvents.indexWhere((event) => event.id == eventId);

    if (index != -1) {
      final event = _ddipEvents[index];
      if (!event.applicants.contains(userId)) {
        final newApplicants = List<String>.from(event.applicants)..add(userId);
        final updatedEvent = event.copyWith(applicants: newApplicants);
        _ddipEvents[index] = updatedEvent;
      }
    } else {
      throw Exception('Event not found');
    }
  }

  @override
  Future<void> selectResponder(String eventId, String responderId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _ddipEvents.indexWhere((event) => event.id == eventId);

    if (index != -1) {
      final event = _ddipEvents[index];
      if (event.applicants.contains(responderId)) {
        final updatedEvent = event.copyWith(
          selectedResponderId: responderId,
          status: DdipEventStatus.in_progress,
        );
        _ddipEvents[index] = updatedEvent;
      } else {
        throw Exception('Responder not in applicants list');
      }
    } else {
      throw Exception('Event not found');
    }
  }

  @override
  Future<void> addPhoto(String eventId, PhotoFeedback photo) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _ddipEvents.indexWhere((event) => event.id == eventId);
    if (index != -1) {
      final event = _ddipEvents[index];
      final newPhotos = List<PhotoFeedback>.from(event.photos)..add(photo);
      final updatedEvent = event.copyWith(photos: newPhotos);
      _ddipEvents[index] = updatedEvent;
    } else {
      throw Exception('Event not found');
    }
  }

  @override
  Future<void> updatePhotoFeedback(
    String eventId,
    String photoId,
    FeedbackStatus feedback,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final eventIndex = _ddipEvents.indexWhere((event) => event.id == eventId);

    if (eventIndex != -1) {
      final event = _ddipEvents[eventIndex];
      final photoIndex = event.photos.indexWhere(
        (photo) => photo.photoId == photoId,
      );

      if (photoIndex != -1) {
        final updatedPhoto = event.photos[photoIndex].copyWith(
          status: feedback,
        );
        final newPhotos = List<PhotoFeedback>.from(event.photos);
        newPhotos[photoIndex] = updatedPhoto;

        DdipEventStatus newEventStatus = event.status;
        if (feedback == FeedbackStatus.approved) {
          newEventStatus = DdipEventStatus.completed;
        } else if (feedback ==
                FeedbackStatus
                    .rejected && // [오류 수정] Feedback -> FeedbackStatus 오타 수정
            newPhotos.length >= 3) {
          newEventStatus = DdipEventStatus.failed;
        }

        final updatedEvent = event.copyWith(
          photos: newPhotos,
          status: newEventStatus,
        );
        _ddipEvents[eventIndex] = updatedEvent;
      } else {
        throw Exception('Photo not found');
      }
    } else {
      throw Exception('Event not found');
    }
  }

  // ▼▼▼ [오류 수정] 다른 메서드 안에서가 아닌, 클래스 레벨로 위치 변경 ▼▼▼
  @override
  Future<void> createDdipEvent(DdipEvent event) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _ddipEvents.insert(0, event);
    print('Fake createDdipEvent success: ${event.title}');
  }

  @override
  Future<List<DdipEvent>> getDdipEvents() async {
    await Future.delayed(const Duration(seconds: 1));
    return _ddipEvents;
  }

  @override
  Future<DdipEvent> getDdipEventById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final event = _ddipEvents.firstWhere((event) => event.id == id);
      return event;
    } catch (e) {
      throw Exception('ID($id)에 해당하는 띱 이벤트를 찾을 수 없습니다.');
    }
  }
}
