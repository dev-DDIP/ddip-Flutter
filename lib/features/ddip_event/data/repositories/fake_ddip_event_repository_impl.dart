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
      requesterId: 'requester_1',
      reward: 1000,
      latitude: 35.8925,
      longitude: 128.60953,
      status: DdipEventStatus.open,
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      applicants: [],
      photos: [],
    ),
    DdipEvent(
      id: 'event_2',
      title: '센트럴파크에 자리 있나요?',
      content: '친구랑 치킨 먹으러는데 2명 앉을 벤치 있는지 봐주세요!',
      requesterId: 'requester_1',
      reward: 500,
      latitude: 35.890,
      longitude: 128.612,
      status: DdipEventStatus.pending_selection,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      applicants: ['responder_1', 'responder_2'],
      photos: [],
    ),
    DdipEvent(
      id: 'event_3',
      title: '공대 9호관 1층 프린터 대기줄 긴가요?',
      content: 'A4 10장 뽑아야 하는데, 지금 가면 얼마나 기다릴지 사진으로 알려주세요.',
      requesterId: 'requester_2',
      reward: 1500,
      latitude: 35.888,
      longitude: 128.611,
      status: DdipEventStatus.in_progress,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      applicants: ['responder_1'],
      selectedResponderId: 'responder_1',
      photos: [
        PhotoFeedback(
          photoId: 'photo_3_1',
          photoUrl: 'assets/images/sample_printer_rejected.png',
          latitude: 35.888,
          longitude: 128.611,
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          status: FeedbackStatus.rejected,
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
