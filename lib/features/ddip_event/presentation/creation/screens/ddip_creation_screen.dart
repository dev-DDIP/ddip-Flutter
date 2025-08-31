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
                // ▼▼▼ 기존에 분석 결과를 보여주던 UI는 삭제합니다. ▼▼▼
                // if (_analyzedInfoText.isNotEmpty) ...
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
