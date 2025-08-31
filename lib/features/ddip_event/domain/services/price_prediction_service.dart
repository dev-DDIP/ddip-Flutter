// lib/features/ddip_event/domain/services/price_prediction_service.dart

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class PricePredictionService {
  Interpreter? _interpreter;
  Map<String, int> _tokenizer = {};

  final Map<String, List<String>> _keywordRules = {
    '상': [
      '애플펜슬',
      '아이패드',
      '노트북',
      '폰',
      '지갑',
      '카드',
      '갤럭시탭',
      '에어팟',
      '워치',
      '카메라',
      '맥북',
      '갤럭시버즈',
      '아이폰',
      '태블릿',
      '갤럭시북',
      '블루투스 이어폰',
      '아이팟',
      '고프로',
      '아이디카드',
      '학생증 카드',
    ],
    '중': [
      '충전기',
      '우산',
      '텀블러',
      '전공 책',
      '필통',
      '모자',
      '보조배터리',
      '마우스',
      '학생증',
      '목도리',
      '에코백',
      '안경',
      '안경집',
      'USB',
      '책',
      '노트',
      '이어폰',
      '헤어밴드',
      '장갑',
      '볼펜',
      '연필 케이스',
      '명찰',
    ],
    'loss_keywords': [
      '두고',
      '놓고',
      '잃어',
      '분실',
      '찾아',
      '남겨',
      '흘렸',
      '떨어뜨렸',
      '어딘가에 놔두고',
      '분실한 것 같',
      '기억이 안 나',
      '안 가져왔',
      '어디 뒀는지 모르겠',
      '두고 온 것 같',
      '안 챙겼',
      '깜빡하고 놓고',
    ],
  };

  final int _maxSequenceLength = 80; // 파이썬 코드2.txt에 맞춰 80으로 수정

  Future<void> initialize() async {
    try {
      print('🔄 1/2: 토크나이저(JSON) 로드를 시작합니다...');
      final tokenizerJson = await rootBundle.loadString(
        'assets/ml/tokenizer_word_index.json',
      );
      _tokenizer = Map<String, int>.from(json.decode(tokenizerJson) as Map);
      print('✅ 1/2: 토크나이저 로드 성공.');
    } catch (e) {
      print('❌ 1/2: 토크나이저(JSON) 로드 실패! pubspec.yaml 경로 또는 실제 파일 위치를 확인해주세요.');
      print('   - 에러 상세: $e');
      rethrow;
    }
    try {
      print('🔄 2/2: AI 모델(TFLite) 로드를 시작합니다...');
      _interpreter = await Interpreter.fromAsset(
        'assets/ml/price_prediction_model.tflite',
      );
      print('✅ 2/2: AI 모델 로드 성공.');
    } catch (e) {
      print(
        '❌ 2/2: AI 모델(TFLite) 로드 실패! 파일이 손상되었거나 tflite_flutter 패키지와의 호환성 문제일 수 있습니다.',
      );
      print('   - 에러 상세: $e');
      rethrow;
    }
    print('🎉 PricePredictionService 초기화 완벽 성공!');
  }

  Int32List _preprocessAndTokenize(String title, String content) {
    String text = "$title $content".trim().toLowerCase();
    text = text.replaceAll(RegExp(r'[ㅠㅜㅋㅎ]+'), '');
    text = text.replaceAll(RegExp(r'[!?]{2,}'), '');
    text = text.replaceAll(RegExp(r'\s+'), ' ');
    List<int> sequence =
        text.split(' ').map((word) {
          return _tokenizer[word] ?? 1;
        }).toList();
    List<int> paddedSequence = List<int>.filled(_maxSequenceLength, 0);
    int length = min(sequence.length, _maxSequenceLength);
    for (int i = 0; i < length; i++) {
      paddedSequence[i] = sequence[i];
    }
    return Int32List.fromList(paddedSequence);
  }

  // ▼▼▼ [핵심 수정] predict 함수 내부에 print문 추가 ▼▼▼
  Future<int> predict({
    required String title,
    required String content,
    required int weather,
    required int hour,
    required int isWeekend,
  }) async {
    if (_interpreter == null || _tokenizer.isEmpty) {
      print('❌ 모델이 초기화되지 않았습니다.');
      return 500;
    }

    // --- 1. 데이터 전처리 ---
    final textPadded = _preprocessAndTokenize(title, content);
    final hourSin = sin(2 * pi * hour / 24);
    final hourCos = cos(2 * pi * hour / 24);
    final weekendEncoded = isWeekend.toDouble();
    final combinedText = "$title $content".toLowerCase();
    final lossKeyword =
        _keywordRules['loss_keywords']!.any((k) => combinedText.contains(k))
            ? 1.0
            : 0.0;
    final highKeyword =
        _keywordRules['상']!.any((k) => combinedText.contains(k)) ? 1.0 : 0.0;

    // --- 2. [DEBUG] 텐서 변환 전 Raw 데이터 출력 ---
    print(' ');
    print('=============== [DEBUG] AI 모델 입력값 분석 ===============');
    print('--- 텐서 변환 전 Raw 데이터 ---');
    print('  - Text (Padded Sequence): ${textPadded.toString()}');
    print('  - Weather: $weather');
    print('  - Hour (Sin): $hourSin');
    print('  - Hour (Cos): $hourCos');
    print('  - Is Weekend: $weekendEncoded');
    print(
      '  - Keyword Features (Loss, High-Value): [$lossKeyword, $highKeyword]',
    );
    print('------------------------------------');

    // --- 3. 모델 입력을 위한 텐서 준비 ---
    final inputs = [
      [textPadded],
      [
        Float32List.fromList([hourSin]),
      ],
      [
        Float32List.fromList([hourCos]),
      ],
      [
        [weather],
      ],
      [
        Float32List.fromList([weekendEncoded]),
      ],
      [
        Float32List.fromList([lossKeyword, highKeyword]),
      ],
    ];

    // --- 4. [DEBUG] 모델에 전달되는 최종 텐서 형태 출력 ---
    print('--- 모델에 전달되는 최종 텐서 형태 ---');
    print('  - Input 0 (Text): ${inputs[0]}');
    print('  - Input 1 (Hour Sin): ${inputs[1]}');
    print('  - Input 2 (Hour Cos): ${inputs[2]}');
    print('  - Input 3 (Weather): ${inputs[3]}');
    print('  - Input 4 (Is Weekend): ${inputs[4]}');
    print('  - Input 5 (Keywords): ${inputs[5]}');
    print('=========================================================');
    print(' ');

    // --- 5. 모델 출력 텐서 및 실행 ---
    final outputs = {
      0: List.filled(1 * 3, 0.0).reshape([1, 3]),
      1: List.filled(1 * 1, 0.0).reshape([1, 1]),
    };
    _interpreter!.runForMultipleInputs(inputs, outputs);

    // --- 6. 결과 후처리 ---
    final predictedPrice = (outputs[1] as List<List<double>>)[0][0];
    final finalPrice = (predictedPrice / 100).round() * 100;
    return max(0, finalPrice);
  }

  void dispose() {
    _interpreter?.close();
  }
}
