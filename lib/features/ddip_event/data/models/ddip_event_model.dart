// lib/features/ddip_event/data/models/ddip_event_model.dart

/*
## DdipEventModel (Data 영역의 모델)
목적: 오직 외부(서버)와의 데이터 통신을 위한 클래스입니다.

특징: 서버 API의 JSON 구조와 1:1로 정확하게 일치해야 합니다.
서버 개발자가 API 필드명을 'requester_id'에서 'author_id'로 바꾸면,
우리도 이 파일을 수정해야 합니다. 즉, 외부의 변화에 매우 취약합니다.
 */
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/ddip_event.dart';

part 'ddip_event_model.freezed.dart';
part 'ddip_event_model.g.dart';

@freezed
class DdipEventModel with _$DdipEventModel {
  // 첫번째 생성자, 앱 내부에서, 이미 있는 변수들을 가지고 객체를 만들 때 사용합니다
  const factory DdipEventModel({
    required String id,
    required String title,
    required String content,
    // @JsonKey를 이렇게 각 필드에 직접 적용해야 합니다.
    @JsonKey(name: 'requester_id') required String requesterId,
    @JsonKey(name: 'responder_id') String? responderId,
    required int reward,
    required double latitude,
    required double longitude,
    required String status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'response_photo_url') String? responsePhotoUrl,
  }) = _DdipEventModel;

  const DdipEventModel._();

  // 두번째 생성자, 앱 외부(주로 서버)로부터 받은 JSON 데이터를 가지고 객체를 만들 때 사용합니다.
  factory DdipEventModel.fromJson(Map<String, dynamic> json) =>
      _$DdipEventModelFromJson(json);

  // Model의 필드를 Entity의 필드로 1:1 매핑하는 정확한 변환 로직입니다.
  DdipEvent toEntity() {
    return DdipEvent(
      id: id,
      title: title,
      content: content,
      requesterId: requesterId,
      responderId: responderId,
      reward: reward,
      latitude: latitude,
      longitude: longitude,
      status: status,
      createdAt: createdAt,
      responsePhotoUrl: responsePhotoUrl,
    );
  }
}
