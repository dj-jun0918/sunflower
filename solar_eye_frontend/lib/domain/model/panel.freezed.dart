// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'panel.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Panel _$PanelFromJson(Map<String, dynamic> json) {
  return _Panel.fromJson(json);
}

/// @nodoc
mixin _$Panel {
  @JsonKey(fromJson: _idToString)
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'rtsp_url')
  String? get rtspUrl => throw _privateConstructorUsedError;
  PanelStatus get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_detection_at')
  DateTime? get lastDetectionAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Panel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Panel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PanelCopyWith<Panel> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PanelCopyWith<$Res> {
  factory $PanelCopyWith(Panel value, $Res Function(Panel) then) =
      _$PanelCopyWithImpl<$Res, Panel>;
  @useResult
  $Res call(
      {@JsonKey(fromJson: _idToString) String id,
      String name,
      String? location,
      double? latitude,
      double? longitude,
      @JsonKey(name: 'rtsp_url') String? rtspUrl,
      PanelStatus status,
      @JsonKey(name: 'last_detection_at') DateTime? lastDetectionAt,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$PanelCopyWithImpl<$Res, $Val extends Panel>
    implements $PanelCopyWith<$Res> {
  _$PanelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Panel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? location = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? rtspUrl = freezed,
    Object? status = null,
    Object? lastDetectionAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      rtspUrl: freezed == rtspUrl
          ? _value.rtspUrl
          : rtspUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as PanelStatus,
      lastDetectionAt: freezed == lastDetectionAt
          ? _value.lastDetectionAt
          : lastDetectionAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PanelImplCopyWith<$Res> implements $PanelCopyWith<$Res> {
  factory _$$PanelImplCopyWith(
          _$PanelImpl value, $Res Function(_$PanelImpl) then) =
      __$$PanelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(fromJson: _idToString) String id,
      String name,
      String? location,
      double? latitude,
      double? longitude,
      @JsonKey(name: 'rtsp_url') String? rtspUrl,
      PanelStatus status,
      @JsonKey(name: 'last_detection_at') DateTime? lastDetectionAt,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$PanelImplCopyWithImpl<$Res>
    extends _$PanelCopyWithImpl<$Res, _$PanelImpl>
    implements _$$PanelImplCopyWith<$Res> {
  __$$PanelImplCopyWithImpl(
      _$PanelImpl _value, $Res Function(_$PanelImpl) _then)
      : super(_value, _then);

  /// Create a copy of Panel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? location = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? rtspUrl = freezed,
    Object? status = null,
    Object? lastDetectionAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$PanelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      rtspUrl: freezed == rtspUrl
          ? _value.rtspUrl
          : rtspUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as PanelStatus,
      lastDetectionAt: freezed == lastDetectionAt
          ? _value.lastDetectionAt
          : lastDetectionAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PanelImpl implements _Panel {
  const _$PanelImpl(
      {@JsonKey(fromJson: _idToString) required this.id,
      required this.name,
      this.location,
      this.latitude,
      this.longitude,
      @JsonKey(name: 'rtsp_url') this.rtspUrl,
      this.status = PanelStatus.normal,
      @JsonKey(name: 'last_detection_at') this.lastDetectionAt,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt});

  factory _$PanelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PanelImplFromJson(json);

  @override
  @JsonKey(fromJson: _idToString)
  final String id;
  @override
  final String name;
  @override
  final String? location;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  @JsonKey(name: 'rtsp_url')
  final String? rtspUrl;
  @override
  @JsonKey()
  final PanelStatus status;
  @override
  @JsonKey(name: 'last_detection_at')
  final DateTime? lastDetectionAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Panel(id: $id, name: $name, location: $location, latitude: $latitude, longitude: $longitude, rtspUrl: $rtspUrl, status: $status, lastDetectionAt: $lastDetectionAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PanelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.rtspUrl, rtspUrl) || other.rtspUrl == rtspUrl) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.lastDetectionAt, lastDetectionAt) ||
                other.lastDetectionAt == lastDetectionAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, location, latitude,
      longitude, rtspUrl, status, lastDetectionAt, createdAt, updatedAt);

  /// Create a copy of Panel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PanelImplCopyWith<_$PanelImpl> get copyWith =>
      __$$PanelImplCopyWithImpl<_$PanelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PanelImplToJson(
      this,
    );
  }
}

abstract class _Panel implements Panel {
  const factory _Panel(
      {@JsonKey(fromJson: _idToString) required final String id,
      required final String name,
      final String? location,
      final double? latitude,
      final double? longitude,
      @JsonKey(name: 'rtsp_url') final String? rtspUrl,
      final PanelStatus status,
      @JsonKey(name: 'last_detection_at') final DateTime? lastDetectionAt,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      @JsonKey(name: 'updated_at') final DateTime? updatedAt}) = _$PanelImpl;

  factory _Panel.fromJson(Map<String, dynamic> json) = _$PanelImpl.fromJson;

  @override
  @JsonKey(fromJson: _idToString)
  String get id;
  @override
  String get name;
  @override
  String? get location;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  @JsonKey(name: 'rtsp_url')
  String? get rtspUrl;
  @override
  PanelStatus get status;
  @override
  @JsonKey(name: 'last_detection_at')
  DateTime? get lastDetectionAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of Panel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PanelImplCopyWith<_$PanelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PanelRequest _$PanelRequestFromJson(Map<String, dynamic> json) {
  return _PanelRequest.fromJson(json);
}

/// @nodoc
mixin _$PanelRequest {
  String get name => throw _privateConstructorUsedError;
  String get location => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'rtsp_url')
  String? get rtspUrl => throw _privateConstructorUsedError;

  /// Serializes this PanelRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PanelRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PanelRequestCopyWith<PanelRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PanelRequestCopyWith<$Res> {
  factory $PanelRequestCopyWith(
          PanelRequest value, $Res Function(PanelRequest) then) =
      _$PanelRequestCopyWithImpl<$Res, PanelRequest>;
  @useResult
  $Res call(
      {String name,
      String location,
      double latitude,
      double longitude,
      @JsonKey(name: 'rtsp_url') String? rtspUrl});
}

/// @nodoc
class _$PanelRequestCopyWithImpl<$Res, $Val extends PanelRequest>
    implements $PanelRequestCopyWith<$Res> {
  _$PanelRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PanelRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? location = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? rtspUrl = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      rtspUrl: freezed == rtspUrl
          ? _value.rtspUrl
          : rtspUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PanelRequestImplCopyWith<$Res>
    implements $PanelRequestCopyWith<$Res> {
  factory _$$PanelRequestImplCopyWith(
          _$PanelRequestImpl value, $Res Function(_$PanelRequestImpl) then) =
      __$$PanelRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String location,
      double latitude,
      double longitude,
      @JsonKey(name: 'rtsp_url') String? rtspUrl});
}

/// @nodoc
class __$$PanelRequestImplCopyWithImpl<$Res>
    extends _$PanelRequestCopyWithImpl<$Res, _$PanelRequestImpl>
    implements _$$PanelRequestImplCopyWith<$Res> {
  __$$PanelRequestImplCopyWithImpl(
      _$PanelRequestImpl _value, $Res Function(_$PanelRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of PanelRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? location = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? rtspUrl = freezed,
  }) {
    return _then(_$PanelRequestImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      rtspUrl: freezed == rtspUrl
          ? _value.rtspUrl
          : rtspUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PanelRequestImpl implements _PanelRequest {
  const _$PanelRequestImpl(
      {required this.name,
      required this.location,
      required this.latitude,
      required this.longitude,
      @JsonKey(name: 'rtsp_url') this.rtspUrl});

  factory _$PanelRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$PanelRequestImplFromJson(json);

  @override
  final String name;
  @override
  final String location;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  @JsonKey(name: 'rtsp_url')
  final String? rtspUrl;

  @override
  String toString() {
    return 'PanelRequest(name: $name, location: $location, latitude: $latitude, longitude: $longitude, rtspUrl: $rtspUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PanelRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.rtspUrl, rtspUrl) || other.rtspUrl == rtspUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, location, latitude, longitude, rtspUrl);

  /// Create a copy of PanelRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PanelRequestImplCopyWith<_$PanelRequestImpl> get copyWith =>
      __$$PanelRequestImplCopyWithImpl<_$PanelRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PanelRequestImplToJson(
      this,
    );
  }
}

abstract class _PanelRequest implements PanelRequest {
  const factory _PanelRequest(
      {required final String name,
      required final String location,
      required final double latitude,
      required final double longitude,
      @JsonKey(name: 'rtsp_url') final String? rtspUrl}) = _$PanelRequestImpl;

  factory _PanelRequest.fromJson(Map<String, dynamic> json) =
      _$PanelRequestImpl.fromJson;

  @override
  String get name;
  @override
  String get location;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  @JsonKey(name: 'rtsp_url')
  String? get rtspUrl;

  /// Create a copy of PanelRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PanelRequestImplCopyWith<_$PanelRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
