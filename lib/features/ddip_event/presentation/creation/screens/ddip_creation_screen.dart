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
import 'package:intl/intl.dart';
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
  int? _weatherCode;
  int? _hour;
  int? _isWeekendCode;
  String _analyzedInfoText = '';

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

  Future<void> _analyzeRequestInfo() async {
    setState(() {
      _isAnalyzing = true;
      _analyzedInfoText = 'AI 분석 중...';
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('위치 권한이 거부되었습니다.');
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final weatherData = await ref
          .read(weatherRepositoryProvider)
          .getCurrentWeather(position.latitude, position.longitude);
      final weatherMain = weatherData.main;
      final temp = weatherData.temp;
      final locationName = weatherData.locationName;

      int resultCode = _weatherConditionMap[weatherMain] ?? 0;
      if (temp < 0)
        resultCode = 3;
      else if (temp > 30)
        resultCode = 4;

      final now = DateTime.now();
      final currentHour = now.hour;
      final weekendCode = (now.weekday >= 6) ? 1 : 0;

      const dayOfWeekMap = {
        1: '월',
        2: '화',
        3: '수',
        4: '목',
        5: '금',
        6: '토',
        7: '일',
      };
      final dayOfWeekString = dayOfWeekMap[now.weekday] ?? '';
      final timeString = DateFormat('HH:mm:ss').format(now);

      // ▼▼▼ 수정된 부분 (핵심 로직) ▼▼▼
      // 제목과 내용을 가져와서 이스케이프 처리
      final title = _titleController.text.replaceAll('\n', '\\n');
      final content = _contentController.text.replaceAll('\n', '\\n');

      setState(() {
        _weatherCode = resultCode;
        _hour = currentHour;
        _isWeekendCode = weekendCode;

        // 화면에 표시될 텍스트를 JSON 형식으로 구성 (제목과 내용 포함)
        _analyzedInfoText = '''
{
  "title": "$title",
  "content": "$content",
  "weather": $_weatherCode ($weatherMain, ${temp.toStringAsFixed(1)}°C, $locationName),
  "time": $_hour ($timeString),
  "is_weekend": $_isWeekendCode ($dayOfWeekString요일)
}''';
      });
      // ▲▲▲ 수정된 부분 (핵심 로직) ▲▲▲
    } catch (e) {
      setState(() {
        _analyzedInfoText = '분석 실패: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
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

      if (_weatherCode == null) _weatherCode = 0;
      if (_hour == null || _isWeekendCode == null) {
        final now = DateTime.now();
        _hour = now.hour;
        _isWeekendCode = (now.weekday >= 6) ? 1 : 0;
      }

      final requestPayload = {
        'title': _titleController.text,
        'content': _contentController.text,
        'weather': _weatherCode,
        'time': _hour,
        'is_weekend': _isWeekendCode,
      };

      print('--- 최종 전송 데이터 ---');
      print(requestPayload);

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
                if (_analyzedInfoText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _analyzedInfoText,
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          height: 1.6,
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

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
