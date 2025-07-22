import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ddip/features/auth/domain/entities/user.dart';

// 1. 테스트용 가상 유저 목록 (우리의 가상 DB)
final List<User> mockUsers = [
  User(id: 'requester_1', name: '김요청 (요청자)'),
  User(id: 'responder_1', name: '이수행 (수행자)'),
  User(id: 'responder_2', name: '박지원 (수행자)'),
];

// 2. 현재 로그인한 사용자를 관리하는 전역 프로바이더
final authProvider = StateProvider<User?>((ref) => null);
