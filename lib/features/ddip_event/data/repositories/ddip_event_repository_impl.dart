// lib/features/ddip_event/data/repositories/ddip_event_repository_impl.dart

import 'package:ddip/features/ddip_event/data/datasources/ddip_event_remote_data_source.dart';
import 'package:ddip/features/ddip_event/data/models/ddip_event_model.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo_feedback.dart';
import 'package:ddip/features/ddip_event/domain/repositories/ddip_event_repository.dart';

class DdipEventRepositoryImpl implements DdipEventRepository {
  final DdipEventRemoteDataSource remoteDataSource;

  DdipEventRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> createDdipEvent(DdipEvent event) async {
    // Domain 계층의 Entity를 Data 계층의 Model로 변환하는 과정이 필요합니다.
    // 이 변환을 통해 각 계층의 독립성을 보장합니다.
    /*
    이 '번역' 과정 덕분에, 앱의 핵심 로직은 서버의 데이터 구조를 전혀 몰라도 되고,
    서버 통신 파트는 앱의 내부 구조를 전혀 몰라도 됩니다.
    이 클래스가 중간에서 완벽하게 분리해주는 것입니다.
     */
    final eventModel = DdipEventModel(
      id: event.id,
      title: event.title,
      content: event.content,
      requesterId: event.requesterId,
      selectedResponderId: event.selectedResponderId,
      reward: event.reward,
      latitude: event.latitude,
      longitude: event.longitude,
      status: event.status.name,
      applicants: event.applicants,
      createdAt: event.createdAt,
      photos: [], // photos는 모델 변환이 필요하므로 별도 로직이 필요하지만, 생성 시에는 비어있으므로 OK
    );

    // 변환된 Model을 사용하여 DataSource에 API 호출을 위임합니다.
    await remoteDataSource.createDdipEvent(eventModel);
  }

  @override
  Future<List<DdipEvent>> getDdipEvents() async {
    final List<DdipEventModel> eventModels =
        await remoteDataSource.getDdipEvents();
    // 모델을 엔티티로 변환
    final List<DdipEvent> events =
        eventModels.map((model) => model.toEntity()).toList();
    return events;
  }

  @override
  Future<DdipEvent> getDdipEventById(String id) async {
    final eventModel = await remoteDataSource.getDdipEventById(id);
    return eventModel.toEntity();
  }

  @override
  Future<void> applyToEvent(String eventId, String userId) async {
    return remoteDataSource.applyToEvent(eventId, userId);
  }

  @override
  Future<void> selectResponder(String eventId, String responderId) async {
    return remoteDataSource.selectResponder(eventId, responderId);
  }

  @override
  Future<void> addPhoto(String eventId, PhotoFeedback photo) async {
    // TODO: PhotoFeedback 엔티티를 API에 맞는 모델로 변환하는 로직 필요
    return remoteDataSource.addPhoto();
  }

  @override
  Future<void> updatePhotoFeedback(
    String eventId,
    String photoId,
    FeedbackStatus feedback,
  ) async {
    // TODO: FeedbackStatus enum을 API에 맞는 String 값으로 변환하는 로직 필요
    return remoteDataSource.updatePhotoFeedback(
      eventId,
      photoId,
      feedback.toString(),
    );
  }
}

/*
domain 폴더는 '설계도'와 '계약서'만 두는 곳입니다.

domain/repositories/ddip_event_repository.dart 파일은
 "나는 '띱'을 생성하는 기능이 필요해!"라고 선언하는 추상적인 계약서입니다.
 이 계약서는 실제 서버와 어떻게 통신하는지 전혀 몰라야 합니다.

data 폴더는 그 계약을 '실제로 이행'하는 곳입니다.

ddip_event_repository_impl.dart 파일은 위 계약서의 내용을 실제로 구현하는 구현체입니다.
 이 파일은 Dio를 사용해서 서버와 통신하는 구체적인 방법을 알고 있죠.

따라서, 구현체(_impl.dart)는 data 폴더에 있는 것이 올바른 구조입니다.
 */
