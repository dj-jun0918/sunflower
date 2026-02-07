// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alert.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Alert _$AlertFromJson(Map<String, dynamic> json) {
  return _Alert.fromJson(json);
}

/// @nodoc
mixin _$Alert {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  AlertSeverity get severity => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;
  String? get panelId => throw _privateConstructorUsedError;
  String? get panelName => throw _privateConstructorUsedError;
  String? get detectionId => throw _privateConstructorUsedError;
  String? get snapshotUrl => throw _privateConstructorUsedError;

  /// Serializes this Alert to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Alert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AlertCopyWith<Alert> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AlertCopyWith<$Res> {
  factory $AlertCopyWith(Alert value, $Res Function(Alert) then) =
      _$AlertCopyWithImpl<$Res, Alert>;
  @useResult
  $Res call(
      {String id,
      String title,
      String message,
      AlertSeverity severity,
      DateTime createdAt,
      bool isRead,
      String? panelId,
      String? panelName,
      String? detectionId,
      String? snapshotUrl});
}

/// @nodoc
class _$AlertCopyWithImpl<$Res, $Val extends Alert>
    implements $AlertCopyWith<$Res> {
  _$AlertCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Alert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? message = null,
    Object? severity = null,
    Object? createdAt = null,
    Object? isRead = null,
    Object? panelId = freezed,
    Object? panelName = freezed,
    Object? detectionId = freezed,
    Object? snapshotUrl = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as AlertSeverity,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      panelId: freezed == panelId
          ? _value.panelId
          : panelId // ignore: cast_nullable_to_non_nullable
              as String?,
      panelName: freezed == panelName
          ? _value.panelName
          : panelName // ignore: cast_nullable_to_non_nullable
              as String?,
      detectionId: freezed == detectionId
          ? _value.detectionId
          : detectionId // ignore: cast_nullable_to_non_nullable
              as String?,
      snapshotUrl: freezed == snapshotUrl
          ? _value.snapshotUrl
          : snapshotUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AlertImplCopyWith<$Res> implements $AlertCopyWith<$Res> {
  factory _$$AlertImplCopyWith(
          _$AlertImpl value, $Res Function(_$AlertImpl) then) =
      __$$AlertImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String message,
      AlertSeverity severity,
      DateTime createdAt,
      bool isRead,
      String? panelId,
      String? panelName,
      String? detectionId,
      String? snapshotUrl});
}

/// @nodoc
class __$$AlertImplCopyWithImpl<$Res>
    extends _$AlertCopyWithImpl<$Res, _$AlertImpl>
    implements _$$AlertImplCopyWith<$Res> {
  __$$AlertImplCopyWithImpl(
      _$AlertImpl _value, $Res Function(_$AlertImpl) _then)
      : super(_value, _then);

  /// Create a copy of Alert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? message = null,
    Object? severity = null,
    Object? createdAt = null,
    Object? isRead = null,
    Object? panelId = freezed,
    Object? panelName = freezed,
    Object? detectionId = freezed,
    Object? snapshotUrl = freezed,
  }) {
    return _then(_$AlertImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as AlertSeverity,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      panelId: freezed == panelId
          ? _value.panelId
          : panelId // ignore: cast_nullable_to_non_nullable
              as String?,
      panelName: freezed == panelName
          ? _value.panelName
          : panelName // ignore: cast_nullable_to_non_nullable
              as String?,
      detectionId: freezed == detectionId
          ? _value.detectionId
          : detectionId // ignore: cast_nullable_to_non_nullable
              as String?,
      snapshotUrl: freezed == snapshotUrl
          ? _value.snapshotUrl
          : snapshotUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AlertImpl implements _Alert {
  const _$AlertImpl(
      {required this.id,
      required this.title,
      required this.message,
      required this.severity,
      required this.createdAt,
      this.isRead = false,
      this.panelId,
      this.panelName,
      this.detectionId,
      this.snapshotUrl});

  factory _$AlertImpl.fromJson(Map<String, dynamic> json) =>
      _$$AlertImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String message;
  @override
  final AlertSeverity severity;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final bool isRead;
  @override
  final String? panelId;
  @override
  final String? panelName;
  @override
  final String? detectionId;
  @override
  final String? snapshotUrl;

  @override
  String toString() {
    return 'Alert(id: $id, title: $title, message: $message, severity: $severity, createdAt: $createdAt, isRead: $isRead, panelId: $panelId, panelName: $panelName, detectionId: $detectionId, snapshotUrl: $snapshotUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlertImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.panelId, panelId) || other.panelId == panelId) &&
            (identical(other.panelName, panelName) ||
                other.panelName == panelName) &&
            (identical(other.detectionId, detectionId) ||
                other.detectionId == detectionId) &&
            (identical(other.snapshotUrl, snapshotUrl) ||
                other.snapshotUrl == snapshotUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, message, severity,
      createdAt, isRead, panelId, panelName, detectionId, snapshotUrl);

  /// Create a copy of Alert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AlertImplCopyWith<_$AlertImpl> get copyWith =>
      __$$AlertImplCopyWithImpl<_$AlertImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AlertImplToJson(
      this,
    );
  }
}

abstract class _Alert implements Alert {
  const factory _Alert(
      {required final String id,
      required final String title,
      required final String message,
      required final AlertSeverity severity,
      required final DateTime createdAt,
      final bool isRead,
      final String? panelId,
      final String? panelName,
      final String? detectionId,
      final String? snapshotUrl}) = _$AlertImpl;

  factory _Alert.fromJson(Map<String, dynamic> json) = _$AlertImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get message;
  @override
  AlertSeverity get severity;
  @override
  DateTime get createdAt;
  @override
  bool get isRead;
  @override
  String? get panelId;
  @override
  String? get panelName;
  @override
  String? get detectionId;
  @override
  String? get snapshotUrl;

  /// Create a copy of Alert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AlertImplCopyWith<_$AlertImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AlertsResponse _$AlertsResponseFromJson(Map<String, dynamic> json) {
  return _AlertsResponse.fromJson(json);
}

/// @nodoc
mixin _$AlertsResponse {
  List<Alert> get alerts => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  int get unreadCount => throw _privateConstructorUsedError;

  /// Serializes this AlertsResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AlertsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AlertsResponseCopyWith<AlertsResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AlertsResponseCopyWith<$Res> {
  factory $AlertsResponseCopyWith(
          AlertsResponse value, $Res Function(AlertsResponse) then) =
      _$AlertsResponseCopyWithImpl<$Res, AlertsResponse>;
  @useResult
  $Res call({List<Alert> alerts, int total, int unreadCount});
}

/// @nodoc
class _$AlertsResponseCopyWithImpl<$Res, $Val extends AlertsResponse>
    implements $AlertsResponseCopyWith<$Res> {
  _$AlertsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AlertsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? alerts = null,
    Object? total = null,
    Object? unreadCount = null,
  }) {
    return _then(_value.copyWith(
      alerts: null == alerts
          ? _value.alerts
          : alerts // ignore: cast_nullable_to_non_nullable
              as List<Alert>,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AlertsResponseImplCopyWith<$Res>
    implements $AlertsResponseCopyWith<$Res> {
  factory _$$AlertsResponseImplCopyWith(_$AlertsResponseImpl value,
          $Res Function(_$AlertsResponseImpl) then) =
      __$$AlertsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Alert> alerts, int total, int unreadCount});
}

/// @nodoc
class __$$AlertsResponseImplCopyWithImpl<$Res>
    extends _$AlertsResponseCopyWithImpl<$Res, _$AlertsResponseImpl>
    implements _$$AlertsResponseImplCopyWith<$Res> {
  __$$AlertsResponseImplCopyWithImpl(
      _$AlertsResponseImpl _value, $Res Function(_$AlertsResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of AlertsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? alerts = null,
    Object? total = null,
    Object? unreadCount = null,
  }) {
    return _then(_$AlertsResponseImpl(
      alerts: null == alerts
          ? _value._alerts
          : alerts // ignore: cast_nullable_to_non_nullable
              as List<Alert>,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AlertsResponseImpl implements _AlertsResponse {
  const _$AlertsResponseImpl(
      {required final List<Alert> alerts,
      required this.total,
      required this.unreadCount})
      : _alerts = alerts;

  factory _$AlertsResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AlertsResponseImplFromJson(json);

  final List<Alert> _alerts;
  @override
  List<Alert> get alerts {
    if (_alerts is EqualUnmodifiableListView) return _alerts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_alerts);
  }

  @override
  final int total;
  @override
  final int unreadCount;

  @override
  String toString() {
    return 'AlertsResponse(alerts: $alerts, total: $total, unreadCount: $unreadCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlertsResponseImpl &&
            const DeepCollectionEquality().equals(other._alerts, _alerts) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_alerts), total, unreadCount);

  /// Create a copy of AlertsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AlertsResponseImplCopyWith<_$AlertsResponseImpl> get copyWith =>
      __$$AlertsResponseImplCopyWithImpl<_$AlertsResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AlertsResponseImplToJson(
      this,
    );
  }
}

abstract class _AlertsResponse implements AlertsResponse {
  const factory _AlertsResponse(
      {required final List<Alert> alerts,
      required final int total,
      required final int unreadCount}) = _$AlertsResponseImpl;

  factory _AlertsResponse.fromJson(Map<String, dynamic> json) =
      _$AlertsResponseImpl.fromJson;

  @override
  List<Alert> get alerts;
  @override
  int get total;
  @override
  int get unreadCount;

  /// Create a copy of AlertsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AlertsResponseImplCopyWith<_$AlertsResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
