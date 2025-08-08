// ▼▼▼ lib/features/auth/data/mock_user_data.dart ▼▼▼
import 'package:ddip/features/auth/domain/entities/user.dart';

// 앱 전체에서 사용할 단일 목업 유저 데이터 소스
final Map<String, User> mockUsersMap = {
  'requester_1': User(id: 'requester_1', name: '김요청'),
  'requester_2': User(id: 'requester_2', name: '센팍지박령'),
  'requester_3': User(id: 'requester_3', name: '신입'),
  'responder_1': User(id: 'responder_1', name: '이수행'),
  'responder_2': User(id: 'responder_2', name: '박지원'),
  'responder_3': User(id: 'responder_3', name: '북문지킴이'),
};

// Provider에서 쉽게 사용할 수 있도록 List 형태로도 제공
final List<User> allMockUsers = mockUsersMap.values.toList();
// ▲▲▲ lib/features/auth/data/mock_user_data.dart ▲▲▲
