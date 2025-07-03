// lib/features/ddip_creation/data/repositories/ddip_creation_repository_impl.dart

import 'package:ddip/features/ddip_creation/data/datasources/ddip_creation_remote_data_source.dart';
import 'package:ddip/features/ddip_creation/data/models/ddip_event_model.dart';
import 'package:ddip/features/ddip_creation/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_creation/domain/repositories/ddip_creation_repository.dart';

class DdipCreationRepositoryImpl implements DdipCreationRepository {
  final DdipCreationRemoteDataSource remoteDataSource;

  DdipCreationRepositoryImpl({required this.remoteDataSource});

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
}

/*
domain 폴더는 '설계도'와 '계약서'만 두는 곳입니다.

domain/repositories/ddip_creation_repository.dart 파일은
 "나는 '띱'을 생성하는 기능이 필요해!"라고 선언하는 추상적인 계약서입니다.
 이 계약서는 실제 서버와 어떻게 통신하는지 전혀 몰라야 합니다.

data 폴더는 그 계약을 '실제로 이행'하는 곳입니다.

ddip_creation_repository_impl.dart 파일은 위 계약서의 내용을 실제로 구현하는 구현체입니다.
 이 파일은 Dio를 사용해서 서버와 통신하는 구체적인 방법을 알고 있죠.

따라서, 구현체(_impl.dart)는 data 폴더에 있는 것이 올바른 구조입니다.
 */
