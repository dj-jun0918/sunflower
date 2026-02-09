// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'detection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Detection _$DetectionFromJson(Map<String, dynamic> json) {
  return _Detection.fromJson(json);
}

/// @nodoc
mixin _$Detection {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'panel_id')
  String get panelId => throw _privateConstructorUsedError;
  @JsonKey(name: 'panel_name')
  String get panelName => throw _privateConstructorUsedError;
  DetectionType get type => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;
  @JsonKey(name: 'detected_at')
  DateTime get detectedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'alert_id')
  String? get alertId => throw _privateConstructorUsedError;

  /// Serializes this Detection to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Detection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DetectionCopyWith<Detection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DetectionCopyWith<$Res> {
  factory $DetectionCopyWith(Detection value, $Res Function(Detection) then) =
      _$DetectionCopyWithImpl<$Res, Detection>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'panel_id') String panelId,
      @JsonKey(name: 'panel_name') String panelName,
      DetectionType type,
      double confidence,
      @JsonKey(name: 'detected_at') DateTime detectedAt,
      @JsonKey(name: 'image_url') String? imageUrl,
      @JsonKey(name: 'alert_id') String? alertId});
}

/// @nodoc
class _$DetectionCopyWithImpl<$Res, $Val extends Detection>
    implements $DetectionCopyWith<$Res> {
  _$DetectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Detection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? panelId = null,
    Object? panelName = null,
    Object? type = null,
    Object? confidence = null,
    Object? detectedAt = null,
    Object? imageUrl = freezed,
    Object? alertId = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      panelId: null == panelId
          ? _value.panelId
          : panelId // ignore: cast_nullable_to_non_nullable
              as String,
      panelName: null == panelName
          ? _value.panelName
          : panelName // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as DetectionType,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      detectedAt: null == detectedAt
          ? _value.detectedAt
          : detectedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      alertId: freezed == alertId
          ? _value.alertId
          : alertId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DetectionImplCopyWith<$Res>
    implements $DetectionCopyWith<$Res> {
  factory _$$DetectionImplCopyWith(
          _$DetectionImpl value, $Res Function(_$DetectionImpl) then) =
      __$$DetectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'panel_id') String panelId,
      @JsonKey(name: 'panel_name') String panelName,
      DetectionType type,
      double confidence,
      @JsonKey(name: 'detected_at') DateTime detectedAt,
      @JsonKey(name: 'image_url') String? imageUrl,
      @JsonKey(name: 'alert_id') String? alertId});
}

/// @nodoc
class __$$DetectionImplCopyWithImpl<$Res>
    extends _$DetectionCopyWithImpl<$Res, _$DetectionImpl>
    implements _$$DetectionImplCopyWith<$Res> {
  __$$DetectionImplCopyWithImpl(
      _$DetectionImpl _value, $Res Function(_$DetectionImpl) _then)
      : super(_value, _then);

  /// Create a copy of Detection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? panelId = null,
    Object? panelName = null,
    Object? type = null,
    Object? confidence = null,
    Object? detectedAt = null,
    Object? imageUrl = freezed,
    Object? alertId = freezed,
  }) {
    return _then(_$DetectionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      panelId: null == panelId
          ? _value.panelId
          : panelId // ignore: cast_nullable_to_non_nullable
              as String,
      panelName: null == panelName
          ? _value.panelName
          : panelName // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as DetectionType,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      detectedAt: null == detectedAt
          ? _value.detectedAt
          : detectedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      alertId: freezed == alertId
          ? _value.alertId
          : alertId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DetectionImpl implements _Detection {
  const _$DetectionImpl(
      {required this.id,
      @JsonKey(name: 'panel_id') required this.panelId,
      @JsonKey(name: 'panel_name') required this.panelName,
      required this.type,
      required this.confidence,
      @JsonKey(name: 'detected_at') required this.detectedAt,
      @JsonKey(name: 'image_url') this.imageUrl,
      @JsonKey(name: 'alert_id') this.alertId});

  factory _$DetectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$DetectionImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'panel_id')
  final String panelId;
  @override
  @JsonKey(name: 'panel_name')
  final String panelName;
  @override
  final DetectionType type;
  @override
  final double confidence;
  @override
  @JsonKey(name: 'detected_at')
  final DateTime detectedAt;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @override
  @JsonKey(name: 'alert_id')
  final String? alertId;

  @override
  String toString() {
    return 'Detection(id: $id, panelId: $panelId, panelName: $panelName, type: $type, confidence: $confidence, detectedAt: $detectedAt, imageUrl: $imageUrl, alertId: $alertId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DetectionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.panelId, panelId) || other.panelId == panelId) &&
            (identical(other.panelName, panelName) ||
                other.panelName == panelName) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.detectedAt, detectedAt) ||
                other.detectedAt == detectedAt) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.alertId, alertId) || other.alertId == alertId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, panelId, panelName, type,
      confidence, detectedAt, imageUrl, alertId);

  /// Create a copy of Detection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DetectionImplCopyWith<_$DetectionImpl> get copyWith =>
      __$$DetectionImplCopyWithImpl<_$DetectionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DetectionImplToJson(
      this,
    );
  }
}

abstract class _Detection implements Detection {
  const factory _Detection(
      {required final String id,
      @JsonKey(name: 'panel_id') required final String panelId,
      @JsonKey(name: 'panel_name') required final String panelName,
      required final DetectionType type,
      required final double confidence,
      @JsonKey(name: 'detected_at') required final DateTime detectedAt,
      @JsonKey(name: 'image_url') final String? imageUrl,
      @JsonKey(name: 'alert_id') final String? alertId}) = _$DetectionImpl;

  factory _Detection.fromJson(Map<String, dynamic> json) =
      _$DetectionImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'panel_id')
  String get panelId;
  @override
  @JsonKey(name: 'panel_name')
  String get panelName;
  @override
  DetectionType get type;
  @override
  double get confidence;
  @override
  @JsonKey(name: 'detected_at')
  DateTime get detectedAt;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;
  @override
  @JsonKey(name: 'alert_id')
  String? get alertId;

  /// Create a copy of Detection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DetectionImplCopyWith<_$DetectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DetectionsResponse _$DetectionsResponseFromJson(Map<String, dynamic> json) {
  return _DetectionsResponse.fromJson(json);
}

/// @nodoc
mixin _$DetectionsResponse {
  List<Detection> get detections => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;

  /// Serializes this DetectionsResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DetectionsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DetectionsResponseCopyWith<DetectionsResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DetectionsResponseCopyWith<$Res> {
  factory $DetectionsResponseCopyWith(
          DetectionsResponse value, $Res Function(DetectionsResponse) then) =
      _$DetectionsResponseCopyWithImpl<$Res, DetectionsResponse>;
  @useResult
  $Res call({List<Detection> detections, int total, int page, int limit});
}

/// @nodoc
class _$DetectionsResponseCopyWithImpl<$Res, $Val extends DetectionsResponse>
    implements $DetectionsResponseCopyWith<$Res> {
  _$DetectionsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DetectionsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? detections = null,
    Object? total = null,
    Object? page = null,
    Object? limit = null,
  }) {
    return _then(_value.copyWith(
      detections: null == detections
          ? _value.detections
          : detections // ignore: cast_nullable_to_non_nullable
              as List<Detection>,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DetectionsResponseImplCopyWith<$Res>
    implements $DetectionsResponseCopyWith<$Res> {
  factory _$$DetectionsResponseImplCopyWith(_$DetectionsResponseImpl value,
          $Res Function(_$DetectionsResponseImpl) then) =
      __$$DetectionsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Detection> detections, int total, int page, int limit});
}

/// @nodoc
class __$$DetectionsResponseImplCopyWithImpl<$Res>
    extends _$DetectionsResponseCopyWithImpl<$Res, _$DetectionsResponseImpl>
    implements _$$DetectionsResponseImplCopyWith<$Res> {
  __$$DetectionsResponseImplCopyWithImpl(_$DetectionsResponseImpl _value,
      $Res Function(_$DetectionsResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of DetectionsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? detections = null,
    Object? total = null,
    Object? page = null,
    Object? limit = null,
  }) {
    return _then(_$DetectionsResponseImpl(
      detections: null == detections
          ? _value._detections
          : detections // ignore: cast_nullable_to_non_nullable
              as List<Detection>,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DetectionsResponseImpl implements _DetectionsResponse {
  const _$DetectionsResponseImpl(
      {required final List<Detection> detections,
      required this.total,
      this.page = 1,
      this.limit = 20})
      : _detections = detections;

  factory _$DetectionsResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$DetectionsResponseImplFromJson(json);

  final List<Detection> _detections;
  @override
  List<Detection> get detections {
    if (_detections is EqualUnmodifiableListView) return _detections;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_detections);
  }

  @override
  final int total;
  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int limit;

  @override
  String toString() {
    return 'DetectionsResponse(detections: $detections, total: $total, page: $page, limit: $limit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DetectionsResponseImpl &&
            const DeepCollectionEquality()
                .equals(other._detections, _detections) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.limit, limit) || other.limit == limit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_detections), total, page, limit);

  /// Create a copy of DetectionsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DetectionsResponseImplCopyWith<_$DetectionsResponseImpl> get copyWith =>
      __$$DetectionsResponseImplCopyWithImpl<_$DetectionsResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DetectionsResponseImplToJson(
      this,
    );
  }
}

abstract class _DetectionsResponse implements DetectionsResponse {
  const factory _DetectionsResponse(
      {required final List<Detection> detections,
      required final int total,
      final int page,
      final int limit}) = _$DetectionsResponseImpl;

  factory _DetectionsResponse.fromJson(Map<String, dynamic> json) =
      _$DetectionsResponseImpl.fromJson;

  @override
  List<Detection> get detections;
  @override
  int get total;
  @override
  int get page;
  @override
  int get limit;

  /// Create a copy of DetectionsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DetectionsResponseImplCopyWith<_$DetectionsResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
