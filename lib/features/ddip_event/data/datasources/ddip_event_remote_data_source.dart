// lib/features/ddip_event/data/datasources/ddip_event_remote_data_source.dart

import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/repositories/ddip_event_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import '../models/ddip_event_model.dart';

// 이 코드는 앞선 RepositoryImpl(중간 관리자)로부터 작업을 위임받아, 실제로 서버와 HTTP 통신을 수행합니다.
// 인터페이스(추상 클래스)를 먼저 정의하여, 어떤 기능을 제공할지 명시합니다.

/*
## 전체 흐름 정리
**리포지토리(RepositoryImpl)**가 '중간 관리자'로서 데이터를 DdipEventModel로 번역합니다.

번역한 데이터를 이 파일의 **DataSource(DdipCreationRemoteDataSourceImpl)**에게 넘깁니다.

DataSource는 '최종 실무자'로서, Dio라는 전문 장비를 사용해 데이터를 JSON으로 포장하여 서버로 발송합니다.


 */
abstract class DdipEventRemoteDataSource {
  Future<void> createDdipEvent(DdipEventModel eventModel);

  Future<List<DdipEventModel>> getDdipEvents({required NLatLngBounds bounds});

  Future<DdipEventModel> getDdipEventById(String id);

  Future<void> applyToEvent(String eventId, String userId);

  Future<void> selectResponder(String eventId, String responderId);

  Future<void> addPhoto(/* ... */); // 사진 파일 등을 전달할 파라미터 필요
  Future<void> updatePhotoFeedback(
    String eventId,
    String photoId,
    String feedback,
  );

  Stream<DdipEventModel> getNewDdipEventStream();

  Stream<DdipEvent> getEventStreamById(String id);

  Future<List<DdipEventModel>> getEventsByUserId(
    String userId,
    UserActivityType type,
  );

  Future<void> completeMission(String eventId);

  /// 서버에 미션 취소(강제 종료)를 요청합니다.
  Future<void> cancelMission(String eventId, String userId);
}

// 위 인터페이스의 실제 구현체입니다.
class DdipEventRemoteDataSourceImpl implements DdipEventRemoteDataSource {
  final Dio dio;

  // 생성자를 통해 Dio를 밖에서 넣어준다! 의존성주입(DI)
  /*
  실제 앱을 실행할 때: 밖에서 **'진짜 Dio'**를 만들어서 넣어줍니다.
  테스트를 할 때: 밖에서 **'가짜 Dio'**를 만들어서 넣어줍니다.
  DdipEventRemoteDataSourceImpl 클래스 코드는 단 한 줄도 바꿀 필요 없이,
  외부에서 어떤 부품을 넣어주느냐에 따라 동작을 바꿀 수 있습니다.
   */
  DdipEventRemoteDataSourceImpl({required this.dio});

  @override
  Future<void> createDdipEvent(DdipEventModel eventModel) async {
    try {
      // 실제 서버의 '띱 생성' API 엔드포인트로 POST 요청을 보냅니다.
      // eventModel.toJson()을 통해 DTO 객체를 JSON으로 변환하여 body에 담습니다.
      await dio.post<dynamic>(
        '/ddip', // 예시 API 경로입니다. 실제 백엔드 경로에 맞게 수정해야 합니다.
        data: eventModel.toJson(),
      );
    } on DioException catch (e) {
      // Dio 통신 중 에러가 발생하면 여기서 처리합니다.
      // 지금은 간단하게 출력만 하지만, 나중에는 구체적인 예외 처리를 추가합니다.
      print('Error creating ddip event: $e');
      rethrow; // 에러를 다시 던져서 상위 계층에서 인지할 수 있도록 합니다.
    }
  }

  @override
  Future<List<DdipEventModel>> getDdipEvents({
    required NLatLngBounds bounds,
  }) async {
    try {
      final response = await dio.get(
        '/ddips',
        queryParameters: {
          'sw_lat': bounds.southWest.latitude,
          'sw_lon': bounds.southWest.longitude,
          'ne_lat': bounds.northEast.latitude,
          'ne_lon': bounds.northEast.longitude,
        },
      );

      // 1. [해결] response.data가 List<dynamic> 타입이라고 명시적으로 알려줍니다.
      final List<dynamic> data = response.data as List<dynamic>;

      // 2. [해결] 리스트의 각 항목(item)이 Map<String, dynamic> 타입이라고 명시적으로 알려줍니다.
      return data
          .map((item) => DdipEventModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting ddip events: $e');
      rethrow;
    }
  }

  @override
  Future<DdipEventModel> getDdipEventById(String id) async {
    try {
      final response = await dio.get('/ddip-events/$id');
      return DdipEventModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  @override
  Future<void> applyToEvent(String eventId, String userId) async {
    // TODO: 백엔드 API 구현 시, POST /ddips/{eventId}/apply 와 같은 API 호출
    print('Calling API: Apply to event $eventId by user $userId');
    await Future.delayed(const Duration(milliseconds: 300)); // 임시 딜레이
  }

  @override
  Future<void> selectResponder(String eventId, String responderId) async {
    // TODO: 백엔드 API 구현 시, POST /ddips/{eventId}/select 와 같은 API 호출
    print('Calling API: Select responder $responderId for event $eventId');
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> addPhoto() async {
    // TODO: 백엔드 API 구현 (사진 업로드 등)
    print('Calling API: Add photo');
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> updatePhotoFeedback(
    String eventId,
    String photoId,
    String feedback,
  ) async {
    // TODO: 백엔드 API 구현
    print('Calling API: Update photo feedback');
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Stream<DdipEventModel> getNewDdipEventStream() {
    // TODO: 실제 WebSocket 클라이언트를 사용하여 서버로부터 새로 생성되는
    // DdipEventModel을 받아오는 로직을 여기에 구현해야 합니다.
    throw UnimplementedError(
      'New DdipEvent stream for real remote data source is not implemented yet.',
    );
  }

  // getEventStreamById 메소드를 구현합니다.
  @override
  Stream<DdipEvent> getEventStreamById(String id) {
    // TODO: 실제 WebSocket 클라이언트를 사용하여 서버에 연결하고,
    // 서버로부터 오는 메시지를 DdipEvent 객체로 변환하여 스트림으로 반환하는
    // 로직을 여기에 구현해야 합니다.
    // 지금은 아직 구현되지 않았으므로 UnimplementedError를 발생시킵니다.
    throw UnimplementedError(
      'WebSocket for real remote data source is not implemented yet.',
    );
  }

  // ▼▼▼ 클래스 하단에 누락된 메소드의 실제 구현을 추가합니다. ▼▼▼
  @override
  Future<List<DdipEventModel>> getEventsByUserId(
    String userId,
    UserActivityType type,
  ) async {
    try {
      // type enum을 API가 이해할 수 있는 문자열로 변환합니다.
      final typeString = type.name; // e.g., "requested", "responded"

      // TODO: 백엔드와 실제 API 엔드포인트 및 쿼리 파라미터 협의 필요
      // e.g., GET /users/{userId}/ddips?type=requested
      final response = await dio.get(
        '/users/$userId/ddips',
        queryParameters: {'type': typeString},
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((item) => DdipEventModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('Error getting events by user id: $e');
      rethrow;
    }
  }

  @override
  Future<void> completeMission(String eventId) async {
    try {
      // TODO: 실제 백엔드 API 엔드포인트(e.g., '/ddips/{eventId}/complete')로 POST 요청
      await dio.post<dynamic>('/ddips/$eventId/complete');
    } on DioException catch (e) {
      print('Error completing mission: $e');
      rethrow;
    }
  }

  @override
  Future<void> cancelMission(String eventId, String userId) async {
    try {
      // TODO: 실제 백엔드 API 엔드포인트(e.g., '/ddips/{eventId}/cancel')로 POST 요청
      // userId를 body에 담아 누가 취소했는지 서버에 알립니다.
      await dio.post<dynamic>(
        '/ddips/$eventId/cancel',
        data: {'userId': userId},
      );
    } on DioException catch (e) {
      print('Error canceling mission: $e');
      rethrow;
    }
  }
}
