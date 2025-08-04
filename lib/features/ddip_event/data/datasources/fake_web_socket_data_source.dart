// lib/features/ddip_event/data/datasources/fake_web_socket_data_source.dart

import 'dart:async';
import 'dart:math';

import 'package:ddip/features/ddip_event/data/datasources/web_socket_data_source.dart';
import 'package:ddip/features/ddip_event/data/models/ddip_event_model.dart';
import 'package:ddip/features/ddip_event/data/models/interaction_model.dart';
import 'package:uuid/uuid.dart';

// ----- ▼▼▼ [신규] 가짜 실시간 데이터를 생성하는 FakeWebSocketDataSource 구현 ▼▼▼ -----
/// 실제 백엔드 서버 없이 실시간 데이터 스트림을 시뮬레이션하는 가짜 데이터 소스입니다.
class FakeWebSocketDataSource implements WebSocketDataSource {
  // StreamController: 데이터가 흐르는 '파이프'라고 생각하시면 됩니다.
  // .broadcast(): 여러 구독자가 이 파이프를 함께 지켜볼 수 있도록 합니다.
  final _controller = StreamController<InteractionModel>.broadcast();
  Timer? _timer; // 주기적으로 데이터를 생성할 타이머

  final _newEventController = StreamController<DdipEventModel>.broadcast();
  Timer? _newEventTimer;

  @override
  Stream<InteractionModel> getInteractionStream(String eventId) {
    // 5초에 한 번씩 새로운 가짜 Interaction을 생성하여 파이프에 흘려보냅니다.
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      final fakeInteraction = _createFakeInteraction();
      _controller.add(fakeInteraction);
    });
    return _controller.stream;
  }

  @override
  Stream<DdipEventModel> getNewDdipEventStream() {
    // 5초마다 새로운 가짜 DdipEvent를 생성하여 파이프에 흘려보냅니다.
    _newEventTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final newEvent = _createFakeDdipEvent();
      _newEventController.add(newEvent);
    });
    return _newEventController.stream;
  }

  @override
  void close() {
    _timer?.cancel(); // 타이머를 중지하고
    _controller.close(); // 파이프를 닫아 리소스를 정리합니다.

    _newEventTimer?.cancel();
    _newEventController.close();
  }

  /// 테스트를 위한 가짜 InteractionModel 객체를 생성하는 헬퍼 메서드입니다.
  InteractionModel _createFakeInteraction() {
    final actors = ['responder_2', 'responder_3'];
    final actorId = actors[Random().nextInt(actors.length)];

    return InteractionModel(
      id: const Uuid().v4(),
      actorId: actorId,
      actorRole: 'RESPONDER',
      actionType: 'APPLY',
      timestamp: DateTime.now(),
    );
  }

  DdipEventModel _createFakeDdipEvent() {
    final random = Random();
    return DdipEventModel(
      id: const Uuid().v4(),
      title: '새로운 가짜 요청 ${random.nextInt(100)}',
      content: '이 요청은 5초마다 자동으로 생성되었습니다.',
      requesterId: 'requester_2',
      reward: (random.nextInt(10) + 1) * 1000,
      latitude: 35.890 + (random.nextDouble() - 0.5) * 0.005,
      // 경북대 주변
      longitude: 128.612 + (random.nextDouble() - 0.5) * 0.005,
      createdAt: DateTime.now(),
      status: 'OPEN',
    );
  }
}

// ----- ▲▲▲ [신규] 가짜 실시간 데이터를 생성하는 FakeWebSocketDataSource 구현 ▲▲▲ -----
