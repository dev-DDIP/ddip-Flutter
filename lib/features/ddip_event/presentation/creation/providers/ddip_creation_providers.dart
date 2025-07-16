// lib/features/ddip_event/presentation/craetion/providers/ddip_creation_providers.dart

import 'package:ddip/core/providers/core_providers.dart';
import 'package:ddip/features/ddip_event/data/datasources/ddip_event_remote_data_source.dart';
import 'package:ddip/features/ddip_event/data/repositories/ddip_event_repository_impl.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/repositories/ddip_event_repository.dart';
import 'package:ddip/features/ddip_event/domain/usecases/create_ddip_event.dart';
import 'package:ddip/features/ddip_event/presentation/feed/providers/ddip_feed_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 백엔드 도입 전까지 fake 사용한다.
import 'package:ddip/features/ddip_event/data/repositories/fake_ddip_event_repository_impl.dart';
// 1. DataSource Provider: DdipEventRemoteDataSource를 제공합니다.
final ddipEventDataSourceProvider =
Provider<DdipEventRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return DdipEventRemoteDataSourceImpl(dio: dio);
});

// 2. Repository Provider: 위에서 만든 DataSource를 주입받아 DdipEventRepository를 제공합니다.
final ddipEventRepositoryProvider = Provider<DdipEventRepository>((ref) {
  // DdipEventDataSourceProvider를 watch 하도록 수정
  final remoteDataSource = ref.watch(ddipEventDataSourceProvider);
  return FakeDdipEventRepositoryImpl(); // 실제 백엔드 도입 전까지는 Fake Repository를 사용할 수도 있음
  // return DdipEventRepositoryImpl(remoteDataSource: remoteDataSource);
});

// 3. UseCase Provider: 위에서 만든 Repository를 주입받아 CreateDdipEvent를 제공합니다.
final createDdipEventUseCaseProvider = Provider<CreateDdipEvent>((ref) {
  // DdipEventRepositoryProvider를 watch 하도록 수정
  final repository = ref.watch(ddipEventRepositoryProvider);
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
  Future<bool> createDdipEvent(DdipEvent event) async {
    // 1. 상태를 로딩 중으로 설정
    state = const AsyncValue.loading();

    // 2. UseCase를 실행하여 비즈니스 로직 수행
    final useCase = ref.read(createDdipEventUseCaseProvider);

    // 3. 실행 결과에 따라 상태 업데이트 (성공 또는 실패)
    state = await AsyncValue.guard(() async {
      await useCase(event);
    });

    // [추가] state에 에러가 있는지 확인하여 성공/실패 결과를 반환
    if (state.hasError) {
      return false; // 실패
    } else {
      // 성공 시, 피드 프로바이더를 무효화하여 새로고침하도록 함
      ref.invalidate(ddipFeedProvider);
      return true; // 성공
    }
  }
}
