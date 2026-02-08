// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReportImpl _$$ReportImplFromJson(Map<String, dynamic> json) => _$ReportImpl(
      id: json['id'] as String,
      type: $enumDecode(_$ReportTypeEnumMap, json['type']),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      summary: ReportSummary.fromJson(json['summary'] as Map<String, dynamic>),
      dailyStats: (json['dailyStats'] as List<dynamic>)
          .map((e) => DetectionStats.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ReportImplToJson(_$ReportImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$ReportTypeEnumMap[instance.type]!,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'summary': instance.summary,
      'dailyStats': instance.dailyStats,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$ReportTypeEnumMap = {
  ReportType.daily: 'daily',
  ReportType.weekly: 'weekly',
  ReportType.monthly: 'monthly',
};

_$ReportSummaryImpl _$$ReportSummaryImplFromJson(Map<String, dynamic> json) =>
    _$ReportSummaryImpl(
      totalDetections: (json['totalDetections'] as num).toInt(),
      normalCount: (json['normalCount'] as num).toInt(),
      soilingCount: (json['soilingCount'] as num).toInt(),
      crackCount: (json['crackCount'] as num).toInt(),
      averageEfficiency: (json['averageEfficiency'] as num).toDouble(),
      normalRate: (json['normalRate'] as num).toDouble(),
    );

Map<String, dynamic> _$$ReportSummaryImplToJson(_$ReportSummaryImpl instance) =>
    <String, dynamic>{
      'totalDetections': instance.totalDetections,
      'normalCount': instance.normalCount,
      'soilingCount': instance.soilingCount,
      'crackCount': instance.crackCount,
      'averageEfficiency': instance.averageEfficiency,
      'normalRate': instance.normalRate,
    };

_$DetectionStatsImpl _$$DetectionStatsImplFromJson(Map<String, dynamic> json) =>
    _$DetectionStatsImpl(
      date: DateTime.parse(json['date'] as String),
      normal: (json['normal'] as num).toInt(),
      soiling: (json['soiling'] as num).toInt(),
      crack: (json['crack'] as num).toInt(),
    );

Map<String, dynamic> _$$DetectionStatsImplToJson(
        _$DetectionStatsImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'normal': instance.normal,
      'soiling': instance.soiling,
      'crack': instance.crack,
    };

_$ReportItemImpl _$$ReportItemImplFromJson(Map<String, dynamic> json) =>
    _$ReportItemImpl(
      id: json['id'] as String,
      type: $enumDecode(_$ReportTypeEnumMap, json['type']),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalDetections: (json['totalDetections'] as num).toInt(),
      normalRate: (json['normalRate'] as num).toDouble(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ReportItemImplToJson(_$ReportItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$ReportTypeEnumMap[instance.type]!,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'totalDetections': instance.totalDetections,
      'normalRate': instance.normalRate,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$AISolutionImpl _$$AISolutionImplFromJson(Map<String, dynamic> json) =>
    _$AISolutionImpl(
      solutionType: json['solutionType'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      actionItems: (json['actionItems'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$AISolutionImplToJson(_$AISolutionImpl instance) =>
    <String, dynamic>{
      'solutionType': instance.solutionType,
      'title': instance.title,
      'content': instance.content,
      'actionItems': instance.actionItems,
    };

_$AIBriefingImpl _$$AIBriefingImplFromJson(Map<String, dynamic> json) =>
    _$AIBriefingImpl(
      id: (json['id'] as num).toInt(),
      reportDate: DateTime.parse(json['reportDate'] as String),
      totalDetections: (json['totalDetections'] as num).toInt(),
      totalDefects: (json['totalDefects'] as num).toInt(),
      totalSoiling: (json['totalSoiling'] as num).toInt(),
      aiSolution: json['aiSolution'] == null
          ? null
          : AISolution.fromJson(json['aiSolution'] as Map<String, dynamic>),
      anomalies: (json['anomalies'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      weatherForecast: json['weatherForecast'] as Map<String, dynamic>?,
      estimatedLossKrw: (json['estimatedLossKrw'] as num?)?.toDouble(),
      cleaningRecommended: json['cleaningRecommended'] as bool? ?? false,
      aiGeneratedAt: json['aiGeneratedAt'] == null
          ? null
          : DateTime.parse(json['aiGeneratedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$AIBriefingImplToJson(_$AIBriefingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reportDate': instance.reportDate.toIso8601String(),
      'totalDetections': instance.totalDetections,
      'totalDefects': instance.totalDefects,
      'totalSoiling': instance.totalSoiling,
      'aiSolution': instance.aiSolution,
      'anomalies': instance.anomalies,
      'weatherForecast': instance.weatherForecast,
      'estimatedLossKrw': instance.estimatedLossKrw,
      'cleaningRecommended': instance.cleaningRecommended,
      'aiGeneratedAt': instance.aiGeneratedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };
