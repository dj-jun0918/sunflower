// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monitoring.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AnalysisSession _$AnalysisSessionFromJson(Map<String, dynamic> json) {
  return _AnalysisSession.fromJson(json);
}

/// @nodoc
mixin _$AnalysisSession {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'panel_id', fromJson: _idToString)
  String get panelId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError; // "cctv" or "drone"
  String get status =>
      throw _privateConstructorUsedError; // "processing", "completed", "failed"
  @JsonKey(name: 'original_image_url')
  String? get originalImageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  List<Detection> get detections => throw _privateConstructorUsedError;

  /// Serializes this AnalysisSession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AnalysisSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnalysisSessionCopyWith<AnalysisSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnalysisSessionCopyWith<$Res> {
  factory $AnalysisSessionCopyWith(
          AnalysisSession value, $Res Function(AnalysisSession) then) =
      _$AnalysisSessionCopyWithImpl<$Res, AnalysisSession>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'panel_id', fromJson: _idToString) String panelId,
      String type,
      String status,
      @JsonKey(name: 'original_image_url') String? originalImageUrl,
      @JsonKey(name: 'created_at') DateTime createdAt,
      List<Detection> detections});
}

/// @nodoc
class _$AnalysisSessionCopyWithImpl<$Res, $Val extends AnalysisSession>
    implements $AnalysisSessionCopyWith<$Res> {
  _$AnalysisSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnalysisSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? panelId = null,
    Object? type = null,
    Object? status = null,
    Object? originalImageUrl = freezed,
    Object? createdAt = null,
    Object? detections = null,
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
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      originalImageUrl: freezed == originalImageUrl
          ? _value.originalImageUrl
          : originalImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      detections: null == detections
          ? _value.detections
          : detections // ignore: cast_nullable_to_non_nullable
              as List<Detection>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AnalysisSessionImplCopyWith<$Res>
    implements $AnalysisSessionCopyWith<$Res> {
  factory _$$AnalysisSessionImplCopyWith(_$AnalysisSessionImpl value,
          $Res Function(_$AnalysisSessionImpl) then) =
      __$$AnalysisSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'panel_id', fromJson: _idToString) String panelId,
      String type,
      String status,
      @JsonKey(name: 'original_image_url') String? originalImageUrl,
      @JsonKey(name: 'created_at') DateTime createdAt,
      List<Detection> detections});
}

/// @nodoc
class __$$AnalysisSessionImplCopyWithImpl<$Res>
    extends _$AnalysisSessionCopyWithImpl<$Res, _$AnalysisSessionImpl>
    implements _$$AnalysisSessionImplCopyWith<$Res> {
  __$$AnalysisSessionImplCopyWithImpl(
      _$AnalysisSessionImpl _value, $Res Function(_$AnalysisSessionImpl) _then)
      : super(_value, _then);

  /// Create a copy of AnalysisSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? panelId = null,
    Object? type = null,
    Object? status = null,
    Object? originalImageUrl = freezed,
    Object? createdAt = null,
    Object? detections = null,
  }) {
    return _then(_$AnalysisSessionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      panelId: null == panelId
          ? _value.panelId
          : panelId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      originalImageUrl: freezed == originalImageUrl
          ? _value.originalImageUrl
          : originalImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      detections: null == detections
          ? _value._detections
          : detections // ignore: cast_nullable_to_non_nullable
              as List<Detection>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AnalysisSessionImpl implements _AnalysisSession {
  const _$AnalysisSessionImpl(
      {required this.id,
      @JsonKey(name: 'panel_id', fromJson: _idToString) required this.panelId,
      required this.type,
      required this.status,
      @JsonKey(name: 'original_image_url') this.originalImageUrl,
      @JsonKey(name: 'created_at') required this.createdAt,
      final List<Detection> detections = const []})
      : _detections = detections;

  factory _$AnalysisSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnalysisSessionImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'panel_id', fromJson: _idToString)
  final String panelId;
  @override
  final String type;
// "cctv" or "drone"
  @override
  final String status;
// "processing", "completed", "failed"
  @override
  @JsonKey(name: 'original_image_url')
  final String? originalImageUrl;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  final List<Detection> _detections;
  @override
  @JsonKey()
  List<Detection> get detections {
    if (_detections is EqualUnmodifiableListView) return _detections;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_detections);
  }

  @override
  String toString() {
    return 'AnalysisSession(id: $id, panelId: $panelId, type: $type, status: $status, originalImageUrl: $originalImageUrl, createdAt: $createdAt, detections: $detections)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnalysisSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.panelId, panelId) || other.panelId == panelId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.originalImageUrl, originalImageUrl) ||
                other.originalImageUrl == originalImageUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality()
                .equals(other._detections, _detections));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      panelId,
      type,
      status,
      originalImageUrl,
      createdAt,
      const DeepCollectionEquality().hash(_detections));

  /// Create a copy of AnalysisSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnalysisSessionImplCopyWith<_$AnalysisSessionImpl> get copyWith =>
      __$$AnalysisSessionImplCopyWithImpl<_$AnalysisSessionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AnalysisSessionImplToJson(
      this,
    );
  }
}

abstract class _AnalysisSession implements AnalysisSession {
  const factory _AnalysisSession(
      {required final String id,
      @JsonKey(name: 'panel_id', fromJson: _idToString)
      required final String panelId,
      required final String type,
      required final String status,
      @JsonKey(name: 'original_image_url') final String? originalImageUrl,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      final List<Detection> detections}) = _$AnalysisSessionImpl;

  factory _AnalysisSession.fromJson(Map<String, dynamic> json) =
      _$AnalysisSessionImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'panel_id', fromJson: _idToString)
  String get panelId;
  @override
  String get type; // "cctv" or "drone"
  @override
  String get status; // "processing", "completed", "failed"
  @override
  @JsonKey(name: 'original_image_url')
  String? get originalImageUrl;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  List<Detection> get detections;

  /// Create a copy of AnalysisSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnalysisSessionImplCopyWith<_$AnalysisSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AnalysisHistoryResponse _$AnalysisHistoryResponseFromJson(
    Map<String, dynamic> json) {
  return _AnalysisHistoryResponse.fromJson(json);
}

/// @nodoc
mixin _$AnalysisHistoryResponse {
  List<AnalysisSession> get sessions => throw _privateConstructorUsedError;

  /// Serializes this AnalysisHistoryResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AnalysisHistoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnalysisHistoryResponseCopyWith<AnalysisHistoryResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnalysisHistoryResponseCopyWith<$Res> {
  factory $AnalysisHistoryResponseCopyWith(AnalysisHistoryResponse value,
          $Res Function(AnalysisHistoryResponse) then) =
      _$AnalysisHistoryResponseCopyWithImpl<$Res, AnalysisHistoryResponse>;
  @useResult
  $Res call({List<AnalysisSession> sessions});
}

/// @nodoc
class _$AnalysisHistoryResponseCopyWithImpl<$Res,
        $Val extends AnalysisHistoryResponse>
    implements $AnalysisHistoryResponseCopyWith<$Res> {
  _$AnalysisHistoryResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnalysisHistoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessions = null,
  }) {
    return _then(_value.copyWith(
      sessions: null == sessions
          ? _value.sessions
          : sessions // ignore: cast_nullable_to_non_nullable
              as List<AnalysisSession>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AnalysisHistoryResponseImplCopyWith<$Res>
    implements $AnalysisHistoryResponseCopyWith<$Res> {
  factory _$$AnalysisHistoryResponseImplCopyWith(
          _$AnalysisHistoryResponseImpl value,
          $Res Function(_$AnalysisHistoryResponseImpl) then) =
      __$$AnalysisHistoryResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<AnalysisSession> sessions});
}

/// @nodoc
class __$$AnalysisHistoryResponseImplCopyWithImpl<$Res>
    extends _$AnalysisHistoryResponseCopyWithImpl<$Res,
        _$AnalysisHistoryResponseImpl>
    implements _$$AnalysisHistoryResponseImplCopyWith<$Res> {
  __$$AnalysisHistoryResponseImplCopyWithImpl(
      _$AnalysisHistoryResponseImpl _value,
      $Res Function(_$AnalysisHistoryResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of AnalysisHistoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessions = null,
  }) {
    return _then(_$AnalysisHistoryResponseImpl(
      sessions: null == sessions
          ? _value._sessions
          : sessions // ignore: cast_nullable_to_non_nullable
              as List<AnalysisSession>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AnalysisHistoryResponseImpl implements _AnalysisHistoryResponse {
  const _$AnalysisHistoryResponseImpl(
      {required final List<AnalysisSession> sessions})
      : _sessions = sessions;

  factory _$AnalysisHistoryResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnalysisHistoryResponseImplFromJson(json);

  final List<AnalysisSession> _sessions;
  @override
  List<AnalysisSession> get sessions {
    if (_sessions is EqualUnmodifiableListView) return _sessions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sessions);
  }

  @override
  String toString() {
    return 'AnalysisHistoryResponse(sessions: $sessions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnalysisHistoryResponseImpl &&
            const DeepCollectionEquality().equals(other._sessions, _sessions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_sessions));

  /// Create a copy of AnalysisHistoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnalysisHistoryResponseImplCopyWith<_$AnalysisHistoryResponseImpl>
      get copyWith => __$$AnalysisHistoryResponseImplCopyWithImpl<
          _$AnalysisHistoryResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AnalysisHistoryResponseImplToJson(
      this,
    );
  }
}

abstract class _AnalysisHistoryResponse implements AnalysisHistoryResponse {
  const factory _AnalysisHistoryResponse(
          {required final List<AnalysisSession> sessions}) =
      _$AnalysisHistoryResponseImpl;

  factory _AnalysisHistoryResponse.fromJson(Map<String, dynamic> json) =
      _$AnalysisHistoryResponseImpl.fromJson;

  @override
  List<AnalysisSession> get sessions;

  /// Create a copy of AnalysisHistoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnalysisHistoryResponseImplCopyWith<_$AnalysisHistoryResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
