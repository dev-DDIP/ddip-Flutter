import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/presentation/creation/providers/ddip_creation_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _rewardController.dispose();
    super.dispose();
  }

  void _submit() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      final newEvent = DdipEvent(
        id: const Uuid().v4(),
        title: _titleController.text,
        content: _contentController.text,
        requesterId: 'temp_user_id',
        reward: int.parse(_rewardController.text),
        latitude: 35.890,
        longitude: 128.612,
        status: 'open',
        createdAt: DateTime.now(),
        responsePhotoUrl: null,
      );

      // Notifier의 메서드를 호출하고 그 결과를 기다립니다.
      final bool success = await ref
          .read(ddipCreationNotifierProvider.notifier)
          .createDdipEvent(newEvent);

      // 위젯이 마운트된 상태인지 확인 (비동기 작업 후 필수)
      if (!mounted) return;

      // 반환된 결과(success)에 따라 UI 로직을 처리합니다.
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('요청이 성공적으로 등록되었습니다!')),
        );
        Navigator.of(context).pop();
      } else {
        // 실패 시에는 Notifier의 state에서 에러를 가져와 보여줄 수 있습니다.
        final error = ref.read(ddipCreationNotifierProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ddipCreationNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('새로운 띱 요청'),
      ),
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
                const SizedBox(height: 32),
                state.isLoading
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
