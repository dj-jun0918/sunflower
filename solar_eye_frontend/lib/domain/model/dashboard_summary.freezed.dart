// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DashboardSummary _$DashboardSummaryFromJson(Map<String, dynamic> json) {
  return _DashboardSummary.fromJson(json);
}

/// @nodoc
mixin _$DashboardSummary {
  int get totalPanels => throw _privateConstructorUsedError;
  int get normalPanels => throw _privateConstructorUsedError;
  int get warningPanels => throw _privateConstructorUsedError;
  int get dangerPanels => throw _privateConstructorUsedError;
  TodayDetections get todayDetections => throw _privateConstructorUsedError;
  double get efficiencyRate => throw _privateConstructorUsedError;
  double get currentOutputKw => throw _privateConstructorUsedError;
  int get todayRevenue => throw _privateConstructorUsedError;
  int get yesterdayRevenueDiff => throw _privateConstructorUsedError;
  List<RecentAlert> get recentAlerts => throw _privateConstructorUsedError;

  /// Serializes this DashboardSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DashboardSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardSummaryCopyWith<DashboardSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardSummaryCopyWith<$Res> {
  factory $DashboardSummaryCopyWith(
          DashboardSummary value, $Res Function(DashboardSummary) then) =
      _$DashboardSummaryCopyWithImpl<$Res, DashboardSummary>;
  @useResult
  $Res call(
      {int totalPanels,
      int normalPanels,
      int warningPanels,
      int dangerPanels,
      TodayDetections todayDetections,
      double efficiencyRate,
      double currentOutputKw,
      int todayRevenue,
      int yesterdayRevenueDiff,
      List<RecentAlert> recentAlerts});

  $TodayDetectionsCopyWith<$Res> get todayDetections;
}

/// @nodoc
class _$DashboardSummaryCopyWithImpl<$Res, $Val extends DashboardSummary>
    implements $DashboardSummaryCopyWith<$Res> {
  _$DashboardSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalPanels = null,
    Object? normalPanels = null,
    Object? warningPanels = null,
    Object? dangerPanels = null,
    Object? todayDetections = null,
    Object? efficiencyRate = null,
    Object? currentOutputKw = null,
    Object? todayRevenue = null,
    Object? yesterdayRevenueDiff = null,
    Object? recentAlerts = null,
  }) {
    return _then(_value.copyWith(
      totalPanels: null == totalPanels
          ? _value.totalPanels
          : totalPanels // ignore: cast_nullable_to_non_nullable
              as int,
      normalPanels: null == normalPanels
          ? _value.normalPanels
          : normalPanels // ignore: cast_nullable_to_non_nullable
              as int,
      warningPanels: null == warningPanels
          ? _value.warningPanels
          : warningPanels // ignore: cast_nullable_to_non_nullable
              as int,
      dangerPanels: null == dangerPanels
          ? _value.dangerPanels
          : dangerPanels // ignore: cast_nullable_to_non_nullable
              as int,
      todayDetections: null == todayDetections
          ? _value.todayDetections
          : todayDetections // ignore: cast_nullable_to_non_nullable
              as TodayDetections,
      efficiencyRate: null == efficiencyRate
          ? _value.efficiencyRate
          : efficiencyRate // ignore: cast_nullable_to_non_nullable
              as double,
      currentOutputKw: null == currentOutputKw
          ? _value.currentOutputKw
          : currentOutputKw // ignore: cast_nullable_to_non_nullable
              as double,
      todayRevenue: null == todayRevenue
          ? _value.todayRevenue
          : todayRevenue // ignore: cast_nullable_to_non_nullable
              as int,
      yesterdayRevenueDiff: null == yesterdayRevenueDiff
          ? _value.yesterdayRevenueDiff
          : yesterdayRevenueDiff // ignore: cast_nullable_to_non_nullable
              as int,
      recentAlerts: null == recentAlerts
          ? _value.recentAlerts
          : recentAlerts // ignore: cast_nullable_to_non_nullable
              as List<RecentAlert>,
    ) as $Val);
  }

  /// Create a copy of DashboardSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TodayDetectionsCopyWith<$Res> get todayDetections {
    return $TodayDetectionsCopyWith<$Res>(_value.todayDetections, (value) {
      return _then(_value.copyWith(todayDetections: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DashboardSummaryImplCopyWith<$Res>
    implements $DashboardSummaryCopyWith<$Res> {
  factory _$$DashboardSummaryImplCopyWith(_$DashboardSummaryImpl value,
          $Res Function(_$DashboardSummaryImpl) then) =
      __$$DashboardSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalPanels,
      int normalPanels,
      int warningPanels,
      int dangerPanels,
      TodayDetections todayDetections,
      double efficiencyRate,
      double currentOutputKw,
      int todayRevenue,
      int yesterdayRevenueDiff,
      List<RecentAlert> recentAlerts});

  @override
  $TodayDetectionsCopyWith<$Res> get todayDetections;
}

/// @nodoc
class __$$DashboardSummaryImplCopyWithImpl<$Res>
    extends _$DashboardSummaryCopyWithImpl<$Res, _$DashboardSummaryImpl>
    implements _$$DashboardSummaryImplCopyWith<$Res> {
  __$$DashboardSummaryImplCopyWithImpl(_$DashboardSummaryImpl _value,
      $Res Function(_$DashboardSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of DashboardSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalPanels = null,
    Object? normalPanels = null,
    Object? warningPanels = null,
    Object? dangerPanels = null,
    Object? todayDetections = null,
    Object? efficiencyRate = null,
    Object? currentOutputKw = null,
    Object? todayRevenue = null,
    Object? yesterdayRevenueDiff = null,
    Object? recentAlerts = null,
  }) {
    return _then(_$DashboardSummaryImpl(
      totalPanels: null == totalPanels
          ? _value.totalPanels
          : totalPanels // ignore: cast_nullable_to_non_nullable
              as int,
      normalPanels: null == normalPanels
          ? _value.normalPanels
          : normalPanels // ignore: cast_nullable_to_non_nullable
              as int,
      warningPanels: null == warningPanels
          ? _value.warningPanels
          : warningPanels // ignore: cast_nullable_to_non_nullable
              as int,
      dangerPanels: null == dangerPanels
          ? _value.dangerPanels
          : dangerPanels // ignore: cast_nullable_to_non_nullable
              as int,
      todayDetections: null == todayDetections
          ? _value.todayDetections
          : todayDetections // ignore: cast_nullable_to_non_nullable
              as TodayDetections,
      efficiencyRate: null == efficiencyRate
          ? _value.efficiencyRate
          : efficiencyRate // ignore: cast_nullable_to_non_nullable
              as double,
      currentOutputKw: null == currentOutputKw
          ? _value.currentOutputKw
          : currentOutputKw // ignore: cast_nullable_to_non_nullable
              as double,
      todayRevenue: null == todayRevenue
          ? _value.todayRevenue
          : todayRevenue // ignore: cast_nullable_to_non_nullable
              as int,
      yesterdayRevenueDiff: null == yesterdayRevenueDiff
          ? _value.yesterdayRevenueDiff
          : yesterdayRevenueDiff // ignore: cast_nullable_to_non_nullable
              as int,
      recentAlerts: null == recentAlerts
          ? _value._recentAlerts
          : recentAlerts // ignore: cast_nullable_to_non_nullable
              as List<RecentAlert>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardSummaryImpl implements _DashboardSummary {
  const _$DashboardSummaryImpl(
      {required this.totalPanels,
      required this.normalPanels,
      required this.warningPanels,
      required this.dangerPanels,
      required this.todayDetections,
      required this.efficiencyRate,
      required this.currentOutputKw,
      required this.todayRevenue,
      required this.yesterdayRevenueDiff,
      required final List<RecentAlert> recentAlerts})
      : _recentAlerts = recentAlerts;

  factory _$DashboardSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardSummaryImplFromJson(json);

  @override
  final int totalPanels;
  @override
  final int normalPanels;
  @override
  final int warningPanels;
  @override
  final int dangerPanels;
  @override
  final TodayDetections todayDetections;
  @override
  final double efficiencyRate;
  @override
  final double currentOutputKw;
  @override
  final int todayRevenue;
  @override
  final int yesterdayRevenueDiff;
  final List<RecentAlert> _recentAlerts;
  @override
  List<RecentAlert> get recentAlerts {
    if (_recentAlerts is EqualUnmodifiableListView) return _recentAlerts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentAlerts);
  }

  @override
  String toString() {
    return 'DashboardSummary(totalPanels: $totalPanels, normalPanels: $normalPanels, warningPanels: $warningPanels, dangerPanels: $dangerPanels, todayDetections: $todayDetections, efficiencyRate: $efficiencyRate, currentOutputKw: $currentOutputKw, todayRevenue: $todayRevenue, yesterdayRevenueDiff: $yesterdayRevenueDiff, recentAlerts: $recentAlerts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardSummaryImpl &&
            (identical(other.totalPanels, totalPanels) ||
                other.totalPanels == totalPanels) &&
            (identical(other.normalPanels, normalPanels) ||
                other.normalPanels == normalPanels) &&
            (identical(other.warningPanels, warningPanels) ||
                other.warningPanels == warningPanels) &&
            (identical(other.dangerPanels, dangerPanels) ||
                other.dangerPanels == dangerPanels) &&
            (identical(other.todayDetections, todayDetections) ||
                other.todayDetections == todayDetections) &&
            (identical(other.efficiencyRate, efficiencyRate) ||
                other.efficiencyRate == efficiencyRate) &&
            (identical(other.currentOutputKw, currentOutputKw) ||
                other.currentOutputKw == currentOutputKw) &&
            (identical(other.todayRevenue, todayRevenue) ||
                other.todayRevenue == todayRevenue) &&
            (identical(other.yesterdayRevenueDiff, yesterdayRevenueDiff) ||
                other.yesterdayRevenueDiff == yesterdayRevenueDiff) &&
            const DeepCollectionEquality()
                .equals(other._recentAlerts, _recentAlerts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalPanels,
      normalPanels,
      warningPanels,
      dangerPanels,
      todayDetections,
      efficiencyRate,
      currentOutputKw,
      todayRevenue,
      yesterdayRevenueDiff,
      const DeepCollectionEquality().hash(_recentAlerts));

  /// Create a copy of DashboardSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardSummaryImplCopyWith<_$DashboardSummaryImpl> get copyWith =>
      __$$DashboardSummaryImplCopyWithImpl<_$DashboardSummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardSummaryImplToJson(
      this,
    );
  }
}

abstract class _DashboardSummary implements DashboardSummary {
  const factory _DashboardSummary(
      {required final int totalPanels,
      required final int normalPanels,
      required final int warningPanels,
      required final int dangerPanels,
      required final TodayDetections todayDetections,
      required final double efficiencyRate,
      required final double currentOutputKw,
      required final int todayRevenue,
      required final int yesterdayRevenueDiff,
      required final List<RecentAlert> recentAlerts}) = _$DashboardSummaryImpl;

  factory _DashboardSummary.fromJson(Map<String, dynamic> json) =
      _$DashboardSummaryImpl.fromJson;

  @override
  int get totalPanels;
  @override
  int get normalPanels;
  @override
  int get warningPanels;
  @override
  int get dangerPanels;
  @override
  TodayDetections get todayDetections;
  @override
  double get efficiencyRate;
  @override
  double get currentOutputKw;
  @override
  int get todayRevenue;
  @override
  int get yesterdayRevenueDiff;
  @override
  List<RecentAlert> get recentAlerts;

  /// Create a copy of DashboardSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardSummaryImplCopyWith<_$DashboardSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TodayDetections _$TodayDetectionsFromJson(Map<String, dynamic> json) {
  return _TodayDetections.fromJson(json);
}

/// @nodoc
mixin _$TodayDetections {
  int get total => throw _privateConstructorUsedError;
  int get normal => throw _privateConstructorUsedError;
  int get soiling => throw _privateConstructorUsedError;
  int get crack => throw _privateConstructorUsedError;

  /// Serializes this TodayDetections to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TodayDetections
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TodayDetectionsCopyWith<TodayDetections> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TodayDetectionsCopyWith<$Res> {
  factory $TodayDetectionsCopyWith(
          TodayDetections value, $Res Function(TodayDetections) then) =
      _$TodayDetectionsCopyWithImpl<$Res, TodayDetections>;
  @useResult
  $Res call({int total, int normal, int soiling, int crack});
}

/// @nodoc
class _$TodayDetectionsCopyWithImpl<$Res, $Val extends TodayDetections>
    implements $TodayDetectionsCopyWith<$Res> {
  _$TodayDetectionsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TodayDetections
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? normal = null,
    Object? soiling = null,
    Object? crack = null,
  }) {
    return _then(_value.copyWith(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      normal: null == normal
          ? _value.normal
          : normal // ignore: cast_nullable_to_non_nullable
              as int,
      soiling: null == soiling
          ? _value.soiling
          : soiling // ignore: cast_nullable_to_non_nullable
              as int,
      crack: null == crack
          ? _value.crack
          : crack // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TodayDetectionsImplCopyWith<$Res>
    implements $TodayDetectionsCopyWith<$Res> {
  factory _$$TodayDetectionsImplCopyWith(_$TodayDetectionsImpl value,
          $Res Function(_$TodayDetectionsImpl) then) =
      __$$TodayDetectionsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int total, int normal, int soiling, int crack});
}

/// @nodoc
class __$$TodayDetectionsImplCopyWithImpl<$Res>
    extends _$TodayDetectionsCopyWithImpl<$Res, _$TodayDetectionsImpl>
    implements _$$TodayDetectionsImplCopyWith<$Res> {
  __$$TodayDetectionsImplCopyWithImpl(
      _$TodayDetectionsImpl _value, $Res Function(_$TodayDetectionsImpl) _then)
      : super(_value, _then);

  /// Create a copy of TodayDetections
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? normal = null,
    Object? soiling = null,
    Object? crack = null,
  }) {
    return _then(_$TodayDetectionsImpl(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      normal: null == normal
          ? _value.normal
          : normal // ignore: cast_nullable_to_non_nullable
              as int,
      soiling: null == soiling
          ? _value.soiling
          : soiling // ignore: cast_nullable_to_non_nullable
              as int,
      crack: null == crack
          ? _value.crack
          : crack // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TodayDetectionsImpl implements _TodayDetections {
  const _$TodayDetectionsImpl(
      {required this.total,
      required this.normal,
      required this.soiling,
      required this.crack});

  factory _$TodayDetectionsImpl.fromJson(Map<String, dynamic> json) =>
      _$$TodayDetectionsImplFromJson(json);

  @override
  final int total;
  @override
  final int normal;
  @override
  final int soiling;
  @override
  final int crack;

  @override
  String toString() {
    return 'TodayDetections(total: $total, normal: $normal, soiling: $soiling, crack: $crack)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TodayDetectionsImpl &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.normal, normal) || other.normal == normal) &&
            (identical(other.soiling, soiling) || other.soiling == soiling) &&
            (identical(other.crack, crack) || other.crack == crack));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, total, normal, soiling, crack);

  /// Create a copy of TodayDetections
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TodayDetectionsImplCopyWith<_$TodayDetectionsImpl> get copyWith =>
      __$$TodayDetectionsImplCopyWithImpl<_$TodayDetectionsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TodayDetectionsImplToJson(
      this,
    );
  }
}

abstract class _TodayDetections implements TodayDetections {
  const factory _TodayDetections(
      {required final int total,
      required final int normal,
      required final int soiling,
      required final int crack}) = _$TodayDetectionsImpl;

  factory _TodayDetections.fromJson(Map<String, dynamic> json) =
      _$TodayDetectionsImpl.fromJson;

  @override
  int get total;
  @override
  int get normal;
  @override
  int get soiling;
  @override
  int get crack;

  /// Create a copy of TodayDetections
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TodayDetectionsImplCopyWith<_$TodayDetectionsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecentAlert _$RecentAlertFromJson(Map<String, dynamic> json) {
  return _RecentAlert.fromJson(json);
}

/// @nodoc
mixin _$RecentAlert {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;

  /// Serializes this RecentAlert to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecentAlert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecentAlertCopyWith<RecentAlert> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecentAlertCopyWith<$Res> {
  factory $RecentAlertCopyWith(
          RecentAlert value, $Res Function(RecentAlert) then) =
      _$RecentAlertCopyWithImpl<$Res, RecentAlert>;
  @useResult
  $Res call(
      {String id,
      String title,
      String message,
      String type,
      DateTime createdAt,
      bool isRead});
}

/// @nodoc
class _$RecentAlertCopyWithImpl<$Res, $Val extends RecentAlert>
    implements $RecentAlertCopyWith<$Res> {
  _$RecentAlertCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecentAlert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? message = null,
    Object? type = null,
    Object? createdAt = null,
    Object? isRead = null,
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
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecentAlertImplCopyWith<$Res>
    implements $RecentAlertCopyWith<$Res> {
  factory _$$RecentAlertImplCopyWith(
          _$RecentAlertImpl value, $Res Function(_$RecentAlertImpl) then) =
      __$$RecentAlertImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String message,
      String type,
      DateTime createdAt,
      bool isRead});
}

/// @nodoc
class __$$RecentAlertImplCopyWithImpl<$Res>
    extends _$RecentAlertCopyWithImpl<$Res, _$RecentAlertImpl>
    implements _$$RecentAlertImplCopyWith<$Res> {
  __$$RecentAlertImplCopyWithImpl(
      _$RecentAlertImpl _value, $Res Function(_$RecentAlertImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecentAlert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? message = null,
    Object? type = null,
    Object? createdAt = null,
    Object? isRead = null,
  }) {
    return _then(_$RecentAlertImpl(
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
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecentAlertImpl implements _RecentAlert {
  const _$RecentAlertImpl(
      {required this.id,
      required this.title,
      required this.message,
      required this.type,
      required this.createdAt,
      required this.isRead});

  factory _$RecentAlertImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecentAlertImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String message;
  @override
  final String type;
  @override
  final DateTime createdAt;
  @override
  final bool isRead;

  @override
  String toString() {
    return 'RecentAlert(id: $id, title: $title, message: $message, type: $type, createdAt: $createdAt, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecentAlertImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isRead, isRead) || other.isRead == isRead));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, title, message, type, createdAt, isRead);

  /// Create a copy of RecentAlert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecentAlertImplCopyWith<_$RecentAlertImpl> get copyWith =>
      __$$RecentAlertImplCopyWithImpl<_$RecentAlertImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecentAlertImplToJson(
      this,
    );
  }
}

abstract class _RecentAlert implements RecentAlert {
  const factory _RecentAlert(
      {required final String id,
      required final String title,
      required final String message,
      required final String type,
      required final DateTime createdAt,
      required final bool isRead}) = _$RecentAlertImpl;

  factory _RecentAlert.fromJson(Map<String, dynamic> json) =
      _$RecentAlertImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get message;
  @override
  String get type;
  @override
  DateTime get createdAt;
  @override
  bool get isRead;

  /// Create a copy of RecentAlert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecentAlertImplCopyWith<_$RecentAlertImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
