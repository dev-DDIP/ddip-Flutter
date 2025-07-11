// lib/features/ddip_event/data/repositories/ddip_event_repository_impl.dart

import 'package:ddip/features/ddip_event/data/datasources/ddip_event_remote_data_source.dart';
import 'package:ddip/features/ddip_event/data/models/ddip_event_model.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
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
      responderId: event.responderId,
      reward: event.reward,
      latitude: event.latitude,
      longitude: event.longitude,
      status: event.status,
      createdAt: event.createdAt,
      responsePhotoUrl: event.responsePhotoUrl,
    );

    // 변환된 Model을 사용하여 DataSource에 API 호출을 위임합니다.
    await remoteDataSource.createDdipEvent(eventModel);
  }

  // [추가] getDdipEvents 구현
  @override
  Future<List<DdipEvent>> getDdipEvents() async {
    // 1. 데이터 소스(API)로부터 Model 리스트를 받아옵니다.
    final List<DdipEventModel> eventModels = await remoteDataSource.getDdipEvents();

    // 2. 받아온 Model 리스트를 Domain 계층의 Entity 리스트로 변환합니다.
    //    이 '번역' 과정이 클린 아키텍처의 핵심입니다.
    final List<DdipEvent> events = eventModels.map((model) => DdipEvent(
      id: model.id,
      title: model.title,
      content: model.content,
      requesterId: model.requesterId,
      reward: model.reward,
      latitude: model.latitude,
      longitude: model.longitude,
      status: model.status,
      createdAt: model.createdAt,
    )).toList();

    return events;
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
