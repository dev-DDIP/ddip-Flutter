// lib/features/ddip_event/providers/ddip_event_providers.dart

import 'package:ddip/core/providers/core_providers.dart';
import 'package:ddip/features/ddip_event/data/datasources/ddip_event_remote_data_source.dart';
import 'package:ddip/features/ddip_event/data/repositories/ddip_event_repository_impl.dart';
import 'package:ddip/features/ddip_event/data/repositories/fake_ddip_event_repository_impl.dart';
import 'package:ddip/features/ddip_event/domain/repositories/ddip_event_repository.dart';
import 'package:ddip/features/ddip_event/domain/usecases/get_ddip_event_by_id.dart';
import 'package:ddip/features/ddip_event/domain/usecases/complete_ddip_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// [리팩토링] DdipEvent 기능 전반에서 사용될 DataSource Provider
final ddipEventDataSourceProvider = Provider<DdipEventRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return DdipEventRemoteDataSourceImpl(dio: dio);
});

// [리팩토링] DdipEvent 기능 전반에서 사용될 Repository Provider
final ddipEventRepositoryProvider = Provider<DdipEventRepository>((ref) {
  final remoteDataSource = ref.watch(ddipEventDataSourceProvider);
  return FakeDdipEventRepositoryImpl(); // 실제 백엔드 도입 전까지는 Fake Repository 사용
  // return DdipEventRepositoryImpl(remoteDataSource: remoteDataSource);
});

// [리팩토링] GetDdipEventById UseCase를 제공하는 Provider
final getDdipEventByIdUseCaseProvider = Provider<GetDdipEventById>((ref) {
  final repository = ref.watch(ddipEventRepositoryProvider);
  return GetDdipEventById(repository);
});

// [신규 추가] CompleteDdipEvent UseCase를 제공하는 Provider
final completeDdipEventUseCaseProvider = Provider<CompleteDdipEvent>((ref) {
  final repository = ref.watch(ddipEventRepositoryProvider);
  return CompleteDdipEvent(repository: repository);
});
