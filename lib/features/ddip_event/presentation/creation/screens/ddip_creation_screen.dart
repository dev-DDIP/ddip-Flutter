// lib/features/ddip_event/presentation/creation/screens/ddip_creation_screen.dart

import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/presentation/creation/widgets/location_picker_screen.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:ddip/features/weather/providers/weather_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

class DdipCreationScreen extends ConsumerStatefulWidget {
  const DdipCreationScreen({super.key});

  @override
  ConsumerState<DdipCreationScreen> createState() => _DdipCreationScreenState();
}

class _DdipCreationScreenState extends ConsumerState<DdipCreationScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _rewardController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  NLatLng? _selectedPosition;

  bool _isAnalyzing = false;

  // ▼▼▼ [수정] AI 모델 입력을 위한 변수들은 유지합니다. ▼▼▼
  int? _weatherCode;
  int? _hour;
  int? _isWeekendCode;

  // ▼▼▼ [수정] 날씨 정보를 숫자로 변환하기 위한 Map은 그대로 사용합니다. ▼▼▼
  static const _weatherConditionMap = {
    'Clear': 0,
    'Clouds': 0,
    'Rain': 1,
    'Drizzle': 1,
    'Snow': 2,
    'Thunderstorm': 5,
    'Tornado': 5,
    'Mist': 6,
    'Haze': 6,
    'Dust': 6,
    'Fog': 6,
    'Sand': 6,
    'Ash': 6,
    'Squall': 6,
  };

  // Python의 테스트 케이스를 Dart 형식으로 변환
  final List<Map<String, dynamic>> testCases = [
    {
      'title': '아이패드 프로 분실했습니다ㅠㅠ',
      'content': '중앙도서관 3층에서 아이패드 프로를 놓고 온 것 같아요. 정말 급해요 제발 도와주세요',
      'weather': 'Rain', // 영문으로 변경
      'hour': 2,
      'is_weekend': '평일',
    },
    {
      'title': '맥북 에어 어디 뒀는지 모르겠어요',
      'content': '공대 건물 어딘가에 맥북을 두고 온 것 같은데 기억이 안나요. 너무 비싼 거라 간절해요',
      'weather': 'Snow', // 영문으로 변경
      'hour': 23,
      'is_weekend': '주말',
    },
    {
      'title': '아이폰 찾습니다',
      'content': '공대 9호관 209호에 아이폰 놔두고 왔는데 제발 있나요..',
      'weather': 'Clear', // 영문으로 변경
      'hour': 9,
      'is_weekend': '평일',
    },
    {
      'title': '볼펜을 융복 3층 강의실에 떨어뜨린 것 같네요',
      'content': '345호 강의실에 검정색 볼펜 잃어 버렸는데 혹시 찾으신 분.. 그거 좀 비싸서요 ㅠㅠ',
      'weather': 'Clear',
      'hour': 15,
      'is_weekend': '평일',
    },
    {
      'title': '축제 사람 많을까요',
      'content': '지금 컴학 주막에 사람 바글바글함?',
      'weather': 'Clear',
      'hour': 20,
      'is_weekend': '평일',
    },
    {
      'title': '융복 지하에 세미나 시작함?',
      'content': '아 좀 늦을 것 같은데 지금 시작했음??',
      'weather': 'Clear',
      'hour': 13,
      'is_weekend': '평일',
    },
    {
      'title': '에어팟 프로 잃어버렸어요',
      'content': '체육관에서 운동하다가 에어팟 프로를 잃어버린 것 같아요. 너무 비싸서 꼭 찾아야 해요',
      'weather': 'Clouds', // 영문으로 변경
      'hour': 18,
      'is_weekend': '주말',
    },
    {
      'title': '학생증 분실',
      'content': '센파 벤치인가 학생증을 놓고 온 것 같은데 어디뒀는지 기억이 안나요',
      'weather': 'Clear',
      'hour': 11,
      'is_weekend': '평일',
    },
  ];

  // 테스트를 실행하고 결과를 출력하는 함수
  Future<void> _runAllTestCases() async {
    final priceService = await ref.read(pricePredictionServiceProvider.future);

    // 날씨 문자열을 코드로 변환하기 위한 맵 (기존 _analyzeRequestInfo 함수에서 복사)
    const weatherConditionMap = {
      'Clear': 0,
      'Clouds': 0,
      'Rain': 1,
      'Drizzle': 1,
      'Snow': 2,
      'Thunderstorm': 5,
      'Tornado': 5,
      'Mist': 6,
      'Haze': 6,
      'Dust': 6,
      'Fog': 6,
      'Sand': 6,
      'Ash': 6,
      'Squall': 6,
    };

    print("\n\n=============== 🤖 AI 모델 전체 테스트 시작 ===============\n");

    for (int i = 0; i < testCases.length; i++) {
      final t = testCases[i];
      final title = t['title'] as String;
      final content = t['content'] as String;
      final weatherStr = t['weather'] as String;
      final hour = t['hour'] as int;
      final isWeekendStr = t['is_weekend'] as String;

      // 모델에 입력할 데이터로 변환
      final weatherCode = weatherConditionMap[weatherStr] ?? 0;
      final isWeekendCode = (isWeekendStr == '주말') ? 1 : 0;

      // 모델 예측 실행
      final predictedPrice = await priceService.predict(
        title: title,
        content: content,
        weather: weatherCode,
        hour: hour,
        isWeekend: isWeekendCode,
      );

      print("[테스트 ${i + 1}] ${t['title']}");
      print("  - 입력값: 날씨=$weatherCode, 시간=$hour, 주말=$isWeekendCode");
      print("  → 예측 가격: $predictedPrice 원\n");
    }

    print("=============== ✅ AI 모델 전체 테스트 종료 ===============\n\n");
  }

  // ▼▼▼ [핵심 수정] _analyzeRequestInfo 함수 전체를 아래 내용으로 교체 ▼▼▼
  Future<void> _analyzeRequestInfo() async {
    // 0. 유효성 검사: 제목과 내용이 비어있으면 실행하지 않음
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('제목과 내용을 먼저 입력해주세요.')));
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      // 1. 위치 및 날씨, 시간 정보 수집 (기존과 동일)
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('위치 권한이 거부되었습니다.');
      }
      final position = await Geolocator.getCurrentPosition();
      final weatherData = await ref
          .read(weatherRepositoryProvider)
          .getCurrentWeather(position.latitude, position.longitude);

      int resultCode = _weatherConditionMap[weatherData.main] ?? 0;
      if (weatherData.temp < 0)
        resultCode = 3;
      else if (weatherData.temp > 30)
        resultCode = 4;

      final now = DateTime.now();
      _weatherCode = resultCode;
      _hour = now.hour;
      _isWeekendCode = (now.weekday >= 6) ? 1 : 0;

      // 2. Riverpod Provider를 통해 AI 서비스 인스턴스를 가져옴
      // .future를 사용하여 서비스 초기화가 완료될 때까지 기다림
      final priceService = await ref.read(
        pricePredictionServiceProvider.future,
      );

      // 3. AI 서비스의 predict 함수 호출
      final predictedPrice = await priceService.predict(
        title: _titleController.text,
        content: _contentController.text,
        weather: _weatherCode!,
        hour: _hour!,
        isWeekend: _isWeekendCode!,
      );

      // 4. 예측된 가격으로 '보상 금액' 필드 업데이트
      _rewardController.text = predictedPrice.toString();

      // 5. 사용자에게 성공 피드백 제공
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🤖 AI가 추천 가격 ${predictedPrice}원을 입력했습니다.'),
            backgroundColor: Colors.indigo,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('AI 가격 추천 중 오류 발생: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _rewardController.dispose();
    super.dispose();
  }

  void _submit() async {
    // submit 로직은 기존과 동일하므로 수정하지 않습니다.
    FocusScope.of(context).unfocus();

    final currentUser = ref.read(authProvider);
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인이 필요한 기능입니다.')));
      return;
    }

    if (_selectedPosition == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('지도에서 위치를 선택해주세요!')));
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final newEvent = DdipEvent(
        id: const Uuid().v4(),
        title: _titleController.text,
        content: _contentController.text,
        requesterId: currentUser.id,
        reward: int.parse(_rewardController.text),
        latitude: _selectedPosition!.latitude,
        longitude: _selectedPosition!.longitude,
        status: DdipEventStatus.open,
        createdAt: DateTime.now(),
      );

      try {
        await ref.read(createDdipEventUseCaseProvider).call(newEvent);
        if (!mounted) return;

        ref.invalidate(ddipEventsNotifierProvider);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('요청이 성공적으로 등록되었습니다!')));
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: $e')));
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // build 메서드 내 UI 구조는 기존과 거의 동일합니다.
    // _analyzedInfoText를 보여주던 부분만 삭제되었습니다.
    return Scaffold(
      appBar: AppBar(title: const Text('새로운 띱 요청')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: '제목'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return '제목을 입력해주세요.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(labelText: '내용'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return '내용을 입력해주세요.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _rewardController,
                  decoration: const InputDecoration(labelText: '보상 금액'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) return '보상 금액을 입력해주세요.';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  icon:
                      _isAnalyzing
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                          : const Icon(Icons.auto_awesome),
                  label: const Text('AI 가격 추천'),
                  onPressed: _isAnalyzing ? null : _analyzeRequestInfo,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                // ▼▼▼ 이 버튼을 여기에 추가하세요 ▼▼▼
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.science_outlined),
                  label: const Text('모델 전체 테스트 실행'),
                  onPressed: _runAllTestCases, // 1단계에서 만든 함수 연결
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                // ▲▲▲ 여기까지 추가 ▲▲▲.
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('지도에서 위치 선택'),
                  onPressed: () async {
                    final result = await Navigator.of(context).push<NLatLng?>(
                      MaterialPageRoute(
                        builder: (context) => const LocationPickerScreen(),
                      ),
                    );
                    if (result != null)
                      setState(() => _selectedPosition = result);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.grey),
                    elevation: 0,
                  ),
                ),
                if (_selectedPosition != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      '선택된 위치: 위도: ${_selectedPosition!.latitude.toStringAsFixed(5)}, 경도: ${_selectedPosition!.longitude.toStringAsFixed(5)}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                const SizedBox(height: 32),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('요청 등록하기'),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
