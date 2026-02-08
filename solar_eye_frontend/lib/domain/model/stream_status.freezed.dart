// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stream_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StreamStatus _$StreamStatusFromJson(Map<String, dynamic> json) {
  return _StreamStatus.fromJson(json);
}

/// @nodoc
mixin _$StreamStatus {
  String get panelId => throw _privateConstructorUsedError;
  String get panelName => throw _privateConstructorUsedError;
  StreamState get state => throw _privateConstructorUsedError;
  String? get rtspUrl => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  DateTime? get lastFrameAt => throw _privateConstructorUsedError;

  /// Serializes this StreamStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StreamStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StreamStatusCopyWith<StreamStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StreamStatusCopyWith<$Res> {
  factory $StreamStatusCopyWith(
          StreamStatus value, $Res Function(StreamStatus) then) =
      _$StreamStatusCopyWithImpl<$Res, StreamStatus>;
  @useResult
  $Res call(
      {String panelId,
      String panelName,
      StreamState state,
      String? rtspUrl,
      String? errorMessage,
      DateTime? lastFrameAt});
}

/// @nodoc
class _$StreamStatusCopyWithImpl<$Res, $Val extends StreamStatus>
    implements $StreamStatusCopyWith<$Res> {
  _$StreamStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StreamStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? panelId = null,
    Object? panelName = null,
    Object? state = null,
    Object? rtspUrl = freezed,
    Object? errorMessage = freezed,
    Object? lastFrameAt = freezed,
  }) {
    return _then(_value.copyWith(
      panelId: null == panelId
          ? _value.panelId
          : panelId // ignore: cast_nullable_to_non_nullable
              as String,
      panelName: null == panelName
          ? _value.panelName
          : panelName // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as StreamState,
      rtspUrl: freezed == rtspUrl
          ? _value.rtspUrl
          : rtspUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      lastFrameAt: freezed == lastFrameAt
          ? _value.lastFrameAt
          : lastFrameAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StreamStatusImplCopyWith<$Res>
    implements $StreamStatusCopyWith<$Res> {
  factory _$$StreamStatusImplCopyWith(
          _$StreamStatusImpl value, $Res Function(_$StreamStatusImpl) then) =
      __$$StreamStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String panelId,
      String panelName,
      StreamState state,
      String? rtspUrl,
      String? errorMessage,
      DateTime? lastFrameAt});
}

/// @nodoc
class __$$StreamStatusImplCopyWithImpl<$Res>
    extends _$StreamStatusCopyWithImpl<$Res, _$StreamStatusImpl>
    implements _$$StreamStatusImplCopyWith<$Res> {
  __$$StreamStatusImplCopyWithImpl(
      _$StreamStatusImpl _value, $Res Function(_$StreamStatusImpl) _then)
      : super(_value, _then);

  /// Create a copy of StreamStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? panelId = null,
    Object? panelName = null,
    Object? state = null,
    Object? rtspUrl = freezed,
    Object? errorMessage = freezed,
    Object? lastFrameAt = freezed,
  }) {
    return _then(_$StreamStatusImpl(
      panelId: null == panelId
          ? _value.panelId
          : panelId // ignore: cast_nullable_to_non_nullable
              as String,
      panelName: null == panelName
          ? _value.panelName
          : panelName // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as StreamState,
      rtspUrl: freezed == rtspUrl
          ? _value.rtspUrl
          : rtspUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      lastFrameAt: freezed == lastFrameAt
          ? _value.lastFrameAt
          : lastFrameAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StreamStatusImpl implements _StreamStatus {
  const _$StreamStatusImpl(
      {required this.panelId,
      required this.panelName,
      required this.state,
      this.rtspUrl,
      this.errorMessage,
      this.lastFrameAt});

  factory _$StreamStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$StreamStatusImplFromJson(json);

  @override
  final String panelId;
  @override
  final String panelName;
  @override
  final StreamState state;
  @override
  final String? rtspUrl;
  @override
  final String? errorMessage;
  @override
  final DateTime? lastFrameAt;

  @override
  String toString() {
    return 'StreamStatus(panelId: $panelId, panelName: $panelName, state: $state, rtspUrl: $rtspUrl, errorMessage: $errorMessage, lastFrameAt: $lastFrameAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StreamStatusImpl &&
            (identical(other.panelId, panelId) || other.panelId == panelId) &&
            (identical(other.panelName, panelName) ||
                other.panelName == panelName) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.rtspUrl, rtspUrl) || other.rtspUrl == rtspUrl) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.lastFrameAt, lastFrameAt) ||
                other.lastFrameAt == lastFrameAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, panelId, panelName, state,
      rtspUrl, errorMessage, lastFrameAt);

  /// Create a copy of StreamStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StreamStatusImplCopyWith<_$StreamStatusImpl> get copyWith =>
      __$$StreamStatusImplCopyWithImpl<_$StreamStatusImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StreamStatusImplToJson(
      this,
    );
  }
}

abstract class _StreamStatus implements StreamStatus {
  const factory _StreamStatus(
      {required final String panelId,
      required final String panelName,
      required final StreamState state,
      final String? rtspUrl,
      final String? errorMessage,
      final DateTime? lastFrameAt}) = _$StreamStatusImpl;

  factory _StreamStatus.fromJson(Map<String, dynamic> json) =
      _$StreamStatusImpl.fromJson;

  @override
  String get panelId;
  @override
  String get panelName;
  @override
  StreamState get state;
  @override
  String? get rtspUrl;
  @override
  String? get errorMessage;
  @override
  DateTime? get lastFrameAt;

  /// Create a copy of StreamStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StreamStatusImplCopyWith<_$StreamStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DetectionResult _$DetectionResultFromJson(Map<String, dynamic> json) {
  return _DetectionResult.fromJson(json);
}

/// @nodoc
mixin _$DetectionResult {
  String get id => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;
  BoundingBox get bbox => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this DetectionResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DetectionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DetectionResultCopyWith<DetectionResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DetectionResultCopyWith<$Res> {
  factory $DetectionResultCopyWith(
          DetectionResult value, $Res Function(DetectionResult) then) =
      _$DetectionResultCopyWithImpl<$Res, DetectionResult>;
  @useResult
  $Res call(
      {String id,
      String label,
      double confidence,
      BoundingBox bbox,
      DateTime timestamp});

  $BoundingBoxCopyWith<$Res> get bbox;
}

/// @nodoc
class _$DetectionResultCopyWithImpl<$Res, $Val extends DetectionResult>
    implements $DetectionResultCopyWith<$Res> {
  _$DetectionResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DetectionResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? confidence = null,
    Object? bbox = null,
    Object? timestamp = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      bbox: null == bbox
          ? _value.bbox
          : bbox // ignore: cast_nullable_to_non_nullable
              as BoundingBox,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  /// Create a copy of DetectionResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BoundingBoxCopyWith<$Res> get bbox {
    return $BoundingBoxCopyWith<$Res>(_value.bbox, (value) {
      return _then(_value.copyWith(bbox: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DetectionResultImplCopyWith<$Res>
    implements $DetectionResultCopyWith<$Res> {
  factory _$$DetectionResultImplCopyWith(_$DetectionResultImpl value,
          $Res Function(_$DetectionResultImpl) then) =
      __$$DetectionResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String label,
      double confidence,
      BoundingBox bbox,
      DateTime timestamp});

  @override
  $BoundingBoxCopyWith<$Res> get bbox;
}

/// @nodoc
class __$$DetectionResultImplCopyWithImpl<$Res>
    extends _$DetectionResultCopyWithImpl<$Res, _$DetectionResultImpl>
    implements _$$DetectionResultImplCopyWith<$Res> {
  __$$DetectionResultImplCopyWithImpl(
      _$DetectionResultImpl _value, $Res Function(_$DetectionResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of DetectionResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? confidence = null,
    Object? bbox = null,
    Object? timestamp = null,
  }) {
    return _then(_$DetectionResultImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      bbox: null == bbox
          ? _value.bbox
          : bbox // ignore: cast_nullable_to_non_nullable
              as BoundingBox,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DetectionResultImpl implements _DetectionResult {
  const _$DetectionResultImpl(
      {required this.id,
      required this.label,
      required this.confidence,
      required this.bbox,
      required this.timestamp});

  factory _$DetectionResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$DetectionResultImplFromJson(json);

  @override
  final String id;
  @override
  final String label;
  @override
  final double confidence;
  @override
  final BoundingBox bbox;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'DetectionResult(id: $id, label: $label, confidence: $confidence, bbox: $bbox, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DetectionResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.bbox, bbox) || other.bbox == bbox) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, label, confidence, bbox, timestamp);

  /// Create a copy of DetectionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DetectionResultImplCopyWith<_$DetectionResultImpl> get copyWith =>
      __$$DetectionResultImplCopyWithImpl<_$DetectionResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DetectionResultImplToJson(
      this,
    );
  }
}

abstract class _DetectionResult implements DetectionResult {
  const factory _DetectionResult(
      {required final String id,
      required final String label,
      required final double confidence,
      required final BoundingBox bbox,
      required final DateTime timestamp}) = _$DetectionResultImpl;

  factory _DetectionResult.fromJson(Map<String, dynamic> json) =
      _$DetectionResultImpl.fromJson;

  @override
  String get id;
  @override
  String get label;
  @override
  double get confidence;
  @override
  BoundingBox get bbox;
  @override
  DateTime get timestamp;

  /// Create a copy of DetectionResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DetectionResultImplCopyWith<_$DetectionResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BoundingBox _$BoundingBoxFromJson(Map<String, dynamic> json) {
  return _BoundingBox.fromJson(json);
}

/// @nodoc
mixin _$BoundingBox {
  double get x => throw _privateConstructorUsedError;
  double get y => throw _privateConstructorUsedError;
  double get width => throw _privateConstructorUsedError;
  double get height => throw _privateConstructorUsedError;

  /// Serializes this BoundingBox to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BoundingBox
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BoundingBoxCopyWith<BoundingBox> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BoundingBoxCopyWith<$Res> {
  factory $BoundingBoxCopyWith(
          BoundingBox value, $Res Function(BoundingBox) then) =
      _$BoundingBoxCopyWithImpl<$Res, BoundingBox>;
  @useResult
  $Res call({double x, double y, double width, double height});
}

/// @nodoc
class _$BoundingBoxCopyWithImpl<$Res, $Val extends BoundingBox>
    implements $BoundingBoxCopyWith<$Res> {
  _$BoundingBoxCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BoundingBox
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? x = null,
    Object? y = null,
    Object? width = null,
    Object? height = null,
  }) {
    return _then(_value.copyWith(
      x: null == x
          ? _value.x
          : x // ignore: cast_nullable_to_non_nullable
              as double,
      y: null == y
          ? _value.y
          : y // ignore: cast_nullable_to_non_nullable
              as double,
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as double,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BoundingBoxImplCopyWith<$Res>
    implements $BoundingBoxCopyWith<$Res> {
  factory _$$BoundingBoxImplCopyWith(
          _$BoundingBoxImpl value, $Res Function(_$BoundingBoxImpl) then) =
      __$$BoundingBoxImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double x, double y, double width, double height});
}

/// @nodoc
class __$$BoundingBoxImplCopyWithImpl<$Res>
    extends _$BoundingBoxCopyWithImpl<$Res, _$BoundingBoxImpl>
    implements _$$BoundingBoxImplCopyWith<$Res> {
  __$$BoundingBoxImplCopyWithImpl(
      _$BoundingBoxImpl _value, $Res Function(_$BoundingBoxImpl) _then)
      : super(_value, _then);

  /// Create a copy of BoundingBox
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? x = null,
    Object? y = null,
    Object? width = null,
    Object? height = null,
  }) {
    return _then(_$BoundingBoxImpl(
      x: null == x
          ? _value.x
          : x // ignore: cast_nullable_to_non_nullable
              as double,
      y: null == y
          ? _value.y
          : y // ignore: cast_nullable_to_non_nullable
              as double,
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as double,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BoundingBoxImpl implements _BoundingBox {
  const _$BoundingBoxImpl(
      {required this.x,
      required this.y,
      required this.width,
      required this.height});

  factory _$BoundingBoxImpl.fromJson(Map<String, dynamic> json) =>
      _$$BoundingBoxImplFromJson(json);

  @override
  final double x;
  @override
  final double y;
  @override
  final double width;
  @override
  final double height;

  @override
  String toString() {
    return 'BoundingBox(x: $x, y: $y, width: $width, height: $height)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BoundingBoxImpl &&
            (identical(other.x, x) || other.x == x) &&
            (identical(other.y, y) || other.y == y) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, x, y, width, height);

  /// Create a copy of BoundingBox
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BoundingBoxImplCopyWith<_$BoundingBoxImpl> get copyWith =>
      __$$BoundingBoxImplCopyWithImpl<_$BoundingBoxImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BoundingBoxImplToJson(
      this,
    );
  }
}

abstract class _BoundingBox implements BoundingBox {
  const factory _BoundingBox(
      {required final double x,
      required final double y,
      required final double width,
      required final double height}) = _$BoundingBoxImpl;

  factory _BoundingBox.fromJson(Map<String, dynamic> json) =
      _$BoundingBoxImpl.fromJson;

  @override
  double get x;
  @override
  double get y;
  @override
  double get width;
  @override
  double get height;

  /// Create a copy of BoundingBox
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BoundingBoxImplCopyWith<_$BoundingBoxImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
