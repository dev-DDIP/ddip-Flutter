import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:ddip/features/map_view/presentation/screens/map_view_screen.dart'; // 1. 방금 만든 지도 화면 import
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      // [수정] 로딩 시작
      setState(() => _isLoading = true);

      final newEvent = DdipEvent(
        // UUID는 전 세계적으로 거의 중복될 가능성이 없는 문자열 ID를 만드는 표준 방식
        id: const Uuid().v4(),
        title: _titleController.text,
        content: _contentController.text,
        requesterId: currentUser.id,
        reward: int.parse(_rewardController.text),
        latitude: _selectedPosition!.latitude,
        longitude: _selectedPosition!.longitude,
        status: DdipEventStatus.open,
        createdAt: DateTime.now(),
        applicants: [],
        photos: [],
      );

      try {
        // [수정] Notifier 대신 UseCase를 직접 호출
        await ref.read(createDdipEventUseCaseProvider).call(newEvent);

        if (!mounted) return;

        // [수정] 목록 새로고침을 위해 Notifier를 invalidate 함
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
        // [수정] 로딩 종료
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
                    if (value == null || value.isEmpty) {
                      return '제목을 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(labelText: '내용'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '내용을 입력해주세요.';
                    }
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
                    if (value == null || value.isEmpty) {
                      return '보상 금액을 입력해주세요.';
                    }
                    if (int.tryParse(value) == null) {
                      return '숫자만 입력해주세요.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16), // 3. 위젯들 사이에 간격 추가
                ElevatedButton.icon(
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('지도에서 위치 선택'),
                  onPressed: () async {
                    final result = await Navigator.of(context).push<NLatLng?>(
                      MaterialPageRoute(
                        builder: (context) => const MapViewScreen(),
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        _selectedPosition = result;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                    backgroundColor: Colors.white,
                    // 버튼 배경색
                    foregroundColor: Colors.black,
                    // 버튼 글자/아이콘 색
                    side: const BorderSide(color: Colors.grey),
                    // 테두리
                    elevation: 0, // 그림자 없애기
                  ),
                ),
                const SizedBox(height: 8),
                if (_selectedPosition != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      '선택된 위치:\n'
                      '위도: ${_selectedPosition!.latitude.toStringAsFixed(5)}, '
                      '경도: ${_selectedPosition!.longitude.toStringAsFixed(5)}',
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
                        textStyle: const TextStyle(fontSize: 16),
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
