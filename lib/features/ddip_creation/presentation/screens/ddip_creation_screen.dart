import 'package:ddip/features/ddip_creation/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_creation/presentation/providers/ddip_creation_providers.dart';
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

  void _submit() {
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

      ref.read(ddipCreationNotifierProvider.notifier).createDdipEvent(newEvent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ddipCreationNotifierProvider);

    ref.listen<AsyncValue<void>>(
      ddipCreationNotifierProvider,
          (previous, next) {
        if (next.hasError && !next.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('오류가 발생했습니다: ${next.error}')),
          );
        }
        if (previous is AsyncLoading && !next.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('요청이 성공적으로 등록되었습니다!')),
          );
          _formKey.currentState?.reset();
          _titleController.clear();
          _contentController.clear();
          _rewardController.clear();
        }
      },
    );

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
