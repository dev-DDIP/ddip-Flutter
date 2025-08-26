// lib/features/profile/data/repositories/mock_profile_data.dart
import 'package:ddip/features/evaluation/domain/entities/evaluation.dart';

// 앱 실행 시 stateful repository의 '초기 상태'를 정의하는 데이터입니다.
final Map<String, Map<String, dynamic>> mockMvpProfileData = {
  // --- 1. 김요청 (요청 위주 사용자) ---
  'requester_1': {
    "userId": "requester_1",
    "nickname": "김요청",
    "profileImageUrl": "https://i.pravatar.cc/150?u=requester_1",
    "oneLineIntro": "궁금한 건 못 참는 편",
    "certifiedSchoolName": "경북대학교",
    "requesterAverageRating": 4.8,
    "responderAverageRating": 5.0,
    "totalRequestCount": 25,
    "totalExecutionCount": 2,
    "requesterPraiseTags": <String, int>{
      "clearRequest": 12,
      "fastFeedback": 9,
      "politeAndKind": 7,
      "reasonableRequest": 5,
    },
    "responderPraiseTags": <String, int>{
      "photoClarity": 2,
      "goodComprehension": 1,
      "kindAndPolite": 1,
    },
  },

  // --- 2. 센팍지박령 (헤비 수행자) ---
  'requester_2': {
    "userId": "requester_2",
    "nickname": "센팍지박령",
    "profileImageUrl": "https://i.pravatar.cc/150?u=requester_2",
    "oneLineIntro": "센트럴파크 소식은 저에게 물어보세요.",
    "certifiedSchoolName": "경북대학교",
    "requesterAverageRating": 4.9,
    "responderAverageRating": 4.9,
    "totalRequestCount": 12,
    "totalExecutionCount": 150,
    "requesterPraiseTags": <String, int>{
      "fastFeedback": 10,
      "politeAndKind": 8,
    },
    "responderPraiseTags": <String, int>{
      "photoClarity": 130,
      "goodComprehension": 120,
      "kindAndPolite": 110,
      "sensibleExtraInfo": 90,
    },
  },

  // --- 3. 신입 (활동 거의 없는 사용자) ---
  'requester_3': {
    "userId": "requester_3",
    "nickname": "신입",
    "profileImageUrl": "https://i.pravatar.cc/150?u=requester_3",
    "oneLineIntro": "아직 잘 모르지만 열심히 해볼게요!",
    "certifiedSchoolName": null, // 미인증
    "requesterAverageRating": null, // 평가 기록 없음
    "responderAverageRating": null, // 평가 기록 없음
    "totalRequestCount": 1,
    "totalExecutionCount": 0,
    "requesterPraiseTags": <String, int>{},
    "responderPraiseTags": <String, int>{},
  },

  // --- 4. 이수행 (성실한 수행자) ---
  'responder_1': {
    "userId": "responder_1",
    "nickname": "이수행",
    "profileImageUrl": "https://i.pravatar.cc/150?u=responder_1",
    "oneLineIntro": "세상 모든 궁금증을 해결해드립니다.",
    "certifiedSchoolName": "경북대학교",
    "requesterAverageRating": 5.0,
    "responderAverageRating": 4.7,
    "totalRequestCount": 2,
    "totalExecutionCount": 35,
    "requesterPraiseTags": <String, int>{"clearRequest": 1, "fastFeedback": 2},
    "responderPraiseTags": <String, int>{
      "photoClarity": 30,
      "goodComprehension": 25,
      "kindAndPolite": 28,
      "sensibleExtraInfo": 10,
    },
  },

  // --- 5. 박지원 (밸런스 있는 사용자) ---
  'responder_2': {
    "userId": "responder_2",
    "nickname": "박지원",
    "profileImageUrl": "https://i.pravatar.cc/150?u=responder_2",
    "oneLineIntro": "지나가다 뭐든 찍어드려요.",
    "certifiedSchoolName": "경북대학교",
    "requesterAverageRating": 4.7,
    "responderAverageRating": 4.8,
    "totalRequestCount": 8,
    "totalExecutionCount": 72,
    "requesterPraiseTags": <String, int>{"fastFeedback": 5, "politeAndKind": 3},
    "responderPraiseTags": <String, int>{
      "photoClarity": 68,
      "goodComprehension": 55,
      "kindAndPolite": 49,
      "sensibleExtraInfo": 30,
    },
  },

  // --- 6. 북문지킴이 (특정 지역 전문 사용자) ---
  'responder_3': {
    "userId": "responder_3",
    "nickname": "북문지킴이",
    "profileImageUrl": "https://i.pravatar.cc/150?u=responder_3",
    "oneLineIntro": "북문이 나의 나와바리",
    "certifiedSchoolName": "경북대학교",
    "requesterAverageRating": 5.0,
    "responderAverageRating": 4.6,
    "totalRequestCount": 1,
    "totalExecutionCount": 12,
    "requesterPraiseTags": <String, int>{"fastFeedback": 1},
    "responderPraiseTags": <String, int>{
      "photoClarity": 10,
      "goodComprehension": 12,
      "kindAndPolite": 9,
    },
  },
};
