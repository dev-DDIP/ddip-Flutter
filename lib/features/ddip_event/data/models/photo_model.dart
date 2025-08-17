// lib/features/ddip_event/data/models/photo_model.dart

import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'photo_model.freezed.dart';
part 'photo_model.g.dart';

@freezed
class PhotoModel with _$PhotoModel {
  const factory PhotoModel({
    @JsonKey(name: 'photoId') required String id,
    @JsonKey(name: 'photoUrl') required String url,
    required double latitude,
    required double longitude,
    required DateTime timestamp,
    required String status,
    String? responderComment,
    String? requesterQuestion,
    String? responderAnswer,
    String? rejectionReason,
  }) = _PhotoModel;

  const PhotoModel._();

  factory PhotoModel.fromJson(Map<String, dynamic> json) =>
      _$PhotoModelFromJson(json);

  Photo toEntity() {
    return Photo(
      id: id,
      url: url,
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp,
      status: PhotoStatus.values.firstWhere(
        (e) => e.name == status.toLowerCase(),
        orElse: () => PhotoStatus.pending,
      ),
      responderComment: responderComment,
      requesterQuestion: requesterQuestion,
      responderAnswer: responderAnswer,
      rejectionReason: rejectionReason,
    );
  }
}
