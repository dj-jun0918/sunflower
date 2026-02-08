// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Report _$ReportFromJson(Map<String, dynamic> json) {
  return _Report.fromJson(json);
}

/// @nodoc
mixin _$Report {
  String get id => throw _privateConstructorUsedError;
  ReportType get type => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;
  ReportSummary get summary => throw _privateConstructorUsedError;
  List<DetectionStats> get dailyStats => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Report to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Report
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReportCopyWith<Report> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReportCopyWith<$Res> {
  factory $ReportCopyWith(Report value, $Res Function(Report) then) =
      _$ReportCopyWithImpl<$Res, Report>;
  @useResult
  $Res call(
      {String id,
      ReportType type,
      DateTime startDate,
      DateTime endDate,
      ReportSummary summary,
      List<DetectionStats> dailyStats,
      DateTime? createdAt});

  $ReportSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class _$ReportCopyWithImpl<$Res, $Val extends Report>
    implements $ReportCopyWith<$Res> {
  _$ReportCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Report
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? summary = null,
    Object? dailyStats = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ReportType,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as ReportSummary,
      dailyStats: null == dailyStats
          ? _value.dailyStats
          : dailyStats // ignore: cast_nullable_to_non_nullable
              as List<DetectionStats>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of Report
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReportSummaryCopyWith<$Res> get summary {
    return $ReportSummaryCopyWith<$Res>(_value.summary, (value) {
      return _then(_value.copyWith(summary: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ReportImplCopyWith<$Res> implements $ReportCopyWith<$Res> {
  factory _$$ReportImplCopyWith(
          _$ReportImpl value, $Res Function(_$ReportImpl) then) =
      __$$ReportImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      ReportType type,
      DateTime startDate,
      DateTime endDate,
      ReportSummary summary,
      List<DetectionStats> dailyStats,
      DateTime? createdAt});

  @override
  $ReportSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class __$$ReportImplCopyWithImpl<$Res>
    extends _$ReportCopyWithImpl<$Res, _$ReportImpl>
    implements _$$ReportImplCopyWith<$Res> {
  __$$ReportImplCopyWithImpl(
      _$ReportImpl _value, $Res Function(_$ReportImpl) _then)
      : super(_value, _then);

  /// Create a copy of Report
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? summary = null,
    Object? dailyStats = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$ReportImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ReportType,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as ReportSummary,
      dailyStats: null == dailyStats
          ? _value._dailyStats
          : dailyStats // ignore: cast_nullable_to_non_nullable
              as List<DetectionStats>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReportImpl implements _Report {
  const _$ReportImpl(
      {required this.id,
      required this.type,
      required this.startDate,
      required this.endDate,
      required this.summary,
      required final List<DetectionStats> dailyStats,
      this.createdAt})
      : _dailyStats = dailyStats;

  factory _$ReportImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReportImplFromJson(json);

  @override
  final String id;
  @override
  final ReportType type;
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  @override
  final ReportSummary summary;
  final List<DetectionStats> _dailyStats;
  @override
  List<DetectionStats> get dailyStats {
    if (_dailyStats is EqualUnmodifiableListView) return _dailyStats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dailyStats);
  }

  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Report(id: $id, type: $type, startDate: $startDate, endDate: $endDate, summary: $summary, dailyStats: $dailyStats, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReportImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            const DeepCollectionEquality()
                .equals(other._dailyStats, _dailyStats) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, type, startDate, endDate,
      summary, const DeepCollectionEquality().hash(_dailyStats), createdAt);

  /// Create a copy of Report
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReportImplCopyWith<_$ReportImpl> get copyWith =>
      __$$ReportImplCopyWithImpl<_$ReportImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReportImplToJson(
      this,
    );
  }
}

abstract class _Report implements Report {
  const factory _Report(
      {required final String id,
      required final ReportType type,
      required final DateTime startDate,
      required final DateTime endDate,
      required final ReportSummary summary,
      required final List<DetectionStats> dailyStats,
      final DateTime? createdAt}) = _$ReportImpl;

  factory _Report.fromJson(Map<String, dynamic> json) = _$ReportImpl.fromJson;

  @override
  String get id;
  @override
  ReportType get type;
  @override
  DateTime get startDate;
  @override
  DateTime get endDate;
  @override
  ReportSummary get summary;
  @override
  List<DetectionStats> get dailyStats;
  @override
  DateTime? get createdAt;

  /// Create a copy of Report
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReportImplCopyWith<_$ReportImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReportSummary _$ReportSummaryFromJson(Map<String, dynamic> json) {
  return _ReportSummary.fromJson(json);
}

/// @nodoc
mixin _$ReportSummary {
  int get totalDetections => throw _privateConstructorUsedError;
  int get normalCount => throw _privateConstructorUsedError;
  int get soilingCount => throw _privateConstructorUsedError;
  int get crackCount => throw _privateConstructorUsedError;
  double get averageEfficiency => throw _privateConstructorUsedError;
  double get normalRate => throw _privateConstructorUsedError;

  /// Serializes this ReportSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReportSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReportSummaryCopyWith<ReportSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReportSummaryCopyWith<$Res> {
  factory $ReportSummaryCopyWith(
          ReportSummary value, $Res Function(ReportSummary) then) =
      _$ReportSummaryCopyWithImpl<$Res, ReportSummary>;
  @useResult
  $Res call(
      {int totalDetections,
      int normalCount,
      int soilingCount,
      int crackCount,
      double averageEfficiency,
      double normalRate});
}

/// @nodoc
class _$ReportSummaryCopyWithImpl<$Res, $Val extends ReportSummary>
    implements $ReportSummaryCopyWith<$Res> {
  _$ReportSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReportSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalDetections = null,
    Object? normalCount = null,
    Object? soilingCount = null,
    Object? crackCount = null,
    Object? averageEfficiency = null,
    Object? normalRate = null,
  }) {
    return _then(_value.copyWith(
      totalDetections: null == totalDetections
          ? _value.totalDetections
          : totalDetections // ignore: cast_nullable_to_non_nullable
              as int,
      normalCount: null == normalCount
          ? _value.normalCount
          : normalCount // ignore: cast_nullable_to_non_nullable
              as int,
      soilingCount: null == soilingCount
          ? _value.soilingCount
          : soilingCount // ignore: cast_nullable_to_non_nullable
              as int,
      crackCount: null == crackCount
          ? _value.crackCount
          : crackCount // ignore: cast_nullable_to_non_nullable
              as int,
      averageEfficiency: null == averageEfficiency
          ? _value.averageEfficiency
          : averageEfficiency // ignore: cast_nullable_to_non_nullable
              as double,
      normalRate: null == normalRate
          ? _value.normalRate
          : normalRate // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReportSummaryImplCopyWith<$Res>
    implements $ReportSummaryCopyWith<$Res> {
  factory _$$ReportSummaryImplCopyWith(
          _$ReportSummaryImpl value, $Res Function(_$ReportSummaryImpl) then) =
      __$$ReportSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalDetections,
      int normalCount,
      int soilingCount,
      int crackCount,
      double averageEfficiency,
      double normalRate});
}

/// @nodoc
class __$$ReportSummaryImplCopyWithImpl<$Res>
    extends _$ReportSummaryCopyWithImpl<$Res, _$ReportSummaryImpl>
    implements _$$ReportSummaryImplCopyWith<$Res> {
  __$$ReportSummaryImplCopyWithImpl(
      _$ReportSummaryImpl _value, $Res Function(_$ReportSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReportSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalDetections = null,
    Object? normalCount = null,
    Object? soilingCount = null,
    Object? crackCount = null,
    Object? averageEfficiency = null,
    Object? normalRate = null,
  }) {
    return _then(_$ReportSummaryImpl(
      totalDetections: null == totalDetections
          ? _value.totalDetections
          : totalDetections // ignore: cast_nullable_to_non_nullable
              as int,
      normalCount: null == normalCount
          ? _value.normalCount
          : normalCount // ignore: cast_nullable_to_non_nullable
              as int,
      soilingCount: null == soilingCount
          ? _value.soilingCount
          : soilingCount // ignore: cast_nullable_to_non_nullable
              as int,
      crackCount: null == crackCount
          ? _value.crackCount
          : crackCount // ignore: cast_nullable_to_non_nullable
              as int,
      averageEfficiency: null == averageEfficiency
          ? _value.averageEfficiency
          : averageEfficiency // ignore: cast_nullable_to_non_nullable
              as double,
      normalRate: null == normalRate
          ? _value.normalRate
          : normalRate // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReportSummaryImpl implements _ReportSummary {
  const _$ReportSummaryImpl(
      {required this.totalDetections,
      required this.normalCount,
      required this.soilingCount,
      required this.crackCount,
      required this.averageEfficiency,
      required this.normalRate});

  factory _$ReportSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReportSummaryImplFromJson(json);

  @override
  final int totalDetections;
  @override
  final int normalCount;
  @override
  final int soilingCount;
  @override
  final int crackCount;
  @override
  final double averageEfficiency;
  @override
  final double normalRate;

  @override
  String toString() {
    return 'ReportSummary(totalDetections: $totalDetections, normalCount: $normalCount, soilingCount: $soilingCount, crackCount: $crackCount, averageEfficiency: $averageEfficiency, normalRate: $normalRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReportSummaryImpl &&
            (identical(other.totalDetections, totalDetections) ||
                other.totalDetections == totalDetections) &&
            (identical(other.normalCount, normalCount) ||
                other.normalCount == normalCount) &&
            (identical(other.soilingCount, soilingCount) ||
                other.soilingCount == soilingCount) &&
            (identical(other.crackCount, crackCount) ||
                other.crackCount == crackCount) &&
            (identical(other.averageEfficiency, averageEfficiency) ||
                other.averageEfficiency == averageEfficiency) &&
            (identical(other.normalRate, normalRate) ||
                other.normalRate == normalRate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, totalDetections, normalCount,
      soilingCount, crackCount, averageEfficiency, normalRate);

  /// Create a copy of ReportSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReportSummaryImplCopyWith<_$ReportSummaryImpl> get copyWith =>
      __$$ReportSummaryImplCopyWithImpl<_$ReportSummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReportSummaryImplToJson(
      this,
    );
  }
}

abstract class _ReportSummary implements ReportSummary {
  const factory _ReportSummary(
      {required final int totalDetections,
      required final int normalCount,
      required final int soilingCount,
      required final int crackCount,
      required final double averageEfficiency,
      required final double normalRate}) = _$ReportSummaryImpl;

  factory _ReportSummary.fromJson(Map<String, dynamic> json) =
      _$ReportSummaryImpl.fromJson;

  @override
  int get totalDetections;
  @override
  int get normalCount;
  @override
  int get soilingCount;
  @override
  int get crackCount;
  @override
  double get averageEfficiency;
  @override
  double get normalRate;

  /// Create a copy of ReportSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReportSummaryImplCopyWith<_$ReportSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DetectionStats _$DetectionStatsFromJson(Map<String, dynamic> json) {
  return _DetectionStats.fromJson(json);
}

/// @nodoc
mixin _$DetectionStats {
  DateTime get date => throw _privateConstructorUsedError;
  int get normal => throw _privateConstructorUsedError;
  int get soiling => throw _privateConstructorUsedError;
  int get crack => throw _privateConstructorUsedError;

  /// Serializes this DetectionStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DetectionStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DetectionStatsCopyWith<DetectionStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DetectionStatsCopyWith<$Res> {
  factory $DetectionStatsCopyWith(
          DetectionStats value, $Res Function(DetectionStats) then) =
      _$DetectionStatsCopyWithImpl<$Res, DetectionStats>;
  @useResult
  $Res call({DateTime date, int normal, int soiling, int crack});
}

/// @nodoc
class _$DetectionStatsCopyWithImpl<$Res, $Val extends DetectionStats>
    implements $DetectionStatsCopyWith<$Res> {
  _$DetectionStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DetectionStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? normal = null,
    Object? soiling = null,
    Object? crack = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
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
abstract class _$$DetectionStatsImplCopyWith<$Res>
    implements $DetectionStatsCopyWith<$Res> {
  factory _$$DetectionStatsImplCopyWith(_$DetectionStatsImpl value,
          $Res Function(_$DetectionStatsImpl) then) =
      __$$DetectionStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime date, int normal, int soiling, int crack});
}

/// @nodoc
class __$$DetectionStatsImplCopyWithImpl<$Res>
    extends _$DetectionStatsCopyWithImpl<$Res, _$DetectionStatsImpl>
    implements _$$DetectionStatsImplCopyWith<$Res> {
  __$$DetectionStatsImplCopyWithImpl(
      _$DetectionStatsImpl _value, $Res Function(_$DetectionStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of DetectionStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? normal = null,
    Object? soiling = null,
    Object? crack = null,
  }) {
    return _then(_$DetectionStatsImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
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
class _$DetectionStatsImpl implements _DetectionStats {
  const _$DetectionStatsImpl(
      {required this.date,
      required this.normal,
      required this.soiling,
      required this.crack});

  factory _$DetectionStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DetectionStatsImplFromJson(json);

  @override
  final DateTime date;
  @override
  final int normal;
  @override
  final int soiling;
  @override
  final int crack;

  @override
  String toString() {
    return 'DetectionStats(date: $date, normal: $normal, soiling: $soiling, crack: $crack)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DetectionStatsImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.normal, normal) || other.normal == normal) &&
            (identical(other.soiling, soiling) || other.soiling == soiling) &&
            (identical(other.crack, crack) || other.crack == crack));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, normal, soiling, crack);

  /// Create a copy of DetectionStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DetectionStatsImplCopyWith<_$DetectionStatsImpl> get copyWith =>
      __$$DetectionStatsImplCopyWithImpl<_$DetectionStatsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DetectionStatsImplToJson(
      this,
    );
  }
}

abstract class _DetectionStats implements DetectionStats {
  const factory _DetectionStats(
      {required final DateTime date,
      required final int normal,
      required final int soiling,
      required final int crack}) = _$DetectionStatsImpl;

  factory _DetectionStats.fromJson(Map<String, dynamic> json) =
      _$DetectionStatsImpl.fromJson;

  @override
  DateTime get date;
  @override
  int get normal;
  @override
  int get soiling;
  @override
  int get crack;

  /// Create a copy of DetectionStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DetectionStatsImplCopyWith<_$DetectionStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReportItem _$ReportItemFromJson(Map<String, dynamic> json) {
  return _ReportItem.fromJson(json);
}

/// @nodoc
mixin _$ReportItem {
  String get id => throw _privateConstructorUsedError;
  ReportType get type => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;
  int get totalDetections => throw _privateConstructorUsedError;
  double get normalRate => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ReportItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReportItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReportItemCopyWith<ReportItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReportItemCopyWith<$Res> {
  factory $ReportItemCopyWith(
          ReportItem value, $Res Function(ReportItem) then) =
      _$ReportItemCopyWithImpl<$Res, ReportItem>;
  @useResult
  $Res call(
      {String id,
      ReportType type,
      DateTime startDate,
      DateTime endDate,
      int totalDetections,
      double normalRate,
      DateTime? createdAt});
}

/// @nodoc
class _$ReportItemCopyWithImpl<$Res, $Val extends ReportItem>
    implements $ReportItemCopyWith<$Res> {
  _$ReportItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReportItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? totalDetections = null,
    Object? normalRate = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ReportType,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalDetections: null == totalDetections
          ? _value.totalDetections
          : totalDetections // ignore: cast_nullable_to_non_nullable
              as int,
      normalRate: null == normalRate
          ? _value.normalRate
          : normalRate // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReportItemImplCopyWith<$Res>
    implements $ReportItemCopyWith<$Res> {
  factory _$$ReportItemImplCopyWith(
          _$ReportItemImpl value, $Res Function(_$ReportItemImpl) then) =
      __$$ReportItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      ReportType type,
      DateTime startDate,
      DateTime endDate,
      int totalDetections,
      double normalRate,
      DateTime? createdAt});
}

/// @nodoc
class __$$ReportItemImplCopyWithImpl<$Res>
    extends _$ReportItemCopyWithImpl<$Res, _$ReportItemImpl>
    implements _$$ReportItemImplCopyWith<$Res> {
  __$$ReportItemImplCopyWithImpl(
      _$ReportItemImpl _value, $Res Function(_$ReportItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReportItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? totalDetections = null,
    Object? normalRate = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$ReportItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ReportType,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalDetections: null == totalDetections
          ? _value.totalDetections
          : totalDetections // ignore: cast_nullable_to_non_nullable
              as int,
      normalRate: null == normalRate
          ? _value.normalRate
          : normalRate // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReportItemImpl implements _ReportItem {
  const _$ReportItemImpl(
      {required this.id,
      required this.type,
      required this.startDate,
      required this.endDate,
      required this.totalDetections,
      required this.normalRate,
      this.createdAt});

  factory _$ReportItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReportItemImplFromJson(json);

  @override
  final String id;
  @override
  final ReportType type;
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  @override
  final int totalDetections;
  @override
  final double normalRate;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'ReportItem(id: $id, type: $type, startDate: $startDate, endDate: $endDate, totalDetections: $totalDetections, normalRate: $normalRate, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReportItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.totalDetections, totalDetections) ||
                other.totalDetections == totalDetections) &&
            (identical(other.normalRate, normalRate) ||
                other.normalRate == normalRate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, type, startDate, endDate,
      totalDetections, normalRate, createdAt);

  /// Create a copy of ReportItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReportItemImplCopyWith<_$ReportItemImpl> get copyWith =>
      __$$ReportItemImplCopyWithImpl<_$ReportItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReportItemImplToJson(
      this,
    );
  }
}

abstract class _ReportItem implements ReportItem {
  const factory _ReportItem(
      {required final String id,
      required final ReportType type,
      required final DateTime startDate,
      required final DateTime endDate,
      required final int totalDetections,
      required final double normalRate,
      final DateTime? createdAt}) = _$ReportItemImpl;

  factory _ReportItem.fromJson(Map<String, dynamic> json) =
      _$ReportItemImpl.fromJson;

  @override
  String get id;
  @override
  ReportType get type;
  @override
  DateTime get startDate;
  @override
  DateTime get endDate;
  @override
  int get totalDetections;
  @override
  double get normalRate;
  @override
  DateTime? get createdAt;

  /// Create a copy of ReportItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReportItemImplCopyWith<_$ReportItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AISolution _$AISolutionFromJson(Map<String, dynamic> json) {
  return _AISolution.fromJson(json);
}

/// @nodoc
mixin _$AISolution {
  @JsonKey(name: 'solutionType')
  String get solutionType => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  @JsonKey(name: 'actionItems')
  List<String> get actionItems => throw _privateConstructorUsedError;

  /// Serializes this AISolution to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AISolution
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AISolutionCopyWith<AISolution> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AISolutionCopyWith<$Res> {
  factory $AISolutionCopyWith(
          AISolution value, $Res Function(AISolution) then) =
      _$AISolutionCopyWithImpl<$Res, AISolution>;
  @useResult
  $Res call(
      {@JsonKey(name: 'solutionType') String solutionType,
      String title,
      String content,
      @JsonKey(name: 'actionItems') List<String> actionItems});
}

/// @nodoc
class _$AISolutionCopyWithImpl<$Res, $Val extends AISolution>
    implements $AISolutionCopyWith<$Res> {
  _$AISolutionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AISolution
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? solutionType = null,
    Object? title = null,
    Object? content = null,
    Object? actionItems = null,
  }) {
    return _then(_value.copyWith(
      solutionType: null == solutionType
          ? _value.solutionType
          : solutionType // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      actionItems: null == actionItems
          ? _value.actionItems
          : actionItems // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AISolutionImplCopyWith<$Res>
    implements $AISolutionCopyWith<$Res> {
  factory _$$AISolutionImplCopyWith(
          _$AISolutionImpl value, $Res Function(_$AISolutionImpl) then) =
      __$$AISolutionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'solutionType') String solutionType,
      String title,
      String content,
      @JsonKey(name: 'actionItems') List<String> actionItems});
}

/// @nodoc
class __$$AISolutionImplCopyWithImpl<$Res>
    extends _$AISolutionCopyWithImpl<$Res, _$AISolutionImpl>
    implements _$$AISolutionImplCopyWith<$Res> {
  __$$AISolutionImplCopyWithImpl(
      _$AISolutionImpl _value, $Res Function(_$AISolutionImpl) _then)
      : super(_value, _then);

  /// Create a copy of AISolution
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? solutionType = null,
    Object? title = null,
    Object? content = null,
    Object? actionItems = null,
  }) {
    return _then(_$AISolutionImpl(
      solutionType: null == solutionType
          ? _value.solutionType
          : solutionType // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      actionItems: null == actionItems
          ? _value._actionItems
          : actionItems // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AISolutionImpl implements _AISolution {
  const _$AISolutionImpl(
      {@JsonKey(name: 'solutionType') required this.solutionType,
      required this.title,
      required this.content,
      @JsonKey(name: 'actionItems') final List<String> actionItems = const []})
      : _actionItems = actionItems;

  factory _$AISolutionImpl.fromJson(Map<String, dynamic> json) =>
      _$$AISolutionImplFromJson(json);

  @override
  @JsonKey(name: 'solutionType')
  final String solutionType;
  @override
  final String title;
  @override
  final String content;
  final List<String> _actionItems;
  @override
  @JsonKey(name: 'actionItems')
  List<String> get actionItems {
    if (_actionItems is EqualUnmodifiableListView) return _actionItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_actionItems);
  }

  @override
  String toString() {
    return 'AISolution(solutionType: $solutionType, title: $title, content: $content, actionItems: $actionItems)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AISolutionImpl &&
            (identical(other.solutionType, solutionType) ||
                other.solutionType == solutionType) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality()
                .equals(other._actionItems, _actionItems));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, solutionType, title, content,
      const DeepCollectionEquality().hash(_actionItems));

  /// Create a copy of AISolution
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AISolutionImplCopyWith<_$AISolutionImpl> get copyWith =>
      __$$AISolutionImplCopyWithImpl<_$AISolutionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AISolutionImplToJson(
      this,
    );
  }
}

abstract class _AISolution implements AISolution {
  const factory _AISolution(
          {@JsonKey(name: 'solutionType') required final String solutionType,
          required final String title,
          required final String content,
          @JsonKey(name: 'actionItems') final List<String> actionItems}) =
      _$AISolutionImpl;

  factory _AISolution.fromJson(Map<String, dynamic> json) =
      _$AISolutionImpl.fromJson;

  @override
  @JsonKey(name: 'solutionType')
  String get solutionType;
  @override
  String get title;
  @override
  String get content;
  @override
  @JsonKey(name: 'actionItems')
  List<String> get actionItems;

  /// Create a copy of AISolution
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AISolutionImplCopyWith<_$AISolutionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AIBriefing _$AIBriefingFromJson(Map<String, dynamic> json) {
  return _AIBriefing.fromJson(json);
}

/// @nodoc
mixin _$AIBriefing {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'reportDate')
  DateTime get reportDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'totalDetections')
  int get totalDetections => throw _privateConstructorUsedError;
  @JsonKey(name: 'totalDefects')
  int get totalDefects => throw _privateConstructorUsedError;
  @JsonKey(name: 'totalSoiling')
  int get totalSoiling => throw _privateConstructorUsedError;
  @JsonKey(name: 'aiSolution')
  AISolution? get aiSolution => throw _privateConstructorUsedError;
  List<String> get anomalies => throw _privateConstructorUsedError;
  @JsonKey(name: 'weatherForecast')
  Map<String, dynamic>? get weatherForecast =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'estimatedLossKrw')
  double? get estimatedLossKrw => throw _privateConstructorUsedError;
  @JsonKey(name: 'cleaningRecommended')
  bool get cleaningRecommended => throw _privateConstructorUsedError;
  @JsonKey(name: 'aiGeneratedAt')
  DateTime? get aiGeneratedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'createdAt')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this AIBriefing to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AIBriefing
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AIBriefingCopyWith<AIBriefing> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AIBriefingCopyWith<$Res> {
  factory $AIBriefingCopyWith(
          AIBriefing value, $Res Function(AIBriefing) then) =
      _$AIBriefingCopyWithImpl<$Res, AIBriefing>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'reportDate') DateTime reportDate,
      @JsonKey(name: 'totalDetections') int totalDetections,
      @JsonKey(name: 'totalDefects') int totalDefects,
      @JsonKey(name: 'totalSoiling') int totalSoiling,
      @JsonKey(name: 'aiSolution') AISolution? aiSolution,
      List<String> anomalies,
      @JsonKey(name: 'weatherForecast') Map<String, dynamic>? weatherForecast,
      @JsonKey(name: 'estimatedLossKrw') double? estimatedLossKrw,
      @JsonKey(name: 'cleaningRecommended') bool cleaningRecommended,
      @JsonKey(name: 'aiGeneratedAt') DateTime? aiGeneratedAt,
      @JsonKey(name: 'createdAt') DateTime createdAt});

  $AISolutionCopyWith<$Res>? get aiSolution;
}

/// @nodoc
class _$AIBriefingCopyWithImpl<$Res, $Val extends AIBriefing>
    implements $AIBriefingCopyWith<$Res> {
  _$AIBriefingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AIBriefing
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reportDate = null,
    Object? totalDetections = null,
    Object? totalDefects = null,
    Object? totalSoiling = null,
    Object? aiSolution = freezed,
    Object? anomalies = null,
    Object? weatherForecast = freezed,
    Object? estimatedLossKrw = freezed,
    Object? cleaningRecommended = null,
    Object? aiGeneratedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      reportDate: null == reportDate
          ? _value.reportDate
          : reportDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalDetections: null == totalDetections
          ? _value.totalDetections
          : totalDetections // ignore: cast_nullable_to_non_nullable
              as int,
      totalDefects: null == totalDefects
          ? _value.totalDefects
          : totalDefects // ignore: cast_nullable_to_non_nullable
              as int,
      totalSoiling: null == totalSoiling
          ? _value.totalSoiling
          : totalSoiling // ignore: cast_nullable_to_non_nullable
              as int,
      aiSolution: freezed == aiSolution
          ? _value.aiSolution
          : aiSolution // ignore: cast_nullable_to_non_nullable
              as AISolution?,
      anomalies: null == anomalies
          ? _value.anomalies
          : anomalies // ignore: cast_nullable_to_non_nullable
              as List<String>,
      weatherForecast: freezed == weatherForecast
          ? _value.weatherForecast
          : weatherForecast // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      estimatedLossKrw: freezed == estimatedLossKrw
          ? _value.estimatedLossKrw
          : estimatedLossKrw // ignore: cast_nullable_to_non_nullable
              as double?,
      cleaningRecommended: null == cleaningRecommended
          ? _value.cleaningRecommended
          : cleaningRecommended // ignore: cast_nullable_to_non_nullable
              as bool,
      aiGeneratedAt: freezed == aiGeneratedAt
          ? _value.aiGeneratedAt
          : aiGeneratedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  /// Create a copy of AIBriefing
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AISolutionCopyWith<$Res>? get aiSolution {
    if (_value.aiSolution == null) {
      return null;
    }

    return $AISolutionCopyWith<$Res>(_value.aiSolution!, (value) {
      return _then(_value.copyWith(aiSolution: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AIBriefingImplCopyWith<$Res>
    implements $AIBriefingCopyWith<$Res> {
  factory _$$AIBriefingImplCopyWith(
          _$AIBriefingImpl value, $Res Function(_$AIBriefingImpl) then) =
      __$$AIBriefingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'reportDate') DateTime reportDate,
      @JsonKey(name: 'totalDetections') int totalDetections,
      @JsonKey(name: 'totalDefects') int totalDefects,
      @JsonKey(name: 'totalSoiling') int totalSoiling,
      @JsonKey(name: 'aiSolution') AISolution? aiSolution,
      List<String> anomalies,
      @JsonKey(name: 'weatherForecast') Map<String, dynamic>? weatherForecast,
      @JsonKey(name: 'estimatedLossKrw') double? estimatedLossKrw,
      @JsonKey(name: 'cleaningRecommended') bool cleaningRecommended,
      @JsonKey(name: 'aiGeneratedAt') DateTime? aiGeneratedAt,
      @JsonKey(name: 'createdAt') DateTime createdAt});

  @override
  $AISolutionCopyWith<$Res>? get aiSolution;
}

/// @nodoc
class __$$AIBriefingImplCopyWithImpl<$Res>
    extends _$AIBriefingCopyWithImpl<$Res, _$AIBriefingImpl>
    implements _$$AIBriefingImplCopyWith<$Res> {
  __$$AIBriefingImplCopyWithImpl(
      _$AIBriefingImpl _value, $Res Function(_$AIBriefingImpl) _then)
      : super(_value, _then);

  /// Create a copy of AIBriefing
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reportDate = null,
    Object? totalDetections = null,
    Object? totalDefects = null,
    Object? totalSoiling = null,
    Object? aiSolution = freezed,
    Object? anomalies = null,
    Object? weatherForecast = freezed,
    Object? estimatedLossKrw = freezed,
    Object? cleaningRecommended = null,
    Object? aiGeneratedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$AIBriefingImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      reportDate: null == reportDate
          ? _value.reportDate
          : reportDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalDetections: null == totalDetections
          ? _value.totalDetections
          : totalDetections // ignore: cast_nullable_to_non_nullable
              as int,
      totalDefects: null == totalDefects
          ? _value.totalDefects
          : totalDefects // ignore: cast_nullable_to_non_nullable
              as int,
      totalSoiling: null == totalSoiling
          ? _value.totalSoiling
          : totalSoiling // ignore: cast_nullable_to_non_nullable
              as int,
      aiSolution: freezed == aiSolution
          ? _value.aiSolution
          : aiSolution // ignore: cast_nullable_to_non_nullable
              as AISolution?,
      anomalies: null == anomalies
          ? _value._anomalies
          : anomalies // ignore: cast_nullable_to_non_nullable
              as List<String>,
      weatherForecast: freezed == weatherForecast
          ? _value._weatherForecast
          : weatherForecast // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      estimatedLossKrw: freezed == estimatedLossKrw
          ? _value.estimatedLossKrw
          : estimatedLossKrw // ignore: cast_nullable_to_non_nullable
              as double?,
      cleaningRecommended: null == cleaningRecommended
          ? _value.cleaningRecommended
          : cleaningRecommended // ignore: cast_nullable_to_non_nullable
              as bool,
      aiGeneratedAt: freezed == aiGeneratedAt
          ? _value.aiGeneratedAt
          : aiGeneratedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AIBriefingImpl implements _AIBriefing {
  const _$AIBriefingImpl(
      {required this.id,
      @JsonKey(name: 'reportDate') required this.reportDate,
      @JsonKey(name: 'totalDetections') required this.totalDetections,
      @JsonKey(name: 'totalDefects') required this.totalDefects,
      @JsonKey(name: 'totalSoiling') required this.totalSoiling,
      @JsonKey(name: 'aiSolution') this.aiSolution,
      final List<String> anomalies = const [],
      @JsonKey(name: 'weatherForecast')
      final Map<String, dynamic>? weatherForecast,
      @JsonKey(name: 'estimatedLossKrw') this.estimatedLossKrw,
      @JsonKey(name: 'cleaningRecommended') this.cleaningRecommended = false,
      @JsonKey(name: 'aiGeneratedAt') this.aiGeneratedAt,
      @JsonKey(name: 'createdAt') required this.createdAt})
      : _anomalies = anomalies,
        _weatherForecast = weatherForecast;

  factory _$AIBriefingImpl.fromJson(Map<String, dynamic> json) =>
      _$$AIBriefingImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'reportDate')
  final DateTime reportDate;
  @override
  @JsonKey(name: 'totalDetections')
  final int totalDetections;
  @override
  @JsonKey(name: 'totalDefects')
  final int totalDefects;
  @override
  @JsonKey(name: 'totalSoiling')
  final int totalSoiling;
  @override
  @JsonKey(name: 'aiSolution')
  final AISolution? aiSolution;
  final List<String> _anomalies;
  @override
  @JsonKey()
  List<String> get anomalies {
    if (_anomalies is EqualUnmodifiableListView) return _anomalies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_anomalies);
  }

  final Map<String, dynamic>? _weatherForecast;
  @override
  @JsonKey(name: 'weatherForecast')
  Map<String, dynamic>? get weatherForecast {
    final value = _weatherForecast;
    if (value == null) return null;
    if (_weatherForecast is EqualUnmodifiableMapView) return _weatherForecast;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'estimatedLossKrw')
  final double? estimatedLossKrw;
  @override
  @JsonKey(name: 'cleaningRecommended')
  final bool cleaningRecommended;
  @override
  @JsonKey(name: 'aiGeneratedAt')
  final DateTime? aiGeneratedAt;
  @override
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;

  @override
  String toString() {
    return 'AIBriefing(id: $id, reportDate: $reportDate, totalDetections: $totalDetections, totalDefects: $totalDefects, totalSoiling: $totalSoiling, aiSolution: $aiSolution, anomalies: $anomalies, weatherForecast: $weatherForecast, estimatedLossKrw: $estimatedLossKrw, cleaningRecommended: $cleaningRecommended, aiGeneratedAt: $aiGeneratedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AIBriefingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.reportDate, reportDate) ||
                other.reportDate == reportDate) &&
            (identical(other.totalDetections, totalDetections) ||
                other.totalDetections == totalDetections) &&
            (identical(other.totalDefects, totalDefects) ||
                other.totalDefects == totalDefects) &&
            (identical(other.totalSoiling, totalSoiling) ||
                other.totalSoiling == totalSoiling) &&
            (identical(other.aiSolution, aiSolution) ||
                other.aiSolution == aiSolution) &&
            const DeepCollectionEquality()
                .equals(other._anomalies, _anomalies) &&
            const DeepCollectionEquality()
                .equals(other._weatherForecast, _weatherForecast) &&
            (identical(other.estimatedLossKrw, estimatedLossKrw) ||
                other.estimatedLossKrw == estimatedLossKrw) &&
            (identical(other.cleaningRecommended, cleaningRecommended) ||
                other.cleaningRecommended == cleaningRecommended) &&
            (identical(other.aiGeneratedAt, aiGeneratedAt) ||
                other.aiGeneratedAt == aiGeneratedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      reportDate,
      totalDetections,
      totalDefects,
      totalSoiling,
      aiSolution,
      const DeepCollectionEquality().hash(_anomalies),
      const DeepCollectionEquality().hash(_weatherForecast),
      estimatedLossKrw,
      cleaningRecommended,
      aiGeneratedAt,
      createdAt);

  /// Create a copy of AIBriefing
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AIBriefingImplCopyWith<_$AIBriefingImpl> get copyWith =>
      __$$AIBriefingImplCopyWithImpl<_$AIBriefingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AIBriefingImplToJson(
      this,
    );
  }
}

abstract class _AIBriefing implements AIBriefing {
  const factory _AIBriefing(
          {required final int id,
          @JsonKey(name: 'reportDate') required final DateTime reportDate,
          @JsonKey(name: 'totalDetections') required final int totalDetections,
          @JsonKey(name: 'totalDefects') required final int totalDefects,
          @JsonKey(name: 'totalSoiling') required final int totalSoiling,
          @JsonKey(name: 'aiSolution') final AISolution? aiSolution,
          final List<String> anomalies,
          @JsonKey(name: 'weatherForecast')
          final Map<String, dynamic>? weatherForecast,
          @JsonKey(name: 'estimatedLossKrw') final double? estimatedLossKrw,
          @JsonKey(name: 'cleaningRecommended') final bool cleaningRecommended,
          @JsonKey(name: 'aiGeneratedAt') final DateTime? aiGeneratedAt,
          @JsonKey(name: 'createdAt') required final DateTime createdAt}) =
      _$AIBriefingImpl;

  factory _AIBriefing.fromJson(Map<String, dynamic> json) =
      _$AIBriefingImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'reportDate')
  DateTime get reportDate;
  @override
  @JsonKey(name: 'totalDetections')
  int get totalDetections;
  @override
  @JsonKey(name: 'totalDefects')
  int get totalDefects;
  @override
  @JsonKey(name: 'totalSoiling')
  int get totalSoiling;
  @override
  @JsonKey(name: 'aiSolution')
  AISolution? get aiSolution;
  @override
  List<String> get anomalies;
  @override
  @JsonKey(name: 'weatherForecast')
  Map<String, dynamic>? get weatherForecast;
  @override
  @JsonKey(name: 'estimatedLossKrw')
  double? get estimatedLossKrw;
  @override
  @JsonKey(name: 'cleaningRecommended')
  bool get cleaningRecommended;
  @override
  @JsonKey(name: 'aiGeneratedAt')
  DateTime? get aiGeneratedAt;
  @override
  @JsonKey(name: 'createdAt')
  DateTime get createdAt;

  /// Create a copy of AIBriefing
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AIBriefingImplCopyWith<_$AIBriefingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
