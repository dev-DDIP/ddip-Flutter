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

  final int _maxSequenceLength = 50; // 파이썬 코드1.txt에 맞춰 80으로 수정

  Future<void> initialize() async {
    try {
      print('🔄 1/2: 토크나이저(JSON) 로드를 시작합니다...');
      final tokenizerJson = await rootBundle.loadString(
        'assets/ml/tokenizer_word_index.json',
      );
      final decodedMap = json.decode(tokenizerJson) as Map<String, dynamic>;
      _tokenizer = decodedMap.map((key, value) => MapEntry(key, value as int));
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

      print('--- TFLite 모델 입출력 명세서 ---');
      final inputTensors = _interpreter!.getInputTensors();
      for (var i = 0; i < inputTensors.length; i++) {
        print(
          'Input $i: shape=${inputTensors[i].shape}, type=${inputTensors[i].type}',
        );
      }
      final outputTensors = _interpreter!.getOutputTensors();
      for (var i = 0; i < outputTensors.length; i++) {
        print(
          'Output $i: shape=${outputTensors[i].shape}, type=${outputTensors[i].type}',
        );
      }
      print('---------------------------------');
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

    // --- 1. 데이터 전처리 (기존과 동일) ---
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

    print('================================================');
    print('🤖 AI 가격 예측 입력 데이터 종합 로그');
    print('--- 원본 데이터 ---');
    print('   - 제목+내용: $textPadded');
    print('   - 날씨 코드: $weather');
    print('   - 시간 (24시): $hour');
    print('   - 주말 여부 (1=주말): $isWeekend');
    print('================================================');

    // --- 2. 명확한 타입의 1차원 버퍼 생성 (기존과 동일) ---
    final textInput = Int32List.fromList(textPadded.toList());
    final hourSinInput = Float32List.fromList([hourSin]);
    final hourCosInput = Float32List.fromList([hourCos]);
    final weatherInput = Int32List.fromList([weather]);
    final weekendInput = Float32List.fromList([weekendEncoded]);
    final keywordInput = Float32List.fromList([lossKeyword, highKeyword]);

    // --- 3. [수정] TFLite 모델 명세서에 맞춰 입력 순서 재배열 ---
    final inputs = [
      hourCosInput.reshape([1, 1]), // Input 0: shape=[1, 1], type=float32
      weatherInput.reshape([1, 1]), // Input 1: shape=[1, 1], type=int32
      textInput.reshape([
        1,
        _maxSequenceLength,
      ]), // Input 2: shape=[1, 80], type=int32
      hourSinInput.reshape([1, 1]), // Input 3: shape=[1, 1], type=float32
      weekendInput.reshape([1, 1]), // Input 4: shape=[1, 1], type=float32
      keywordInput.reshape([1, 2]), // Input 5: shape=[1, 2], type=float32
    ];

    // --- 4. [수정] TFLite 모델 명세서에 맞춰 출력 순서 재배열 ---
    var priceOutput = <List<double>>[
      [0.0],
    ]; // Output 0: shape=[1, 1], type=float32
    var difficultyOutput = <List<double>>[
      [0.0, 0.0, 0.0],
    ]; // Output 1: shape=[1, 3], type=float32

    final outputs = {
      0: priceOutput, // 가격 예측 결과
      1: difficultyOutput, // 난이도 분류 결과
    };

    // --- 5. 모델 실행 ---
    try {
      _interpreter!.runForMultipleInputs(inputs, outputs);

      // --- 6. [수정] 올바른 버퍼에서 결과 추출 ---
      final predictedPrice = priceOutput[0][0];
      print('✅ 모델 예측 성공: Raw Price = $predictedPrice');

      final finalPrice = (predictedPrice / 100).round() * 100;
      return max(500, finalPrice).toInt();
    } catch (e) {
      print('❌ 모델 실행 중 심각한 오류 발생: $e');
      return 500;
    }
  }

  void dispose() {
    _interpreter?.close();
  }
}
