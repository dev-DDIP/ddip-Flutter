// ▼▼▼ lib/features/profile/data/repositories/mock_profile_data.dart ▼▼▼
// 각기 다른 특성을 가진 3명의 사용자에 대한 상세 목업 데이터

const Map<String, Map<String, dynamic>> mockUserProfileData = {
  'requester_1': {
    "userId": "requester_1",
    "nickname": "김요청",
    "profileImageUrl": "https://i.pravatar.cc/150?u=requester_1",
    "oneLineIntro": "궁금한 건 못 참는 편",
    "totalRequestCount": 25,
    "totalExecutionCount": 2,
    "ddipPoints": 5300,
    "certificationMark": null,
    "requesterReputation": {
      "photoApprovalRate": 96.0,
      "avgSelectionTimeMinutes": 15,
      "responderSatisfaction": 4.8,
    },
    "responderReputation": {
      "avgResponseTimeMinutes": 30,
      "photoApprovalRate": 100.0,
      "abandonmentRate": 0.0,
    },
    "badges": [
      {
        "name": "첫 요청 등록",
        "description": "첫 번째 '띱' 요청을 성공적으로 등록했습니다.",
        "imageUrl": "https://cdn-icons-png.flaticon.com/512/880/880534.png",
        "category": "activity",
      },
    ],
    "tags": [
      {"name": "#질문", "count": 18},
      {"name": "#확인", "count": 7},
    ],
    "activityHours": {"11": 10, "14": 8, "17": 5},
  },
  'requester_2': {
    "userId": "requester_2",
    "nickname": "센팍지박령",
    "profileImageUrl": "https://i.pravatar.cc/150?u=requester_2",
    "oneLineIntro": "센트럴파크 소식은 저에게 물어보세요.",
    "totalRequestCount": 12,
    "totalExecutionCount": 150,
    "ddipPoints": 25000,
    "certificationMark": {"title": "상위 1% 성실 수행자", "semester": "25-2학기"},
    "requesterReputation": {
      "photoApprovalRate": 98.5,
      "avgSelectionTimeMinutes": 5,
      "responderSatisfaction": 4.9,
    },
    "responderReputation": {
      "avgResponseTimeMinutes": 2,
      "photoApprovalRate": 99.1,
      "abandonmentRate": 0.5,
    },
    "badges": [
      {
        "name": "센팍 지배자",
        "description": "센트럴파크에서 50회 이상 미션 완료",
        "imageUrl": "https://cdn-icons-png.flaticon.com/512/1149/1149339.png",
        "category": "professionalism",
      },
      {
        "name": "띱 마스터",
        "description": "총 100회 이상 미션 완료",
        "imageUrl": "https://cdn-icons-png.flaticon.com/512/2921/2921201.png",
        "category": "activity",
      },
      {
        "name": "고양이 집사",
        "description": "'고양이' 키워드가 포함된 요청 10회 완료",
        "imageUrl": "https://cdn-icons-png.flaticon.com/512/1818/1818320.png",
        "category": "special",
      },
    ],
    "tags": [
      {"name": "#센트럴파크", "count": 78},
      {"name": "#자리확인", "count": 41},
      {"name": "#고양이", "count": 15},
    ],
    "activityHours": {"13": 50, "14": 45, "15": 30},
  },
  'requester_3': {
    "userId": "requester_3",
    "nickname": "신입",
    "profileImageUrl": "https://i.pravatar.cc/150?u=requester_3",
    "oneLineIntro": "아직 잘 모르지만 열심히 해볼게요!",
    "totalRequestCount": 1,
    "totalExecutionCount": 0,
    "ddipPoints": 1000,
    "certificationMark": null,
    "requesterReputation": {
      "photoApprovalRate": 0.0,
      "avgSelectionTimeMinutes": 0,
      "responderSatisfaction": 0.0,
    },
    "responderReputation": {
      "avgResponseTimeMinutes": 0,
      "photoApprovalRate": 0.0,
      "abandonmentRate": 0.0,
    },
    "badges": [],
    "tags": [],
    "activityHours": {},
  },
  'responder_1': {
    "userId": "responder_1",
    "nickname": "이수행",
    "profileImageUrl": "https://i.pravatar.cc/150?u=responder_1",
    "oneLineIntro": "세상 모든 궁금증을 해결해드립니다.",
    "totalRequestCount": 2,
    "totalExecutionCount": 35,
    "ddipPoints": 8200,
    "certificationMark": null,
    "requesterReputation": {
      "photoApprovalRate": 100.0,
      "avgSelectionTimeMinutes": 30,
      "responderSatisfaction": 5.0,
    },
    "responderReputation": {
      "avgResponseTimeMinutes": 5,
      "photoApprovalRate": 95.0,
      "abandonmentRate": 2.0,
    },
    "badges": [
      {
        "name": "성실의 아이콘",
        "description": "일주일 연속 미션 완료",
        "imageUrl": "https://cdn-icons-png.flaticon.com/512/4759/4759320.png",
        "category": "activity",
      },
    ],
    "tags": [
      {"name": "#도서관", "count": 15},
      {"name": "#메뉴확인", "count": 10},
    ],
    "activityHours": {"09": 20, "10": 10, "11": 5},
  },
  'responder_2': {
    "userId": "responder_2",
    "nickname": "박지원",
    "profileImageUrl": "https://i.pravatar.cc/150?u=responder_2",
    "oneLineIntro": "지나가다 뭐든 찍어드려요.",
    "totalRequestCount": 8,
    "totalExecutionCount": 72,
    "ddipPoints": 15000,
    "certificationMark": {"title": "상위 10% 활발 수행자", "semester": "25-2학기"},
    "requesterReputation": {
      "photoApprovalRate": 92.0,
      "avgSelectionTimeMinutes": 20,
      "responderSatisfaction": 4.7,
    },
    "responderReputation": {
      "avgResponseTimeMinutes": 4,
      "photoApprovalRate": 97.0,
      "abandonmentRate": 1.5,
    },
    "badges": [
      {
        "name": "베테랑 수행자",
        "description": "50회 이상 미션 완료",
        "imageUrl": "https://cdn-icons-png.flaticon.com/512/2921/2921201.png",
        "category": "activity",
      },
      {
        "name": "포토그래퍼",
        "description": "사진 승인율 95% 이상 달성",
        "imageUrl": "https://cdn-icons-png.flaticon.com/512/831/831124.png",
        "category": "professionalism",
      },
    ],
    "tags": [
      {"name": "#실시간인파", "count": 30},
      {"name": "#줄서기", "count": 22},
    ],
    "activityHours": {"12": 30, "18": 25, "19": 10},
  },
  'responder_3': {
    "userId": "responder_3",
    "nickname": "북문지킴이",
    "profileImageUrl": "https://i.pravatar.cc/150?u=responder_3",
    "oneLineIntro": "북문이 나의 나와바리",
    "totalRequestCount": 1,
    "totalExecutionCount": 12,
    "ddipPoints": 3100,
    "certificationMark": null,
    "requesterReputation": {
      "photoApprovalRate": 100.0,
      "avgSelectionTimeMinutes": 60,
      "responderSatisfaction": 5.0,
    },
    "responderReputation": {
      "avgResponseTimeMinutes": 10,
      "photoApprovalRate": 90.0,
      "abandonmentRate": 5.0,
    },
    "badges": [
      {
        "name": "북문 전문가",
        "description": "북문에서 10회 이상 미션 완료",
        "imageUrl": "https://cdn-icons-png.flaticon.com/512/1149/1149339.png",
        "category": "professionalism",
      },
    ],
    "tags": [
      {"name": "#북문", "count": 12},
    ],
    "activityHours": {"18": 5, "19": 4, "20": 3},
  },
};
// ▲▲▲ lib/features/profile/data/repositories/mock_profile_data.dart ▲▲▲
