// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'evaluation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Evaluation {
  String get missionId => throw _privateConstructorUsedError;
  String get evaluatorId => throw _privateConstructorUsedError; // 평가를 하는 사람
  String get evaluateeId => throw _privateConstructorUsedError; // 평가를 받는 사람
  int get rating => throw _privateConstructorUsedError; // 종합 별점 (1~5)
  List<PraiseTag> get tags =>
      throw _privateConstructorUsedError; // 선택된 칭찬 태그 목록
  String? get comment => throw _privateConstructorUsedError;

  /// Create a copy of Evaluation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EvaluationCopyWith<Evaluation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EvaluationCopyWith<$Res> {
  factory $EvaluationCopyWith(
    Evaluation value,
    $Res Function(Evaluation) then,
  ) = _$EvaluationCopyWithImpl<$Res, Evaluation>;
  @useResult
  $Res call({
    String missionId,
    String evaluatorId,
    String evaluateeId,
    int rating,
    List<PraiseTag> tags,
    String? comment,
  });
}

/// @nodoc
class _$EvaluationCopyWithImpl<$Res, $Val extends Evaluation>
    implements $EvaluationCopyWith<$Res> {
  _$EvaluationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Evaluation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? missionId = null,
    Object? evaluatorId = null,
    Object? evaluateeId = null,
    Object? rating = null,
    Object? tags = null,
    Object? comment = freezed,
  }) {
    return _then(
      _value.copyWith(
            missionId:
                null == missionId
                    ? _value.missionId
                    : missionId // ignore: cast_nullable_to_non_nullable
                        as String,
            evaluatorId:
                null == evaluatorId
                    ? _value.evaluatorId
                    : evaluatorId // ignore: cast_nullable_to_non_nullable
                        as String,
            evaluateeId:
                null == evaluateeId
                    ? _value.evaluateeId
                    : evaluateeId // ignore: cast_nullable_to_non_nullable
                        as String,
            rating:
                null == rating
                    ? _value.rating
                    : rating // ignore: cast_nullable_to_non_nullable
                        as int,
            tags:
                null == tags
                    ? _value.tags
                    : tags // ignore: cast_nullable_to_non_nullable
                        as List<PraiseTag>,
            comment:
                freezed == comment
                    ? _value.comment
                    : comment // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EvaluationImplCopyWith<$Res>
    implements $EvaluationCopyWith<$Res> {
  factory _$$EvaluationImplCopyWith(
    _$EvaluationImpl value,
    $Res Function(_$EvaluationImpl) then,
  ) = __$$EvaluationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String missionId,
    String evaluatorId,
    String evaluateeId,
    int rating,
    List<PraiseTag> tags,
    String? comment,
  });
}

/// @nodoc
class __$$EvaluationImplCopyWithImpl<$Res>
    extends _$EvaluationCopyWithImpl<$Res, _$EvaluationImpl>
    implements _$$EvaluationImplCopyWith<$Res> {
  __$$EvaluationImplCopyWithImpl(
    _$EvaluationImpl _value,
    $Res Function(_$EvaluationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Evaluation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? missionId = null,
    Object? evaluatorId = null,
    Object? evaluateeId = null,
    Object? rating = null,
    Object? tags = null,
    Object? comment = freezed,
  }) {
    return _then(
      _$EvaluationImpl(
        missionId:
            null == missionId
                ? _value.missionId
                : missionId // ignore: cast_nullable_to_non_nullable
                    as String,
        evaluatorId:
            null == evaluatorId
                ? _value.evaluatorId
                : evaluatorId // ignore: cast_nullable_to_non_nullable
                    as String,
        evaluateeId:
            null == evaluateeId
                ? _value.evaluateeId
                : evaluateeId // ignore: cast_nullable_to_non_nullable
                    as String,
        rating:
            null == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                    as int,
        tags:
            null == tags
                ? _value._tags
                : tags // ignore: cast_nullable_to_non_nullable
                    as List<PraiseTag>,
        comment:
            freezed == comment
                ? _value.comment
                : comment // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc

class _$EvaluationImpl implements _Evaluation {
  const _$EvaluationImpl({
    required this.missionId,
    required this.evaluatorId,
    required this.evaluateeId,
    required this.rating,
    required final List<PraiseTag> tags,
    this.comment,
  }) : _tags = tags;

  @override
  final String missionId;
  @override
  final String evaluatorId;
  // 평가를 하는 사람
  @override
  final String evaluateeId;
  // 평가를 받는 사람
  @override
  final int rating;
  // 종합 별점 (1~5)
  final List<PraiseTag> _tags;
  // 종합 별점 (1~5)
  @override
  List<PraiseTag> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  // 선택된 칭찬 태그 목록
  @override
  final String? comment;

  @override
  String toString() {
    return 'Evaluation(missionId: $missionId, evaluatorId: $evaluatorId, evaluateeId: $evaluateeId, rating: $rating, tags: $tags, comment: $comment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EvaluationImpl &&
            (identical(other.missionId, missionId) ||
                other.missionId == missionId) &&
            (identical(other.evaluatorId, evaluatorId) ||
                other.evaluatorId == evaluatorId) &&
            (identical(other.evaluateeId, evaluateeId) ||
                other.evaluateeId == evaluateeId) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.comment, comment) || other.comment == comment));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    missionId,
    evaluatorId,
    evaluateeId,
    rating,
    const DeepCollectionEquality().hash(_tags),
    comment,
  );

  /// Create a copy of Evaluation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EvaluationImplCopyWith<_$EvaluationImpl> get copyWith =>
      __$$EvaluationImplCopyWithImpl<_$EvaluationImpl>(this, _$identity);
}

abstract class _Evaluation implements Evaluation {
  const factory _Evaluation({
    required final String missionId,
    required final String evaluatorId,
    required final String evaluateeId,
    required final int rating,
    required final List<PraiseTag> tags,
    final String? comment,
  }) = _$EvaluationImpl;

  @override
  String get missionId;
  @override
  String get evaluatorId; // 평가를 하는 사람
  @override
  String get evaluateeId; // 평가를 받는 사람
  @override
  int get rating; // 종합 별점 (1~5)
  @override
  List<PraiseTag> get tags; // 선택된 칭찬 태그 목록
  @override
  String? get comment;

  /// Create a copy of Evaluation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EvaluationImplCopyWith<_$EvaluationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
