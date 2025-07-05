// lib/features/ddip_event/presentation/craetion/providers/ddip_creation_providers.dart

import 'package:ddip/core/providers/core_providers.dart';
import 'package:ddip/features/ddip_event/data/datasources/ddip_event_remote_data_source.dart';
import 'package:ddip/features/ddip_event/data/repositories/ddip_event_repository_impl.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/repositories/ddip_event_repository.dart';
import 'package:ddip/features/ddip_event/domain/usecases/create_ddip_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. DataSource Provider
final ddipCreationDataSourceProvider =
Provider<DdipCreationRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return DdipCreationRemoteDataSourceImpl(dio: dio);
});

// 2. Repository Provider
final ddipCreationRepositoryProvider = Provider<DdipCreationRepository>((ref) {
  final remoteDataSource = ref.watch(ddipCreationDataSourceProvider);
  return DdipCreationRepositoryImpl(remoteDataSource: remoteDataSource);
});

// 3. UseCase Provider
final createDdipEventUseCaseProvider = Provider<CreateDdipEvent>((ref) {
  final repository = ref.watch(ddipCreationRepositoryProvider);
  return CreateDdipEvent(repository: repository);
});

// 4. State Notifier Provider
// UI가 직접 상호작용할 프로바이더입니다. '띱 생성' 행위의 상태(초기, 로딩, 에러, 성공)를 관리합니다.
final ddipCreationNotifierProvider =
AsyncNotifierProvider<DdipCreationNotifier, void>(() {
  return DdipCreationNotifier();
});

class DdipCreationNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // 초기화 시에는 아무 작업도 하지 않습니다.
    return;
  }

  // UI에서 호출할 메서드
  Future<void> createDdipEvent(DdipEvent event) async {
    // 1. 상태를 로딩 중으로 설정
    state = const AsyncValue.loading();

    // 2. UseCase를 실행하여 비즈니스 로직 수행
    final useCase = ref.read(createDdipEventUseCaseProvider);

    // 3. 실행 결과에 따라 상태 업데이트 (성공 또는 실패)
    state = await AsyncValue.guard(() async {
      await useCase(event);
    });
  }
}