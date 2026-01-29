// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'json_tree.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JsonTree _$JsonTreeFromJson(Map<String, dynamic> json) => JsonTree(
  item: json['item'] as Map<String, dynamic>,
  children:
      (json['children'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, JsonTree.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
);

Map<String, dynamic> _$JsonTreeToJson(JsonTree instance) => <String, dynamic>{
  'item': instance.item,
  'children': instance.children.map((k, e) => MapEntry(k, e.toJson())),
};
