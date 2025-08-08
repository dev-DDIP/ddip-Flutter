import 'package:ddip/features/auth/data/mock_user_data.dart';
import 'package:ddip/features/auth/domain/entities/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 2. 현재 로그인한 사용자를 관리하는 전역 프로바이더
final authProvider = StateProvider<User?>((ref) => null);

/// 테스트용 가상 유저 목록 전체를 앱의 다른 곳에서 사용할 수 있도록 제공하는 Provider입니다.
final mockUsersProvider = Provider<List<User>>((ref) => allMockUsers);
