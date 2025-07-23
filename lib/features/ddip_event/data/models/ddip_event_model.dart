// lib/features/ddip_event/data/models/ddip_event_model.dart

import 'package:ddip/features/ddip_event/data/models/interaction_model.dart';
import 'package:ddip/features/ddip_event/data/models/photo_model.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ddip_event_model.freezed.dart';
part 'ddip_event_model.g.dart';

@freezed
class DdipEventModel with _$DdipEventModel {
  const factory DdipEventModel({
    required String id,
    required String title,
    required String content,
    @JsonKey(name: 'requesterId') required String requesterId,
    required int reward,
    required double latitude,
    required double longitude,
    @JsonKey(name: 'createdAt') required DateTime createdAt,
    required String status,
    @JsonKey(name: 'selectedResponderId') String? selectedResponderId,
    @Default([]) List<String> applicants,
    @Default([]) List<PhotoModel> photos,
    @Default([]) List<InteractionModel> interactions,
  }) = _DdipEventModel;

  const DdipEventModel._();

  factory DdipEventModel.fromJson(Map<String, dynamic> json) =>
      _$DdipEventModelFromJson(json);

  DdipEvent toEntity() {
    return DdipEvent(
      id: id,
      title: title,
      content: content,
      requesterId: requesterId,
      reward: reward,
      latitude: latitude,
      longitude: longitude,
      createdAt: createdAt,
      status: DdipEventStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => DdipEventStatus.open,
      ),
      applicants: applicants,
      selectedResponderId: selectedResponderId,
      photos: photos.map((photoModel) => photoModel.toEntity()).toList(),
      interactions:
          interactions
              .map((interactionModel) => interactionModel.toEntity())
              .toList(),
    );
  }
}
