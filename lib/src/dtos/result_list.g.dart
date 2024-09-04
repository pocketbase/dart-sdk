// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResultList<M> _$ResultListFromJson<M extends Jsonable>(
        Map<String, dynamic> json) =>
    ResultList<M>(
      page: (json['page'] as num?)?.toInt() ?? 0,
      perPage: (json['perPage'] as num?)?.toInt() ?? 0,
      totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ResultListToJson<M extends Jsonable>(
        ResultList<M> instance) =>
    <String, dynamic>{
      'page': instance.page,
      'perPage': instance.perPage,
      'totalItems': instance.totalItems,
      'totalPages': instance.totalPages,
    };
